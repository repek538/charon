use charon::constants::{MAX_BURN_SQUARED};
use starknet::ContractAddress;

use charon::models::game::{ShipComposition,StationComposition};

use charon::models::ships::{ShipClass,Faction,Ship,Vec2};

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




pub mod credit_helper {

    use super::{ContractAddress,ShipComposition,StationComposition};

    #[generate_trait]
    pub impl CreditHelperImpl of CreditHelperTrait {

        fn get_tier_from_credits(credits: u256) -> u8 {
            if credits < 100 {
                1 // Tier 1: Beginner
            } else if credits < 500 {
                2 // Tier 2: Intermediate
            } else if credits < 1000 {
                3 // Tier 3: Advanced
            } else if credits < 5000 {
                4 // Tier 4: Expert
            } else {
                5 // Tier 5: Legendary
            }
        }

     fn calculate_threat_budget(credits: u256) -> u32 {
            let credits_u64: u64 = credits.try_into().unwrap_or(0);
            let base_budget: u32 = 50;
            
            // Every 10 credits = 5 threat points
            let bonus: u32 = ((credits_u64 / 10) * 5).try_into().unwrap_or(0);
            
            base_budget + bonus
        }


      // Get recommended ship composition based on credits and mortality
    fn get_recommended_composition(
        credits: u256, 
        mortality_level: u8,
        rescue_id: u32
    ) -> (ShipComposition, StationComposition) {
        let threat_budget = Self::calculate_threat_budget(credits);
        let tier = Self::get_tier_from_credits(credits) - 1;
        
        // Calculate how aggressive the composition should be based on mortality
        let aggression_factor = mortality_level; // 0-100
        
        match tier {
            0 => Self::tier1_composition(threat_budget, aggression_factor,rescue_id),
            1 => Self::tier2_composition(threat_budget, aggression_factor,rescue_id),
            2 => Self::tier3_composition(threat_budget, aggression_factor,rescue_id),
            3 => Self::tier4_composition(threat_budget, aggression_factor,rescue_id),
            4 => Self::tier5_composition(threat_budget, aggression_factor,rescue_id),
            _ => Self::tier1_composition(threat_budget, aggression_factor,rescue_id),
        }
    } 

    // Tier 1: 0-99 credits (Low threat, learning gauntlets)
    fn tier1_composition(budget: u32, aggression: u8,rescue_id: u32) -> (ShipComposition, StationComposition) {
        let ships = if aggression < 30 {
            // Easy: Mostly weak ships
            ShipComposition {
                game_id: 0,
                rescue_id,
                pirate_skiff_count: 6,  // 30 points
                corvette_count: 2,      // 20 points
                freighter_count: 0,
                frigate_count: 0,
                destroyer_count: 0,
                cruiser_count: 0,
                carrier_count: 0,
                battleship_count: 0,
            }
        } else if aggression < 60 {
            // Medium: Mix of light and medium
            ShipComposition {
                game_id: 0,
                rescue_id,
                pirate_skiff_count: 4,  // 20 points
                corvette_count: 2,      // 20 points
                frigate_count: 1,       // 20 points
                freighter_count: 1,     // 12 points
                destroyer_count: 0,
                cruiser_count: 0,
                carrier_count: 0,
                battleship_count: 0,
            }
        } else {
            // Hard: Some heavier units
            ShipComposition {
                game_id: 0,
                rescue_id,
                pirate_skiff_count: 2,  // 10 points
                corvette_count: 2,      // 20 points
                frigate_count: 1,       // 20 points
                destroyer_count: 1,     // 35 points
                freighter_count: 0,
                cruiser_count: 0,
                carrier_count: 0,
                battleship_count: 0,
            }
        };
        
        let stations = StationComposition {
            game_id: 0,
            rescue_id,
            habitat_count: 1,           // 15 points
            relay_station_count: 0,
            tradehub_count: 0,
            mining_outpost_count: 0,
            smuggler_den_count: 0,
            research_lab_count: 0,
            shipyard_count: 0,
            military_base_count: 0,
        };
        
        (ships, stations)
    }
    
