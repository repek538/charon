use starknet::ContractAddress;

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
    pub x: u32,                   // Coordinates
    pub y: u32,
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug, DojoStore, Default)]
pub enum StationType {
    #[default]
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
        y: u32
    ) -> Station {
        Station {
            id,
            name,
            station_type,
            owner,
            defense_level: Self::get_base_defense_level(station_type),
            capacity: Self::get_base_capacity(station_type),
            crew: Self::get_base_crew(station_type),
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