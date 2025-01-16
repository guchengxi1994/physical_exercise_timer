// modified from candle offcial examples

use std::cmp::Ordering;

use candle_core::{DType, Device, IndexOp, Result, Tensor};
use candle_nn::{Module, VarBuilder};
use candle_transformers::object_detection::{non_maximum_suppression, Bbox, KeyPoint};
use image::DynamicImage;

use super::{
    model::{Multiples, YoloV8, YoloV8Pose},
    utils::Point,
    Model, ModelRun,
};

pub const COCO_CLASSES: [&str; 80] = [
    "person",
    "bicycle",
    "car",
    "motorbike",
    "aeroplane",
    "bus",
    "train",
    "truck",
    "boat",
    "traffic light",
    "fire hydrant",
    "stop sign",
    "parking meter",
    "bench",
    "bird",
    "cat",
    "dog",
    "horse",
    "sheep",
    "cow",
    "elephant",
    "bear",
    "zebra",
    "giraffe",
    "backpack",
    "umbrella",
    "handbag",
    "tie",
    "suitcase",
    "frisbee",
    "skis",
    "snowboard",
    "sports ball",
    "kite",
    "baseball bat",
    "baseball glove",
    "skateboard",
    "surfboard",
    "tennis racket",
    "bottle",
    "wine glass",
    "cup",
    "fork",
    "knife",
    "spoon",
    "bowl",
    "banana",
    "apple",
    "sandwich",
    "orange",
    "broccoli",
    "carrot",
    "hot dog",
    "pizza",
    "donut",
    "cake",
    "chair",
    "sofa",
    "pottedplant",
    "bed",
    "diningtable",
    "toilet",
    "tvmonitor",
    "laptop",
    "mouse",
    "remote",
    "keyboard",
    "cell phone",
    "microwave",
    "oven",
    "toaster",
    "sink",
    "refrigerator",
    "book",
    "clock",
    "vase",
    "scissors",
    "teddy bear",
    "hair drier",
    "toothbrush",
];

// Keypoints as reported by ChatGPT :)
// Nose
// Left Eye
// Right Eye
// Left Ear
// Right Ear
// Left Shoulder
// Right Shoulder
// Left Elbow
// Right Elbow
// Left Wrist
// Right Wrist
// Left Hip
// Right Hip
// Left Knee
// Right Knee
// Left Ankle
// Right Ankle
const KP_CONNECTIONS: [(usize, usize); 16] = [
    (0, 1),
    (0, 2),
    (1, 3),
    (2, 4),
    (5, 6),
    (5, 11),
    (6, 12),
    (11, 12),
    (5, 7),
    (6, 8),
    (7, 9),
    (8, 10),
    (11, 13),
    (12, 14),
    (13, 15),
    (14, 16),
];

