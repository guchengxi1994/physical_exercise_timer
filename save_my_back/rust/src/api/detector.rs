use crate::yolo;

pub fn init_models(model_path: String)-> String{
    let result = yolo::init_models(model_path);
    match result {
        Ok(_) => "Model initialized successfully".to_string(),
        Err(err) => format!("Error initializing model: {}", err),
    }
}

pub fn infer(img_bytes: Vec<u8>) -> Option<(Vec<u8>, String)> {
    let result = yolo::infer(img_bytes);
    match result {
        Ok((img_bytes, message)) => Some((img_bytes, message)),
        Err(err) => {
            eprintln!("Error inferring: {}", err);
            None
        }
    }
}