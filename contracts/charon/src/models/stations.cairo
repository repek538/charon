use starknet::ContractAddress;
use charon::models::ships::{ShipClass};

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Station {
    #[key]
    pub id: u64,                  // Unique station ID
    pub name: felt252,            // Station name
    pub station_type: StationType,// Category (shipyard, trade, defense, etc.)
    pub owner: ContractAddress, // Who controls it (None = neutral)
    pub defense_level: u16,       // Station defenses
    pub capacity: u32,            // Docking / cargo capacity
    pub crew: u32, 
    pub hull: u32,
    pub shield: u32,
    pub x: u32,                   // Coordinates
    pub y: u32,
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug, DojoStore, Default)]
pub enum StationType {
    #[default]
    None,
    Shipyard,     // Build/repair ships
    TradeHub,     // Marketplace for goods
    MiningOutpost,// Refines asteroid/planet resources
    ResearchLab,  // Tech upgrades
    MilitaryBase, // Strong defenses, fleet staging
    SmugglerDen,  // Black market, illegal goods
    RelayStation, // Communication, navigation boost
    Habitat,      // Civilian hub, population center
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct StationScanner {
    #[key]
    pub station_id: u64,
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
    pub station_type: StationType,
    pub scanner_health: u8,          // 0-100 (damage reduces effectiveness)
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug, DojoStore, Default)]
pub enum ScanMode {
    #[default]
    Passive,              // Low power, limited range
    Active,               // High power, full range
    DeepScan,            // Detailed analysis, takes time
    WideScan,            // Sweep large area, less detail
    TargetedScan,        // Focus on single target
    Stealth,             // Reduced signature, reduced range
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug, DojoStore, Default)]
pub enum ScanResult {
    #[default]
    NoContact,           // Nothing detected
    ContactDetected,     // Something is there
    ShipIdentified,      // Ship type known
    ShipFullyScanned,    // Complete ship data
    StealthShipDetected, // Stealth ship found
    JammedSignal,        // Scan blocked/jammed
    MultipleContacts,    // Multiple targets
    AnomalyDetected,     // Unknown signature
}

#[derive(Copy, Drop, Serde, Debug)]
pub struct ScanData {
    #[key]
    pub station_id: u64,
    pub target_id: ContractAddress,
    pub distance: u32,
    pub signature_strength: u8,    // 0-100 how clear the reading is
    pub ship_class: ShipClass,       // May be unknown if poor scan
    pub hull_integrity: u8,        // 0-100 estimated condition
    pub shield_status: u8,         // 0-100 shield strength
    pub cargo_mass: u32,           // Detected cargo weight
    pub weapon_systems: u8,        // 0-100 threat level
    pub stealth_active: bool,
    pub jamming_active: bool,
    pub scan_quality: u8,          // 0-100 confidence in data
    pub scan_timestamp: u64,
}


#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct MiniZoneStation {
    #[key]
    pub mini_zone_id: u8,     // Unique mini zone ID from our zone system
    pub station: u64, // Ship address in this mini zone
    pub is_active: bool,       // Whether ship is currently active/spawned
}


#[generate_trait]
pub impl StationImpl of StationTrait {
    // Constructor function
    fn new(
        id: u64,
        name: felt252,
        station_type: StationType,
        owner: ContractAddress,
        x: u32,
        y: u32,
        hull: u32,
        shield: u32,
    ) -> Station {
        Station {
            id,
            name,
            station_type,
            owner,
            defense_level: Self::get_base_defense_level(station_type),
            capacity: Self::get_base_capacity(station_type),
            crew: Self::get_base_crew(station_type),
            hull,
            shield,
            x,
            y,
        }
    }

    // Get base defense level based on station type
    fn get_base_defense_level(station_type: StationType) -> u16 {
        match station_type {
            StationType::MilitaryBase => 100,
            StationType::ResearchLab => 60,
            StationType::Shipyard => 50,
            StationType::TradeHub => 40,
            StationType::Habitat => 30,
            StationType::MiningOutpost => 25,
            StationType::RelayStation => 20,
            StationType::SmugglerDen => 15,
            StationType::None => 0,
        }
    }

    // Get base capacity based on station type
    fn get_base_capacity(station_type: StationType) -> u32 {
        match station_type {
            StationType::TradeHub => 10000,
            StationType::Habitat => 8000,
            StationType::Shipyard => 5000,
            StationType::MiningOutpost => 4000,
            StationType::MilitaryBase => 3000,
            StationType::ResearchLab => 2000,
            StationType::SmugglerDen => 1500,
            StationType::RelayStation => 1000,
            StationType::None => 0,
        }
    }