    // Tier 2: 100-499 credits (Medium threat)
    fn tier2_composition(budget: u32, aggression: u8,rescue_id: u32) -> (ShipComposition, StationComposition) {
        let ships = if aggression < 30 {
            ShipComposition {
                game_id: 0,
                rescue_id,
                pirate_skiff_count: 8,
                corvette_count: 4,
                frigate_count: 2,
                freighter_count: 1,
                destroyer_count: 1,
                cruiser_count: 0,
                carrier_count: 0,
                battleship_count: 0,
            }
        } else if aggression < 60 {
            ShipComposition {
                game_id: 0,
                rescue_id,
                pirate_skiff_count: 4,
                corvette_count: 3,
                frigate_count: 3,
                destroyer_count: 2,
                freighter_count: 0,
                cruiser_count: 1,
                carrier_count: 0,
                battleship_count: 0,
            }
        } else {
            ShipComposition {
                game_id: 0,
                rescue_id,
                pirate_skiff_count: 2,
                corvette_count: 2,
                frigate_count: 2,
                destroyer_count: 2,
                cruiser_count: 1,
                carrier_count: 1,
                freighter_count: 0,
                battleship_count: 0,
            }
        };
        
        let stations = if aggression < 50 {
            StationComposition {
                game_id: 0,
                rescue_id,
                habitat_count: 2,
                relay_station_count: 1,
                tradehub_count: 1,
                mining_outpost_count: 1,
                smuggler_den_count: 0,
                research_lab_count: 0,
                shipyard_count: 0,
                military_base_count: 0,
            }
        } else {
            StationComposition {
                game_id: 0,
                rescue_id,
                habitat_count: 1,
                relay_station_count: 0,
                tradehub_count: 1,
                mining_outpost_count: 1,
                smuggler_den_count: 1,
                research_lab_count: 1,
                shipyard_count: 0,
                military_base_count: 0,
            }
        };
        
        (ships, stations)
    }
    
    // Tier 3: 500-999 credits (High threat)
    fn tier3_composition(budget: u32, aggression: u8,rescue_id: u32) -> (ShipComposition, StationComposition) {
        let ships = if aggression < 30 {
            ShipComposition {
                game_id: 0,
                rescue_id,
                pirate_skiff_count: 10,
                corvette_count: 5,
                frigate_count: 4,
                destroyer_count: 3,
                cruiser_count: 1,
                freighter_count: 1,
                carrier_count: 0,
                battleship_count: 0,
            }
        } else if aggression < 60 {
            ShipComposition {
                game_id: 0,
                rescue_id,
                pirate_skiff_count: 5,
                corvette_count: 4,
                frigate_count: 4,
                destroyer_count: 3,
                cruiser_count: 2,
                carrier_count: 1,
                freighter_count: 0,
                battleship_count: 0,
            }
        } else {
            ShipComposition {
                game_id: 0,
                rescue_id,
                pirate_skiff_count: 3,
                corvette_count: 3,
                frigate_count: 3,
                destroyer_count: 3,
                cruiser_count: 2,
                carrier_count: 1,
                freighter_count: 0,
                battleship_count: 1, // First battleship unlocked
            }
        };
        
        let stations = if aggression < 50 {
            StationComposition {
                game_id: 0,
                rescue_id,
                habitat_count: 2,
                relay_station_count: 2,
                tradehub_count: 1,
                mining_outpost_count: 2,
                smuggler_den_count: 1,
                research_lab_count: 1,
                shipyard_count: 0,
                military_base_count: 0,
            }
        } else {
            StationComposition {
                game_id: 0,
                rescue_id,
                habitat_count: 1,
                relay_station_count: 1,
                tradehub_count: 0,
                mining_outpost_count: 2,
                smuggler_den_count: 1,
                research_lab_count: 1,
                shipyard_count: 1,
                military_base_count: 0,
            }
        };
        
        (ships, stations)
    }
    
