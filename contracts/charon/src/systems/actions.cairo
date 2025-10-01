use core::circuit::u384;
use starknet::ContractAddress;use crate::systems::oberon;

use charon::models::oberon::{ShipOberon,OberonScanner,OberonScanResult,OberonScanResultTrait,StationScanResult,StationScanResultTrait};
use charon::models::zones::{Zone,ZoneType,ZoneTypeTrait};
use charon::models::stations::{Station,MiniZoneStation,MiniZoneStationTrait,StationType};
use charon::models::ships::{Ship,Scanner,MiniZoneShip,MiniZoneShipTrait,Vec2,Faction,ShipClass};
use charon::models::engagements::{Engagement,EngagementTrait,PlayerAction,NPSAction};
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

    fn initiate_engagement_ship(
        ref self: T,
        game_id: u32,
        target_ship: ContractAddress,
        player_action: PlayerAction,
        torpedo_active: u8,
        raiguns_active: u8,
        pdcs_active: u8
    );
    
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
        StationScanResultTrait,
        StationType,
        PlayerAction,
        NPSAction,
        Faction,
        ShipClass
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
                    
                     let mut station_scan_res: StationScanResult = world.read_model(player_ship.ship);


                    station_scan_res.station_type_known = target_e_station.station_type;
                    station_scan_res.owner_known = true;
                    station_scan_res.defense_level_known = true;
                    station_scan_res.capacity_known = true;
                    station_scan_res.crew_count_known = true;
                    station_scan_res.approx_defense_level= target_e_station.defense_level;
                    station_scan_res.approx_capacity = target_e_station.capacity;
                    station_scan_res.is_hostile = false;
                    station_scan_res.last_updated = current_time;

                    world.write_model(@station_scan_res);

                 }
        }

        fn initiate_engagement_ship(
            ref self: ContractState,
            game_id: u32,
            target_ship: ContractAddress,
            player_action: PlayerAction,
            torpedo_active: u8,
            raiguns_active: u8,
            pdcs_active: u8
        ) {
            // Get the default world.
            let mut world = self.world_default();

            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();

            let player_ship: ShipOberon = world.read_model(player);
            assert(player_ship.point_defense == 0, 'Ship already exists');

            let current_time = get_block_timestamp();

            let  scan_res: OberonScanResult = world.read_model(player_ship.ship);

            let mut game: Game =  world.read_model(game_id);

            assert(target_ship == scan_res.vessel, 'Scan Vessel');

            let target_e_ship: Ship = world.read_model(target_ship);

            let mut engagement_id = game.engagements_count + 1;

            let target_e_ship_scanner: Scanner = world.read_model(target_e_ship.id);

            let oberon_scanner: OberonScanner = world.read_model(player_ship.ship);

            let engagement_range = target_e_ship_scanner.max_range + oberon_scanner.max_range;

            //create engagement
            let mut engagement  = EngagementTrait::new(
                player,
                engagement_id,
                player_ship_id: player_ship.ship,
                enemy_ship_id: target_e_ship.id,
                current_time: current_time,
                engagement_range: engagement_range,
                player_hull: player_ship.hull,
                enemy_hull: target_e_ship.hull_points,
                player_shields: player_ship.shield,
                enemy_shields: target_e_ship.shield_points,
            );

            world.write_model(@engagement);


        }
        
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {

   /// Use the default namespace "charon". This function is handy since the ByteArray
        /// can't be const.
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"charon")
        }

        fn nps_ship_action_res(
            ref self: ContractState,
            ship_id: ContractAddress,
            target_ship: ContractAddress,
            target_ship_action: PlayerAction,
            torpedo_active: u8,
            railguns_active: u8,
            pdcs_active: u8
        ) -> (NPSAction, u8, u8, u8) {
            let mut world = self.world_default();
            
            let nps_ship: Ship = world.read_model(ship_id);
            let player_ship: ShipOberon = world.read_model(target_ship);
            
            // Calculate all context needed for decisions
            let nps_power = self.calculate_nps_ship_power(nps_ship);
            let player_power = self.calculate_oberon_power(player_ship);
            let power_diff = nps_power - player_power;
            
            let nps_morality = self.get_faction_morality(nps_ship.faction);
            let player_morality = player_ship.morarity;
            
            let cargo_threshold = if nps_morality < 30 { 200 } else { 500 };
            let has_valuable_cargo = player_ship.cargo > cargo_threshold || player_ship.fuel > 1000;
            
            let player_seems_weak = player_morality > 70;
            let player_seems_dangerous = player_morality < 30;
            
            // Determine response based on player action
            let action = self.determine_nps_response(
                target_ship_action,
                nps_morality,
                player_morality,
                power_diff,
                has_valuable_cargo,
                player_seems_weak,
                player_seems_dangerous,
                nps_ship.hull_points
            );
            
            // Determine weapon activation based on action and player weapons
            let (nps_torpedoes, nps_railguns, nps_pdcs) = self.determine_weapon_activation(
                action,
                nps_ship,
                player_ship,
                torpedo_active,
                railguns_active,
                pdcs_active,
                power_diff,
                has_valuable_cargo,
                nps_morality
            );
            
            (action, nps_torpedoes, nps_railguns, nps_pdcs)
        }

        // Main decision router
        fn determine_nps_response(
            self: @ContractState,
            player_action: PlayerAction,
            nps_morality: u8,
            player_morality: u8,
            power_diff: u32,
            has_valuable_cargo: bool,
            player_seems_weak: bool,
            player_seems_dangerous: bool,
            nps_hull: u32
        ) -> NPSAction {
            match player_action {
                PlayerAction::None => self.handle_initial_contact(
                    nps_morality, power_diff, has_valuable_cargo, 
                    player_seems_weak, player_seems_dangerous
                ),
                PlayerAction::Hail => self.handle_hail(
                    nps_morality, power_diff, has_valuable_cargo,
                    player_seems_weak, player_seems_dangerous
                ),
                PlayerAction::Comply | PlayerAction::SurrenderCargo => self.handle_surrender(
                    nps_morality, nps_hull, player_seems_dangerous
                ),
                PlayerAction::PayBribe => self.handle_bribe(
                    nps_morality, power_diff, player_seems_dangerous
                ),
                PlayerAction::Negotiate => self.handle_negotiation(
                    nps_morality, power_diff, player_seems_weak, player_seems_dangerous
                ),
                PlayerAction::Threaten => self.handle_threat(
                    nps_morality, power_diff, player_seems_weak, player_seems_dangerous
                ),
                PlayerAction::OpenFire | PlayerAction::LaunchTorpedoes | PlayerAction::ActivatePDCs => {
                   self.handle_combat(
                        nps_morality, power_diff, has_valuable_cargo,
                        player_seems_dangerous, nps_hull
                    )
                },
                PlayerAction::ActivateShields => self.handle_shields(
                    nps_morality, power_diff, player_seems_weak, player_seems_dangerous
                ),
                PlayerAction::Burn => self.handle_escape(
                    nps_morality, power_diff, has_valuable_cargo,
                    player_seems_weak, player_seems_dangerous
                ),
                PlayerAction::PrepareBoarding => self.handle_boarding(power_diff, nps_hull),
                PlayerAction::SurrenderShip => self.handle_total_surrender(
                    nps_morality, player_seems_dangerous
                ),
                PlayerAction::RamEnemy => NPSAction::Burn,  // Emergency evasion
                _ => NPSAction::None
            }
        }

        // Handler functions
        fn handle_initial_contact(
            self: @ContractState,
            nps_morality: u8,
            power_diff: u32,
            has_valuable_cargo: bool,
            player_seems_weak: bool,
            player_seems_dangerous: bool
        ) -> NPSAction {
            if nps_morality < 30 {
                if power_diff > 2000 || player_seems_weak {
                    NPSAction::Demand
                } else if power_diff > 0 {
                    NPSAction::Threaten
                } else if player_seems_dangerous {
                    NPSAction::Hail
                } else {
                    NPSAction::Threaten
                }
            } else if nps_morality < 70 {
                if has_valuable_cargo && power_diff > 1000 {
                    NPSAction::Demand
                } else if player_seems_dangerous {
                    NPSAction::ActivateShields
                } else {
                    NPSAction::Hail
                }
            } else {
                NPSAction::Hail
            }
        }

        fn handle_hail(
            self: @ContractState,
            nps_morality: u8,
            power_diff: u32,
            has_valuable_cargo: bool,
            player_seems_weak: bool,
            player_seems_dangerous: bool
        ) -> NPSAction {
            if nps_morality < 20 && has_valuable_cargo && !player_seems_dangerous {
                NPSAction::Demand
            } else if nps_morality < 50 && power_diff > 3000 && player_seems_weak {
                NPSAction::Threaten
            } else if player_seems_dangerous && nps_morality < 60 {
                NPSAction::Negotiate
            } else {
                NPSAction::Hail
            }
        }

        fn handle_surrender(
            self: @ContractState,
            nps_morality: u8,
            nps_hull: u32,
            player_seems_dangerous: bool
        ) -> NPSAction {
            if nps_morality < 30 {
                if nps_hull < nps_hull / 2 {
                    NPSAction::Rob
                } else if player_seems_dangerous {
                    NPSAction::AcceptBribe
                } else {
                    NPSAction::Rob
                }
            } else {
                NPSAction::AcceptBribe
            }
        }

        fn handle_bribe(
            self: @ContractState,
            nps_morality: u8,
            power_diff: u32,
            player_seems_dangerous: bool
        ) -> NPSAction {
            if nps_morality < 40 && !player_seems_dangerous {
                if power_diff > 2000 {
                    NPSAction::Demand
                } else {
                    NPSAction::AcceptBribe
                }
            } else if player_seems_dangerous && nps_morality < 60 {
                NPSAction::AcceptBribe
            } else {
                NPSAction::AcceptBribe
            }
        }

        fn handle_negotiation(
            self: @ContractState,
            nps_morality: u8,
            power_diff:u32,
            player_seems_weak: bool,
            player_seems_dangerous: bool
        ) -> NPSAction {
            if nps_morality < 25 && !player_seems_dangerous {
                NPSAction::Threaten
            } else if nps_morality < 60 {
                if power_diff > 1500 && player_seems_weak {
                    NPSAction::Demand
                } else if player_seems_dangerous {
                    NPSAction::Negotiate
                } else {
                    NPSAction::Negotiate
                }
            } else {
                NPSAction::Negotiate
            }
        }

        fn handle_threat(
            self: @ContractState,
            nps_morality: u8,
            power_diff: u32,
            player_seems_weak: bool,
            player_seems_dangerous: bool
        ) -> NPSAction {
            if power_diff > 3000 && !player_seems_dangerous {
                NPSAction::OpenFire
            } else if power_diff > 0 && player_seems_weak {
                NPSAction::Threaten
            } else if player_seems_dangerous {
                if power_diff > 1000 {
                    NPSAction::Threaten
                } else {
                    NPSAction::Negotiate
                }
            } else {
                if nps_morality < 40 {
                    NPSAction::Negotiate
                } else {
                    NPSAction::Retreat
                }
            }
        }

        fn handle_combat(
            self: @ContractState,
            nps_morality: u8,
            power_diff: u32,
            has_valuable_cargo: bool,
            player_seems_dangerous: bool,
            nps_hull: u32
        ) -> NPSAction {
            if nps_hull < 30 || power_diff <  2000 {
                if nps_morality > 60 {
                    NPSAction::Retreat
                } else {
                    NPSAction::Burn
                }
            } else if power_diff > 1000 {
                if player_seems_dangerous && nps_morality > 50 {
                    NPSAction::Disable
                } else {
                    NPSAction::Destroy
                }
            } else if has_valuable_cargo && nps_morality < 50 {
                NPSAction::Disable
            } else {
                NPSAction::OpenFire
            }
        }

        fn handle_shields(
            self: @ContractState,
            nps_morality: u8,
            power_diff: u32,
            player_seems_weak: bool,
            player_seems_dangerous: bool
        ) -> NPSAction {
            if nps_morality < 30 && power_diff > 2000 && !player_seems_dangerous {
                NPSAction::OpenFire
            } else if power_diff > 1000 && player_seems_weak {
                NPSAction::Threaten
            } else {
                NPSAction::ActivateShields
            }
        }

        fn handle_escape(
            self: @ContractState,
            nps_morality: u8,
            power_diff: u32,
            has_valuable_cargo: bool,
            player_seems_weak: bool,
            player_seems_dangerous: bool
        ) -> NPSAction {
            if nps_morality < 30 && has_valuable_cargo && power_diff > 0 {
                if player_seems_dangerous {
                    NPSAction::Hail
                } else {
                    NPSAction::OpenFire
                }
            } else if power_diff > 1500 && player_seems_weak {
                NPSAction::LaunchTorpedoes
            } else {
                NPSAction::Hail
            }
        }

        fn handle_boarding(self: @ContractState,power_diff: u32, nps_hull: u32) -> NPSAction {
            if power_diff <  1000 {
                NPSAction::SurrenderShip
            } else if nps_hull < 40 {
                NPSAction::RamEnemy
            } else {
                NPSAction::PrepareBoarding
            }
        }

        fn handle_total_surrender(
            self: @ContractState,
            nps_morality: u8,
            player_seems_dangerous: bool
        ) -> NPSAction {
            if nps_morality < 20 && !player_seems_dangerous {
                NPSAction::Destroy
            } else if nps_morality < 50 {
                NPSAction::Rob
            } else if player_seems_dangerous {
                NPSAction::Rob
            } else {
                NPSAction::AcceptBribe
            }
        }

        // Helper: Get faction-based morality
        fn get_faction_morality(self: @ContractState,faction: Faction) -> u8 {
            match faction {
                Faction::Pirates => 15,
                Faction::UN => 85,
                Faction::MarsFederation => 75,
                Faction::KuiperUnion => 60,
                Faction::Independent => 50,
                Faction::None => 50,
            }
        }

        // Helper: Calculate NPS Ship power level
        fn calculate_nps_ship_power(self: @ContractState,ship: Ship) -> u32 {
            let mut power: u32 = 0;
            
            power += ship.hull_points;
            power += ship.shield_points * 2;
            power += (ship.railguns.into() * 300);
            power += (ship.torpedoes.into() * 200);
            power += (ship.pdcs.into() * 100);
            power += (ship.crew_size / 10);
            
            power = match ship.s_class {
                ShipClass::Battleship => power * 2,
                ShipClass::Cruiser => (power * 3) / 2,
                ShipClass::Destroyer => (power * 5) / 4,
                ShipClass::Frigate => power,
                ShipClass::Corvette => (power * 3) / 4,
                ShipClass::PirateSkiff => (power * 2) / 3,
                ShipClass::Freighter => power / 2,
                ShipClass::Carrier => (power * 4) / 3,
                _ => power
            };
            
            power
        }

        // Helper: Calculate player Oberon power
        fn calculate_oberon_power(self: @ContractState,ship: ShipOberon) -> u32 {
            let mut power: u32 = 0;
            
            power += ship.hull;
            power += ship.shield * 2;
            power += (ship.point_defense.into() * 100);
            power += (ship.torpedoes.into() * 200);
            if ship.railgun { power += 300; }
            power += (ship.crew_capacity.into() / 10);
            
            // Oberon morality affects perceived threat
            if ship.morarity < 30 {
                power += 200;
            } else if ship.morarity > 80 {
                power -= 100;
            }
            
            power
        }

        // Helper: Squared distance (no square root)
        fn squared_distance(self: @ContractState,x1: u256, y1: u256, x2: u256, y2: u256) -> u256 {
            let dx = if x2 > x1 { x2 - x1 } else { x1 - x2 };
            let dy = if y2 > y1 { y2 - y1 } else { y1 - y2 };
            (dx * dx) + (dy * dy)
        }

        // Weapon activation logic based on NPS action and situation
        fn determine_weapon_activation(
            self: @ContractState,
            action: NPSAction,
            nps_ship: Ship,
            player_ship: ShipOberon,
            player_torpedoes: u8,
            player_railguns: u8,
            player_pdcs: u8,
            power_diff: u32,
            has_valuable_cargo: bool,
            nps_morality: u8
        ) -> (u8, u8, u8) {
            let mut torpedoes: u8 = 0;
            let mut railguns: u8 = 0;
            let mut pdcs: u8 = 0;
            
            match action {
                NPSAction::OpenFire => {
                    // Standard combat response - balanced approach
                    if nps_ship.railguns > 0 { railguns = 1; }
                    if nps_ship.pdcs > 0 { pdcs = 1; }
                    
                    // Use torpedoes if player has shields or is tough
                    if (player_ship.shield > 50 || power_diff < 500) && nps_ship.torpedo_ammo > 0 {
                        torpedoes = 1;
                    }
                },
                
                NPSAction::Destroy => {
                    // All-out attack - use everything
                    if nps_ship.torpedoes > 0 && nps_ship.torpedo_ammo > 0 { torpedoes = 1; }
                    if nps_ship.railguns > 0 { railguns = 1; }
                    if nps_ship.pdcs > 0 { pdcs = 1; }
                },
                
                NPSAction::Disable => {
                    // Surgical strike - want to capture, not destroy
                    // Prioritize railguns (precision) over torpedoes (destructive)
                    if nps_ship.railguns > 0 { railguns = 1; }
                    if nps_ship.pdcs > 0 { pdcs = 1; }
                    
                    // Only use torpedoes if target has heavy shields
                    if player_ship.shield > 100 && nps_ship.torpedo_ammo > 0 {
                        torpedoes = 1;
                    }
                },
                
                NPSAction::LaunchTorpedoes => {
                    // Specific torpedo attack (long range or heavy target)
                    if nps_ship.torpedoes > 0 && nps_ship.torpedo_ammo > 0 {
                        torpedoes = 1;
                    }
                    // Backup with railguns if available
                    if nps_ship.railguns > 0 { railguns = 1; }
                },
                
                NPSAction::ActivatePDCs => {
                    // Defensive - PDCs for incoming threats
                    if nps_ship.pdcs > 0 { pdcs = 1; }
                    
                    // Counter player's torpedoes with our own
                    if player_torpedoes > 0 && nps_ship.torpedo_ammo > 0 {
                        torpedoes = 1;
                    }
                },
                
                NPSAction::Threaten => {
                    // Show of force - activate weapons but don't fire yet
                    // Return weapon readiness, not activation
                    // For now, just ready PDCs as warning
                    if nps_ship.pdcs > 0 { pdcs = 1; }
                },
                
                NPSAction::ActivateShields => {
                    // Defensive posture with point defense
                    if nps_ship.pdcs > 0 { pdcs = 1; }
                },
                
                NPSAction::PrepareBoarding => {
                    // Suppression fire to enable boarding
                    if nps_ship.pdcs > 0 { pdcs = 1; }
                    if nps_ship.railguns > 0 { railguns = 1; }
                },
                
                NPSAction::RamEnemy => {
                    // Kamikaze - fire everything
                    if nps_ship.torpedoes > 0 && nps_ship.torpedo_ammo > 0 { torpedoes = 1; }
                    if nps_ship.railguns > 0 { railguns = 1; }
                    if nps_ship.pdcs > 0 { pdcs = 1; }
                },
                
                _ => {
                    // Non-combat actions - no weapons
                    torpedoes = 0;
                    railguns = 0;
                    pdcs = 0;
                }
            }
            
            // Reactive defense - if player is firing, respond appropriately
            if player_torpedoes > 0 || player_railguns > 0 || player_pdcs > 0 {
                // Always activate PDCs if being attacked
                if nps_ship.pdcs > 0 { pdcs = 1; }
                
                // If player uses torpedoes, counter with our own
                if player_torpedoes > 0 && nps_ship.torpedo_ammo > 0 {
                    torpedoes = 1;
                }
                
                // If player uses railguns, return fire
                if player_railguns > 0 && nps_ship.railguns > 0 {
                    railguns = 1;
                }
            }
            
            // Smart weapon selection based on ship class
            match nps_ship.s_class {
                ShipClass::Battleship => {
                    // Battleships use all weapons
                    if torpedoes == 0 && nps_ship.torpedo_ammo > 0 && (action == NPSAction::OpenFire || action == NPSAction::Destroy) {
                        torpedoes = 1;
                    }
                },
                ShipClass::Frigate => {
                    // Frigates specialize in PDCs
                    if nps_ship.pdcs > 0 { pdcs = 1; }
                },
                ShipClass::Corvette => {
                    // Corvettes are hit-and-run, prefer railguns
                    if railguns == 0 && nps_ship.railguns > 0 && (action == NPSAction::OpenFire || action == NPSAction::Destroy) {
                        railguns = 1;
                    }
                },
                ShipClass::PirateSkiff => {
                    // Pirates conserve ammo unless sure win
                    if power_diff < 1000 && nps_morality < 40 {
                        torpedoes = 0;  // Save expensive torpedoes
                    }
                },
                _ => {}
            }
            
            (torpedoes, railguns, pdcs)
        }
    }
}

