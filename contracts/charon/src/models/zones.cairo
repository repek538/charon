
use starknet::ContractAddress;
use charon::models::ships::{Faction};


#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Zone {
    #[key]
    pub zone_id: u8,
    pub zone_type: ZoneType,
    pub name: felt252,
    
    // Coordinate boundaries (using simplified 2D coordinates)
    pub min_x: u32,
    pub min_y: u32, 
    pub max_x: u32,
    pub max_y: u32,
    
    // Zone characteristics
    pub resource_density: u8,    // 0-100, mining/salvage opportunities
    pub danger_level: u8,        // 0-100, hostile encounters
    pub patrol_frequency: u8,    // 0-100, how often patrols scan
    pub fuel_cost_modifier: u8,  // 50-200, movement cost multiplier
    
    // Environmental effects
    pub radiation_level: u8,     // 0-100, affects crew health
    pub asteroid_density: u8,    // 0-100, navigation hazards
    pub gravity_wells: u8,       // 0-100, affects fuel consumption
    
    // Political control
    pub controlling_faction: Faction, // Who controls this zone
    pub security_level: u8,      // 0-100, how well defended
    pub trade_hub_bonus: u8,     // 0-100, economic activity
    
    // Detection systems
    pub sensor_coverage: u8,     // 0-100, how well monitored
    pub communication_delay: u8,  // Turns for messages to propagate
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug, DojoStore, Default)]
pub enum ZoneType {
    #[default]
    Cislunar,       // Earth-Moon system
    InnerPlanets,   // Mercury, Venus, Mars orbit
    AsteroidBelt,   // Main asteroid belt
    Jupiter,        // Jupiter and major moons
    Saturn,         // Saturn and ring system  
    OuterPlanets,   // Uranus, Neptune
    KuiperBelt,     // Pluto and beyond
    Void
}

pub trait ZoneTypeTrait {
    fn from_zone_id(value: u8) -> Option<ZoneType>;
    fn to_zone_id(self: ZoneType) -> u8;
    fn from_coordinates(x: u32, y: u32) -> ZoneType;
    fn get_fuel_cost_modifier(self: ZoneType) -> u8;
    fn get_mini_zone_grid_size(self: ZoneType) -> u8;
    fn get_global_mini_zone_id(self: ZoneType, x: u32, y: u32) -> u8;
}

pub impl ZoneTypeImpl of ZoneTypeTrait {
    fn from_zone_id(value: u8) -> Option<ZoneType> {
        match value {
            0 => Option::Some(ZoneType::Cislunar),
            1 => Option::Some(ZoneType::InnerPlanets),
            2 => Option::Some(ZoneType::AsteroidBelt),
            3 => Option::Some(ZoneType::Jupiter),
            4 => Option::Some(ZoneType::Saturn),
            5 => Option::Some(ZoneType::OuterPlanets),
            6 => Option::Some(ZoneType::KuiperBelt),
            7 => Option::Some(ZoneType::Void),
            _ => Option::None,
        }
    }

    fn to_zone_id(self: ZoneType) -> u8 {
        match self {
            ZoneType::Cislunar => 0,
            ZoneType::InnerPlanets => 1,
            ZoneType::AsteroidBelt => 2,
            ZoneType::Jupiter => 3,
            ZoneType::Saturn => 4,
            ZoneType::OuterPlanets => 5,
            ZoneType::KuiperBelt => 6,
            ZoneType::Void => 7,
        }
    }

    fn from_coordinates(x: u32, y: u32) -> ZoneType {
        let sum = x + y;
        
        // Zone 1: Cislunar - diagonal band from 0 to 500
        if sum < 500 {
            return ZoneType::Cislunar;
        }
        
        // Void Gap 1: 500 to 700
        if sum >= 500 && sum < 700 {
            return ZoneType::Void;
        }
        
        // Zone 2: InnerPlanets - 700 to 1200
        if sum >= 700 && sum < 1200 {
            return ZoneType::InnerPlanets;
        }
        
        // Void Gap 2: 1200 to 1400
        if sum >= 1200 && sum < 1400 {
            return ZoneType::Void;
        }
        
        // Zone 3: AsteroidBelt - 1400 to 2000
        if sum >= 1400 && sum < 2000 {
            return ZoneType::AsteroidBelt;
        }
        
        // Void Gap 3: 2000 to 2200
        if sum >= 2000 && sum < 2200 {
            return ZoneType::Void;
        }
        
        // Zone 4: Jupiter - 2200 to 2800
        if sum >= 2200 && sum < 2800 {
            return ZoneType::Jupiter;
        }
        
        // Void Gap 4: 2800 to 3000
        if sum >= 2800 && sum < 3000 {
            return ZoneType::Void;
        }
        
        // Zone 5: Saturn - 3000 to 3600
        if sum >= 3000 && sum < 3600 {
            return ZoneType::Saturn;
        }
        
        // Void Gap 5: 3600 to 3800
        if sum >= 3600 && sum < 3800 {
            return ZoneType::Void;
        }
        
        // Zone 6: OuterPlanets - 3800 to 4500
        if sum >= 3800 && sum < 4500 {
            return ZoneType::OuterPlanets;
        }
        
        // Void Gap 6: 4500 to 4700
        if sum >= 4500 && sum < 4700 {
            return ZoneType::Void;
        }
        
        // Zone 7: KuiperBelt - 4700 to 8000
        if sum >= 4700 && sum < 8000 {
            return ZoneType::KuiperBelt;
        }
        
        // Everything else is Void (beyond 8000)
        ZoneType::Void
    }

