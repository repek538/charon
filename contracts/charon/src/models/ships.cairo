use starknet::ContractAddress;
use charon::models::zones::{ZoneType};

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Ship {
    #[key]
    pub id: ContractAddress,                     // Unique ship ID
    pub owner: ContractAddress,      // Player or faction holding it
    pub faction: Faction,            // Political allegiance
    pub s_class: ShipClass,            // Realistic naval s_class
    pub hull_points: u32,            // Structural integrity
    pub shield_points: u32,          // If using near-future shielding, else drop
    pub speed: u32,                  // Maneuverability (delta-v proxy)
    pub crew_size: u32,              // Linked to ShipsCrew model
    pub cargo_capacity: u32,         // For freighters/logistics
    pub location: Vec2,   // Coordinates in Sol system
    
    // Enhanced weapon systems
    pub railguns: u8,                // Kinetic energy weapons
    pub torpedoes: u8,               // Nuclear/antimatter warheads
    pub pdcs: u8,                    // Point Defense Cannons
    pub torpedo_ammo: u8,           // Current torpedo count
    pub railgun_ammo: u8,           // Railgun slugs/projectiles
    
    // Fuel and power systems
    pub fuel_capacity: u32,          // Maximum fuel (for thrusters)
    pub current_fuel: u32,           // Current fuel level
    pub reactor_fuel: u32,           // Nuclear reactor fuel (separate from thruster fuel)
    pub power_output: u32,           // MW output for weapons/systems
}


#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct ShipArmament {
    #[key]
    pub ship_id: ContractAddress,
    pub ship_class: ShipClass,
    
    // Weapon counts
    pub railgun_count: u8,
    pub torpedo_count: u8,
    pub pdc_count: u8,
    pub has_shield: bool,
    
    // Total armament characteristics
    pub total_power_requirement: u32, // MW needed for all weapons
    pub total_ammunition_storage: u32, // Combined ammo capacity
    pub armament_mass: u32,           // Affects ship maneuverability
    pub crew_required: u32,           // Crew needed to operate weapons
}

#[derive(Copy, Drop, Serde, IntrospectPacked, Debug, DojoStore)]
pub struct Vec2 {
    pub x: u32,
    pub y: u32,
}