    // Get base crew based on station type
    fn get_base_crew(station_type: StationType) -> u32 {
        match station_type {
            StationType::Habitat => 5000,
            StationType::MilitaryBase => 2000,
            StationType::TradeHub => 1500,
            StationType::Shipyard => 1000,
            StationType::ResearchLab => 800,
            StationType::MiningOutpost => 500,
            StationType::RelayStation => 200,
            StationType::SmugglerDen => 100,
            StationType::None => 0,
        }
    }

    // // Check if station is neutral (no owner)
    // fn is_neutral(self: Station) -> bool {
    //     self.owner.is_zero()
    // }

    // Check if station is owned by specific address
    fn is_owned_by(self: Station, address: ContractAddress) -> bool {
        self.owner == address
    }

    // Upgrade defense level
    fn upgrade_defense(ref self: Station, amount: u16) {
        self.defense_level += amount;
    }

    // Upgrade capacity
    fn upgrade_capacity(ref self: Station, amount: u32) {
        self.capacity += amount;
    }

    // Add crew to station
    fn add_crew(ref self: Station, amount: u32) {
        self.crew += amount;
    }

    // Remove crew from station (with minimum check)
    fn remove_crew(ref self: Station, amount: u32) {
        let min_crew = Self::get_min_crew(self.station_type);
        if self.crew > amount + min_crew {
            self.crew -= amount;
        } else {
            self.crew = min_crew;
        }
    }

    // Get minimum crew required for station type
    fn get_min_crew(station_type: StationType) -> u32 {
        match station_type {
            StationType::Habitat => 1000,
            StationType::MilitaryBase => 500,
            StationType::TradeHub => 300,
            StationType::Shipyard => 200,
            StationType::ResearchLab => 150,
            StationType::MiningOutpost => 100,
            StationType::RelayStation => 50,
            StationType::SmugglerDen => 25,
            StationType::None => 0,
        }
    }

    // Calculate distance to another station
    fn distance_to(self: Station, other: Station) -> u64 {
        let dx = if self.x > other.x { self.x - other.x } else { other.x - self.x };
        let dy = if self.y > other.y { self.y - other.y } else { other.y - self.y };
        
        // Simple Manhattan distance for now
        (dx + dy).into()
    }

    // Check if station can dock a ship based on capacity
    fn can_dock(self: Station, ship_size: u32) -> bool {
        ship_size <= self.capacity
    }

    // Transfer ownership
    fn transfer_ownership(ref self: Station, new_owner: ContractAddress) {
        self.owner = new_owner;
    }

    // Set as neutral (remove owner)
    fn set_neutral(ref self: Station) {
        self.owner = starknet::contract_address_const::<0>();
    }

    // Get station's combat effectiveness
    fn combat_effectiveness(self: Station) -> u32 {
        (self.defense_level.into() * self.crew) / 100
    }

    // Check if station has specific functionality based on type
    fn has_shipyard(self: Station) -> bool {
        self.station_type == StationType::Shipyard
    }

    fn has_trade_hub(self: Station) -> bool {
        self.station_type == StationType::TradeHub
    }

    fn has_mining(self: Station) -> bool {
        self.station_type == StationType::MiningOutpost
    }

    fn has_research(self: Station) -> bool {
        self.station_type == StationType::ResearchLab
    }

    fn has_military(self: Station) -> bool {
        self.station_type == StationType::MilitaryBase
    }


}

// Trait to help with mini zone ship operations
pub trait MiniZoneStationTrait {
    fn new(mini_zone_id: u8, station: u64) -> MiniZoneStation;
    fn activate(ref self: MiniZoneStation);
    fn deactivate(ref self: MiniZoneStation);
}

pub impl MiniZoneStationImpl of MiniZoneStationTrait {
    fn new(mini_zone_id: u8, station: u64) -> MiniZoneStation {
        MiniZoneStation {
            mini_zone_id,
            station,
            is_active: true, // Ships start inactive until player enters zone
        }
    }
    
    fn activate(ref self: MiniZoneStation) {
        self.is_active = true;
    }
    
    fn deactivate(ref self: MiniZoneStation) {
        self.is_active = false;
    }
}

