use std::{io::Cursor, sync::RwLock};

use anyhow::Ok;
use candle_core::{DType, Device, Tensor};
use image::DynamicImage;
use imageproc::definitions::Image;
use infer::{report_detect, report_pose, report_pose_with_points};
use model::{YoloV8, YoloV8Pose};
use once_cell::sync::Lazy;
use utils::check_posture;

pub mod infer;
pub mod model;
pub mod utils;

pub static MODELS: Lazy<RwLock<Models>> = Lazy::new(|| RwLock::new(Models::default()));

pub fn init_models(model_path: String) -> anyhow::Result<()> {
    let mut models = MODELS.write().unwrap();
    {
        // let mut model = Box::new(Model::<YoloV8>::new(model_path.clone()));
        // model.load()?;
        // models.yolov8 = Some(model);
        let mut model_pose = Box::new(Model::<YoloV8Pose>::new(model_path.clone()));
        model_pose.load()?;
        models.yolov8_pose = Some(model_pose);
    }
    Ok(())
}

pub fn infer(img_bytes: Vec<u8>) -> anyhow::Result<(Vec<u8>, String)> {
    let models = MODELS.read().unwrap();
    models.pose_run(img_bytes)
}

pub struct Models {
    pub yolov8: Option<Box<dyn ModelRun<Vec<u8>> + Send + Sync>>,
    pub yolov8_pose: Option<Box<dyn ModelRun<Vec<u8>> + Send + Sync>>,
}

impl Models {
    pub fn default() -> Self {
        Self {
            yolov8: None,
            yolov8_pose: None,
        }
    }

    #[deprecated(note = "unused for pose detection")]
    pub fn run(&self, image_bytes: Vec<u8>) -> anyhow::Result<Vec<u8>> {
        let device = Device::cuda_if_available(0)?;
        let origin_image = ImageProcessor::from_bytes(image_bytes, &device)?;

        if let Some(model) = &self.yolov8 {
            let pred = model.run(origin_image.0.clone())?;

            if let Some(model_pose) = &self.yolov8_pose {
                let pred_pose = model_pose.run(origin_image.0)?;

                let img = report_detect(
                    &pred,
                    origin_image.1,
                    origin_image.2,
                    origin_image.3,
                    0.1,
                    0.45,
                    2,
                )?;
                let img = report_pose(&pred_pose, img, origin_image.2, origin_image.3, 0.1, 0.45)?;

                return Ok(img.into_bytes());
            } else {
                anyhow::bail!("pose model not found")
            }
        } else {
            anyhow::bail!("detect model not found")
        }
    }

    pub fn pose_run(&self, image_bytes: Vec<u8>) -> anyhow::Result<(Vec<u8>, String)> {
        let device = Device::cuda_if_available(0)?;
        let origin_image = ImageProcessor::from_bytes(image_bytes, &device)?;

        if let Some(model_pose) = &self.yolov8_pose {
            let pred_pose = model_pose.run(origin_image.0)?;
            let (img, points) = report_pose_with_points(
                &pred_pose,
                origin_image.1,
                origin_image.2,
                origin_image.3,
                0.1,
                0.45,
            )?;

            let c = check_posture(&points);

            let mut bytes: Vec<u8> = Vec::new();
            // img.save("result.jpg")?;
            img.write_to(&mut Cursor::new(&mut bytes), image::ImageFormat::Png)?;

            return Ok((bytes, c));
        } else {
            anyhow::bail!("detect model not found")
        }
    }
}

pub struct ImageProcessor;

impl ImageProcessor {
    pub fn from_bytes(
        image_bytes: Vec<u8>,
        device: &Device,
    ) -> anyhow::Result<(Tensor, DynamicImage, usize, usize)> {
        let original_image = image::ImageReader::new(Cursor::new(image_bytes))
            .with_guessed_format()?
            .decode()?;

        let (width, height) = {
            let w = original_image.width() as usize;
            let h = original_image.height() as usize;
            if w < h {
                let w = w * 640 / h;
                // Sizes have to be divisible by 32.
                (w / 32 * 32, 640)
            } else {
                let h = h * 640 / w;
                (640, h / 32 * 32)
            }
        };

        let image_t = {
            let img = original_image.resize_exact(
                width as u32,
                height as u32,
                image::imageops::FilterType::CatmullRom,
            );
            let data = img.to_rgb8().into_raw();
            Tensor::from_vec(
                data,
                (img.height() as usize, img.width() as usize, 3),
                &device,
            )?
            .permute((2, 0, 1))?
        };
        let image_t = (image_t.unsqueeze(0)?.to_dtype(DType::F32)? * (1. / 255.))?;

        Ok((image_t, original_image, width, height))
    }

    pub fn from_file(
        path: &str,
        device: &Device,
    ) -> anyhow::Result<(Tensor, DynamicImage, usize, usize)> {
        let image_bytes = std::fs::read(path)?;
        Self::from_bytes(image_bytes, device)
    }
}

pub struct Model<T> {
    pub inner: Option<T>,
    pub model_path: String,
    pub device: Device,
}

pub trait ModelRun<S> {
    fn load(&mut self) -> anyhow::Result<()>;

    fn run(&self, image: Tensor) -> anyhow::Result<Tensor>;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_yolov8() -> anyhow::Result<()> {
        // let img_path = r"D:\github_repo\physical_exercise_timer\save_my_back\rust\bike.jpg";
        let img_path = r"C:\Users\xiaoshuyui\Desktop\test.png";
        let img_bytes = std::fs::read(img_path)?;
        let model_path = r"D:\github_repo\ai_tools\rust\assets\yolov8s-pose.safetensors";
        init_models(model_path.to_owned())?;

        let b = infer(img_bytes)?;
        std::fs::write("bike_result.jpg", b.0)?;
        println!("{}", b.1);
        anyhow::Ok(())
    }
}