    // Tier 4: 1000-4999 credits (Very high threat)
    fn tier4_composition(budget: u32, aggression: u8,rescue_id: u32) -> (ShipComposition, StationComposition) {
        let ships = if aggression < 30 {
            ShipComposition {
                game_id: 0,
                rescue_id,
                pirate_skiff_count: 12,
                corvette_count: 6,
                frigate_count: 5,
                destroyer_count: 4,
                cruiser_count: 2,
                carrier_count: 1,
                freighter_count: 0,
                battleship_count: 1,
            }
        } else if aggression < 60 {
            ShipComposition {
                game_id: 0,
                rescue_id,
                pirate_skiff_count: 6,
                corvette_count: 5,
                frigate_count: 5,
                destroyer_count: 4,
                cruiser_count: 3,
                carrier_count: 1,
                freighter_count: 0,
                battleship_count: 1,
            }
        } else {
            ShipComposition {
                game_id: 0,
                rescue_id,
                pirate_skiff_count: 4,
                corvette_count: 4,
                frigate_count: 4,
                destroyer_count: 4,
                cruiser_count: 3,
                carrier_count: 2,
                freighter_count: 0,
                battleship_count: 2,
            }
        };
        
        let stations = if aggression < 50 {
            StationComposition {
                game_id: 0,
                rescue_id,
                habitat_count: 2,
                relay_station_count: 2,
                tradehub_count: 2,
                mining_outpost_count: 2,
                smuggler_den_count: 2,
                research_lab_count: 1,
                shipyard_count: 1,
                military_base_count: 0,
            }
        } else {
            StationComposition {
                game_id: 0,
                rescue_id,
                habitat_count: 1,
                relay_station_count: 1,
                tradehub_count: 1,
                mining_outpost_count: 2,
                smuggler_den_count: 2,
                research_lab_count: 2,
                shipyard_count: 1,
                military_base_count: 1, // First military base
            }
        };
        
        (ships, stations)
    }
    
    // Tier 5: 5000+ credits (Maximum threat)
    fn tier5_composition(budget: u32, aggression: u8,rescue_id: u32) -> (ShipComposition, StationComposition) {
        let ships = if aggression < 30 {
            ShipComposition {
                game_id: 0,
                rescue_id,
                pirate_skiff_count: 15,
                corvette_count: 8,
                frigate_count: 6,
                destroyer_count: 5,
                cruiser_count: 4,
                carrier_count: 2,
                freighter_count: 1,
                battleship_count: 2,
            }
        } else if aggression < 60 {
            ShipComposition {
                game_id: 0,
                rescue_id,
                pirate_skiff_count: 8,
                corvette_count: 6,
                frigate_count: 6,
                destroyer_count: 5,
                cruiser_count: 4,
                carrier_count: 2,
                freighter_count: 0,
                battleship_count: 3,
            }
        } else {
            ShipComposition {
                game_id: 0,
                rescue_id,
                pirate_skiff_count: 5,
                corvette_count: 5,
                frigate_count: 5,
                destroyer_count: 5,
                cruiser_count: 5,
                carrier_count: 3,
                freighter_count: 0,
                battleship_count: 4, // Maximum battleships
            }
        };
        
        let stations = if aggression < 50 {
            StationComposition {
                game_id: 0,
                rescue_id,
                habitat_count: 3,
                relay_station_count: 2,
                tradehub_count: 2,
                mining_outpost_count: 3,
                smuggler_den_count: 2,
                research_lab_count: 2,
                shipyard_count: 2,
                military_base_count: 1,
            }
        } else {
            StationComposition {
                game_id: 0,
                rescue_id,
                habitat_count: 1,
                relay_station_count: 1,
                tradehub_count: 1,
                mining_outpost_count: 3,
                smuggler_den_count: 3,
                research_lab_count: 2,
                shipyard_count: 2,
                military_base_count: 2, // Maximum military bases
            }
        };
        
        (ships, stations)
    }

    }
}

pub mod armament_helper {
    use super::{Ship, ShipClass, Faction, ContractAddress, Vec2};
    
    #[generate_trait]
    pub impl ArmamentHelperImpl of ArmamentHelperTrait {
        
        // ============================================
        // Main Initialization Function
        // ============================================
        
        fn initialize_ship(
            id: ContractAddress,
            owner: ContractAddress,
            name: felt252,
            rescue_gauntlet_id: u32,
            faction: Faction,
            ship_class: ShipClass,
            location: Vec2,
        ) -> Ship {
            // Get base ship
            let mut ship = Self::get_base_ship(
                id,
                owner,
                name,
                rescue_gauntlet_id,
                ship_class,
                location
            );
            
            // Apply faction modifiers
            Self::apply_faction_modifiers(ref ship, faction);
            
            ship
        }
        