#[generate_trait]
pub impl StationScannerImpl of StationScannerTrait {
    #[inline(always)]
    fn new(
        station_id: u64,
        station_type: StationType,
    ) -> StationScanner {
        let (max_range, resolution, stealth_detection, electronic_warfare, target_lock) = 
            Self::get_base_stats_for_type(station_type);
        
        StationScanner {
            station_id,
            max_range,
            resolution,
            scan_time: 3,
            power_cost: max_range / 10,
            passive_range: max_range / 3,
            active_range: max_range,
            stealth_detection,
            electronic_warfare,
            target_lock_strength: target_lock,
            scan_signature: 50,
            station_type,
            scanner_health: 100,
        }
    }

    #[inline(always)]
    fn get_base_stats_for_type(station_type: StationType) -> (u32, u32, u8, u8, u8) {
        // Returns: (max_range, resolution, stealth_detection, electronic_warfare, target_lock)
        match station_type {
            StationType::MilitaryBase => (50000, 80, 70, 80, 90),
            StationType::RelayStation => (60000, 70, 40, 60, 50),
            StationType::TradeHub => (30000, 50, 30, 40, 30),
            StationType::Shipyard => (35000, 60, 40, 50, 60),
            StationType::ResearchLab => (40000, 90, 80, 70, 40),
            StationType::MiningOutpost => (25000, 40, 20, 30, 20),
            StationType::SmugglerDen => (35000, 60, 60, 50, 40),
            StationType::Habitat => (20000, 30, 10, 20, 10),
            StationType::None => (15000, 20, 10, 10, 10),
        }
    }

    #[inline(always)]
    fn get_effective_range(self: StationScanner, mode: ScanMode) -> u32 {
        let health_multiplier = self.scanner_health.into();
        
        let base_range = match mode {
            ScanMode::Passive => self.passive_range,
            ScanMode::Active => self.active_range,
            ScanMode::DeepScan => self.active_range / 2,
            ScanMode::WideScan => self.active_range,
            ScanMode::TargetedScan => self.active_range + (self.active_range / 4),
            ScanMode::Stealth => self.passive_range / 2,
        };
        
        (base_range * health_multiplier) / 100
    }

    #[inline(always)]
    fn get_power_cost(self: StationScanner, mode: ScanMode) -> u32 {
        match mode {
            ScanMode::Passive => 0,
            ScanMode::Active => self.power_cost,
            ScanMode::DeepScan => self.power_cost * 2,
            ScanMode::WideScan => self.power_cost * 3,
            ScanMode::TargetedScan => self.power_cost / 2,
            ScanMode::Stealth => self.power_cost / 4,
        }
    }

    #[inline(always)]
    fn can_detect_at_range(
        self: StationScanner, 
        distance: u32, 
        mode: ScanMode
    ) -> bool {
        let effective_range = self.get_effective_range(mode);
        distance <= effective_range && self.scanner_health > 0
    }

    #[inline(always)]
    fn calculate_signature_strength(
        self: StationScanner,
        distance: u32,
        target_stealth: u8,
        target_jamming: u8,
        mode: ScanMode,
    ) -> u8 {
        if self.scanner_health == 0 {
            return 0;
        }

        let effective_range = self.get_effective_range(mode);
        if distance > effective_range {
            return 0;
        }

        // Base strength from distance (closer = stronger)
        let distance_factor: u32 = if effective_range > 0 {
            100 - ((distance * 100) / effective_range)
        } else {
            0
        };

        // Resolution bonus for active scans
        let resolution_bonus: u32 = match mode {
            ScanMode::Active => self.resolution.into(),
            ScanMode::DeepScan => (self.resolution * 2).into(),
            ScanMode::TargetedScan => (self.resolution * 3 / 2).into(),
            ScanMode::WideScan => (self.resolution / 2).into(),
            ScanMode::Passive => (self.resolution / 3).into(),
            ScanMode::Stealth => (self.resolution / 4).into(),
        };

        // Calculate stealth penalty
        let stealth_resistance: u32 = self.stealth_detection.into();
        let stealth_penalty: u32 = if target_stealth > 0 {
            let target_stealth_u32: u32 = target_stealth.into();
            if stealth_resistance >= target_stealth_u32 {
                (stealth_resistance - target_stealth_u32) / 2
            } else {
                0
            }
        } else {
            stealth_resistance
        };

        // Calculate jamming penalty
        let ew_resistance: u32 = self.electronic_warfare.into();
        let jamming_penalty: u32 = if target_jamming > 0 {
            let target_jamming_u32: u32 = target_jamming.into();
            if ew_resistance >= target_jamming_u32 {
                ew_resistance - target_jamming_u32
            } else {
                0
            }
        } else {
            ew_resistance
        };

        // Health penalty
        let health_multiplier: u32 = self.scanner_health.into();

        // Combine all factors
        let raw_strength = (distance_factor + resolution_bonus + stealth_penalty + jamming_penalty) / 4;
        let strength_with_health = (raw_strength * health_multiplier) / 100;

        if strength_with_health > 100 {
            100
        } else {
            strength_with_health.try_into().unwrap_or(100)
        }
    }

