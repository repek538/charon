use starknet::ContractAddress;
use charon::models::ships::{ShipClass};

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Crew {
    #[key]
    pub ship: ContractAddress,   
    pub captain: ContractAddress,
    pub members: u8,             
    pub engineers: u8,            
    pub gunners: u8,              
    pub medics: u8,               
}



#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct ShipOberon {
    #[key]
    pub ship: ContractAddress,                 
    pub owner: ContractAddress,  
    pub name: felt252,          
    pub hull: u32,              
    pub shield: u32,             

    // Weapons loadout
    pub point_defense: u8,       // Number of PDCs (default = 2)
    pub torpedoes: u8,           // Current torpedo count (max 8)
    pub railgun: bool,           // Small railgun mounted? (true/false)

    // Crew & operations
    pub crew_capacity: u16,      // Max crew size
    pub fuel: u32,               // Fuel level for movement
    pub cargo: u32,              // Cargo capacity (for resources)

    pub location: Vec2,
    pub state: ShipState,
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug, DojoStore, Default)]
pub enum ShipState {
    #[default]
    Idle,
    Moving,
    InCombat,
    Contacted,
    InCommunication,
    Hailing,
    AwaitingResponse,
    Docked,
    Refueling,
    Loading,
    Damaged,
    Disabled,
}