        // ============================================
        // Base Ship Stats by Class
        // ============================================
        
fn get_base_ship(
    id: ContractAddress,
    owner: ContractAddress,
    name: felt252,
    rescue_gauntlet_id: u32,
    ship_class: ShipClass,
    location: Vec2,
) -> Ship {
    match ship_class {
        ShipClass::PirateSkiff => Ship {
            id,
            owner,
            name,
            rescue_gauntlet_id,
            faction: Faction::None,
            s_class: ship_class,
            location,
            hull_points: 100,
            shield_points: 0,
            speed: 120,
            crew_size: 3,
            cargo_capacity: 50,
            railguns: 0,
            torpedoes: 2,
            pdcs: 1,
            torpedo_ammo: 6,
            railgun_ammo: 0,
            pdc_ammo: 5000,         // 5k rounds - light load
            fuel_capacity: 500,
            current_fuel: 500,
            reactor_fuel: 100,
            power_output: 10,
        },
        
        ShipClass::Corvette => Ship {
            id,
            owner,
            name,
            rescue_gauntlet_id,
            faction: Faction::None,
            s_class: ship_class,
            location,
            hull_points: 250,
            shield_points: 50,
            speed: 100,
            crew_size: 15,
            cargo_capacity: 100,
            railguns: 1,
            torpedoes: 4,
            pdcs: 2,
            torpedo_ammo: 16,
            railgun_ammo: 5,
            pdc_ammo: 15000,        // 15k rounds total
            fuel_capacity: 1000,
            current_fuel: 1000,
            reactor_fuel: 300,
            power_output: 25,
        },
        
        ShipClass::Freighter => Ship {
            id,
            owner,
            name,
            rescue_gauntlet_id,
            faction: Faction::None,
            s_class: ship_class,
            location,
            hull_points: 300,
            shield_points: 20,
            speed: 40,
            crew_size: 25,
            cargo_capacity: 2000,
            railguns: 0,
            torpedoes: 0,
            pdcs: 3,
            torpedo_ammo: 0,
            railgun_ammo: 0,
            pdc_ammo: 12000,        // Defensive ammo
            fuel_capacity: 3000,
            current_fuel: 3000,
            reactor_fuel: 500,
            power_output: 15,
        },
        
        ShipClass::Frigate => Ship {
            id,
            owner,
            name,
            rescue_gauntlet_id,
            faction: Faction::None,
            s_class: ship_class,
            location,
            hull_points: 400,
            shield_points: 100,
            speed: 80,
            crew_size: 50,
            cargo_capacity: 200,
            railguns: 1,
            torpedoes: 6,
            pdcs: 6,
            torpedo_ammo: 24,
            railgun_ammo: 10,
            pdc_ammo: 30000,        // Heavy anti-missile defense
            fuel_capacity: 1500,
            current_fuel: 1500,
            reactor_fuel: 600,
            power_output: 50,
        },
        
        ShipClass::Destroyer => Ship {
            id,
            owner,
            name,
            rescue_gauntlet_id,
            faction: Faction::None,
            s_class: ship_class,
            location,
            hull_points: 600,
            shield_points: 150,
            speed: 70,
            crew_size: 100,
            cargo_capacity: 300,
            railguns: 1,
            torpedoes: 12,
            pdcs: 8,
            torpedo_ammo: 48,
            railgun_ammo: 20,
            pdc_ammo: 50000,        // 50k rounds
            fuel_capacity: 2500,
            current_fuel: 2500,
            reactor_fuel: 1000,
            power_output: 100,
        },
        
        ShipClass::Cruiser => Ship {
            id,
            owner,
            name,
            rescue_gauntlet_id,
            faction: Faction::None,
            s_class: ship_class,
            location,
            hull_points: 800,
            shield_points: 200,
            speed: 60,
            crew_size: 200,
            cargo_capacity: 500,
            railguns: 4,
            torpedoes: 18,
            pdcs: 10,
            torpedo_ammo: 72,
            railgun_ammo: 25,
            pdc_ammo: 80000,        // 80k rounds
            fuel_capacity: 4000,
            current_fuel: 4000,
            reactor_fuel: 1500,
            power_output: 200,
        },
        
        ShipClass::Carrier => Ship {
            id,
            owner,
            name,
            rescue_gauntlet_id,
            faction: Faction::None,
            s_class: ship_class,
            location,
            hull_points: 1000,
            shield_points: 250,
            speed: 50,
            crew_size: 500,
            cargo_capacity: 1500,
            railguns: 6,
            torpedoes: 6,
            pdcs: 20,
            torpedo_ammo: 60,
            railgun_ammo: 50,
            pdc_ammo: 150000,       // 150k rounds - massive defensive screen
            fuel_capacity: 6000,
            current_fuel: 6000,
            reactor_fuel: 2000,
            power_output: 300,
        },
        
        ShipClass::Battleship => Ship {
            id,
            owner,
            name,
            rescue_gauntlet_id,
            faction: Faction::None,
            s_class: ship_class,
            location,
            hull_points: 1500,
            shield_points: 400,
            speed: 40,
            crew_size: 800,
            cargo_capacity: 800,
            railguns: 6,
            torpedoes: 30,
            pdcs: 30,
            torpedo_ammo: 120,
            railgun_ammo: 80,
            pdc_ammo: 200000,       // 200k rounds - impenetrable defensive wall
            fuel_capacity: 10000,
            current_fuel: 10000,
            reactor_fuel: 5000,
            power_output: 500,
        },
        
        ShipClass::None => Ship {
            id,
            owner,
            name,
            rescue_gauntlet_id,
            faction: Faction::None,
            s_class: ship_class,
            location,
            hull_points: 0,
            shield_points: 0,
            speed: 0,
            crew_size: 0,
            cargo_capacity: 0,
            railguns: 0,
            torpedoes: 0,
            pdcs: 0,
            torpedo_ammo: 0,
            railgun_ammo: 0,
            pdc_ammo: 0,
            fuel_capacity: 0,
            current_fuel: 0,
            reactor_fuel: 0,
            power_output: 0,
        },
    }
}
        