    #[inline(always)]
    fn perform_scan(
        self: StationScanner,
        target_distance: u32,
        target_stealth: u8,
        target_jamming: u8,
        mode: ScanMode,
    ) -> ScanResult {
        if self.scanner_health == 0 {
            return ScanResult::NoContact;
        }

        if !self.can_detect_at_range(target_distance, mode) {
            return ScanResult::NoContact;
        }

        let signature = self.calculate_signature_strength(
            target_distance,
            target_stealth,
            target_jamming,
            mode
        );

        // Determine scan result based on signature strength and conditions
        if signature == 0 {
            ScanResult::NoContact
        } else if target_jamming > self.electronic_warfare {
            ScanResult::JammedSignal
        } else if target_stealth > 0 && signature < 40 {
            ScanResult::StealthShipDetected
        } else if signature < 30 {
            ScanResult::ContactDetected
        } else if signature < 60 {
            ScanResult::ShipIdentified
        } else {
            match mode {
                ScanMode::DeepScan => ScanResult::ShipFullyScanned,
                ScanMode::TargetedScan => ScanResult::ShipFullyScanned,
                _ => ScanResult::ShipIdentified,
            }
        }
    }

    #[inline(always)]
    fn get_scan_quality(
        self: StationScanner,
        signature_strength: u8,
        mode: ScanMode,
    ) -> u8 {
        let base_quality = signature_strength;
        
        let mode_multiplier = match mode {
            ScanMode::DeepScan => 150,
            ScanMode::TargetedScan => 130,
            ScanMode::Active => 100,
            ScanMode::WideScan => 70,
            ScanMode::Passive => 60,
            ScanMode::Stealth => 50,
        };

        let quality: u32 = (base_quality.into() * mode_multiplier) / 100;
        
        if quality > 100 {
            100
        } else {
            quality.try_into().unwrap_or(100)
        }
    }

    #[inline(always)]
    fn can_lock_target(self: StationScanner, signature_strength: u8) -> bool {
        if self.scanner_health < 25 {
            return false;
        }

        let lock_threshold: u8 = 100 - self.target_lock_strength;
        signature_strength >= lock_threshold
    }

    #[inline(always)]
    fn get_scan_time_required(self: StationScanner, mode: ScanMode) -> u8 {
        match mode {
            ScanMode::Passive => 1,
            ScanMode::Active => self.scan_time,
            ScanMode::DeepScan => self.scan_time * 3,
            ScanMode::WideScan => self.scan_time / 2,
            ScanMode::TargetedScan => self.scan_time * 2,
            ScanMode::Stealth => self.scan_time,
        }
    }

    #[inline(always)]
    fn is_scan_detectable(self: StationScanner, mode: ScanMode) -> bool {
        match mode {
            ScanMode::Passive => false,
            ScanMode::Stealth => self.scan_signature < 30,
            ScanMode::Active => true,
            ScanMode::DeepScan => true,
            ScanMode::WideScan => true,
            ScanMode::TargetedScan => true,
        }
    }

    #[inline(always)]
    fn get_detection_chance(self: StationScanner, mode: ScanMode) -> u8 {
        if !self.is_scan_detectable(mode) {
            return 0;
        }

        let base_signature: u32 = self.scan_signature.into();
        
        let mode_multiplier = match mode {
            ScanMode::Passive => 0,
            ScanMode::Stealth => 20,
            ScanMode::Active => 100,
            ScanMode::DeepScan => 150,
            ScanMode::WideScan => 120,
            ScanMode::TargetedScan => 80,
        };

        let detection: u32 = (base_signature * mode_multiplier) / 100;
        
        if detection > 100 {
            100
        } else {
            detection.try_into().unwrap_or(100)
        }
    }