#[deprecated(note = "unused for pose detection")]
pub fn report_detect(
    pred: &Tensor,
    img: DynamicImage,
    w: usize,
    h: usize,
    confidence_threshold: f32,
    nms_threshold: f32,
    legend_size: u32,
) -> Result<DynamicImage> {
    let pred = pred.to_device(&Device::Cpu)?;
    let (pred_size, npreds) = pred.dims2()?;
    let nclasses = pred_size - 4;
    // The bounding boxes grouped by (maximum) class index.
    let mut bboxes: Vec<Vec<Bbox<Vec<KeyPoint>>>> = (0..nclasses).map(|_| vec![]).collect();
    // Extract the bounding boxes for which confidence is above the threshold.
    for index in 0..npreds {
        let pred = Vec::<f32>::try_from(pred.i((.., index))?)?;
        let confidence = *pred[4..].iter().max_by(|x, y| x.total_cmp(y)).unwrap();
        if confidence > confidence_threshold {
            let mut class_index = 0;
            for i in 0..nclasses {
                if pred[4 + i] > pred[4 + class_index] {
                    class_index = i
                }
            }
            if pred[class_index + 4] > 0. {
                let bbox = Bbox {
                    xmin: pred[0] - pred[2] / 2.,
                    ymin: pred[1] - pred[3] / 2.,
                    xmax: pred[0] + pred[2] / 2.,
                    ymax: pred[1] + pred[3] / 2.,
                    confidence,
                    data: vec![],
                };
                bboxes[class_index].push(bbox)
            }
        }
    }

    non_maximum_suppression(&mut bboxes, nms_threshold);

    // Annotate the original image and print boxes information.
    let (initial_h, initial_w) = (img.height(), img.width());
    let w_ratio = initial_w as f32 / w as f32;
    let h_ratio = initial_h as f32 / h as f32;
    let mut img = img.to_rgb8();
    let font = Vec::from(include_bytes!("roboto-mono-stripped.ttf") as &[u8]);
    let font = ab_glyph::FontRef::try_from_slice(&font).map_err(candle_core::Error::wrap)?;
    for (class_index, bboxes_for_class) in bboxes.iter().enumerate() {
        for b in bboxes_for_class.iter() {
            println!("{}: {:?}", COCO_CLASSES[class_index], b);
            let xmin = (b.xmin * w_ratio) as i32;
            let ymin = (b.ymin * h_ratio) as i32;
            let dx = (b.xmax - b.xmin) * w_ratio;
            let dy = (b.ymax - b.ymin) * h_ratio;
            if dx >= 0. && dy >= 0. {
                imageproc::drawing::draw_hollow_rect_mut(
                    &mut img,
                    imageproc::rect::Rect::at(xmin, ymin).of_size(dx as u32, dy as u32),
                    image::Rgb([255, 0, 0]),
                );
            }
            if legend_size > 0 {
                imageproc::drawing::draw_filled_rect_mut(
                    &mut img,
                    imageproc::rect::Rect::at(xmin, ymin).of_size(dx as u32, legend_size),
                    image::Rgb([170, 0, 0]),
                );
                let legend = format!(
                    "{}   {:.0}%",
                    COCO_CLASSES[class_index],
                    100. * b.confidence
                );
                imageproc::drawing::draw_text_mut(
                    &mut img,
                    image::Rgb([255, 255, 255]),
                    xmin,
                    ymin,
                    ab_glyph::PxScale {
                        x: legend_size as f32 - 1.,
                        y: legend_size as f32 - 1.,
                    },
                    &font,
                    &legend,
                )
            }
        }
    }
    Ok(DynamicImage::ImageRgb8(img))
}

pub fn report_pose(
    pred: &Tensor,
    img: DynamicImage,
    w: usize,
    h: usize,
    confidence_threshold: f32,
    nms_threshold: f32,
) -> Result<DynamicImage> {
    let pred = pred.to_device(&Device::Cpu)?;
    let (pred_size, npreds) = pred.dims2()?;
    if pred_size != 17 * 3 + 4 + 1 {
        candle_core::bail!("unexpected pred-size {pred_size}");
    }
    let mut bboxes = vec![];
    // Extract the bounding boxes for which confidence is above the threshold.
    for index in 0..npreds {
        let pred = Vec::<f32>::try_from(pred.i((.., index))?)?;
        let confidence = pred[4];
        if confidence > confidence_threshold {
            let keypoints = (0..17)
                .map(|i| KeyPoint {
                    x: pred[3 * i + 5],
                    y: pred[3 * i + 6],
                    mask: pred[3 * i + 7],
                })
                .collect::<Vec<_>>();
            let bbox = Bbox {
                xmin: pred[0] - pred[2] / 2.,
                ymin: pred[1] - pred[3] / 2.,
                xmax: pred[0] + pred[2] / 2.,
                ymax: pred[1] + pred[3] / 2.,
                confidence,
                data: keypoints,
            };
            bboxes.push(bbox)
        }
    }

    let mut bboxes = vec![bboxes];
    non_maximum_suppression(&mut bboxes, nms_threshold);
    let bboxes = &bboxes[0];

    // Annotate the original image and print boxes information.
    let (initial_h, initial_w) = (img.height(), img.width());
    let w_ratio = initial_w as f32 / w as f32;
    let h_ratio = initial_h as f32 / h as f32;
    let mut img = img.to_rgb8();
    for b in bboxes.iter() {
        println!("{b:?}");
        let xmin = (b.xmin * w_ratio) as i32;
        let ymin = (b.ymin * h_ratio) as i32;
        let dx = (b.xmax - b.xmin) * w_ratio;
        let dy = (b.ymax - b.ymin) * h_ratio;
        if dx >= 0. && dy >= 0. {
            imageproc::drawing::draw_hollow_rect_mut(
                &mut img,
                imageproc::rect::Rect::at(xmin, ymin).of_size(dx as u32, dy as u32),
                image::Rgb([255, 0, 0]),
            );
        }
        for kp in b.data.iter() {
            if kp.mask < 0.6 {
                continue;
            }
            let x = (kp.x * w_ratio) as i32;
            let y = (kp.y * h_ratio) as i32;
            imageproc::drawing::draw_filled_circle_mut(
                &mut img,
                (x, y),
                2,
                image::Rgb([0, 255, 0]),
            );
        }

        for &(idx1, idx2) in KP_CONNECTIONS.iter() {
            let kp1 = &b.data[idx1];
            let kp2 = &b.data[idx2];
            if kp1.mask < 0.6 || kp2.mask < 0.6 {
                continue;
            }
            imageproc::drawing::draw_line_segment_mut(
                &mut img,
                (kp1.x * w_ratio, kp1.y * h_ratio),
                (kp2.x * w_ratio, kp2.y * h_ratio),
                image::Rgb([255, 255, 0]),
            );
        }
    }
    Ok(DynamicImage::ImageRgb8(img))
}

