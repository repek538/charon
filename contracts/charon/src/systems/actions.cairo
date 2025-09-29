use core::circuit::u384;
use starknet::ContractAddress;use crate::systems::oberon;

use charon::models::oberon::{ShipOberon,OberonScanner,OberonScanResult,OberonScanResultTrait,StationScanResult,StationScanResultTrait};
use charon::models::zones::{Zone,ZoneType,ZoneTypeTrait};
use charon::models::stations::{Station,MiniZoneStation,MiniZoneStationTrait,};
use charon::models::ships::{Ship,Scanner,MiniZoneShip,MiniZoneShipTrait,Vec2};
use charon::models::engagements::{Engagement,EngagementTrait};
use charon::models::game::{Game,GameTrait};

#[starknet::interface]
pub trait IActions<T> {
    // === MOVEMENT ACTIONS ===
    fn move_ship(
        ref self: T,
        game_id: u32,
        location_x: u32,
        location_y: u32,
    );
    // === SCANNING ACTIONS ===
    fn passive_scan(
        ref self: T,
        game_id: u32,
        location_x: u32,
        location_y: u32,
    ); // Returns detected ships
    
    fn active_scan(
        ref self: T,
        game_id: u32,
        target_ship: ContractAddress,
        
    ); // Returns if scan was successful

    fn active_scan_station(
        ref self: T,
        game_id: u32,
        target_station: u64,
        
    ); // Returns if scan was successful
    
    // fn detailed_scan(
    //     ref self: T,
    //     target_ship: ContractAddress,
    // ); // Multi-turn detailed scan

    // // === COMBAT ACTIONS ===
    // fn fire_railgun(
    //     ref self: T,
    //     target_ship: ContractAddress,
    // ); // Returns if shot hit
    
    // fn fire_torpedo(
    //     ref self: T,
    //     torpedo_id: u64,
    //     target_ship: ContractAddress,
    // ); // Returns if torpedo launched
    
    // fn fire_pdc_burst(
    //     ref self: T,
    //     target: ContractAddress, // Can target ships or incoming missiles
    // ) -> u16; // Returns damage dealt
    
    // fn intercept_missiles(
    //     ref self: T,
    // ); // Returns intercepted missile IDs

    // // === DEFENSIVE ACTIONS ===
    // fn raise_shields(ref self: T);
    
    // fn lower_shields(ref self: T);
    
    // fn modulate_shield_frequency(
    //     ref self: T,
    //     new_frequency: u8,
    // );
    
    // fn emergency_shield_shutdown(ref self: T);

    // // === CREW ACTIONS ===
    // fn repair_hull(
    //     ref self: T,
    //     repair_amount: u32,
    // ); // Returns actual amount repaired
    
    // fn repair_system(
    //     ref self: T,
    //     system_type: u8, // 1=scanner, 2=railgun, 3=shields, etc.
    // );
    
    // fn medical_treatment(
    //     ref self: T,
    //     injured_crew: u8,
    // ); // Returns crew saved
    
    // fn assign_crew_stations(
    //     ref self: T,
    //     engineers: u8,
    //     gunners: u8,
    //     medics: u8,
    // );

    // // === SUPPLY ACTIONS ===
    // fn refuel(
    //     ref self: T,
    //     fuel_amount: u32,
    // );
    
    // fn reload_railgun(
    //     ref self: T,
    //     ammo_count: u32,
    // );
    
    // fn reload_torpedoes(
    //     ref self: T,
    //     torpedo_count: u16,
    // );
    
    // fn reload_pdc(
    //     ref self: T,
    //     pdc_id: u64,
    //     ammo_count: u32,
    // );

    // // === CARGO ACTIONS ===
    // fn load_cargo(
    //     ref self: T,
    //     cargo_amount: u32,
    //     cargo_type: felt252,
    // ); // Returns if successful
    
    // fn unload_cargo(
    //     ref self: T,
    //     cargo_amount: u32,
    // );

    // // === MAINTENANCE ACTIONS ===
    // fn cool_down_systems(ref self: T); // Cool PDCs, manage heat
    
    // fn perform_maintenance(
    //     ref self: T,
    //     system_type: u8,
    // ); // General maintenance
    
    // fn emergency_repairs(
    //     ref self: T,
    //     priority_system: u8,
    // ); // Battle damage control

    // // === POWER MANAGEMENT ===
    // fn set_power_allocation(
    //     ref self: T,
    //     shields: u8,    // Percentage of power to shields
    //     weapons: u8,    // Percentage to weapons
    //     engines: u8,    // Percentage to engines
    //     sensors: u8,    // Percentage to sensors
    // );
    
    // fn emergency_power_reroute(
    //     ref self: T,
    //     target_system: u8,
    // );