    #[inline(always)]
    fn apply_damage(ref self: StationScanner, damage: u8) {
        if damage >= self.scanner_health {
            self.scanner_health = 0;
        } else {
            self.scanner_health -= damage;
        }
    }

    #[inline(always)]
    fn repair(ref self: StationScanner, repair_amount: u8) {
        let new_health: u16 = self.scanner_health.into() + repair_amount.into();
        if new_health > 100 {
            self.scanner_health = 100;
        } else {
            self.scanner_health = new_health.try_into().unwrap_or(100);
        }
    }

    #[inline(always)]
    fn is_operational(self: StationScanner) -> bool {
        self.scanner_health > 0
    }

    #[inline(always)]
    fn get_degradation_factor(self: StationScanner) -> u8 {
        // Returns how much scanner effectiveness is reduced (0-100)
        100 - self.scanner_health
    }

    #[inline(always)]
    fn estimate_threat_level(
        self: StationScanner,
        signature_strength: u8,
        target_size: u32,
    ) -> u8 {
        // Returns 0-100 threat assessment
        if signature_strength < 20 {
            return 10; // Unknown = potentially dangerous
        }

        // Larger ships are potentially more dangerous
        let size_factor = if target_size > 50000 {
            80
        } else if target_size > 20000 {
            60
        } else if target_size > 5000 {
            40
        } else {
            20
        };

        // Combine signature clarity with size
        let threat: u32 = ((signature_strength.into() + size_factor) / 2);
        
        if threat > 100 {
            100
        } else {
            threat.try_into().unwrap_or(100)
        }
    }

    #[inline(always)]
    fn can_track_multiple_targets(self: StationScanner, target_count: u32) -> bool {
        if self.scanner_health < 50 {
            return target_count <= 2;
        }

        let max_targets = match self.station_type {
            StationType::MilitaryBase => 20,
            StationType::RelayStation => 15,
            StationType::ResearchLab => 12,
            StationType::Shipyard => 10,
            StationType::TradeHub => 8,
            StationType::SmugglerDen => 6,
            StationType::MiningOutpost => 4,
            StationType::Habitat => 3,
            StationType::None => 1,
        };

        target_count <= max_targets
    }

    #[inline(always)]
    fn upgrade_resolution(ref self: StationScanner, amount: u32) {
        let new_resolution = self.resolution + amount;
        if new_resolution > 100 {
            self.resolution = 100;
        } else {
            self.resolution = new_resolution;
        }
    }

    #[inline(always)]
    fn upgrade_range(ref self: StationScanner, amount: u32) {
        self.max_range += amount;
        self.active_range += amount;
        self.passive_range += amount / 3;
    }

    #[inline(always)]
    fn upgrade_stealth_detection(ref self: StationScanner, amount: u8) {
        let new_stealth: u16 = self.stealth_detection.into() + amount.into();
        if new_stealth > 100 {
            self.stealth_detection = 100;
        } else {
            self.stealth_detection = new_stealth.try_into().unwrap_or(100);
        }
    }

    #[inline(always)]
    fn reduce_scan_signature(ref self: StationScanner, amount: u8) {
        if amount >= self.scan_signature {
            self.scan_signature = 0;
        } else {
            self.scan_signature -= amount;
        }
    }
}

#[generate_trait]
pub impl ScanDataImpl of ScanDataTrait {
    #[inline(always)]
    fn new(
        target_id: ContractAddress,
        station_id: u64,
        distance: u32,
        signature_strength: u8,
        timestamp: u64,
    ) -> ScanData {
        ScanData {
            station_id,
            target_id,
            distance,
            signature_strength,
            ship_class: ShipClass::None, // Unknown initially
            hull_integrity: 0,
            shield_status: 0,
            cargo_mass: 0,
            weapon_systems: 0,
            stealth_active: false,
            jamming_active: false,
            scan_quality: 0,
            scan_timestamp: timestamp,
        }
    }


    #[inline(always)]
    fn calculate_integrity_reading(hull: u32, hull_max: u32, quality: u8) -> u8 {
        if hull_max == 0 {
            return 0;
        }

        let actual_percent: u32 = (hull * 100) / hull_max;
        let quality_factor: u32 = quality.into();

        // Add randomness based on scan quality (lower quality = more error)
        let error_margin = 100 - quality_factor;
        let error: u32 = (error_margin / 2); // Max ±50% error at quality 0

        // Apply error (simplified - in real impl would use random)
        let reading = if actual_percent > error {
            actual_percent - (error / 2)
        } else {
            0
        };

        if reading > 100 {
            100
        } else {
            reading.try_into().unwrap_or(100)
        }
    }

