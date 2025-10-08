use charon::constants::{MAX_BURN_SQUARED};

pub fn calculate_distance_squared(x1: u32, y1: u32, x2: u32, y2: u32) -> u32 {
    let dx = if x2 > x1 { x2 - x1 } else { x1 - x2 };
    let dy = if y2 > y1 { y2 - y1 } else { y1 - y2 };
    
    let dis_squared: u32 = (dx) * (dx) + (dy) * (dy);

    dis_squared
}

// Check if within range using squared distances (most efficient)
pub fn is_within_range_squared(x1: u32, y1: u32, x2: u32, y2: u32, range: u32) -> bool {
    let range_squared: u32 = (range) * (range);
    calculate_distance_squared(x1, y1, x2, y2) <= range_squared
}
pub fn is_valid_burn_distance(distance_squared: u32) -> bool {
    distance_squared <= MAX_BURN_SQUARED
}

// Helper functions
pub fn min_u8(a: u8, b: u8) -> u8 {
    if a < b { a } else { b }
}

pub fn min_u32_u8(a: u32, b: u8) -> u8 {
    let a_as_u8: u8 = if a > 255_u32 { 255_u8 } else { a.try_into().unwrap() };
    if a_as_u8 < b { a_as_u8 } else { b }
}



pub fn max_u8(a: u8, b: u8) -> u8 {
    if a > b { a } else { b }
}

// Helper
pub fn min_u32(a: u32, b: u32) -> u32 {
    if a < b { a } else { b }
}

pub fn max_u32(a: u32, b: u32) -> u32 {
    if a > b { a } else { b }
}