#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct OberonScanner {
    #[key]
    pub ship: ContractAddress, 
    pub max_range: u32,              // Maximum detection range in km
    pub resolution: u16,             // Detail level of scans (affects identification)
    pub scan_time: u8,               // Turns needed for detailed scan
    pub power_cost: u16,             // MW for active scanning
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
pub struct OberonScanResult {
    #[key]
    pub ship: ContractAddress, 
    pub detection_time: u32,         // Game turn when detected
    pub confidence: u8,              // 0-100 accuracy of scan data
    pub distance: u32,               // Range to target in km
    pub bearing: u16,                // 0-359 degrees
    pub velocity: u16,               // Target speed
    pub ship_class_known: bool,      // Whether ship class is identified
    pub faction_known: bool,         // Whether faction is identified
    pub armament_known: bool,        // Whether weapons are identified
    pub hull_status_known: bool,     // Whether damage state is known
    pub shield_status_known: bool,   // Whether shield state is known
    pub is_stealthed: bool,          // Whether target is using stealth
    pub last_updated: u32,           // Last turn this data was refreshed
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct OberonRailgun {
    #[key]
    pub ship: ContractAddress, 
    pub damage: u16,                 // 150-300 depending on class
    pub max_range: u32,              // 2000km
    pub optimal_range: u32,          // 800km
    pub rate_of_fire: u8,            // 1 shot per turn
    pub power_cost: u16,             // 50MW
    pub tracking_speed: u8,          // 20 (poor vs fast targets)
    pub ammunition: u32,             // Slug count
    pub barrel_wear: u8,             // 0-100 (affects accuracy)
    pub compatible_classes: u8,      // Bitfield: which ship classes can mount
    pub ship_class: ShipClass,
}

#[derive(Copy, Drop, Serde, IntrospectPacked, Debug, DojoStore)]
pub struct Vec2 {
    pub x: u32,
    pub y: u32,
}


#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct OberonTorpedo {
    #[key]
    pub torpedo_id: u64,
    #[key]
    pub ship: ContractAddress, 
    pub damage: u16,                 // 500-800 depending on warhead
    pub max_range: u32,              // 5000km (self-propelled)
    pub optimal_range: u32,          // 3000km
    pub rate_of_fire: u8,            // 1 per turn
    pub power_cost: u16,             // 10MW (just for launch)
    pub tracking_speed: u8,          // 80 (excellent guidance)
    pub ammunition: u16,             // Torpedo count
    pub fuel_per_torpedo: u8,        // Fuel cost for each launch
    pub compatible_classes: u8,      // Bitfield: Destroyer, Cruiser, Battleship
    pub ship_class: ShipClass,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct OberonPDC {
    #[key]
    pub pdc_id: u64,
    #[key]
    pub ship: ContractAddress, 
    pub damage: u16,                 // 25-40 per burst
    pub max_range: u32,              // 100km
    pub optimal_range: u32,          // 50km
    pub rate_of_fire: u8,            // 8 shots per turn
    pub power_cost: u16,             // 5MW per burst
    pub tracking_speed: u8,          // 95 (excellent vs missiles/fighters)
    pub ammunition: u32,             // Rounds remaining
    pub heat_buildup: u8,            // 0-100 (overheating reduces rate)
    pub compatible_classes: u8,      // Bitfield: All classes can mount
    pub ship_class: ShipClass,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct OberonShield {
    #[key]
    pub ship_id: ContractAddress,
    pub max_strength: u16,           // Maximum shield points
    pub current_strength: u16,       // Current shield level
    pub recharge_rate: u8,           // Points per turn regeneration
    pub power_cost: u16,             // MW to maintain shields
    pub coverage: u8,                // 0-100% coverage (directional weak spots)
    pub frequency: u8,               // Shield frequency (affects weapon effectiveness)
    pub generator_health: u8,        // 0-100 (damage reduces effectiveness)
    pub compatible_classes: u8,      // Bitfield: which classes can mount shields
    pub ship_class: ShipClass,
}

#[generate_trait]
pub impl CrewImpl of CrewTrait {
    #[inline(always)]
    fn new(
        ship: ContractAddress,
        captain: ContractAddress,
        members: u8,
        engineers: u8,
        gunners: u8,
        medics: u8,
    ) -> Crew {
        Crew {
            ship,
            captain,
            members,
            engineers,
            gunners,
            medics,
        }
    }

    #[inline(always)]
    fn get_total_crew(self: Crew) -> u8 {
        let specialists = self.engineers + self.gunners + self.medics;
        self.members + specialists
    }

    #[inline(always)]
    fn get_crew_efficiency(self: Crew) -> u8 {
        let total_crew: u8 = self.get_total_crew();

        // Baseline efficiency (max crew = 8)
        let base_efficiency: u8 = if total_crew == 8 {
            100
        } else if total_crew == 7 {
            90
        } else if total_crew == 6 {
            80
        } else if total_crew == 5 {
            65
        } else if total_crew >= 3 {
            50
        } else if total_crew >= 1 {
            30
        } else {
            0
        };

        // Specialist bonus (engineers + gunners + medics)
        let specialists: u32 = (self.engineers + self.gunners + self.medics).into();
        let ratio: u32 = specialists * 100 / total_crew.into();
        let specialist_bonus: u8 = if ratio >= 50 {
            10
        } else {
            (ratio / 5).try_into().unwrap_or(0)
        };

        let final_efficiency: u16 = base_efficiency.into() + specialist_bonus.into();
        if final_efficiency > 100_u16 {
            100_u8
        } else {
            final_efficiency.try_into().unwrap_or(80_u8)
        }
    }


    #[inline(always)]
    fn can_operate_systems(self: Crew, required_crew: u8) -> bool {
        self.get_total_crew() >= required_crew
    }

    #[inline(always)]
    fn get_combat_effectiveness(self: Crew) -> u8 {
        let gunner_effectiveness = if self.gunners >= 4 {
            100
        } else {
            self.gunners.into() * 25
        };
        
        let crew_support = self.get_crew_efficiency() / 2;
        let total = gunner_effectiveness + crew_support;
        if total > 100 { 100 } else { total.try_into().unwrap_or(50) }
    }

    #[inline(always)]
    fn get_repair_capability(self: Crew) -> u8 {
        let engineer_capability = if self.engineers >= 3 {
            100
        } else {
            self.engineers.into() * 33
        };
        
        let crew_support = self.get_crew_efficiency() / 3;
        let total = engineer_capability + crew_support;
        if total > 100 { 100 } else { total.try_into().unwrap_or(30) }
    }

    #[inline(always)]
    fn get_medical_capability(self: Crew) -> u8 {
        if self.medics >= 2 {
            100
        } else if self.medics == 1 {
            75
        } else {
            25 // Basic first aid from general crew
        }
    }

    #[inline(always)]
    fn update_crew_count(ref self: Crew, new_members: u8, new_engineers: u8, new_gunners: u8, new_medics: u8) {
        self.members = new_members;
        self.engineers = new_engineers;
        self.gunners = new_gunners;
        self.medics = new_medics;
    }

    #[inline(always)]
    fn take_casualties(ref self: Crew, casualties: u8) {
        let total_crew = self.get_total_crew();
        if casualties >= total_crew {
            // Total crew loss
            self.members = 0;
            self.engineers = 0;
            self.gunners = 0;
            self.medics = 0;
        } else {
            // Proportional losses
            let survival_rate = (total_crew - casualties) * 100 / total_crew;
            
            self.members = (self.members.into() * survival_rate / 100).try_into().unwrap_or(0);
            self.engineers = (self.engineers.into() * survival_rate / 100).try_into().unwrap_or(0);
            self.gunners = (self.gunners.into() * survival_rate / 100).try_into().unwrap_or(0);
            self.medics = (self.medics.into() * survival_rate / 100).try_into().unwrap_or(0);
        }
    }

    #[inline(always)]
    fn is_skeleton_crew(self: Crew) -> bool {
        self.get_total_crew() < 8
    }
}


#[generate_trait]
pub impl ShipOberonImpl of ShipOberonTrait {
    #[inline(always)]
    fn new(
        ship: ContractAddress,
        owner: ContractAddress,
        name: felt252,
        hull: u32,
        shield: u32,
        point_defense: u8,
        torpedoes: u8,
        railgun: bool,
        crew_capacity: u16,
        fuel: u32,
        cargo: u32,
        location: Vec2,
    ) -> ShipOberon {

        ShipOberon {
            ship,
            owner,
            name,
            hull,
            shield,
            point_defense,
            torpedoes,
            railgun,
            crew_capacity,
            fuel,
            cargo,
            location,
            state: ShipState::Idle
        }
    }

    #[inline(always)]
    fn get_total_firepower(self: ShipOberon) -> u16 {
        let pdc_power = self.point_defense.into() * 30;
        let torpedo_power = self.torpedoes.into() * 100;
        let railgun_power = if self.railgun { 200 } else { 0 };
        
        pdc_power + torpedo_power + railgun_power
    }

    #[inline(always)]
    fn get_combat_rating(self: ShipOberon) -> u32 {
        let firepower = self.get_total_firepower().into();
        let defense = self.hull / 10 + self.shield.into() * 2;
        let mobility = if self.fuel > 1000 { 50 } else { self.fuel / 20 };
        
        firepower + defense + mobility
    }

    #[inline(always)]
    fn can_engage_target(self: ShipOberon, range: u32) -> bool {
        // Can engage if we have any weapons with sufficient range
        if self.railgun && range <= 2000 {
            return true;
        }
        
        if self.torpedoes > 0 && range <= 5000 {
            return true;
        }
        
        if self.point_defense > 0 && range <= 100 {
            return true;
        }
        
        false
    }

    #[inline(always)]
    fn get_optimal_engagement_range(self: ShipOberon) -> u32 {
        if self.torpedoes > 0 {
            3000 // Torpedo optimal range
        } else if self.railgun {
            800  // Railgun optimal range
        } else {
            50   // PDC optimal range
        }
    }

    #[inline(always)]
    fn calculate_fuel_consumption(self: ShipOberon, distance: u32) -> u32 {
        // Oberon-class is a light freighter, relatively efficient
        let base_consumption = distance / 15; // Better fuel efficiency than warships
        
        // Cargo affects fuel consumption
        let cargo_modifier = if self.cargo > 500 {
            base_consumption / 4 // Heavy cargo penalty
        } else {
            0
        };
        
        let total = base_consumption + cargo_modifier;
        if total == 0 { 1 } else { total }
    }

    #[inline(always)]
    fn needs_refuel(self: ShipOberon) -> bool {
        self.fuel < 500 // Emergency fuel level
    }

    #[inline(always)]
    fn needs_resupply(self: ShipOberon) -> bool {
        self.torpedoes < 2 || self.fuel < 500
    }

    #[inline(always)]
    fn can_carry_cargo(self: ShipOberon, additional_cargo: u32) -> bool {
        self.cargo + additional_cargo <= 1000 // Max cargo capacity
    }

    #[inline(always)]
    fn take_hull_damage(ref self: ShipOberon, damage: u32) {
        if damage >= self.hull {
            self.hull = 0;
        } else {
            self.hull -= damage;
        }
    }

    #[inline(always)]
    fn repair_hull(ref self: ShipOberon, repair_amount: u32) {
        let max_hull = 800; // Oberon max hull
        self.hull += repair_amount;
        if self.hull > max_hull {
            self.hull = max_hull;
        }
    }

    #[inline(always)]
    fn consume_fuel(ref self: ShipOberon, fuel_used: u32) {
        if fuel_used >= self.fuel {
            self.fuel = 0;
        } else {
            self.fuel -= fuel_used;
        }
    }

    #[inline(always)]
    fn refuel(ref self: ShipOberon, fuel_added: u32) {
        let max_fuel = 2000; // Oberon max fuel
        self.fuel += fuel_added;
        if self.fuel > max_fuel {
            self.fuel = max_fuel;
        }
    }

    #[inline(always)]
    fn fire_torpedo(ref self: ShipOberon) -> bool {
        if self.torpedoes > 0 {
            self.torpedoes -= 1;
            true
        } else {
            false
        }
    }

    #[inline(always)]
    fn reload_torpedoes(ref self: ShipOberon, torpedo_count: u8) {
        self.torpedoes += torpedo_count;
        if self.torpedoes > 8 { // Max torpedo capacity
            self.torpedoes = 8;
        }
    }

    #[inline(always)]
    fn is_destroyed(self: ShipOberon) -> bool {
        self.hull == 0
    }

    #[inline(always)]
    fn is_combat_effective(self: ShipOberon) -> bool {
        // Ship is combat effective if it has hull and weapons
        if self.hull == 0 {
            return false;
        }
        
        if self.torpedoes > 0 || self.railgun || self.point_defense > 0 {
            return true;
        }
        
        false
    }

    #[inline(always)]
    fn get_sensor_signature(self: ShipOberon) -> u8 {
        // Oberon is a civilian freighter, relatively low signature
        let base_signature = 45;
        
        // Cargo affects signature
        let cargo_modifier = if self.cargo > 500 { 15 } else { self.cargo / 33 };
        
        // Fuel affects signature
        let fuel_modifier = if self.fuel > 1500 { 10 } else { 0 };
        
        let total = base_signature + cargo_modifier + fuel_modifier;
        if total > 100 { 100 } else { total.try_into().unwrap_or(50) }
    }

    #[inline(always)]
    fn load_cargo(ref self: ShipOberon, cargo_amount: u32) {
        if self.can_carry_cargo(cargo_amount) {
            self.cargo += cargo_amount;
        }
    }

    #[inline(always)]
    fn unload_cargo(ref self: ShipOberon, cargo_amount: u32) {
        if cargo_amount >= self.cargo {
            self.cargo = 0;
        } else {
            self.cargo -= cargo_amount;
        }
    }
}


#[generate_trait]
pub impl OberonScannerImpl of OberonScannerTrait {
    #[inline(always)]
    fn new(
        ship: ContractAddress,
        max_range: u32,
        resolution: u16,
        scan_time: u8,
        power_cost: u16,
        passive_range: u32,
        active_range: u32,
        stealth_detection: u8,
        electronic_warfare: u8,
        target_lock_strength: u8,
        scan_signature: u8,
        compatible_classes: u8,
        ship_class: ShipClass,
        scanner_health: u8,
    ) -> OberonScanner {
        OberonScanner {
            ship,
            max_range,
            resolution,
            scan_time,
            power_cost,
            passive_range,
            active_range,
            stealth_detection,
            electronic_warfare,
            target_lock_strength,
            scan_signature,
            compatible_classes,
            ship_class,
            scanner_health,
        }
    }

    #[inline(always)]
    fn get_effective_range(self: OberonScanner, active_scan: bool) -> u32 {
        let base_range = if active_scan { self.active_range } else { self.passive_range };
        
        // Health affects range
        let health_modifier = self.scanner_health;
        (base_range.into() * health_modifier.into() / 100)
    }

    #[inline(always)]
    fn can_detect_at_range(self: OberonScanner, range: u32, target_signature: u8, active_scan: bool) -> bool {
        let effective_range = self.get_effective_range(active_scan);
        
        if range > effective_range {
            return false;
        }
        
        // Detection chance based on target signature and scanner quality
        let detection_threshold = if active_scan {
            30 // Easier with active scanning
        } else {
            60 // Harder with passive
        };
        
        target_signature >= detection_threshold
    }

    #[inline(always)]
    fn calculate_scan_time(self: OberonScanner, range: u32, target_signature: u8) -> u8 {
        let base_time = self.scan_time;
        
        // Range affects scan time
        let range_modifier = if range > self.max_range / 2 {
            base_time / 2
        } else {
            0
        };
        
        // Target signature affects scan time
        let signature_modifier = if target_signature < 30 {
            base_time / 2 // Harder to scan stealthed targets
        } else {
            0
        };
        
        base_time + range_modifier + signature_modifier
    }

    #[inline(always)]
    fn can_penetrate_stealth(self: OberonScanner, target_stealth: u8) -> bool {
        self.stealth_detection >= target_stealth
    }

    #[inline(always)]
    fn resist_jamming(self: OberonScanner, jamming_strength: u8) -> bool {
        self.electronic_warfare >= jamming_strength
    }

    #[inline(always)]
    fn get_target_lock_quality(self: OberonScanner, range: u32) -> u8 {
        let base_lock = self.target_lock_strength;
        
        // Range affects lock quality
        let range_penalty = if range > self.max_range / 2 {
            20
        } else {
            range * 20 / (self.max_range / 2)
        };
        
        if base_lock >= range_penalty.try_into().unwrap_or(0) {
            base_lock - range_penalty.try_into().unwrap_or(0)
        } else {
            0
        }
    }

    #[inline(always)]
    fn take_damage(ref self: OberonScanner, damage: u8) {
        if damage >= self.scanner_health {
            self.scanner_health = 0;
        } else {
            self.scanner_health -= damage;
        }
    }

    #[inline(always)]
    fn repair_scanner(ref self: OberonScanner, repair_amount: u8) {
        self.scanner_health += repair_amount;
        if self.scanner_health > 100 {
            self.scanner_health = 100;
        }
    }

    #[inline(always)]
    fn is_operational(self: OberonScanner) -> bool {
        self.scanner_health > 25 // Needs at least 25% health to function
    }

    #[inline(always)]
    fn get_power_requirement(self: OberonScanner, active_scan: bool) -> u16 {
        if active_scan {
            self.power_cost
        } else {
            self.power_cost / 4 // Passive scanning uses less power
        }
    }
}

#[generate_trait]
pub impl OberonRailgunImpl of OberonRailgunTrait {
    #[inline(always)]
    fn new(
        ship: ContractAddress,
        damage: u16,
        max_range: u32,
        optimal_range: u32,
        rate_of_fire: u8,
        power_cost: u16,
        tracking_speed: u8,
        ammunition: u32,
        barrel_wear: u8,
        compatible_classes: u8,
        ship_class: ShipClass,
    ) -> OberonRailgun {
        OberonRailgun {
            ship,
            damage,
            max_range,
            optimal_range,
            rate_of_fire,
            power_cost,
            tracking_speed,
            ammunition,
            barrel_wear,
            compatible_classes,
            ship_class,
        }
    }

    #[inline(always)]
    fn calculate_damage_at_range(self: OberonRailgun, range: u32) -> u16 {
        if range > self.max_range {
            return 0;
        }
        
        let damage_modifier = if range <= self.optimal_range {
            100 // Full damage at optimal range
        } else {
            // Damage drops off beyond optimal range
            let range_penalty = (range - self.optimal_range) * 50 / (self.max_range - self.optimal_range);
            let capped_penalty = if range_penalty > 50 { 50 } else { range_penalty };
            100 - capped_penalty // Max 50% damage loss
        };
        
        // Barrel wear affects damage
        let wear_penalty = (100 - self.barrel_wear.into()) * self.damage.into() / 100;
        let base_damage = wear_penalty * damage_modifier / 100;
        
        base_damage.try_into().unwrap_or(0)
    }

    #[inline(always)]
    fn can_hit_target(self: OberonRailgun, target_speed: u8, range: u32) -> bool {
        // Tracking ability vs target speed and range
        let range_penalty = if range > self.optimal_range {
            (range - self.optimal_range) * 30 / (self.max_range - self.optimal_range)
        } else {
            0
        };
        
        let effective_tracking = if self.tracking_speed.into() >= range_penalty {
            self.tracking_speed.into() - range_penalty
        } else {
            0
        };
        
        target_speed.into() <= effective_tracking
    }

    #[inline(always)]
    fn fire_shot(ref self: OberonRailgun) -> bool {
        if self.ammunition > 0 && self.barrel_wear < 95 {
            self.ammunition -= 1;
            self.barrel_wear += 1; // Each shot adds wear
            true
        } else {
            false
        }
    }

    #[inline(always)]
    fn reload_ammunition(ref self: OberonRailgun, ammo_count: u32) {
        self.ammunition += ammo_count;
        if self.ammunition > 1000 { // Max ammo capacity
            self.ammunition = 1000;
        }
    }

    #[inline(always)]
    fn repair_barrel(ref self: OberonRailgun, repair_amount: u8) {
        if self.barrel_wear >= repair_amount {
            self.barrel_wear -= repair_amount;
        } else {
            self.barrel_wear = 0;
        }
    }

    #[inline(always)]
    fn get_accuracy(self: OberonRailgun, range: u32) -> u8 {
        let base_accuracy = 80;
        
        // Range affects accuracy
        let range_penalty = if range > self.optimal_range {
            (range - self.optimal_range) * 30 / (self.max_range - self.optimal_range)
        } else {
            0
        };
        
        // Barrel wear affects accuracy
        let wear_penalty = self.barrel_wear.into() / 2;
        
        let total_penalty = range_penalty + wear_penalty;
        if base_accuracy >= total_penalty {
            (base_accuracy - total_penalty).try_into().unwrap_or(30)
        } else {
            30 // Minimum accuracy
        }
    }

    #[inline(always)]
    fn is_operational(self: OberonRailgun) -> bool {
        self.ammunition > 0 && self.barrel_wear < 95
    }

    #[inline(always)]
    fn needs_maintenance(self: OberonRailgun) -> bool {
        self.barrel_wear > 70 || self.ammunition < 50
    }
}

#[generate_trait]
pub impl OberonTorpedoImpl of OberonTorpedoTrait {
    #[inline(always)]
    fn new(
        torpedo_id: u64,
        ship: ContractAddress,
        damage: u16,
        max_range: u32,
        optimal_range: u32,
        rate_of_fire: u8,
        power_cost: u16,
        tracking_speed: u8,
        ammunition: u16,
        fuel_per_torpedo: u8,
        compatible_classes: u8,
        ship_class: ShipClass,
    ) -> OberonTorpedo {
        OberonTorpedo {
            torpedo_id,
            ship,
            damage,
            max_range,
            optimal_range,
            rate_of_fire,
            power_cost,
            tracking_speed,
            ammunition,
            fuel_per_torpedo,
            compatible_classes,
            ship_class,
        }
    }

    #[inline(always)]
    fn calculate_hit_chance(self: OberonTorpedo, target_speed: u8, range: u32, target_pdc_count: u8) -> u8 {
        let base_hit_chance = 85; // Torpedoes are very accurate
        
        // Range affects hit chance slightly (they're self-guided)
        let range_penalty = if range > self.optimal_range {
            (range - self.optimal_range) * 10 / (self.max_range - self.optimal_range)
        } else {
            0
        };
        
        // Target speed affects hit chance
        let speed_penalty = if target_speed > self.tracking_speed {
            (target_speed - self.tracking_speed).into() * 2
        } else {
            0
        };
        
        // PDCs can intercept torpedoes
        let pdc_penalty = target_pdc_count.into() * 15; // Each PDC reduces hit chance
        
        let total_penalty = range_penalty + speed_penalty + pdc_penalty;
        if base_hit_chance >= total_penalty {
            (base_hit_chance - total_penalty).try_into().unwrap_or(20)
        } else {
            20 // Minimum hit chance
        }
    }

    #[inline(always)]
    fn launch_torpedo(ref self: OberonTorpedo) -> bool {
        if self.ammunition > 0 {
            self.ammunition -= 1;
            true
        } else {
            false
        }
    }

    #[inline(always)]
    fn reload_torpedoes(ref self: OberonTorpedo, torpedo_count: u16) {
        self.ammunition += torpedo_count;
        if self.ammunition > 8 { // Max torpedo capacity for Oberon
            self.ammunition = 8;
        }
    }

    #[inline(always)]
    fn get_fuel_cost(self: OberonTorpedo) -> u8 {
        self.fuel_per_torpedo
    }

    #[inline(always)]
    fn is_effective_at_range(self: OberonTorpedo, range: u32) -> bool {
        range <= self.max_range
    }

    #[inline(always)]
    fn get_damage_at_range(self: OberonTorpedo, range: u32) -> u16 {
        if range > self.max_range {
            0
        } else {
            self.damage // Torpedoes maintain full damage at all ranges
        }
    }

    #[inline(always)]
    fn has_ammunition(self: OberonTorpedo) -> bool {
        self.ammunition > 0
    }
}

#[generate_trait]
pub impl OberonPDCImpl of OberonPDCTrait {
    #[inline(always)]
    fn new(
        pdc_id: u64,
        ship: ContractAddress,
        damage: u16,
        max_range: u32,
        optimal_range: u32,
        rate_of_fire: u8,
        power_cost: u16,
        tracking_speed: u8,
        ammunition: u32,
        heat_buildup: u8,
        compatible_classes: u8,
        ship_class: ShipClass,
    ) -> OberonPDC {
        OberonPDC {
            pdc_id,
            ship,
            damage,
            max_range,
            optimal_range,
            rate_of_fire,
            power_cost,
            tracking_speed,
            ammunition,
            heat_buildup,
            compatible_classes,
            ship_class,
        }
    }

    #[inline(always)]
    fn calculate_burst_damage(self: OberonPDC, range: u32) -> u16 {
        if range > self.max_range {
            return 0;
        }
        
        // PDCs are most effective at close range
        let range_modifier = if range <= self.optimal_range {
            100
        } else {
            // Rapid damage drop-off beyond optimal range
            let penalty = (range - self.optimal_range) * 70 / (self.max_range - self.optimal_range);
            let capped_penalty = if penalty > 70 { 70 } else { penalty };
            100 - capped_penalty
        };
        
        // Heat buildup reduces effectiveness
        let heat_penalty = self.heat_buildup.into() / 2;
        let effective_modifier = if range_modifier >= heat_penalty {
            range_modifier - heat_penalty
        } else {
            30 // Minimum effectiveness
        };
        
        (self.damage.into() * effective_modifier / 100).try_into().unwrap_or(0)
    }

    #[inline(always)]
    fn can_intercept_missile(self: OberonPDC, missile_speed: u8, range: u32) -> bool {
        // PDCs excel at intercepting fast-moving targets
        if range > self.max_range {
            return false;
        }
        
        // Heat buildup affects tracking
        let effective_tracking = if self.tracking_speed >= self.heat_buildup / 2 {
            self.tracking_speed - self.heat_buildup / 2
        } else {
            50 // Minimum tracking ability
        };
        
        missile_speed <= effective_tracking
    }

    #[inline(always)]
    fn fire_burst(ref self: OberonPDC) -> bool {
        let shots_per_burst = self.rate_of_fire;
        
        if self.ammunition >= shots_per_burst.into() && self.heat_buildup < 90 {
            self.ammunition -= shots_per_burst.into();
            self.heat_buildup += 10; // Each burst adds heat
            if self.heat_buildup > 100 {
                self.heat_buildup = 100;
            }
            true
        } else {
            false
        }
    }

    #[inline(always)]
    fn cool_down(ref self: OberonPDC, cooling_amount: u8) {
        if self.heat_buildup >= cooling_amount {
            self.heat_buildup -= cooling_amount;
        } else {
            self.heat_buildup = 0;
        }
    }

    #[inline(always)]
    fn reload_ammunition(ref self: OberonPDC, ammo_count: u32) {
        self.ammunition += ammo_count;
        if self.ammunition > 5000 { // Max ammo capacity
            self.ammunition = 5000;
        }
    }

    #[inline(always)]
    fn is_overheated(self: OberonPDC) -> bool {
        self.heat_buildup >= 90
    }

    #[inline(always)]
    fn is_operational(self: OberonPDC) -> bool {
        self.ammunition > 0 && self.heat_buildup < 95
    }

    #[inline(always)]
    fn get_effective_rate_of_fire(self: OberonPDC) -> u8 {
        if self.heat_buildup < 50 {
            self.rate_of_fire
        } else if self.heat_buildup < 80 {
            self.rate_of_fire * 75 / 100
        } else {
            self.rate_of_fire * 50 / 100
        }
    }

    #[inline(always)]
    fn needs_cooling(self: OberonPDC) -> bool {
        self.heat_buildup > 60
    }
}

#[generate_trait]
pub impl OberonShieldImpl of OberonShieldTrait {
    #[inline(always)]
    fn new(
        ship_id: ContractAddress,
        max_strength: u16,
        current_strength: u16,
        recharge_rate: u8,
        power_cost: u16,
        coverage: u8,
        frequency: u8,
        generator_health: u8,
        compatible_classes: u8,
        ship_class: ShipClass,
    ) -> OberonShield {
        OberonShield {
            ship_id,
            max_strength,
            current_strength,
            recharge_rate,
            power_cost,
            coverage,
            frequency,
            generator_health,
            compatible_classes,
            ship_class,
        }
    }

    #[inline(always)]
    fn absorb_damage(ref self: OberonShield, incoming_damage: u16) -> u16 {
        if self.current_strength == 0 || self.generator_health < 25 {
            return incoming_damage; // Shield offline, no protection
        }
        
    // Coverage affects how much damage the shield can absorb
    let coverage_modifier = self.coverage;
    let absorbable_damage = incoming_damage * coverage_modifier.into() / 100;
    let absorbed = if absorbable_damage > self.current_strength { 
        self.current_strength
    } else { 
        absorbable_damage 
    };
    
    self.current_strength -= absorbed;
    
    // Return damage that got through
    incoming_damage - absorbed
}

    #[inline(always)]
    fn recharge_shields(ref self: OberonShield) {
        if self.generator_health < 25 {
            return; // Can't recharge with damaged generator
        }
        
        let effective_recharge: u16 = self.recharge_rate.into() * self.generator_health.into() / 100;
        self.current_strength += effective_recharge;
        
        if self.current_strength > self.max_strength {
            self.current_strength = self.max_strength;
        }
    }

    #[inline(always)]
    fn get_shield_percentage(self: OberonShield) -> u16 {
        if self.max_strength == 0 {
            return 0;
        }
        
        self.current_strength * 100 / self.max_strength
    }

    #[inline(always)]
    fn is_shields_up(self: OberonShield) -> bool {
        self.current_strength > 0 && self.generator_health >= 25
    }

    #[inline(always)]
    fn get_frequency_effectiveness(self: OberonShield, weapon_frequency: u8) -> u8 {
        // Shield frequency vs weapon frequency affects damage absorption
        let frequency_diff = if self.frequency >= weapon_frequency {
            self.frequency - weapon_frequency
        } else {
            weapon_frequency - self.frequency
        };
        
        if frequency_diff < 10 {
            100 // Perfect frequency match, full effectiveness
        } else if frequency_diff < 30 {
            75  // Good match
        } else if frequency_diff < 50 {
            50  // Poor match
        } else {
            25  // Very poor match
        }
    }

    #[inline(always)]
    fn modulate_frequency(ref self: OberonShield, new_frequency: u8) {
        if self.generator_health >= 50 {
            self.frequency = new_frequency;
        }
    }

    #[inline(always)]
    fn take_generator_damage(ref self: OberonShield, damage: u8) {
        if damage >= self.generator_health {
            self.generator_health = 0;
            self.current_strength = 0; // Generator destroyed, shields collapse
        } else {
            self.generator_health -= damage;
            
            // Damaged generator reduces shield capacity
            let effective_max: u16 = self.max_strength.into() * self.generator_health.into() / 100;
            if self.current_strength.into() > effective_max {
                self.current_strength = effective_max.try_into().unwrap_or(0);
            }
        }
    }

    #[inline(always)]
    fn repair_generator(ref self: OberonShield, repair_amount: u8) {
        self.generator_health += repair_amount;
        if self.generator_health > 100 {
            self.generator_health = 100;
        }
    }

    #[inline(always)]
    fn get_power_requirement(self: OberonShield) -> u16 {
        if self.current_strength == 0 {
            0 // No power needed for offline shields
        } else {
            // Power requirement scales with shield strength and health
            let base_power = self.power_cost;
            let efficiency_modifier = self.generator_health.into() * 100 / 100;
            base_power.into() * efficiency_modifier / 100
        }
    }

    #[inline(always)]
    fn emergency_shutdown(ref self: OberonShield) {
        self.current_strength = 0;
    }

    #[inline(always)]
    fn restart_shields(ref self: OberonShield) {
        if self.generator_health >= 25 {
            // Restart with minimal power
            let startup_strength = self.max_strength / 10;
            self.current_strength = startup_strength;
        }
    }

    #[inline(always)]
    fn needs_repair(self: OberonShield) -> bool {
        self.generator_health < 75 || self.current_strength < self.max_strength / 4
    }

    #[inline(always)]
    fn is_generator_destroyed(self: OberonShield) -> bool {
        self.generator_health == 0
    }

    #[inline(always)]
    fn get_coverage_percentage(self: OberonShield) -> u8 {
        if self.generator_health < 25 {
            0
        } else {
            self.coverage * self.generator_health / 100
        }
    }
}