#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Railgun {
    #[key]
    pub ship_id: ContractAddress,
    pub ship: ContractAddress,
    pub damage: u32,                 // 150-300 depending on s_class
    pub max_range: u32,              // 2000km
    pub optimal_range: u32,          // 800km
    pub rate_of_fire: u8,            // 1 shot per turn
    pub power_cost: u32,             // 50MW
    pub tracking_speed: u8,          // 20 (poor vs fast targets)
    pub ammunition: u32,             // Slug count
    pub barrel_wear: u8,             // 0-100 (affects accuracy)
    pub compatible_classes: u8,      // Bitfield: which ship classes can mount
    pub ship_class: ShipClass,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Torpedo {
    #[key]
    pub ship_id: ContractAddress,
    pub ship: ContractAddress,
    pub damage: u32,                 // 500-800 depending on warhead
    pub max_range: u32,              // 5000km (self-propelled)
    pub optimal_range: u32,          // 3000km
    pub rate_of_fire: u8,            // 1 per turn
    pub power_cost: u32,             // 10MW (just for launch)
    pub tracking_speed: u8,          // 80 (excellent guidance)
    pub ammunition: u32,             // Torpedo count
    pub fuel_per_torpedo: u8,        // Fuel cost for each launch
    pub compatible_classes: u8,      // Bitfield: Destroyer, Cruiser, Battleship
    pub ship_class: ShipClass,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct PDC {
    #[key]
    pub ship_id: ContractAddress,
    pub ship: ContractAddress,
    pub damage: u32,                 // 25-40 per burst
    pub max_range: u32,              // 100km
    pub optimal_range: u32,          // 50km
    pub rate_of_fire: u8,            // 8 shots per turn
    pub power_cost: u32,             // 5MW per burst
    pub tracking_speed: u8,          // 95 (excellent vs missiles/fighters)
    pub ammunition: u32,             // Rounds remaining
    pub heat_buildup: u8,            // 0-100 (overheating reduces rate)
    pub compatible_classes: u8,      // Bitfield: All classes can mount
    pub ship_class: ShipClass,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Shield {
    #[key]
    pub ship_id: ContractAddress,
    pub max_strength: u32,           // Maximum shield points
    pub current_strength: u32,       // Current shield level
    pub recharge_rate: u8,           // Points per turn regeneration
    pub power_cost: u32,             // MW to maintain shields
    pub coverage: u8,                // 0-100% coverage (directional weak spots)
    pub frequency: u8,               // Shield frequency (affects weapon effectiveness)
    pub generator_health: u8,        // 0-100 (damage reduces effectiveness)
    pub compatible_classes: u8,      // Bitfield: which classes can mount shields
    pub ship_class: ShipClass,
}


#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug, DojoStore, Default)]
pub enum ShipClass {
    #[default]
    None,
    Corvette,     // Fast attack / patrol - Light railguns, few PDCs
    Frigate,      // Escort, anti-fighter/missile defense - Heavy PDCs
    Destroyer,    // Heavy escort, fleet backbone - Balanced weapons
    Cruiser,      // Command & control, heavy weapons - Heavy railguns
    Battleship,   // Maximum firepower, rare - All weapon types
    Carrier,      // Drone / small craft carrier - Minimal weapons, heavy PDCs
    Freighter,    // Logistics / civilian converted ships - Light PDCs only
    PirateSkiff,  // Light pirate craft - Improvised weapons
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug, DojoStore, Default)]
pub enum Faction {
    #[default]
    None,
    Pirates,         // Independent raiders
    UN,              // Earth-based United Nations
    MarsFederation,  // Martian Congressional Republic  
    KuiperUnion,     // Outermost Belt/Kuiper colonies
    Independent,     // Neutral traders, mercenaries
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct MiniZoneShip {
    #[key]
    pub mini_zone_id: u8,     // Unique mini zone ID from our zone system
    pub ship: ContractAddress, // Ship address in this mini zone
    pub is_active: bool,       // Whether ship is currently active/spawned
}



#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Scanner {
    #[key]
    pub ship_id: ContractAddress,
    pub max_range: u32,              // Maximum detection range in km
    pub resolution: u32,             // Detail level of scans (affects identification)
    pub scan_time: u8,               // Turns needed for detailed scan
    pub power_cost: u32,             // MW for active scanning
    pub passive_range: u32,          // Passive detection range (no power)
    pub active_range: u32,           // Active scanning range (uses power)
    pub stealth_detection: u8,       // 0-100 ability to detect stealthed ships
    pub electronic_warfare: u8,      // 0-100 resistance to jamming
    pub target_lock_strength: u8,    // 0-100 for weapon guidance systems
    pub scan_signature: u8,          // 0-100 how detectable scanner emissions are
    pub compatible_classes: u8,      // Bitfield: which ship classes can mount
    pub ship_class: ShipClass,
    pub scanner_health: u8,          // 0-100 (damage reduces effectiveness)
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct ScanResult {
    #[key]
    pub scanning_ship_id: ContractAddress,
    #[key]
    pub target_ship_id: ContractAddress,
    pub detection_time: u32,         // Game turn when detected
    pub confidence: u8,              // 0-100 accuracy of scan data
    pub distance: u32,               // Range to target in km
    pub bearing: u32,                // 0-359 degrees
    pub velocity: u32,               // Target speed
    pub ship_class_known: bool,      // Whether ship s_class is identified
    pub faction_known: bool,         // Whether faction is identified
    pub armament_known: bool,        // Whether weapons are identified
    pub hull_status_known: bool,     // Whether damage state is known
    pub shield_status_known: bool,   // Whether shield state is known
    pub is_stealthed: bool,          // Whether target is using stealth
    pub last_updated: u32,           // Last turn this data was refreshed
}

#[generate_trait]
pub impl ShipImpl of ShipTrait {
    #[inline(always)]
    fn new(
        id: ContractAddress,
        owner: ContractAddress,
        faction: Faction,
        s_class: ShipClass,
        hull_points: u32,
        shield_points: u32,
        speed: u32,
        crew_size: u32,
        cargo_capacity: u32,
        location: Vec2,
        railguns: u8,
        torpedoes: u8,
        pdcs: u8,
        torpedo_ammo: u8,
        railgun_ammo: u8,
        fuel_capacity: u32,
        current_fuel: u32,
        reactor_fuel: u32,
        power_output: u32,
    ) -> Ship {
        Ship {
            id,
            owner,
            faction,
            s_class,
            hull_points,
            shield_points,
            speed,
            crew_size,
            cargo_capacity,
            location,
            railguns,
            torpedoes,
            pdcs,
            torpedo_ammo,
            railgun_ammo,
            fuel_capacity,
            current_fuel,
            reactor_fuel,
            power_output,
        }
    }

    #[inline(always)]
    fn get_total_combat_rating(self: Ship) -> u32 {
        let weapon_score = (self.railguns.into() * 50) + (self.torpedoes.into() * 100) + (self.pdcs.into() * 20);
        let hull_score = self.hull_points / 10;
        let shield_score = self.shield_points * 2;
        weapon_score + hull_score + shield_score
    }

    #[inline(always)]
    fn get_class_bonus(self: Ship) -> u32 {
        match self.s_class {
            ShipClass::Battleship => 100,
            ShipClass::Cruiser => 75,
            ShipClass::Destroyer => 50,
            ShipClass::Frigate => 35,
            ShipClass::Corvette => 20,
            ShipClass::Carrier => 60,
            ShipClass::Freighter => 5,
            ShipClass::PirateSkiff => 15,
            ShipClass::None => 0,
        }
    }

    #[inline(always)]
    fn has_advantage_over(self: Ship, target: Ship) -> bool {
        // Corvettes counter larger ships with speed
        if self.s_class == ShipClass::Corvette {
            if target.s_class == ShipClass::Battleship || target.s_class == ShipClass::Cruiser {
                return true;
            }
        }
        
        // Frigates counter corvettes and fighters
        if self.s_class == ShipClass::Frigate {
            if target.s_class == ShipClass::Corvette || target.s_class == ShipClass::PirateSkiff {
                return true;
            }
        }
        
        // Destroyers counter frigates and corvettes
        if self.s_class == ShipClass::Destroyer {
            if target.s_class == ShipClass::Frigate || target.s_class == ShipClass::Corvette {
                return true;
            }
        }
        
        // Cruisers counter destroyers
        if self.s_class == ShipClass::Cruiser && target.s_class == ShipClass::Destroyer {
            return true;
        }
        
        // Battleships counter everything except corvettes
        if self.s_class == ShipClass::Battleship {
            if target.s_class == ShipClass::Cruiser 
                || target.s_class == ShipClass::Destroyer 
                || target.s_class == ShipClass::Frigate 
                || target.s_class == ShipClass::Carrier {
                return true;
            }
        }
        
        // Carriers vulnerable to direct combat (except from corvettes)
        if target.s_class == ShipClass::Carrier && self.s_class != ShipClass::Corvette {
            return true;
        }
        
        false
    }

    #[inline(always)]
    fn can_engage_at_range(self: Ship) -> bool {
        self.torpedoes > 0 || (self.railguns > 0 && self.s_class != ShipClass::Corvette)
    }

    #[inline(always)]
    fn get_movement_range(self: Ship) -> u32 {
        let base_movement = match self.s_class {
            ShipClass::Corvette => self.speed / 2 + 3,
            ShipClass::Frigate => self.speed / 3 + 2,
            ShipClass::Destroyer => self.speed / 4 + 2,
            ShipClass::Cruiser => self.speed / 4 + 1,
            ShipClass::Battleship => self.speed / 5 + 1,
            ShipClass::Carrier => self.speed / 5,
            ShipClass::Freighter => self.speed / 6,
            ShipClass::PirateSkiff => self.speed / 2 + 4,
            ShipClass::None => 0,
        };
        
        // Fuel affects movement
        if self.current_fuel < self.fuel_capacity / 4 {
            base_movement / 2
        } else {
            base_movement
        }
    }

    #[inline(always)]
    fn is_capital_ship(self: Ship) -> bool {
        match self.s_class {
            ShipClass::Battleship | ShipClass::Cruiser | ShipClass::Carrier => true,
            _ => false
        }
    }

    #[inline(always)]
    fn can_provide_support(self: Ship) -> bool {
        if self.s_class == ShipClass::Cruiser || self.s_class == ShipClass::Carrier {
            return true;
        }
        
        if self.s_class == ShipClass::Destroyer && self.crew_size >= 200 {
            return true;
        }
        
        false
    }

    #[inline(always)]
    fn get_detection_signature(self: Ship) -> u8 {
        let base_signature = match self.s_class {
            ShipClass::PirateSkiff => 20,
            ShipClass::Corvette => 35,
            ShipClass::Frigate => 50,
            ShipClass::Destroyer => 70,
            ShipClass::Cruiser => 85,
            ShipClass::Battleship => 100,
            ShipClass::Carrier => 90,
            ShipClass::Freighter => 60,
            ShipClass::None => 0,
        };
        
        // Power output affects signature
        let power_modifier = self.power_output / 100;
        let result = base_signature + power_modifier.try_into().unwrap_or(0);
        if result > 100 { 100 } else { result }
    }

    #[inline(always)]
    fn calculate_fuel_consumption(self: Ship, distance: u32) -> u32 {
        let base_consumption = match self.s_class {
            ShipClass::Corvette => distance / 10,
            ShipClass::Frigate => distance / 8,
            ShipClass::Destroyer => distance / 6,
            ShipClass::Cruiser => distance / 4,
            ShipClass::Battleship => distance / 3,
            ShipClass::Carrier => distance / 4,
            ShipClass::Freighter => distance / 7,
            ShipClass::PirateSkiff => distance / 12,
            ShipClass::None => 0,
        };
        if base_consumption == 0 { 1 } else { base_consumption }
    }

        #[inline(always)]
    fn can_dock_with(self: Ship, target: Ship) -> bool {
        // Only small ships can dock with carriers
        if target.s_class == ShipClass::Carrier {
            if self.s_class == ShipClass::Corvette || self.s_class == ShipClass::PirateSkiff {
                return true;
            }
        }
        
        // Freighters can dock with capital ships for resupply
        if self.s_class == ShipClass::Freighter && target.is_capital_ship() {
            return true;
        }
        
        // Ships can dock with friendly freighters
        if target.s_class == ShipClass::Freighter && self.faction == target.faction {
            return true;
        }
        
        false
    }

    #[inline(always)]
    fn update_location(ref self: Ship, new_location: Vec2) {
        self.location = new_location;
    }

    #[inline(always)]
    fn update_fuel(ref self: Ship, fuel_consumed: u32) {
        if fuel_consumed <= self.current_fuel {
            self.current_fuel -= fuel_consumed;
        } else {
            self.current_fuel = 0;
        }
    }

    #[inline(always)]
    fn update_ammo(ref self: Ship, railgun_used: u8, torpedo_used: u8) {
        if railgun_used <= self.railgun_ammo {
            self.railgun_ammo -= railgun_used;
        } else {
            self.railgun_ammo = 0;
        }
        
        if torpedo_used <= self.torpedo_ammo {
            self.torpedo_ammo -= torpedo_used;
        } else {
            self.torpedo_ammo = 0;
        }
    }

    #[inline(always)]
    fn take_damage(ref self: Ship, damage: u32) {
        if self.shield_points > 0 {
            let shield_damage_u32 = if damage <= self.shield_points.into() { damage } else { self.shield_points.into() };
            let shield_damage: u32 = shield_damage_u32.try_into().unwrap_or(0);
            self.shield_points -= shield_damage;
            
            let remaining_damage = damage - shield_damage_u32;
            if remaining_damage > 0 && remaining_damage < self.hull_points {
                self.hull_points -= remaining_damage;
            } else if remaining_damage >= self.hull_points {
                self.hull_points = 0;
            }
        } else {
            if damage < self.hull_points {
                self.hull_points -= damage;
            } else {
                self.hull_points = 0;
            }
        }
    }

    #[inline(always)]
    fn is_destroyed(self: Ship) -> bool {
        self.hull_points == 0
    }

    #[inline(always)]
    fn needs_resupply(self: Ship) -> bool {
        self.current_fuel < self.fuel_capacity / 4 
        || self.torpedo_ammo < 2 
        || self.railgun_ammo < 100
    }

    #[inline(always)]
    fn get_power_usage(self: Ship) -> u32 {
        let weapon_power = (self.railguns.into() * 50) + (self.torpedoes.into() * 10) + (self.pdcs.into() * 5);
        let shield_power = if self.shield_points > 0 { 25 } else { 0 };
        let base_systems = 50; // Life support, navigation, etc.
        
        weapon_power + shield_power + base_systems
    }

    #[inline(always)]
    fn has_power_for_combat(self: Ship) -> bool {
        self.get_power_usage() <= self.power_output
    }
}

// Trait to help with mini zone ship operations
pub trait MiniZoneShipTrait {
    fn new(mini_zone_id: u8, ship: ContractAddress) -> MiniZoneShip;
    fn activate(ref self: MiniZoneShip);
    fn deactivate(ref self: MiniZoneShip);
}

pub impl MiniZoneShipImpl of MiniZoneShipTrait {
    fn new(mini_zone_id: u8, ship: ContractAddress) -> MiniZoneShip {
        MiniZoneShip {
            mini_zone_id,
            ship,
            is_active: true, // Ships start inactive until player enters zone
        }
    }
    
    fn activate(ref self: MiniZoneShip) {
        self.is_active = true;
    }
    
    fn deactivate(ref self: MiniZoneShip) {
        self.is_active = false;
    }
}