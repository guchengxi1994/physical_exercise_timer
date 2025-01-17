use flutter_rust_bridge::frb;

use crate::yolo::{self, utils::PoseState};

pub fn init_models(model_path: String) -> String {
    let result = yolo::init_models(model_path);
    match result {
        Ok(_) => "Model initialized successfully".to_string(),
        Err(err) => format!("Error initializing model: {}", err),
    }
}

#[frb(sync)]
pub fn get_hint(state: PoseState) -> String {
    state.get_hint()
}

#[frb(sync)]
pub fn get_pose_type(state: PoseState) -> usize {
    match state {
        PoseState::Good => 0,
        PoseState::Nobody => 1,
        PoseState::PointsCountError(_) => 2,
        PoseState::HeadOffsetTooMuch => 3,
        PoseState::HeadInclinedTooMuch => 4,
        PoseState::ShoulderHeightDiffTooMuch => 5,
        PoseState::SpineAlignment => 6,
        PoseState::LeftArmAngleNotGood => 7,
        PoseState::RightArmAngleNotGood => 8,
        PoseState::LeftLegAngleNotGood => 9,
        PoseState::RightLegAngleNotGood => 10,
    }
}

#[frb(sync)]
pub fn get_pose_state_by_index(index: usize) -> PoseState {
    match index {
        0 => PoseState::Good,
        1 => PoseState::Nobody,
        2 => PoseState::PointsCountError(0),
        3 => PoseState::HeadOffsetTooMuch,
        4 => PoseState::HeadInclinedTooMuch,
        5 => PoseState::ShoulderHeightDiffTooMuch,
        6 => PoseState::SpineAlignment,
        7 => PoseState::LeftArmAngleNotGood,
        8 => PoseState::RightArmAngleNotGood,
        9 => PoseState::LeftLegAngleNotGood,
        10 => PoseState::RightLegAngleNotGood,
        _ => panic!("Invalid index"),
    }
}

pub fn infer(img_bytes: Vec<u8>) -> Option<(Vec<u8>, Vec<PoseState>)> {
    let result = yolo::infer(img_bytes);
    match result {
        Ok((img_bytes, states)) => Some((img_bytes, states)),
        Err(err) => {
            eprintln!("Error inferring: {}", err);
            None
        }
    }
}