    #[inline(always)]
    fn calculate_shield_reading(shields: u32, shields_max: u32, quality: u8) -> u8 {
        if shields_max == 0 {
            return 0;
        }

        let actual_percent: u32 = (shields * 100) / shields_max;
        let quality_factor: u32 = quality.into();

        let error_margin = 100 - quality_factor;
        let error: u32 = error_margin / 3; // Shields easier to read than hull

        let reading = if actual_percent > error {
            actual_percent - (error / 2)
        } else {
            0
        };

        if reading > 100 {
            100
        } else {
            reading.try_into().unwrap_or(100)
        }
    }

    #[inline(always)]
    fn calculate_cargo_reading(actual_cargo: u32, quality: u8) -> u32 {
        let quality_factor: u32 = quality.into();
        let accuracy = (quality_factor * actual_cargo) / 100;
        
        // Lower quality = less accurate reading
        let error_factor = 100 - quality_factor;
        let error_amount = (actual_cargo * error_factor) / 200;

        if accuracy > error_amount {
            accuracy - error_amount
        } else {
            0
        }
    }

    #[inline(always)]
    fn calculate_weapon_reading(actual_weapons: u8, quality: u8) -> u8 {
        let quality_factor: u32 = quality.into();
        let actual_weapons_u32: u32 = actual_weapons.into();
        
        let reading = (actual_weapons_u32 * quality_factor) / 100;

        if reading > 100 {
            100
        } else {
            reading.try_into().unwrap_or(100)
        }
    }

    #[inline(always)]
    fn is_data_stale(self: ScanData, current_time: u64, max_age: u64) -> bool {
        if current_time < self.scan_timestamp {
            return true; // Time went backwards?
        }
        
        let age = current_time - self.scan_timestamp;
        age > max_age
    }

    #[inline(always)]
    fn get_data_age(self: ScanData, current_time: u64) -> u64 {
        if current_time < self.scan_timestamp {
            return 0;
        }
        current_time - self.scan_timestamp
    }

    #[inline(always)]
    fn is_reliable(self: ScanData) -> bool {
        self.scan_quality >= 50
    }

    #[inline(always)]
    fn is_high_quality(self: ScanData) -> bool {
        self.scan_quality >= 70
    }

    #[inline(always)]
    fn has_ship_class(self: ScanData) -> bool {
        self.ship_class != ShipClass::None && self.scan_quality >= 30
    }

    #[inline(always)]
    fn has_hull_data(self: ScanData) -> bool {
        self.scan_quality >= 40
    }

    #[inline(always)]
    fn has_shield_data(self: ScanData) -> bool {
        self.scan_quality >= 50
    }

    #[inline(always)]
    fn has_cargo_data(self: ScanData) -> bool {
        self.scan_quality >= 60
    }

    #[inline(always)]
    fn has_weapon_data(self: ScanData) -> bool {
        self.scan_quality >= 70
    }

    #[inline(always)]
    fn is_threat(self: ScanData) -> bool {
        // Consider a target threatening if:
        // - Weapon systems detected and high
        // - Unknown ship (could be dangerous)
        // - Jamming active (hostile intent)
        
        if self.jamming_active {
            return true;
        }

        if self.has_weapon_data() && self.weapon_systems >= 50 {
            return true;
        }

        if self.scan_quality < 30 {
            return true; // Unknown = potentially dangerous
        }

        false
    }

    #[inline(always)]
    fn is_damaged(self: ScanData) -> bool {
        self.has_hull_data() && self.hull_integrity < 75
    }

    #[inline(always)]
    fn is_heavily_damaged(self: ScanData) -> bool {
        self.has_hull_data() && self.hull_integrity < 40
    }

    #[inline(always)]
    fn is_critical(self: ScanData) -> bool {
        self.has_hull_data() && self.hull_integrity < 20
    }

    #[inline(always)]
    fn shields_active(self: ScanData) -> bool {
        self.has_shield_data() && self.shield_status > 0
    }

    #[inline(always)]
    fn is_loaded(self: ScanData) -> bool {
        self.has_cargo_data() && self.cargo_mass > 0
    }

    #[inline(always)]
    fn is_heavily_loaded(self: ScanData) -> bool {
        self.has_cargo_data() && self.cargo_mass > 10000
    }