        // ============================================
        // Faction Modifiers
        // ============================================
        
        fn apply_faction_modifiers(ref ship: Ship, faction: Faction) {
            ship.faction = faction;
            
            match faction {
                Faction::UN => {
                    // UN: Better shields, more crew
                    ship.shield_points = (ship.shield_points * 120) / 100;
                    ship.crew_size = (ship.crew_size * 110) / 100;
                },
                
                Faction::MarsFederation => {
                    // Mars: Faster ships, efficient fuel
                    ship.speed = (ship.speed * 115) / 100;
                    ship.fuel_capacity = (ship.fuel_capacity * 120) / 100;
                    ship.current_fuel = (ship.current_fuel * 120) / 100;
                    ship.reactor_fuel = (ship.reactor_fuel * 120) / 100;
                },
                
                Faction::KuiperUnion => {
                    // Kuiper: Better hull, more cargo
                    ship.hull_points = (ship.hull_points * 120) / 100;
                    ship.cargo_capacity = (ship.cargo_capacity * 130) / 100;
                },
                
                Faction::Pirates => {
                    // Pirates: Faster, less crew, more ammo
                    ship.speed = (ship.speed * 125) / 100;
                    ship.crew_size = (ship.crew_size * 70) / 100;
                    ship.shield_points = (ship.shield_points * 80) / 100;
                    ship.railgun_ammo = (ship.railgun_ammo * 120) / 100;
                    ship.torpedo_ammo = (ship.torpedo_ammo * 120) / 100;
                },
                
                Faction::Independent => {
                    // Independent: Balanced, cargo/fuel bonus
                    ship.cargo_capacity = (ship.cargo_capacity * 110) / 100;
                    ship.fuel_capacity = (ship.fuel_capacity * 110) / 100;
                    ship.current_fuel = (ship.current_fuel * 110) / 100;
                },
                
                Faction::None => {},
            }
        }
        
        // ============================================
        // Threat Rating (for credit system)
        // ============================================
        
        fn get_threat_rating(ship_class: ShipClass) -> u32 {
            match ship_class {
                ShipClass::PirateSkiff => 5,
                ShipClass::Corvette => 10,
                ShipClass::Freighter => 12,
                ShipClass::Frigate => 20,
                ShipClass::Destroyer => 35,
                ShipClass::Cruiser => 50,
                ShipClass::Carrier => 60,
                ShipClass::Battleship => 100,
                ShipClass::None => 0,
            }
        }
    }
}