    // // === TACTICAL ACTIONS ===
    // fn set_combat_stance(
    //     ref self: T,
    //     stance: u8, // 1=aggressive, 2=defensive, 3=evasive
    // );
    
    // fn target_lock(
    //     ref self: T,
    //     target_ship: ContractAddress,
    // ); // Returns lock quality (0-100)
    
    // fn break_target_lock(ref self: T);
    
    // fn evasive_maneuvers(ref self: T) -> u8; // Returns evasion bonus

    // // === COMMUNICATION ACTIONS ===
    // fn hail_ship(
    //     ref self: T,
    //     target_ship: ContractAddress,
    //     message: felt252,
    // );
    
    // fn broadcast_distress(ref self: T);
    
    // fn request_docking(
    //     ref self: T,
    //     station_address: ContractAddress,
    // );

    // // === STATUS QUERIES ===
    // fn get_ship_status(ref self: T) -> (
    //     u32, // hull
    //     u16, // shields
    //     u32, // fuel
    //     u8,  // crew count
    //     bool // combat ready
    // );
    
    // fn get_weapons_status(ref self: T) -> (
    //     u32, // railgun ammo
    //     u16, // torpedo count
    //     u32, // pdc ammo
    //     bool // weapons online
    // );
    
    // fn get_system_health(ref self: T) -> (
    //     u8, // scanner health
    //     u8, // shield generator health
    //     u8, // railgun barrel wear
    //     u8  // overall ship condition
    // );

    // // === ADVANCED ACTIONS ===
    // fn self_destruct_sequence(
    //     ref self: T,
    //     confirmation_code: felt252,
    // );
    
    // fn abandon_ship(ref self: T) -> bool; // Crew evacuation
    
    // fn ram_target(
    //     ref self: T,
    //     target_ship: ContractAddress,
    // ); // Last resort attack
}

// dojo decorator
#[dojo::contract]
pub mod actions {

    use super::{
        IActions,
        MiniZoneStation,
        MiniZoneStationTrait,
        ShipOberon,
        Station,
        Ship,
        Engagement,
        EngagementTrait,
        Scanner,
        OberonScanner,
        ZoneType,
        ZoneTypeTrait,
        MiniZoneShip,
        MiniZoneShipTrait,
        Game,
        GameTrait,
        OberonScanResult,
        OberonScanResultTrait,
        StationScanResult,
        StationScanResultTrait
    };

    use starknet::{ContractAddress, get_caller_address,get_block_timestamp};
    

    use dojo::model::{ModelStorage};
    use dojo::event::EventStorage;

    use core::num::traits::Zero;

    use charon::utils::{is_within_range_squared};
    


    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        fn move_ship(
        ref self: ContractState,
        game_id: u32,
        location_x: u32,
        location_y: u32,
        ){

        // Get the default world.
        let mut world = self.world_default();

        // Get the address of the current caller, possibly the player's address.
        let player = get_caller_address();

        let player_ship: ShipOberon = world.read_model(player);
        assert(player_ship.point_defense == 0, 'Ship already exists');

        // before making the move lets find assets in the minizone 

        let main_zone_type: ZoneType = ZoneTypeTrait::from_coordinates(location_x,location_y);

        let mini_zone_id = main_zone_type.get_global_mini_zone_id(location_x,location_y);

        // check for any ships 

        let mini_zone_ship: MiniZoneShip = world.read_model(mini_zone_id);

        let mini_zone_station: MiniZoneStation = world.read_model(mini_zone_id);

        let current_time = get_block_timestamp();

        let mut game: Game =  world.read_model(game_id);

        
        if (mini_zone_ship.ship != Zero::zero() && mini_zone_ship.is_active){

            let enemy_ship: Ship = world.read_model(mini_zone_ship.ship);

            let mut engagement_id = game.engagements_count + 1;

            let enemy_ship_scanner: Scanner = world.read_model(enemy_ship.id);

            let oberon_scanner: OberonScanner = world.read_model(player_ship.ship);

            let engagement_range = enemy_ship_scanner.max_range + oberon_scanner.max_range;

            //create engagement
            let engagement  = EngagementTrait::new(
                player,
                engagement_id,
                player_ship_id: player_ship.ship,
                enemy_ship_id: enemy_ship.id,
                current_time: current_time,
                engagement_range: engagement_range,
                player_hull: player_ship.hull,
                enemy_hull: enemy_ship.hull_points,
                player_shields: player_ship.shield,
                enemy_shields: enemy_ship.shield_points,
            );

            world.write_model(@engagement);

            game.engagements_count = engagement_id;

            world.write_model(@game);

        }




        }