    fn get_mini_zone_grid_size(self: ZoneType) -> u8 {
        match self {
            ZoneType::Cislunar => 1,      // 1 mini zone (boundaries: 0, 500)
            ZoneType::InnerPlanets => 3,  // 3 mini zones (boundaries: 0, 500, 700, 1200)
            ZoneType::AsteroidBelt => 5,  // 5 mini zones (boundaries: 0, 500, 700, 1200, 1400, 2000)
            ZoneType::Jupiter => 7,       // 7 mini zones (boundaries: 0, 500, 700, 1200, 1400, 2000, 2200, 2800)
            ZoneType::Saturn => 8,        // 8 mini zones (boundaries: 0, 500, 700, 1200, 1400, 2000, 2200, 2800, 3000, 3600)
            ZoneType::OuterPlanets => 9,  // 9 mini zones (boundaries: 0, 500, 700, 1200, 1400, 2000, 2200, 2800, 3000, 3600, 3800, 4500)
            ZoneType::KuiperBelt => 11,   // 11 mini zones (boundaries: 0, 500, 700, 1200, 1400, 2000, 2200, 2800, 3000, 3600, 3800, 4500, 4700, 8000)
            ZoneType::Void => 1,          // No subdivision needed
        }
    }

    fn get_global_mini_zone_id(self: ZoneType, x: u32, y: u32) -> u8 {
        // Get cumulative starting ID for this zone
        let zone_start_id = match self {
            ZoneType::Cislunar => 1,       // Starts at 1 (has 1 mini zone: 1)
            ZoneType::InnerPlanets => 2,   // Starts at 2 (has 3 mini zones: 2,3,4)
            ZoneType::AsteroidBelt => 5,   // Starts at 5 (has 5 mini zones: 5,6,7,8,9)
            ZoneType::Jupiter => 10,       // Starts at 10 (has 7 mini zones: 10,11,12,13,14,15,16)
            ZoneType::Saturn => 17,        // Starts at 17 (has 8 mini zones: 17,18,19,20,21,22,23,24)
            ZoneType::OuterPlanets => 25,  // Starts at 25 (has 9 mini zones: 25,26,27,28,29,30,31,32,33)
            ZoneType::KuiperBelt => 34,    // Starts at 34 (has 11 mini zones: 34,35,36,37,38,39,40,41,42,43,44)
            ZoneType::Void => 0,           // Void has no mini zones
        };
        
        // Calculate which Y boundary range this coordinate falls into (0-based offset)
        let mini_zone_offset = if y < 500 {
            0
        } else if y < 700 {
            1
        } else if y < 1200 {
            2
        } else if y < 1400 {
            3
        } else if y < 2000 {
            4
        } else if y < 2200 {
            5
        } else if y < 2800 {
            6
        } else if y < 3000 {
            7
        } else if y < 3600 {
            8
        } else if y < 3800 {
            9
        } else if y < 4500 {
            10
        } else if y < 4700 {
            11
        } else {
            12 // y >= 4700
        };

        zone_start_id + mini_zone_offset
    }

    fn get_fuel_cost_modifier(self: ZoneType) -> u8 {
        match self {
            ZoneType::Cislunar => 80,      // 20% fuel savings
            ZoneType::InnerPlanets => 90,  // 10% fuel savings  
            ZoneType::AsteroidBelt => 110, // 10% extra fuel
            ZoneType::Jupiter => 120,      // 20% extra fuel
            ZoneType::Saturn => 115,       // 15% extra fuel
            ZoneType::OuterPlanets => 130, // 30% extra fuel
            ZoneType::KuiperBelt => 140,   // 40% extra fuel
            ZoneType::Void => 200,         // 100% extra fuel (double cost)
        }
    }
}