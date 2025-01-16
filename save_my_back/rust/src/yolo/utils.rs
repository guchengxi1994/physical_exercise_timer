#[derive(Debug)]
pub struct Point {
    x: f32,
    y: f32,
}

impl Point {
    pub fn new(x: f32, y: f32) -> Self {
        Point { x, y }
    }

    pub fn from_tuple(tuple: (f32, f32)) -> Self {
        Point {
            x: tuple.0,
            y: tuple.1,
        }
    }

    pub fn valid(&self) -> bool {
        self.x != -1.0 && self.y != -1.0
    }
}

// 检查坐姿是否标准
pub fn check_posture(keypoints: &Vec<Point>) -> String {
    let threshold = 20.0;

    if keypoints.is_empty() {
        return "未监测到人员".to_string();
    }

    // 确保关键点数量足够
    if keypoints.len() < 17 {
        return format!("无法判断坐姿, 只有{}个关键点", keypoints.len());
    }

    // 提取关键点
    let head = &keypoints[0];
    let left_shoulder = &keypoints[5];
    let right_shoulder = &keypoints[6];
    let left_ear = &keypoints[3];
    let right_ear = &keypoints[4];
    let left_elbow = &keypoints[7];
    let right_elbow = &keypoints[8];
    let left_wrist = &keypoints[9];
    let right_wrist = &keypoints[10];
    let left_hip = &keypoints[11];
    let right_hip = &keypoints[12];
    let left_knee = &keypoints[13];
    let right_knee = &keypoints[14];
    let left_ankle = &keypoints[15];
    let right_ankle = &keypoints[16];

    let mut reasons = Vec::new();

    // 计算各指标
    if head.valid() && left_shoulder.valid() && right_shoulder.valid() {
        let head_to_shoulders_diff = (head.y - (left_shoulder.y + right_shoulder.y) / 2.0).abs();
        if head_to_shoulders_diff > threshold {
            reasons.push("头部位置偏移过大");
        }
    }

    if left_ear.valid() && right_ear.valid() {
        let ear_height_diff = (left_ear.y - right_ear.y).abs();
        if ear_height_diff > threshold {
            reasons.push("头部倾斜过大");
        }
    }

    if left_shoulder.valid() && right_shoulder.valid() {
        let shoulder_height_diff = (left_shoulder.y - right_shoulder.y).abs();
        if shoulder_height_diff > threshold {
            reasons.push("两肩高度差过大");
        }
    }

    if left_shoulder.valid() && right_shoulder.valid() && left_hip.valid() && right_hip.valid() {
        let spine_alignment =
            ((left_hip.x + right_hip.x) / 2.0 - (left_shoulder.x + right_shoulder.x) / 2.0).abs();
        if spine_alignment > threshold {
            reasons.push("脊椎未对齐");
        }
    }

    if left_shoulder.valid() && left_elbow.valid() && left_wrist.valid() {
        let left_arm_angle: f32 = calculate_angle(left_shoulder, left_elbow, left_wrist);
        if !(70.0..=150.0).contains(&left_arm_angle) {
            reasons.push("左臂角度不在合理范围 (70° - 150°)");
        }
    }

    if right_shoulder.valid() && right_elbow.valid() && right_wrist.valid() {
        let right_arm_angle = calculate_angle(right_shoulder, right_elbow, right_wrist);
        if !(70.0..=150.0).contains(&right_arm_angle) {
            reasons.push("右臂角度不在合理范围 (70° - 150°)");
        }
    }

    if left_hip.valid() && left_knee.valid() && left_ankle.valid() {
        let left_leg_angle = calculate_angle(left_hip, left_knee, left_ankle);
        if !(90.0..=180.0).contains(&left_leg_angle) {
            reasons.push("左腿角度不在合理范围 (90° - 180°)");
        }
    }

    if (right_hip.valid() && right_knee.valid() && right_ankle.valid()) {
        let right_leg_angle = calculate_angle(right_hip, right_knee, right_ankle);
        if !(90.0..=180.0).contains(&right_leg_angle) {
            reasons.push("右腿角度不在合理范围 (90° - 180°)");
        }
    }

    // 输出结果
    if reasons.is_empty() {
        // println!("坐姿标准");
        return "坐姿标准".to_string();
    } else {
        reasons.join("; ").to_string()
    }
}

// 计算角度的辅助函数
fn calculate_angle(a: &Point, b: &Point, c: &Point) -> f32 {
    let ab = (b.x - a.x, b.y - a.y);
    let bc = (c.x - b.x, c.y - b.y);
    let dot_product = ab.0 * bc.0 + ab.1 * bc.1;
    let mag_ab = (ab.0.powi(2) + ab.1.powi(2)).sqrt();
    let mag_bc = (bc.0.powi(2) + bc.1.powi(2)).sqrt();
    let cos_angle = dot_product / (mag_ab * mag_bc);
    cos_angle.acos().to_degrees()
}