pub fn report_pose_with_points(
    pred: &Tensor,
    img: DynamicImage,
    w: usize,
    h: usize,
    confidence_threshold: f32,
    nms_threshold: f32,
) -> Result<(DynamicImage, Vec<Point>)> {
    let pred = pred.to_device(&Device::Cpu)?;
    let (pred_size, npreds) = pred.dims2()?;
    if pred_size != 17 * 3 + 4 + 1 {
        candle_core::bail!("unexpected pred-size {pred_size}");
    }
    let mut bboxes = vec![];
    // Extract the bounding boxes for which confidence is above the threshold.
    for index in 0..npreds {
        let pred = Vec::<f32>::try_from(pred.i((.., index))?)?;
        let confidence = pred[4];
        if confidence > confidence_threshold {
            let keypoints = (0..17)
                .map(|i| KeyPoint {
                    x: pred[3 * i + 5],
                    y: pred[3 * i + 6],
                    mask: pred[3 * i + 7],
                })
                .collect::<Vec<_>>();
            let bbox = Bbox {
                xmin: pred[0] - pred[2] / 2.,
                ymin: pred[1] - pred[3] / 2.,
                xmax: pred[0] + pred[2] / 2.,
                ymax: pred[1] + pred[3] / 2.,
                confidence,
                data: keypoints,
            };
            bboxes.push(bbox)
        }
    }

    if bboxes.is_empty() {
        return Ok((img.into(), vec![]));
    }

    let mut bboxes = vec![bboxes];
    non_maximum_suppression(&mut bboxes, nms_threshold);
    let bboxes = &bboxes[0];

    if let Some(largest_bbox) = bboxes.iter().max_by(|a, b| {
        let a_area = (a.xmax - a.xmin) * (a.ymax - a.ymin);
        let b_area = (b.xmax - b.xmin) * (b.ymax - b.ymin);
        return a_area.partial_cmp(&b_area).unwrap_or(Ordering::Greater);
    }) {
        let mut points = vec![];

        // Annotate the original image and print boxes information.
        let (initial_h, initial_w) = (img.height(), img.width());
        let w_ratio = initial_w as f32 / w as f32;
        let h_ratio = initial_h as f32 / h as f32;
        let mut img = img.to_rgb8();

        let xmin = (largest_bbox.xmin * w_ratio) as i32;
        let ymin = (largest_bbox.ymin * h_ratio) as i32;
        let dx = (largest_bbox.xmax - largest_bbox.xmin) * w_ratio;
        let dy = (largest_bbox.ymax - largest_bbox.ymin) * h_ratio;
        if dx >= 0. && dy >= 0. {
            imageproc::drawing::draw_hollow_rect_mut(
                &mut img,
                imageproc::rect::Rect::at(xmin, ymin).of_size(dx as u32, dy as u32),
                image::Rgb([255, 0, 0]),
            );
        }
        for kp in largest_bbox.data.iter() {
            if kp.mask < 0.6 {
                continue;
            }
            let x = (kp.x * w_ratio) as i32;
            let y = (kp.y * h_ratio) as i32;
            imageproc::drawing::draw_filled_circle_mut(
                &mut img,
                (x, y),
                2,
                image::Rgb([0, 255, 0]),
            );
        }

        // 只检测一个人的姿态
        for kp in largest_bbox.data.iter() {
            if kp.mask < 0.6 {
                points.push(Point::new(-1.0, -1.0));
            }
            points.push(Point::new(kp.x * w_ratio, kp.y * h_ratio));
        }

        for &(idx1, idx2) in KP_CONNECTIONS.iter() {
            let kp1 = &largest_bbox.data[idx1];
            let kp2 = &largest_bbox.data[idx2];
            if kp1.mask < 0.6 || kp2.mask < 0.6 {
                continue;
            }
            imageproc::drawing::draw_line_segment_mut(
                &mut img,
                (kp1.x * w_ratio, kp1.y * h_ratio),
                (kp2.x * w_ratio, kp2.y * h_ratio),
                image::Rgb([255, 255, 0]),
            );
        }

        return Ok((DynamicImage::ImageRgb8(img), points));
    }

    return Ok((img.into(), vec![]));
}