        fn passive_scan(
             ref self: ContractState,
             game_id: u32,
            location_x: u32,
            location_y: u32,
        ){
                    // Get the default world.
                let mut world = self.world_default();

                // Get the address of the current caller, possibly the player's address.
                let player = get_caller_address();

                let player_ship: ShipOberon = world.read_model(player);
                assert(player_ship.point_defense == 0, 'Ship already exists');

                // before making the move lets find assets in the minizone 

                let main_zone_type: ZoneType = ZoneTypeTrait::from_coordinates(location_x,location_y);

                let mini_zone_id = main_zone_type.get_global_mini_zone_id(location_x,location_y);

                // check for any ships 

                let mini_zone_ship: MiniZoneShip = world.read_model(mini_zone_id);

                let mini_zone_station: MiniZoneStation = world.read_model(mini_zone_id);

                let current_time = get_block_timestamp();

                let mut game: Game =  world.read_model(game_id);

                if (mini_zone_ship.ship != Zero::zero() && mini_zone_ship.is_active){

                        let enemy_ship: Ship = world.read_model(mini_zone_ship.ship);


                        let oberon_scanner: OberonScanner = world.read_model(player_ship.ship);

                        assert(oberon_scanner.scanner_health > 0, 'Scanner Damaged');

                        // if there is power to scan - passive scaner
                        if player_ship.power_available > oberon_scanner.power_cost{

                            let enemy_stealth_rating: u8 = (enemy_ship.shield_points % 100).try_into().unwrap();
                            
                            if oberon_scanner.stealth_detection >= enemy_stealth_rating {
                                // Ship detected! Add to scanner result 

                                let mut scanner_result = OberonScanResultTrait::new(
                                    ship: player_ship.ship,
                                    vessel: enemy_ship.id,
                                    detection_time: current_time,
                                    distance: 0, // will have to look into this 
                                    bearing: 0,
                                    confidence: 0,
                                    station: 0,
                                );

                                if (mini_zone_station.station != Zero::zero() && mini_zone_station.is_active){

                                    let station: Station = world.read_model(mini_zone_station.station);

                                    scanner_result.station = station.id;

                                    let station_scan_res = StationScanResultTrait::new(
                                        scanner_ship:  player_ship.ship,
                                        station_id: mini_zone_station.station,
                                        detection_time: current_time,
                                        distance: 0,
                                        confidence: oberon_scanner.scanner_health,
                                    );

                                    world.write_model(@scanner_result);

                                    world.write_model(@station_scan_res);

                                }
                                
                            }

                        }




                        

                        

                     

        }


        }

       fn active_scan(
            ref self: ContractState,
            game_id: u32,
            target_ship: ContractAddress,
        ) { 

                // Get the default world.
                let mut world = self.world_default();

                // Get the address of the current caller, possibly the player's address.
                let player = get_caller_address();

                let player_ship: ShipOberon = world.read_model(player);
                assert(player_ship.point_defense == 0, 'Ship already exists');

                let oberon_scanner: OberonScanner = world.read_model(player_ship.ship);

                let current_time = get_block_timestamp();


                assert(oberon_scanner.scanner_health > 0, 'Scanner Damaged');

                // if there is power to scan - passive scaner
                if player_ship.power_available > oberon_scanner.power_cost{

                    let target_e_ship: Ship =  world.read_model(target_ship);

                    let mut  passive_scan_res: OberonScanResult = world.read_model(player_ship.ship);


                            passive_scan_res.confidence = oberon_scanner.scanner_health;
                            passive_scan_res.ship_class_known = target_e_ship.s_class;
                            passive_scan_res.faction_known = target_e_ship.faction;
                            passive_scan_res.armament_known = true;        
                            passive_scan_res.hull_status_known = true;   
                            passive_scan_res.shield_status_known = true; 
                            passive_scan_res.is_stealthed = true;           
                            passive_scan_res.last_updated = current_time;   
                            world.write_model(@passive_scan_res);        

                }


        }

        fn active_scan_station(
            ref self: ContractState,
            game_id: u32,
            target_station: u64,
            
        ){

               // Get the default world.
                let mut world = self.world_default();

                // Get the address of the current caller, possibly the player's address.
                let player = get_caller_address();

                let player_ship: ShipOberon = world.read_model(player);
                assert(player_ship.point_defense == 0, 'Ship already exists');

                let oberon_scanner: OberonScanner = world.read_model(player_ship.ship);

                let current_time = get_block_timestamp();


                assert(oberon_scanner.scanner_health > 0, 'Scanner Damaged');

                // if there is power to scan - passive scaner
                if player_ship.power_available > oberon_scanner.power_cost {

                     let target_e_station: Station =  world.read_model(target_station);





                 }
        }
        
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        /// Use the default namespace "charon". This function is handy since the ByteArray
        /// can't be const.
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"charon")
        }
    }
}

