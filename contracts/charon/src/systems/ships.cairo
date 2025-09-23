
use starknet::{ContractAddress};
use charon::models::ships::{Ship,Faction,ShipClass,ShipTrait, Vec2,MiniZoneShipTrait,MiniZoneShip};
use charon::models::zones::{ZoneType, ZoneTypeTrait};

#[starknet::interface]
pub trait IShip<T> {
    fn create_ship(
        ref self: T,
        id: ContractAddress,
        faction: Faction,
        class: ShipClass,
        hull_points: u32,
        shield_points: u32,
        speed: u32,
        crew_size: u32,
        cargo_capacity: u32,
        location_x: u32,
        location_y: u32,
        railguns: u8,
        torpedoes: u8,
        pdcs: u8,
        torpedo_ammo: u32,
        railgun_ammo: u32,
        fuel_capacity: u32,
        current_fuel: u32,
        reactor_fuel: u32,
        power_output: u32,
    );
}

#[dojo::contract]
pub mod ship {

    use super::{IShip,Ship,Faction,ShipClass,ShipTrait,Vec2,MiniZoneShipTrait,MiniZoneShip,ZoneType,ZoneTypeTrait};
    use starknet::{ContractAddress,get_caller_address};
    use dojo::model::{ModelStorage};
    use dojo::event::EventStorage;

    #[abi(embed_v0)]
    impl ShipImpl of IShip<ContractState> {
        fn create_ship(
            ref self: ContractState,
            id: ContractAddress,
            faction: Faction,
            class: ShipClass,
            hull_points: u32,
            shield_points: u32,
            speed: u32,
            crew_size: u32,
            cargo_capacity: u32,
            location_x: u32,
            location_y: u32,
            railguns: u8,
            torpedoes: u8,
            pdcs: u8,
            torpedo_ammo: u32,
            railgun_ammo: u32,
            fuel_capacity: u32,
            current_fuel: u32,
            reactor_fuel: u32,
            power_output: u32,
        ){

            let mut world = self.world_default();
            let owner = get_caller_address();

            let existing_ship: Ship = world.read_model(id);
            assert(existing_ship.pdcs == 0, 'Ship already exists');

            let location = Vec2 {
                x: location_x,
                y: location_y,
            };

            let ship = ShipTrait::new(
                            id,
                            owner,
                            faction,
                            class,
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
                            );
            world.write_model(@ship);

            // Calculate mini zone and create lookup entry
            let zone_type = ZoneTypeTrait::from_coordinates(location_x, location_y);
            let mini_zone_id = zone_type.get_global_mini_zone_id(location_x, location_y);
            
            let mini_zone_ship = MiniZoneShipTrait::new(mini_zone_id, id);
            world.write_model(@mini_zone_ship);


            }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"charon")
        }
    }

}