impl Model<YoloV8> {
    pub fn new(model_path: String) -> Self {
        Model {
            inner: None,
            model_path,
            device: Device::cuda_if_available(0).unwrap_or(Device::Cpu),
        }
    }
}

impl Model<YoloV8Pose> {
    pub fn new(model_path: String) -> Self {
        Model {
            inner: None,
            model_path,
            device: Device::cuda_if_available(0).unwrap_or(Device::Cpu),
        }
    }
}

impl ModelRun<Vec<u8>> for Model<YoloV8> {
    fn run(&self, image_bytes: Tensor) -> anyhow::Result<Tensor> {
        if let Some(inner) = &self.inner {
            let pred = inner.forward(&image_bytes)?.squeeze(0)?;
            return Ok(pred);
        }

        anyhow::bail!("detect model not loaded")
    }

    fn load(&mut self) -> anyhow::Result<()> {
        let size: Multiples;
        if self.model_path.contains("yolov8n") {
            size = Multiples::n();
        } else if self.model_path.contains("yolov8s") {
            size = Multiples::s();
        } else if self.model_path.contains("yolov8m") {
            size = Multiples::m();
        } else if self.model_path.contains("yolov8l") {
            size = Multiples::l();
        } else if self.model_path.contains("yolov8x") {
            size = Multiples::x();
        } else {
            return Err(anyhow::anyhow!("unknown model type"));
        }
        let vb = unsafe {
            VarBuilder::from_mmaped_safetensors(
                &[self.model_path.clone()],
                DType::F32,
                &self.device,
            )?
        };
        let v8 = YoloV8::load(vb, size, 80)?;
        self.inner = Some(v8);

        anyhow::Ok(())
    }
}

impl ModelRun<Vec<u8>> for Model<YoloV8Pose> {
    fn load(&mut self) -> anyhow::Result<()> {
        // let size: Multiples = Multiples::s();
        let size: Multiples;
        if self.model_path.contains("yolov8n") {
            size = Multiples::n();
        } else if self.model_path.contains("yolov8s") {
            size = Multiples::s();
        } else if self.model_path.contains("yolov8m") {
            size = Multiples::m();
        } else if self.model_path.contains("yolov8l") {
            size = Multiples::l();
        } else if self.model_path.contains("yolov8x") {
            size = Multiples::x();
        } else {
            return Err(anyhow::anyhow!("unknown model type"));
        }
        let vb = unsafe {
            VarBuilder::from_mmaped_safetensors(
                &[self.model_path.clone()],
                DType::F32,
                &self.device,
            )?
        };
        let v8 = YoloV8Pose::load(vb, size, 1, (17, 3))?;
        self.inner = Some(v8);

        anyhow::Ok(())
    }

    fn run(&self, image_bytes: Tensor) -> anyhow::Result<Tensor> {
        if let Some(inner) = &self.inner {
            let pred = inner.forward(&image_bytes)?.squeeze(0)?;
            return Ok(pred);
        }

        anyhow::bail!("pose model not loaded")
    }
}
