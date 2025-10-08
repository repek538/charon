use starknet::ContractAddress;
use charon::models::oberon::{
    ShipOberon, ShipOberonTrait,
    OberonScanner, OberonScannerTrait,
    OberonRailgun, OberonRailgunTrait,
    OberonTorpedo, OberonTorpedoTrait,
    OberonPDC, OberonPDCTrait,
    OberonShield, OberonShieldTrait, Crew,CrewTrait
};
use charon::models::ships::{ShipClass,Vec2};



#[starknet::interface]
pub trait IShipOberon<T> {
    fn create_ship(
        ref self: T,
        name: felt252,
    );
}

#[dojo::contract]

pub mod  shipoberon {

    use super::{IShipOberon,
    ShipOberon, ShipOberonTrait, Vec2,
    OberonScanner, OberonScannerTrait,
    OberonRailgun, OberonRailgunTrait,
    OberonTorpedo, OberonTorpedoTrait,
    OberonPDC, OberonPDCTrait,
    OberonShield, OberonShieldTrait,
    ShipClass,Crew,CrewTrait
    };

    use starknet::{ContractAddress,get_caller_address};
    use dojo::model::{ModelStorage};
    use dojo::event::EventStorage;

    use charon::constants::{
        DEFAULT_POINT_DEFENSE,
        DEFAULT_TORPEDOES,
        DEFAULT_RAILGUN,

        DEFAULT_CREW_CAPACITY,
        DEFAULT_FUEL,
        DEFAULT_CARGO,
        DEFAULT_POWER_OUTPUT,
        DEFAULT_POWER_AVAILABLE,

        DEFAULT_LOCATION_X,
        DEFAULT_LOCATION_Y,
        DEFAULT_MORALE,
        DEFAULT_HULL,
        DEFAULT_SHIELD
        };

    #[abi(embed_v0)]
    impl ShipOberonImpl of IShipOberon<ContractState> { 

        fn create_ship(
            ref self: ContractState,
            name: felt252
        ){
            let mut world = self.world_default();
            let owner = get_caller_address();
            let ship = get_caller_address();

            let existing_ship: ShipOberon = world.read_model(owner);
            assert(existing_ship.point_defense == 0, 'Ship already exists');

            let location = Vec2 {
                x: DEFAULT_LOCATION_X,
                y: DEFAULT_LOCATION_Y,
            };

            let ship_oberon = ShipOberonTrait::new(
                ship,
                owner,
                name,
                DEFAULT_HULL,
                DEFAULT_SHIELD,
                DEFAULT_POINT_DEFENSE,
                DEFAULT_TORPEDOES,
                DEFAULT_RAILGUN,
                DEFAULT_CREW_CAPACITY,
                DEFAULT_FUEL,
                DEFAULT_CARGO,
                location,
                DEFAULT_POWER_OUTPUT
            );

            // Create scanner system
            let scanner = OberonScannerTrait::new(
                ship,
                1500,           // max_range: 1500km
                75,             // resolution: civilian grade
                3,              // scan_time: 3 turns
                25,             // power_cost: 25MW
                500,            // passive_range: 500km
                1500,           // active_range: 1500km
                40,             // stealth_detection: moderate
                30,             // electronic_warfare: basic
                60,             // target_lock_strength: decent
                35,             // scan_signature: civilian freighter
                1,     // compatible_classes: Oberon bit
                ShipClass::Corvette,
                100             // scanner_health: new condition
            );

            // Create railgun
            let railgun = OberonRailgunTrait::new(
                ship,
                200,            // damage: light railgun
                2000,           // max_range: 2000km
                800,            // optimal_range: 800km
                1,              // rate_of_fire: 1 per turn
                50,             // power_cost: 50MW
                20,             // tracking_speed: poor vs fast targets
                500,            // ammunition: 500 slugs
                0,              // barrel_wear: new condition
                1,     // compatible_classes: Oberon
                ShipClass::Corvette,
            );

            // Create torpedo launchers (creating multiple torpedo entries)
            let mut torpedo_id = 0;
            loop {
                if torpedo_id >= 8 { break; }
                
                let torpedo = OberonTorpedoTrait::new(
                    torpedo_id,
                    ship,
                    600,            // damage: standard warhead
                    5000,           // max_range: 5000km
                    3000,           // optimal_range: 3000km
                    1,              // rate_of_fire: 1 per turn
                    10,             // power_cost: 10MW for launch
                    80,             // tracking_speed: excellent
                    1,              // ammunition: 1 torpedo per launcher
                    5,              // fuel_per_torpedo: 5 units
                    1,     // compatible_classes: Destroyer, Cruiser, Battleship
                    ShipClass::Corvette,
                );
                
                world.write_model(@torpedo);
                torpedo_id += 1;
            };

            // Create PDC systems (2 PDCs)
            let mut pdc_id = 0;
            loop {
                if pdc_id >= 2 { break; }
                
                let pdc = OberonPDCTrait::new(
                    pdc_id,
                    ship,
                    30,             // damage: 30 per burst
                    100,            // max_range: 100km
                    50,             // optimal_range: 50km
                    8,              // rate_of_fire: 8 shots per turn
                    5,              // power_cost: 5MW per burst
                    95,             // tracking_speed: excellent vs missiles
                    2000,           // ammunition: 2000 rounds
                    0,              // heat_buildup: cool
                    1,     // compatible_classes: all classes
                    ShipClass::Corvette,
                );
                
                world.write_model(@pdc);
                pdc_id += 1;
            };

            // Create shield system
            let shield = OberonShieldTrait::new(
                ship,    // ship_id as u64
                200,            // max_strength
                200,            // current_strength: full
                5,              // recharge_rate: 5 per turn
                30,             // power_cost: 30MW
                85,             // coverage: 85%
                50,             // frequency: standard
                100,            // generator_health: new
                1,     // compatible_classes: Corvette
                ShipClass::Corvette,
            );

            let ship_crew = CrewTrait::new(
                ship,
                captain: owner,
                members: 0,
                engineers: 0,
                gunners: 0,
                medics: 0,
                pilots: 0,
                scientists: 0           
            );



            // Write all models to world storage
            world.write_model(@ship_oberon);
            world.write_model(@scanner);
            world.write_model(@railgun);
            world.write_model(@shield);
            world.write_model(@ship_crew);

        }


    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"charon")
        }
    }

}
