use starknet::{ContractAddress};
use charon::models::ships::{Ship, Faction, ShipClass, ShipTrait, Vec2, MiniZoneShipTrait, MiniZoneShip};
use charon::models::zones::{ZoneType, ZoneTypeTrait};

#[starknet::interface]
pub trait IShip<T> {
    fn create_ship(
        ref self: T,
        id: ContractAddress,
        name: felt252,
        rescue_gauntlet_id: u32,
        faction: Faction,
        s_class: ShipClass,
        location_x: u32,
        location_y: u32,
    );
    
    // TODO: Implement after combat/rescue logic
    // fn rearm_ship(ref self: T, ship_id: ContractAddress);
}

#[dojo::contract]
pub mod ship {

    use super::{IShip, Ship, Faction, ShipClass, ShipTrait, Vec2, MiniZoneShipTrait, MiniZoneShip, ZoneType, ZoneTypeTrait};
    use starknet::{ContractAddress, get_caller_address};
    use dojo::model::{ModelStorage};
    use dojo::event::EventStorage;

    use charon::utils::armament_helper::{ArmamentHelperImpl, ArmamentHelperTrait};

    
    #[derive(Drop, starknet::Event)]
    pub struct ShipCreated {
        pub ship_id: ContractAddress,
        pub owner: ContractAddress,
        pub faction: Faction,
        pub s_class: ShipClass,
        pub location: Vec2,
    }
    
    // #[derive(Drop, starknet::Event)]
    // pub struct ShipRearmed {
    //     pub ship_id: ContractAddress,
    // }
    
    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        ShipCreated: ShipCreated,
        // ShipRearmed: ShipRearmed,
    }

    #[abi(embed_v0)]
    impl ShipImpl of IShip<ContractState> {
        
        // ============================================
        // Create Ship Using Armament Helper
        // ============================================
        
        fn create_ship(
            ref self: ContractState,
            id: ContractAddress,
            name: felt252,
            rescue_gauntlet_id: u32,
            faction: Faction,
            s_class: ShipClass,
            location_x: u32,
            location_y: u32,
        ) {
            let mut world = self.world_default();
            let owner = get_caller_address();

            // Check ship doesn't already exist
            let existing_ship: Ship = world.read_model(id);
            assert(existing_ship.pdcs == 0, 'Ship already exists');

            let location = Vec2 {
                x: location_x,
                y: location_y,
            };

            // Use armament helper to initialize ship with proper stats
            let ship = ArmamentHelperTrait::initialize_ship(
                id,
                owner,
                name,
                rescue_gauntlet_id,
                faction,
                s_class,
                location,
            );

            world.write_model(@ship);

            // Calculate mini zone and create lookup entry
            let zone_type = ZoneTypeTrait::from_coordinates(location_x, location_y);
            let mini_zone_id = zone_type.get_global_mini_zone_id(location_x, location_y);
            
            let mini_zone_ship = MiniZoneShipTrait::new(mini_zone_id, id);
            world.write_model(@mini_zone_ship);

            // Emit event using modern syntax
            self.emit(Event::ShipCreated(
                ShipCreated {
                    ship_id: id,
                    owner,
                    faction,
                    s_class,
                    location,
                }
            ));
        }
        
 
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"charon")
        }
    }
}