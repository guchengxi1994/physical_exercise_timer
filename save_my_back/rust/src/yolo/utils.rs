#[derive(Debug)]
struct Point {
    x: f64,
    y: f64,
}

// 检查坐姿是否标准
fn check_posture(keypoints: &Vec<Point>) {
    let threshold = 20.0;

    // 计算不同的检查指标
    let head_to_shoulders_diff = (keypoints[0].y - (keypoints[5].y + keypoints[6].y) / 2.0).abs();
    let ear_height_diff = (keypoints[3].y - keypoints[4].y).abs();
    let shoulder_height_diff = (keypoints[5].y - keypoints[6].y).abs();
    let spine_alignment =
        ((keypoints[11].x + keypoints[12].x) / 2.0 - (keypoints[5].x + keypoints[6].x) / 2.0).abs();

    let left_arm_angle = calculate_angle(&keypoints[5], &keypoints[7], &keypoints[9]);
    let right_arm_angle = calculate_angle(&keypoints[6], &keypoints[8], &keypoints[10]);
    let left_leg_angle = calculate_angle(&keypoints[11], &keypoints[13], &keypoints[15]);
    let right_leg_angle = calculate_angle(&keypoints[12], &keypoints[14], &keypoints[16]);

    // 不标准原因列表
    let mut reasons = Vec::new();

    if head_to_shoulders_diff > threshold {
        reasons.push("头部位置偏移过大");
    }
    if ear_height_diff > threshold {
        reasons.push("头部倾斜过大");
    }
    if shoulder_height_diff > threshold {
        reasons.push("两肩高度差过大");
    }
    if spine_alignment > threshold {
        reasons.push("脊椎未对齐");
    }
    if !(left_arm_angle >= 70.0 && left_arm_angle <= 150.0) {
        reasons.push("左臂角度不在合理范围 (70° - 150°)");
    }
    if !(right_arm_angle >= 70.0 && right_arm_angle <= 150.0) {
        reasons.push("右臂角度不在合理范围 (70° - 150°)");
    }
    if !(left_leg_angle >= 90.0 && left_leg_angle <= 180.0) {
        reasons.push("左腿角度不在合理范围 (90° - 180°)");
    }
    if !(right_leg_angle >= 90.0 && right_leg_angle <= 180.0) {
        reasons.push("右腿角度不在合理范围 (90° - 180°)");
    }

    // 输出结果
    if reasons.is_empty() {
        println!("坐姿标准");
    } else {
        println!("坐姿不标准，原因如下：");
        for reason in reasons {
            println!("- {}", reason);
        }
    }
}

// 计算角度的辅助函数
fn calculate_angle(a: &Point, b: &Point, c: &Point) -> f64 {
    let ab = (b.x - a.x, b.y - a.y);
    let bc = (c.x - b.x, c.y - b.y);
    let dot_product = ab.0 * bc.0 + ab.1 * bc.1;
    let mag_ab = (ab.0.powi(2) + ab.1.powi(2)).sqrt();
    let mag_bc = (bc.0.powi(2) + bc.1.powi(2)).sqrt();
    let cos_angle = dot_product / (mag_ab * mag_bc);
    cos_angle.acos().to_degrees()
}
