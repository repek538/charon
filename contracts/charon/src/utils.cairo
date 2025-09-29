pub fn calculate_distance_squared(x1: u32, y1: u32, x2: u32, y2: u32) -> u64 {
    let dx = if x2 > x1 { x2 - x1 } else { x1 - x2 };
    let dy = if y2 > y1 { y2 - y1 } else { y1 - y2 };
    
    let dis_squared: u64 = (dx.into()) * (dx.into()) + (dy.into()) * (dy.into());

    dis_squared
}

// Check if within range using squared distances (most efficient)
pub fn is_within_range_squared(x1: u32, y1: u32, x2: u32, y2: u32, range: u32) -> bool {
    let range_squared: u64 = (range.into()) * (range.into());
    calculate_distance_squared(x1, y1, x2, y2) <= range_squared
}