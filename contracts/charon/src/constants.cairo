pub const MAX_BURN_SQUARED: u32 = 250000;

// Ship Oberon Default Constants
pub const DEFAULT_POINT_DEFENSE: u8 = 2;
pub const DEFAULT_TORPEDOES: u8 = 8;
pub const DEFAULT_RAILGUN: bool = true;

pub const DEFAULT_CREW_CAPACITY: u16 = 1;
pub const DEFAULT_FUEL: u32 = 10000;
pub const DEFAULT_CARGO: u32 = 1000;
pub const DEFAULT_POWER_OUTPUT: u16 = 500;
pub const DEFAULT_POWER_AVAILABLE: u16 = 500;

pub const DEFAULT_LOCATION_X: u32 = 20;
pub const DEFAULT_LOCATION_Y: u32 = 20;
pub const DEFAULT_MORALE: u8 = 50; // Neutral starting morale

// Maximum values (for validation)
pub const MAX_POINT_DEFENSE: u8 = 4;
pub const MAX_TORPEDOES: u8 = 8;
pub const MAX_CREW_CAPACITY: u16 = 30;
pub const MAX_CARGO: u32 = 200;
pub const MAX_MORALE: u8 = 100;
pub const MIN_MORALE: u8 = 0;

pub const DEFAULT_HULL: u32 = 5000;
pub const DEFAULT_SHIELD: u32 = 2000;

pub const TORPEDO_BASE_DAMAGE: u32 = 1000;      // Torpedoes are devastating
pub const RAILGUN_BASE_DAMAGE: u32 = 200;       // Heavy kinetic damage
pub const PDC_BASE_DAMAGE: u32 = 50;            // Light point defense rounds