    #[inline(always)]
    fn get_threat_level(self: ScanData) -> u8 {
        let mut threat: u32 = 0;

        // Base threat from weapons
        if self.has_weapon_data() {
            threat += self.weapon_systems.into();
        } else if self.scan_quality < 30 {
            threat += 50; // Unknown = assume dangerous
        }

        // Stealth and jamming increase threat
        if self.stealth_active {
            threat += 20;
        }
        if self.jamming_active {
            threat += 30;
        }

        // Shields suggest combat readiness
        if self.shields_active() {
            threat += 15;
        }

        // Normalize to 0-100
        if threat > 100 {
            100
        } else {
            threat.try_into().unwrap_or(100)
        }
    }

    #[inline(always)]
    fn estimate_ship_size(self: ScanData) -> u32 {
        // Estimate based on cargo capacity and signature
        let base_size = self.cargo_mass * 2;
        let signature_factor: u32 = self.signature_strength.into();
        
        (base_size * signature_factor) / 100
    }

    #[inline(always)]
    fn is_military_vessel(self: ScanData) -> bool {
        if !self.has_weapon_data() {
            return false;
        }

        // High weapons, low cargo = military
        self.weapon_systems >= 60 && (!self.has_cargo_data() || self.cargo_mass < 5000)
    }

    #[inline(always)]
    fn is_civilian_vessel(self: ScanData) -> bool {
        if !self.has_weapon_data() {
            return true; // No weapons detected = probably civilian
        }

        // Low weapons, high cargo = civilian
        self.weapon_systems < 30 && self.has_cargo_data() && self.cargo_mass > 5000
    }

    #[inline(always)]
    fn needs_assistance(self: ScanData) -> bool {
        // Critical damage suggests distress
        self.is_critical() || (self.is_heavily_damaged() && !self.shields_active())
    }

    #[inline(always)]
    fn compare_quality(self: ScanData, other: ScanData) -> bool {
        // Returns true if this scan is better quality than other
        if self.scan_quality != other.scan_quality {
            return self.scan_quality > other.scan_quality;
        }

        // If quality equal, newer is better
        self.scan_timestamp > other.scan_timestamp
    }

    #[inline(always)]
    fn merge_data(ref self: ScanData, other: ScanData) {
        // Merge two scans of the same target, keeping best data
        if other.scan_quality > self.scan_quality {
            self.scan_quality = other.scan_quality;
        }

        // Take newer timestamp
        if other.scan_timestamp > self.scan_timestamp {
            self.scan_timestamp = other.scan_timestamp;
        }

        // Take better signature strength
        if other.signature_strength > self.signature_strength {
            self.signature_strength = other.signature_strength;
        }

        // Update individual fields if other has better quality
        if other.has_ship_class() && !self.has_ship_class() {
            self.ship_class = other.ship_class;
        }

        if other.has_hull_data() && !self.has_hull_data() {
            self.hull_integrity = other.hull_integrity;
        }

        if other.has_shield_data() && !self.has_shield_data() {
            self.shield_status = other.shield_status;
        }

        if other.has_cargo_data() && !self.has_cargo_data() {
            self.cargo_mass = other.cargo_mass;
        }

        if other.has_weapon_data() && !self.has_weapon_data() {
            self.weapon_systems = other.weapon_systems;
        }

        // Update status flags
        if other.stealth_active {
            self.stealth_active = true;
        }
        if other.jamming_active {
            self.jamming_active = true;
        }
    }

    #[inline(always)]
    fn get_confidence_description(self: ScanData) -> felt252 {
        if self.scan_quality >= 90 {
            'EXCELLENT'
        } else if self.scan_quality >= 70 {
            'GOOD'
        } else if self.scan_quality >= 50 {
            'MODERATE'
        } else if self.scan_quality >= 30 {
            'POOR'
        } else {
            'MINIMAL'
        }
    }

    #[inline(always)]
    fn degrade_over_time(ref self: ScanData, time_passed: u64) {
        // Scan quality degrades over time (data becomes less reliable)
        let degradation_rate = 1; // 1% per time unit
        let total_degradation: u32 = (time_passed * degradation_rate).try_into().unwrap_or(0);

        if total_degradation >= self.scan_quality.into() {
            self.scan_quality = 0;
        } else {
            self.scan_quality -= total_degradation.try_into().unwrap_or(0);
        }
    }
}
