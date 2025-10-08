use starknet::ContractAddress;
use charon::models::oberon::{ShipOberon,OberonScanner,OberonScanResult,OberonScanResultTrait,StationScanResult,StationScanResultTrait};
use charon::models::zones::{Zone,ZoneType,ZoneTypeTrait};
use charon::models::stations::{Station,MiniZoneStation,MiniZoneStationTrait,StationType,ScanData,StationScanner,ScanDataTrait};
use charon::models::ships::{Ship,Scanner,MiniZoneShip,MiniZoneShipTrait,Vec2,Faction,ShipClass};
use charon::models::engagements::{Engagement,EngagementTrait,PlayerAction,NPSAction,StationAction,PlayerStationAction,StationEngagement,StationEngagementTrait};
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

    fn engagement_ship(
        ref self: T,
        game_id: u32,
        target_ship: ContractAddress,
        player_action: PlayerAction,
        torpedo_active: u8,
        railguns_active: u8,
        pdcs_active: u8
    );

    fn engagement_station(
        ref self: T,
        game_id: u32,
        target_station: u64,
        player_action: PlayerStationAction,
        torpedo_active: u8,
        railguns_active: u8,
        pdcs_active: u8
    );


    
}

// dojo decorator
#[dojo::contract]
pub mod actions {

    use crate::models::oberon::ShipOberonTrait;
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
        ShipClass,
        StationAction,
        StationEngagementTrait,
        StationEngagement,
        PlayerStationAction,
        StationScanner,
        ScanData,
        ScanDataTrait,
        Vec2
    };

    use starknet::{ContractAddress, get_caller_address,get_block_timestamp};
    

    use dojo::model::{ModelStorage};
    use dojo::event::EventStorage;

    use core::num::traits::Zero;

    use charon::utils::{is_within_range_squared,calculate_distance_squared,is_valid_burn_distance,min_u8,min_u32_u8,max_u8,min_u32,max_u32};
    
    use charon::constants::{TORPEDO_BASE_DAMAGE,RAILGUN_BASE_DAMAGE,PDC_BASE_DAMAGE};

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

        let mut  player_ship: ShipOberon = world.read_model(player);
        assert(player_ship.point_defense == 0, 'Ship already exists');

        assert(player_ship.crew_capacity > 2, 'Ship Inoperable');

        // before making the move lets find assets in the minizone 

        let main_zone_type: ZoneType = ZoneTypeTrait::from_coordinates(location_x,location_y);

        let mini_zone_id = main_zone_type.get_global_mini_zone_id(location_x,location_y);

        // check for any ships 

        let mini_zone_ship: MiniZoneShip = world.read_model(mini_zone_id);

        let mini_zone_station: MiniZoneStation = world.read_model(mini_zone_id);

        let current_time = get_block_timestamp();

        let mut game: Game =  world.read_model(game_id);

        
        if (mini_zone_ship.ship != Zero::zero() && mini_zone_ship.is_active){

            let nps_ship: Ship = world.read_model(mini_zone_ship.ship);

            let mut engagement_id = game.engagements_count + 1;

            let nps_ship_scanner: Scanner = world.read_model(nps_ship.id);

            let oberon_scanner: OberonScanner = world.read_model(player_ship.ship);

            let engagement_range = nps_ship_scanner.max_range + oberon_scanner.max_range;

            //create engagement
            let engagement  = EngagementTrait::new(
                player,
                player_ship_id: player_ship.ship,
                nps_ship_id: nps_ship.id,
                current_time: current_time,
                engagement_range: engagement_range,
                player_hull: player_ship.hull,
                nps_hull: nps_ship.hull_points,
                player_shields: player_ship.shield,
                nps_shields: nps_ship.shield_points,
                nps_action: NPSAction::Hail
            );

            world.write_model(@engagement);

            game.engagements_count = engagement_id;

            world.write_model(@game);

        }

        player_ship.location.x = location_x;
        player_ship.location.y = location_y;

        world.write_model(@player_ship);


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

                let mut player_ship: ShipOberon = world.read_model(player);
                assert(player_ship.point_defense == 0, 'Ship already exists');

                let dis_squared = calculate_distance_squared(player_ship.location.x, player_ship.location.y, location_x, location_y);

                let is_valid_burn_dis = is_valid_burn_distance(dis_squared);

                assert(is_valid_burn_dis, 'Invalid burn range');

                let fuel_consumption = player_ship.calculate_fuel_consumption(dis_squared);

                assert(player_ship.fuel > fuel_consumption, 'Not Enough Fuel');


                // before making the move lets find assets in the minizone 

                let main_zone_type: ZoneType = ZoneTypeTrait::from_coordinates(location_x,location_y);

                let mini_zone_id = main_zone_type.get_global_mini_zone_id(location_x,location_y);

                // check for any ships 

                let mini_zone_ship: MiniZoneShip = world.read_model(mini_zone_id);

                let mini_zone_station: MiniZoneStation = world.read_model(mini_zone_id);

                let current_time = get_block_timestamp();

                let mut game: Game =  world.read_model(game_id);

                if (mini_zone_ship.ship != Zero::zero() && mini_zone_ship.is_active){

                        let nps_ship: Ship = world.read_model(mini_zone_ship.ship);

                        let nps_ship_scanner: Scanner = world.read_model(nps_ship.id);

                        let oberon_scanner: OberonScanner = world.read_model(player_ship.ship);

                        assert(oberon_scanner.scanner_health > 0, 'Scanner Damaged');

                        let engagement_range = nps_ship_scanner.max_range + oberon_scanner.max_range;

                        // if there is power to scan - passive scaner
                        if player_ship.power_available > oberon_scanner.power_cost{

                            let nps_stealth_rating: u8 = (nps_ship.shield_points % 100).try_into().unwrap();
                            
                            if oberon_scanner.stealth_detection >= nps_stealth_rating {
                                // Ship detected! Add to scanner result 

                                let mut scanner_result = OberonScanResultTrait::new(
                                    ship: player_ship.ship,
                                    vessel: nps_ship.id,
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

                                    // create station engagement

                                    let station_engagement = StationEngagementTrait::new(
                                            player,
                                            player_ship_id: player_ship.ship,
                                            station_id: station.id,
                                            current_time: current_time ,
                                            engagement_range: oberon_scanner.max_range,
                                            player_hull: player_ship.hull,
                                            player_shields: player_ship.shield,
                                            station_hull: station.hull,
                                            station_shields: station.shield,
                                    );

                                    world.write_model(@station_engagement);

                                    world.write_model(@scanner_result);

                                    world.write_model(@station_scan_res);

                                }
                                
                            }

                        }

                    //create engagement
                    let engagement  = EngagementTrait::new(
                        player,
                        player_ship_id: player_ship.ship,
                        nps_ship_id: nps_ship.id,
                        current_time: current_time,
                        engagement_range: engagement_range,
                        player_hull: player_ship.hull,
                        nps_hull: nps_ship.hull_points,
                        player_shields: player_ship.shield,
                        nps_shields: nps_ship.shield_points,
                        nps_action: NPSAction::Hail
                    );

                    let mut engagement_id = game.engagements_count + 1;

                    world.write_model(@engagement);

                    game.engagements_count = engagement_id;

        }
        
        if ((mini_zone_ship.ship == Zero::zero() || !mini_zone_ship.is_active) && (mini_zone_station.station != Zero::zero() && mini_zone_station.is_active)){

            let oberon_scanner: OberonScanner = world.read_model(player_ship.ship);

            assert(oberon_scanner.scanner_health > 0, 'Scanner Damaged');
             
             if player_ship.power_available > oberon_scanner.power_cost{

             }
            let station: Station = world.read_model(mini_zone_station.station);

            let station_scan_res = StationScanResultTrait::new(
                scanner_ship:  player_ship.ship,
                station_id: mini_zone_station.station,
                detection_time: current_time,
                distance: 0,
                confidence: oberon_scanner.scanner_health,
            );

            // create station engagement

            let station_engagement = StationEngagementTrait::new(
                    player,
                    player_ship_id: player_ship.ship,
                    station_id: station.id,
                    current_time: current_time ,
                    engagement_range: oberon_scanner.max_range,
                    player_hull: player_ship.hull,
                    player_shields: player_ship.shield,
                    station_hull: station.hull,
                    station_shields: station.shield,
            );

            world.write_model(@station_engagement);

            world.write_model(@station_scan_res);

        
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

        // How long will this take - if engagement is combat
        fn engagement_ship(
            ref self: ContractState,
            game_id: u32,
            target_ship: ContractAddress,
            player_action: PlayerAction,
            torpedo_active: u8,
            railguns_active: u8,
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

            // let engagement - be initiated by passive scans

            //create engagement
            let mut engagement: Engagement  = world.read_model(player);

            assert(engagement.nps_ship_id == target_ship,'Scan Vessel');

            let (nps_action,tors_Active,rails_active,pdcs_active) = self.nps_ship_action_res(
                ship_id: target_e_ship.id,
                target_ship: player_ship.ship,
                target_ship_action: player_action,
                torpedo_active: torpedo_active,
                railguns_active: railguns_active,
                pdcs_active: pdcs_active
            );

          engagement.player_action = player_action;
          engagement.nps_action = nps_action;

          if (torpedo_active > 0 || railguns_active> 0 || pdcs_active> 0){
             let (hull_damage, shield_damage, speed_loss, crew_casualties, power_damage) = self.calculate_damage_effects(
                target_e_ship,target_e_ship.location,player_ship.location,nps_action,
                torpedo_active,
                railguns_active,
                pdcs_active,
                torpedo_damage: TORPEDO_BASE_DAMAGE,
                railgun_damage: RAILGUN_BASE_DAMAGE,
                pdc_damage: PDC_BASE_DAMAGE
            );
          }

           

          world.write_model(@engagement);


        }

        fn engagement_station(
                ref self: ContractState,
                game_id: u32,
                target_station: u64,
                player_action: PlayerStationAction,
                torpedo_active: u8,
                railguns_active: u8,
                pdcs_active: u8
            ){
                                // Get the default world.
                let mut world = self.world_default();

                // Get the address of the current caller, possibly the player's address.
                let player = get_caller_address();

                let player_ship: ShipOberon = world.read_model(player);
                assert(player_ship.point_defense == 0, 'Ship already exists');

                let current_time = get_block_timestamp();

                let  scan_res: StationScanResult = world.read_model(player_ship.ship);

                let mut game: Game =  world.read_model(game_id);

                assert(target_station == scan_res.station_id, 'Scan station');

                let target_e_station: Station = world.read_model(target_station);

                let mut engagement_id = game.engagements_count + 1;

                let target_e_ship_scanner: StationScanner = world.read_model(target_e_station.id);

                let oberon_scanner: OberonScanner = world.read_model(player_ship.ship);

                let engagement_range = target_e_ship_scanner.max_range + oberon_scanner.max_range;

                let mut station_engagement = StationEngagementTrait::new(
                    player,
                    player_ship_id: player_ship.ship,
                    station_id: target_e_station.id,
                    current_time: current_time,
                    engagement_range: engagement_range,
                    player_hull: player_ship.hull,
                    player_shields: player_ship.shield,
                    station_hull: target_e_station.hull,
                    station_shields: target_e_station.shield,
                );

                station_engagement.player_action = player_action;

                let station_action = self.station_action_response(
                    player_ship.ship,
                    target_station,
                    player_action
                );

                station_engagement.station_action = station_action;

                world.write_model(@station_engagement);

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
            let (nps_stronger, power_diff) = self.compare_ship_power(nps_power, player_power);
            
            let nps_morality = self.get_faction_morality(nps_ship.faction);
            let player_morality = player_ship.morarity;
            
            let cargo_threshold = if nps_morality < 30 { 200 } else { 500 };
            let has_valuable_cargo = player_ship.cargo > cargo_threshold || player_ship.fuel > 1000;
            
            let player_seems_weak = player_morality > 70;
            let player_seems_dangerous = player_morality < 30;
            
            // Determine response based on player action
            let action = self.determine_nps_response(
                target_ship_action,
                nps_ship,
                nps_morality,
                player_morality,
                nps_stronger,
                power_diff,
                has_valuable_cargo,
                player_seems_weak,
                player_seems_dangerous,
                nps_ship.hull_points,
                torpedo_active,
                railguns_active,
                pdcs_active
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
            nps_ship: Ship,
            nps_morality: u8,
            player_morality: u8,
            nps_stronger: bool,
            power_diff: u32,
            has_valuable_cargo: bool,
            player_seems_weak: bool,
            player_seems_dangerous: bool,
            nps_hull: u32,
            player_torpedoes_incoming: u8,
            player_railguns_active: u8,
            player_pdcs_active: u8,
        ) -> NPSAction {
            match player_action {
                PlayerAction::None => self.handle_initial_contact(
                    nps_morality,nps_stronger, power_diff, has_valuable_cargo, 
                    player_seems_weak, player_seems_dangerous
                ),
                PlayerAction::Hail => self.handle_hail(
                    nps_morality,nps_stronger, power_diff, has_valuable_cargo,
                    player_seems_weak, player_seems_dangerous
                ),
                PlayerAction::Comply | PlayerAction::SurrenderCargo => self.handle_surrender(
                    nps_morality, nps_hull, player_seems_dangerous
                ),
                PlayerAction::PayBribe => self.handle_bribe(
                    nps_morality,nps_stronger, power_diff, player_seems_dangerous
                ),
                PlayerAction::Negotiate => self.handle_negotiation(
                    nps_morality,nps_stronger, power_diff, player_seems_weak, player_seems_dangerous
                ),
                PlayerAction::Threaten => self.handle_threat(
                    nps_morality,nps_stronger, power_diff, player_seems_weak, player_seems_dangerous
                ),
                PlayerAction::OpenFire | PlayerAction::LaunchTorpedoes | PlayerAction::ActivatePDCs => {
                   self.handle_combat(
                        nps_ship,nps_morality,nps_stronger, power_diff, has_valuable_cargo,
                        player_seems_dangerous,player_torpedoes_incoming,
                        player_railguns_active,
                        player_pdcs_active,
                    )
                },
                PlayerAction::ActivateShields => self.handle_shields(
                    nps_morality,nps_stronger, power_diff, player_seems_weak, player_seems_dangerous
                ),
                PlayerAction::Burn => self.handle_escape(
                    nps_morality,nps_stronger, power_diff, has_valuable_cargo,
                    player_seems_weak, player_seems_dangerous
                ),
                PlayerAction::PrepareBoarding => self.handle_boarding(nps_morality,nps_stronger,power_diff, nps_hull,has_valuable_cargo),
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
            nps_stronger: bool,
            power_diff: u32,
            has_valuable_cargo: bool,
            player_seems_weak: bool,
            player_seems_dangerous: bool
        ) -> NPSAction {
            if nps_morality < 30 {
                if (nps_stronger && power_diff > 2000) || player_seems_weak {
                    NPSAction::Demand
                } else if nps_stronger && power_diff > 0 {
                    NPSAction::Threaten
                } else if player_seems_dangerous {
                    NPSAction::Hail
                } else {
                    NPSAction::Threaten
                }
            } else if nps_morality < 70 {
                if has_valuable_cargo && nps_stronger && power_diff > 1000 {
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
            nps_stronger: bool,
            power_diff: u32,
            has_valuable_cargo: bool,
            player_seems_weak: bool,
            player_seems_dangerous: bool
        ) -> NPSAction {
            // Extremely hostile (< 20) - betrayal after hail
            if nps_morality < 20 {
                if has_valuable_cargo && !player_seems_dangerous && nps_stronger {
                    NPSAction::Demand  // "Thanks for stopping... now hand it over"
                } else if player_seems_weak && nps_stronger && power_diff > 1500 {
                    NPSAction::Demand  // Easy prey
                } else if player_seems_dangerous || !nps_stronger {
                    NPSAction::Retreat  // Abort, they're too strong or we're outmatched
                } else {
                    NPSAction::Threaten  // Intimidation tactics
                }
            }
            // Low morality (20-50) - opportunistic
            else if nps_morality < 50 {
                if has_valuable_cargo && nps_stronger && power_diff > 3000 && player_seems_weak {
                    NPSAction::Demand  // Big advantage = take the risk
                } else if nps_stronger && power_diff > 2000 && player_seems_weak {
                    NPSAction::Threaten  // Test their resolve
                } else if player_seems_dangerous && !nps_stronger {
                    NPSAction::Retreat  // Outmatched, retreat
                } else if player_seems_dangerous {
                    NPSAction::Negotiate  // Better to trade than fight
                } else {
                    NPSAction::Negotiate  // Open to deals
                }
            }
            // Neutral (50-70) - cautious trader
            else if nps_morality < 70 {
                if player_seems_dangerous && !nps_stronger {
                    NPSAction::Burn  // Full throttle escape from superior force
                } else if player_seems_dangerous {
                    NPSAction::ActivateShields  // Defensive posture when stronger
                } else {
                    NPSAction::Negotiate  // Normal trade relations
                }
            }
            // Lawful/friendly (≥ 70)
            else {
                if player_seems_weak {
                    NPSAction::Negotiate  // Offer assistance through dialogue
                } else if player_seems_dangerous && !nps_stronger {
                    NPSAction::Retreat  // Even good ships retreat from overwhelming force
                } else if player_seems_dangerous {
                    NPSAction::Negotiate  // Diplomatic even with danger when stronger
                } else {
                    NPSAction::Negotiate  // Standard friendly interaction
                }
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
        nps_stronger: bool,
        power_diff: u32,
        player_seems_dangerous: bool
    ) -> NPSAction {
        // Extremely hostile (< 20) - greedy and treacherous
        if nps_morality < 20 {
            if nps_stronger && power_diff > 3000 && !player_seems_dangerous {
                NPSAction::Demand  // "Not enough, give me everything"
            } else if player_seems_dangerous || !nps_stronger {
                NPSAction::AcceptBribe  // Take the money and run
            } else if nps_stronger && power_diff > 1500 {
                NPSAction::Threaten  // "I'll take the bribe AND more"
            } else {
                NPSAction::AcceptBribe  // Take what you can get
            }
        }
        // Low morality (20-40) - corrupt but practical
        else if nps_morality < 40 {
            if nps_stronger && power_diff > 2000 && !player_seems_dangerous {
                NPSAction::Demand  // Push for more
            } else {
                NPSAction::AcceptBribe  // Money talks
            }
        }
        // Medium morality (40-60) - pragmatic
        else if nps_morality < 60 {
            if player_seems_dangerous {
                NPSAction::AcceptBribe  // Not worth the risk
            } else if nps_stronger && power_diff > 4000 {
                NPSAction::Demand  // Significant advantage, press it
            } else {
                NPSAction::AcceptBribe  // Fair deal
            }
        }
        // High morality (60-80) - reluctant but reasonable
        else if nps_morality < 80 {
            if player_seems_dangerous || !nps_stronger {
                NPSAction::AcceptBribe  // Practical decision
            } else {
                NPSAction::Negotiate  // "Let's talk this through properly"
            }
        }
        // Very high morality (≥ 80) - lawful/principled
        else {
            if player_seems_dangerous && !nps_stronger {
                NPSAction::AcceptBribe  // Survival instinct overrides principles
            } else {
                NPSAction::Negotiate  // "I don't take bribes, but we can talk"
            }
        }
    }

    fn handle_negotiation(
        self: @ContractState,
        nps_morality: u8,
        nps_stronger: bool,
        power_diff: u32,
        player_seems_weak: bool,
        player_seems_dangerous: bool
    ) -> NPSAction {
        // Extremely hostile (< 20) - bad faith negotiation
        if nps_morality < 20 {
            if nps_stronger && power_diff > 2500 && !player_seems_dangerous {
                NPSAction::Demand  // "Negotiation over, give me everything"
            } else if nps_stronger && power_diff > 1000 && player_seems_weak {
                NPSAction::Threaten  // Intimidation during talks
            } else if player_seems_dangerous || !nps_stronger {
                NPSAction::Negotiate  // Actually negotiate when outmatched
            } else {
                NPSAction::Threaten  // Default to threats
            }
        }
        // Low morality (20-40) - opportunistic negotiator
        else if nps_morality < 40 {
            if nps_stronger && power_diff > 2000 && player_seems_weak {
                NPSAction::Demand  // Leverage advantage
            } else if nps_stronger && power_diff > 1000 {
                NPSAction::Threaten  // Apply pressure
            } else if player_seems_dangerous {
                NPSAction::Negotiate  // Fair dealing with dangerous targets
            } else {
                NPSAction::Negotiate  // Normal negotiation
            }
        }
        // Medium morality (40-60) - pragmatic trader
        else if nps_morality < 60 {
            if nps_stronger && power_diff > 3000 && player_seems_weak {
                NPSAction::Demand  // Massive advantage = harder terms
            } else if player_seems_dangerous && !nps_stronger {
                NPSAction::Negotiate  // Respectful when outmatched
            } else {
                NPSAction::Negotiate  // Standard fair negotiation
            }
        }
        // High morality (60-80) - honest dealer
        else if nps_morality < 80 {
            if player_seems_dangerous && !nps_stronger {
                NPSAction::Negotiate  // Respectful even when threatened
            } else if player_seems_weak && nps_stronger {
                NPSAction::Negotiate  // Fair even with advantage
            } else {
                NPSAction::Negotiate  // Always negotiates in good faith
            }
        }
        // Very high morality (≥ 80) - honorable
        else {
            NPSAction::Negotiate  // Always negotiates fairly, regardless of power
        }
    }

        fn handle_threat(
            self: @ContractState,
            nps_morality: u8,
            nps_stronger: bool,
            power_diff: u32,
            player_seems_weak: bool,
            player_seems_dangerous: bool
        ) -> NPSAction {
            // Extremely hostile (< 20) - aggressive escalation
            if nps_morality < 20 {
                if nps_stronger && power_diff > 3000 && !player_seems_dangerous {
                    NPSAction::OpenFire  // Overwhelming advantage, attack immediately
                } else if nps_stronger && power_diff > 1500 && player_seems_weak {
                    NPSAction::Demand  // Force compliance with violence threat
                } else if nps_stronger && power_diff > 500 {
                    NPSAction::Threaten  // Continue threats with any advantage
                } else if player_seems_dangerous || !nps_stronger {
                    NPSAction::Retreat  // Back down when outmatched
                } else {
                    NPSAction::Threaten  // Keep posturing
                }
            }
            // Low morality (20-40) - willing to escalate
            else if nps_morality < 40 {
                if nps_stronger && power_diff > 4000 && !player_seems_dangerous {
                    NPSAction::OpenFire  // Massive advantage, follow through
                } else if nps_stronger && power_diff > 2000 && player_seems_weak {
                    NPSAction::Demand  // Press advantage
                } else if nps_stronger && power_diff > 1000 {
                    NPSAction::Threaten  // Maintain pressure
                } else if player_seems_dangerous || !nps_stronger {
                    NPSAction::Negotiate  // Back down diplomatically
                } else {
                    NPSAction::Threaten  // Continue bluffing
                }
            }
            // Medium morality (40-60) - cautious aggressor
            else if nps_morality < 60 {
                if nps_stronger && power_diff > 5000 && player_seems_weak {
                    NPSAction::Demand  // Only push with massive advantage
                } else if nps_stronger && power_diff > 2000 {
                    NPSAction::Threaten  // Continue posturing
                } else if player_seems_dangerous || !nps_stronger {
                    NPSAction::Negotiate  // De-escalate when risky
                } else {
                    NPSAction::Negotiate  // Prefer peaceful resolution
                }
            }
            // High morality (60-80) - reluctant threatener
            else if nps_morality < 80 {
                if player_seems_dangerous && !nps_stronger {
                    NPSAction::Retreat  // Strategic withdrawal
                } else if nps_stronger && power_diff > 3000 {
                    NPSAction::ActivateShields  // Defensive posture only
                } else {
                    NPSAction::Negotiate  // Always try to talk it out
                }
            }
            // Very high morality (≥ 80) - defensive only
            else {
                if player_seems_dangerous && !nps_stronger {
                    NPSAction::Burn  // Emergency escape
                } else if nps_stronger {
                    NPSAction::ActivateShields  // Defensive only, even when stronger
                } else {
                    NPSAction::Retreat  // Withdraw peacefully
                }
            }
        }

        fn handle_combat(
            self: @ContractState,
            nps_ship: Ship,
            nps_morality: u8,
            nps_stronger: bool,
            power_diff: u32,
            has_valuable_cargo: bool,
            player_seems_dangerous: bool,
            // INCOMING THREATS
            player_torpedoes_incoming: u8,
            player_railguns_active: u8,
            player_pdcs_active: u8,
        ) -> NPSAction {
            
            // CRITICAL: Incoming torpedoes - highest threat priority
            if player_torpedoes_incoming > 0 {
                return self.handle_incoming_torpedoes(
                    nps_ship,
                    nps_morality,
                    nps_stronger,
                    power_diff,
                    player_torpedoes_incoming
                );
            }
            
            // HIGH THREAT: Heavy railgun fire
            if player_railguns_active > 3 {
                return self.handle_heavy_railgun_fire(
                    nps_ship,
                    nps_morality,
                    nps_stronger,
                    power_diff
                );
            }
            
            // MODERATE THREAT: Railgun fire
            if player_railguns_active > 0 {
                return self.handle_railgun_fire(
                    nps_ship,
                    nps_morality,
                    nps_stronger,
                    power_diff
                );
            }
            
            // LOW THREAT: Only PDCs active (defensive posture or weak attack)
            if player_pdcs_active > 0 {
                return self.handle_pdc_fire(
                    nps_ship,
                    nps_morality,
                    nps_stronger,
                    power_diff
                );
            }
            
            // No incoming fire - shouldn't reach here in combat
            NPSAction::ActivateShields
        }

            // React to incoming torpedoes - CRITICAL THREAT
        fn handle_incoming_torpedoes(
        self: @ContractState,
        nps_ship: Ship,
        nps_morality: u8,
        nps_stronger: bool,
        power_diff: u32,
        torpedo_count: u8
        ) -> NPSAction {

        match nps_ship.s_class {
            ShipClass::Carrier | ShipClass::Frigate => {
                // PDS specialists - intercept with point defense
                NPSAction::ActivatePDCs
            },
            ShipClass::Battleship | ShipClass::Cruiser => {
                // Capital ships - can tank some hits, counter-attack
                if torpedo_count >= 3 {
                    // Heavy torpedo barrage - activate all defenses
                    NPSAction::ActivatePDCs
                } else if nps_stronger && power_diff > 2000 {
                    // We're winning - counter with our own torpedoes
                    NPSAction::LaunchTorpedoes
                } else {
                    // Defensive PDCs
                    NPSAction::ActivatePDCs
                }
            },
            ShipClass::Destroyer => {
                // Balanced response
                if torpedo_count >= 2 {
                    NPSAction::ActivatePDCs  // Prioritize defense
                } else if nps_stronger {
                    NPSAction::LaunchTorpedoes  // Counter-strike
                } else {
                    NPSAction::ActivatePDCs
                }
            },
            ShipClass::Corvette => {
                // Fast ship - evade or burn
                if nps_ship.pdcs >= 2 {
                    NPSAction::ActivatePDCs  // Try to shoot them down
                } else {
                    NPSAction::Burn  // Can't intercept, run!
                }
            },
            ShipClass::Freighter => {
                // Civilian ship - panic
                if nps_morality > 60 {
                    NPSAction::SurrenderShip  // Give up
                } else {
                    NPSAction::Burn  // Run for your life
                }
            },
            ShipClass::PirateSkiff => {
                // Pirates - depends on situation
                if nps_stronger && power_diff > 1500 {
                    NPSAction::LaunchTorpedoes  // Fight back
                } else if torpedo_count >= 2 {
                    NPSAction::Burn  // Too many, escape!
                } else {
                    NPSAction::ActivatePDCs  // Try to intercept
                }
            },
            _ => NPSAction::ActivatePDCs
        }
        }

        // React to heavy railgun fire (4+ railguns)
        fn handle_heavy_railgun_fire(
        self: @ContractState,
        nps_ship: Ship,
        nps_morality: u8,
        nps_stronger: bool,
        power_diff: u32
        ) -> NPSAction {

        match nps_ship.s_class {
            ShipClass::Battleship => {
                // Battleship can take it - return fire
                if nps_stronger {
                    NPSAction::Destroy  // Full counter-attack
                } else {
                    NPSAction::OpenFire  // Trade blows
                }
            },
            ShipClass::Cruiser | ShipClass::Destroyer => {
                // Capital ships - shields and counter
                if nps_ship.shield_points > 1000 {
                    NPSAction::OpenFire  // Shields can take it, return fire
                } else {
                    NPSAction::ActivateShields  // Need shields first
                }
            },
            ShipClass::Frigate | ShipClass::Corvette => {
                // Light ships - can't tank heavy railgun fire
                if nps_stronger && power_diff > 2000 {
                    NPSAction::OpenFire  // Fight back if winning
                } else {
                    NPSAction::Burn  // Get out of firing line
                }
            },
            ShipClass::Carrier => {
                // Carrier - not built for slugging matches
                NPSAction::ActivatePDCs  // Defensive
            },
            ShipClass::Freighter => {
                // Civilian - surrender or run
                if nps_morality > 50 {
                    NPSAction::SurrenderCargo  // Give them what they want
                } else {
                    NPSAction::Burn  // Escape attempt
                }
            },
            ShipClass::PirateSkiff => {
                // Pirates - hit and run
                if nps_stronger {
                    NPSAction::OpenFire  // Quick burst
                } else {
                    NPSAction::Burn  // Outgunned, retreat
                }
            },
            _ => NPSAction::ActivateShields
        }
        }

        // React to moderate railgun fire (1-3 railguns)
        fn handle_railgun_fire(
        self: @ContractState,
        nps_ship: Ship,
        nps_morality: u8,
        nps_stronger: bool,
        power_diff: u32
        ) -> NPSAction {

        match nps_ship.s_class {
            ShipClass::Battleship | ShipClass::Cruiser => {
                // Heavy ships - return fire
                NPSAction::OpenFire
            },
            ShipClass::Destroyer | ShipClass::Frigate => {
                // Medium ships - shields or fire back
                if nps_ship.shield_points < 500 {
                    NPSAction::ActivateShields
                } else {
                    NPSAction::OpenFire
                }
            },
            ShipClass::Corvette => {
                // Fast attack - hit and run
                if nps_stronger {
                    NPSAction::OpenFire
                } else {
                    NPSAction::Burn  // Evade
                }
            },
            ShipClass::Carrier => {
                // Defensive posture
                NPSAction::ActivatePDCs
            },
            ShipClass::Freighter => {
                // Minimal defense
                if nps_morality > 60 {
                    NPSAction::Comply  // Stop resisting
                } else {
                    NPSAction::ActivateShields
                }
            },
            ShipClass::PirateSkiff => {
                // Pirates - opportunistic
                if nps_stronger && power_diff > 1000 {
                    NPSAction::OpenFire  // We have advantage
                } else if nps_morality < 30 {
                    NPSAction::OpenFire  // Desperate fight
                } else {
                    NPSAction::Retreat  // Live to raid another day
                }
            },
            _ => NPSAction::ActivateShields
        }
        }

        // React to PDC fire only (minimal threat)
        fn handle_pdc_fire(
        self: @ContractState,
        nps_ship: Ship,
        nps_morality: u8,
        nps_stronger: bool,
        power_diff: u32
        ) -> NPSAction {

        // PDCs are defensive/suppressive - not a major threat
        match nps_ship.s_class {
            ShipClass::Battleship | ShipClass::Cruiser | ShipClass::Destroyer => {
                // Heavy ships - ignore PDCs, press attack
                if nps_stronger {
                    NPSAction::OpenFire
                } else {
                    NPSAction::ActivatePDCs  // Defensive counter
                }
            },
            ShipClass::Frigate => {
                // PDS specialist - counter with our PDCs
                NPSAction::ActivatePDCs
            },
            ShipClass::Corvette => {
                // Fast ship - press advantage if we have it
                if nps_stronger {
                    NPSAction::OpenFire
                } else {
                    NPSAction::Burn  // Reposition
                }
            },
            ShipClass::Carrier => {
                // Defensive stance
                NPSAction::ActivatePDCs
            },
            ShipClass::Freighter => {
                // Minimal response
                NPSAction::ActivateShields
            },
            ShipClass::PirateSkiff => {
                // Pirates - aggressive if winning
                if nps_stronger && power_diff > 1000 {
                    NPSAction::OpenFire  // Push attack
                } else {
                    NPSAction::ActivatePDCs  // Defensive
                }
            },
            _ => NPSAction::ActivatePDCs
        }
        }

        fn handle_shields(
            self: @ContractState,
            nps_morality: u8,
            nps_stronger: bool,
            power_diff: u32,
            player_seems_weak: bool,
            player_seems_dangerous: bool
        ) -> NPSAction {
            // Extremely hostile (< 20) - shields up means aggression
            if nps_morality < 20 {
                if nps_stronger && power_diff > 3000 && !player_seems_dangerous {
                    NPSAction::OpenFire  // Shields ready, attack now
                } else if nps_stronger && power_diff > 1500 && player_seems_weak {
                    NPSAction::Demand  // Shields give confidence to demand
                } else if nps_stronger && power_diff > 500 {
                    NPSAction::Threaten  // Aggressive posture
                } else if player_seems_dangerous || !nps_stronger {
                    NPSAction::ActivateShields  // Maintain defense
                } else {
                    NPSAction::ActivateShields  // Stay defensive
                }
            }
            // Low morality (20-40) - opportunistic with shields
            else if nps_morality < 40 {
                if nps_stronger && power_diff > 4000 && player_seems_weak {
                    NPSAction::Demand  // Press advantage from safety
                } else if nps_stronger && power_diff > 2000 {
                    NPSAction::Threaten  // Intimidate from behind shields
                } else if player_seems_dangerous && !nps_stronger {
                    NPSAction::Burn  // Escape while protected
                } else {
                    NPSAction::ActivateShields  // Maintain defensive stance
                }
            }
            // Medium morality (40-60) - defensive posture
            else if nps_morality < 60 {
                if nps_stronger && power_diff > 3000 && player_seems_weak {
                    NPSAction::Threaten  // Show strength
                } else if player_seems_dangerous && !nps_stronger {
                    NPSAction::Burn  // Protected retreat
                } else if !nps_stronger {
                    NPSAction::Retreat  // Tactical withdrawal with shields
                } else {
                    NPSAction::ActivateShields  // Hold position
                }
            }
            // High morality (60-80) - purely defensive
            else if nps_morality < 80 {
                if player_seems_dangerous && !nps_stronger {
                    NPSAction::Retreat  // Strategic withdrawal
                } else if nps_stronger && power_diff > 2000 {
                    NPSAction::Negotiate  // Negotiate from position of strength
                } else {
                    NPSAction::ActivateShields  // Maintain shields, await response
                }
            }
            // Very high morality (≥ 80) - defensive only
            else {
                if player_seems_dangerous && !nps_stronger {
                    NPSAction::Burn  // Emergency escape
                } else if player_seems_dangerous {
                    NPSAction::ActivateShields  // Shields stay up
                } else {
                    NPSAction::Negotiate  // Try to de-escalate
                }
            }
        }

        fn handle_escape(
            self: @ContractState,
            nps_morality: u8,
            nps_stronger: bool,
            power_diff: u32,
            has_valuable_cargo: bool,
            player_seems_weak: bool,
            player_seems_dangerous: bool
        ) -> NPSAction {
            // Extremely hostile (< 20) - aggressive pursuit
            if nps_morality < 20 {
                if nps_stronger && power_diff > 3000 && has_valuable_cargo {
                    NPSAction::LaunchTorpedoes  // Disable fleeing ship for cargo
                } else if nps_stronger && power_diff > 2000 && player_seems_weak {
                    NPSAction::OpenFire  // Shoot fleeing target
                } else if nps_stronger && power_diff > 1000 {
                    NPSAction::Demand  // "Stop or I'll shoot!"
                } else if player_seems_dangerous || !nps_stronger {
                    NPSAction::Hail  // Let them go
                } else {
                    NPSAction::Threaten  // Try to intimidate them to stop
                }
            }
            // Low morality (20-40) - opportunistic pursuit
            else if nps_morality < 40 {
                if nps_stronger && power_diff > 4000 && has_valuable_cargo {
                    NPSAction::LaunchTorpedoes  // Worth the risk for valuable cargo
                } else if nps_stronger && power_diff > 2500 && player_seems_weak {
                    NPSAction::Demand  // Try to force them to stop
                } else if nps_stronger && power_diff > 1500 {
                    NPSAction::Threaten  // Intimidate
                } else if player_seems_dangerous || !nps_stronger {
                    NPSAction::Hail  // Not worth chasing
                } else {
                    NPSAction::Hail  // Let them go
                }
            }
            // Medium morality (40-60) - reluctant pursuit
            else if nps_morality < 60 {
                if nps_stronger && power_diff > 5000 && has_valuable_cargo {
                    NPSAction::Demand  // Half-hearted attempt to stop them
                } else if nps_stronger && power_diff > 3000 {
                    NPSAction::Threaten  // Warning shot mentality
                } else {
                    NPSAction::Hail  // Let them escape
                }
            }
            // High morality (60-80) - no pursuit
            else if nps_morality < 80 {
                if player_seems_dangerous && nps_stronger {
                    NPSAction::ActivateShields  // Defensive in case they turn around
                } else {
                    NPSAction::Hail  // Friendly farewell
                }
            }
            // Very high morality (≥ 80) - never pursue
            else {
                NPSAction::Hail  // Let them go peacefully
            }
        }

        fn handle_boarding(
            self: @ContractState,
            nps_morality: u8,
            nps_stronger: bool,
            power_diff: u32,
            nps_hull: u32,
            has_valuable_cargo: bool
        ) -> NPSAction {
            // Critical damage - desperation
            if nps_hull < 30 {
                if nps_morality < 20 {
                    NPSAction::RamEnemy  // Kamikaze
                } else if nps_morality < 50 {
                    NPSAction::SurrenderShip  // Give up before death
                } else {
                    NPSAction::SurrenderShip  // Preserve crew lives
                }
            }
            // Losing badly - not stronger or minimal advantage
            else if !nps_stronger || power_diff < 500 {
                if nps_morality < 20 && nps_hull < 50 {
                    NPSAction::RamEnemy  // Desperate last stand
                } else if nps_morality < 40 {
                    NPSAction::BoardingAction  // Risky counter-boarding attempt
                } else if nps_morality < 70 {
                    NPSAction::SurrenderShip  // Smart surrender
                } else {
                    NPSAction::SurrenderShip  // Honorable surrender
                }
            }
            // Damaged but still fighting (hull 30-60)
            else if nps_hull < 60 {
                if nps_morality < 30 && nps_stronger && power_diff > 1500 {
                    NPSAction::PrepareBoarding  // Pirates fight wounded
                } else if nps_morality < 50 && nps_stronger && power_diff > 2000 {
                    NPSAction::PrepareBoarding  // Push through damage
                } else if nps_stronger && power_diff > 1000 {
                    NPSAction::ActivatePDCs  // Defensive holding action
                } else {
                    NPSAction::SurrenderShip  // Too damaged to continue
                }
            }
            // Good condition - strong position
            else if nps_stronger && power_diff > 2000 {
                if nps_morality < 30 {
                    NPSAction::PrepareBoarding  // Pirates board aggressively
                } else if nps_morality < 50 && has_valuable_cargo {
                    NPSAction::PrepareBoarding  // Board for cargo
                } else if nps_morality < 70 {
                    NPSAction::PrepareBoarding  // Standard boarding
                } else {
                    NPSAction::Demand  // Request surrender first
                }
            }
            // Moderate advantage
            else if nps_stronger && power_diff > 1000 {
                if nps_morality < 40 {
                    NPSAction::PrepareBoarding  // Aggressive boarding
                } else if nps_morality < 60 && has_valuable_cargo {
                    NPSAction::PrepareBoarding  // Worth the risk
                } else {
                    NPSAction::ActivatePDCs  // Hold defensive position
                }
            }
            // Small advantage or even
            else {
                if nps_morality < 30 && has_valuable_cargo {
                    NPSAction::BoardingAction  // Pirates risk it for cargo
                } else if nps_morality < 60 {
                    NPSAction::ActivatePDCs  // Defensive stance
                } else {
                    NPSAction::Negotiate  // Try to talk it out
                }
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
            player_torpedoes_incoming: u8,  // Torpedoes heading toward us
            player_railguns_active: u8,     // Player's railguns firing at us
            player_pdcs_active: u8,         // Player's PDCs active
            power_diff: u32,
            has_valuable_cargo: bool,
            nps_morality: u8
        ) -> (u8, u8, u8) {
            let mut torpedoes: u8 = 0;
            let mut railguns: u8 = 0;
            let mut pdcs: u8 = 0;
            
            match action {
                NPSAction::OpenFire => {
                    // Standard combat - moderate firepower
                    match nps_ship.s_class {
                        ShipClass::Battleship => {
                            railguns = min_u8(nps_ship.railguns, 4);
                            pdcs = min_u8(nps_ship.pdcs, 3);
                            if nps_ship.torpedo_ammo > 0 {
                                torpedoes = min_u8(nps_ship.torpedoes, 2);
                            }
                        },
                        ShipClass::Cruiser => {
                            railguns = min_u8(nps_ship.railguns, 3);
                            pdcs = min_u8(nps_ship.pdcs, 2);
                            if player_ship.shield > 50 && nps_ship.torpedo_ammo > 0 {
                                torpedoes = 1;
                            }
                        },
                        ShipClass::Destroyer => {
                            railguns = min_u8(nps_ship.railguns, 2);
                            pdcs = min_u8(nps_ship.pdcs, 2);
                            if nps_ship.torpedo_ammo > 0 {
                                torpedoes = 1;
                            }
                        },
                        ShipClass::Frigate => {
                            railguns = min_u8(nps_ship.railguns, 1);
                            pdcs = min_u8(nps_ship.pdcs, 4);
                            if nps_ship.torpedo_ammo > 2 {
                                torpedoes = 1;
                            }
                        },
                        ShipClass::Corvette => {
                            railguns = min_u8(nps_ship.railguns, 2);
                            pdcs = min_u8(nps_ship.pdcs, 1);
                        },
                        ShipClass::PirateSkiff => {
                            railguns = min_u8(nps_ship.railguns, 1);
                            pdcs = min_u8(nps_ship.pdcs, 1);
                            if power_diff > 1500 && nps_ship.torpedo_ammo > 0 {
                                torpedoes = 1;
                            }
                        },
                        ShipClass::Carrier => {
                            pdcs = min_u8(nps_ship.pdcs, 5);
                            railguns = min_u8(nps_ship.railguns, 1);
                        },
                        ShipClass::Freighter => {
                            pdcs = min_u8(nps_ship.pdcs, 1);
                        },
                        _ => {}
                    }
                },
                
                NPSAction::Destroy => {
                    // Full alpha strike - maximum firepower
                    match nps_ship.s_class {
                        ShipClass::Battleship => {
                            railguns = nps_ship.railguns;
                            pdcs = nps_ship.pdcs;
                            if nps_ship.torpedo_ammo >= 4 {
                                torpedoes = min_u8(nps_ship.torpedoes, 4);
                            }
                        },
                        ShipClass::Cruiser => {
                            railguns = nps_ship.railguns;
                            pdcs = min_u8(nps_ship.pdcs, 4);
                            if nps_ship.torpedo_ammo >= 2 {
                                torpedoes = min_u8(nps_ship.torpedoes, 3);
                            }
                        },
                        ShipClass::Destroyer => {
                            railguns = nps_ship.railguns;
                            pdcs = nps_ship.pdcs;
                            if nps_ship.torpedo_ammo >= 2 {
                                torpedoes = min_u8(nps_ship.torpedoes, 2);
                            }
                        },
                        ShipClass::Frigate => {
                            railguns = nps_ship.railguns;
                            pdcs = nps_ship.pdcs;
                            if nps_ship.torpedo_ammo >= 1 {
                                torpedoes = 1;
                            }
                        },
                        ShipClass::Corvette => {
                            railguns = nps_ship.railguns;
                            pdcs = nps_ship.pdcs;
                            if nps_ship.torpedo_ammo >= 1 {
                                torpedoes = 1;
                            }
                        },
                        ShipClass::PirateSkiff => {
                            railguns = nps_ship.railguns;
                            pdcs = nps_ship.pdcs;
                            if nps_ship.torpedo_ammo > 0 {
                                torpedoes = min_u8(nps_ship.torpedoes, 1);
                            }
                        },
                        ShipClass::Carrier => {
                            pdcs = nps_ship.pdcs;
                            railguns = nps_ship.railguns;
                        },
                        ShipClass::Freighter => {
                            pdcs = nps_ship.pdcs;
                            railguns = nps_ship.railguns;
                        },
                        _ => {}
                    }
                },
                
                NPSAction::Disable => {
                    // Precision strikes - want to capture, not destroy
                    match nps_ship.s_class {
                        ShipClass::Battleship => {
                            railguns = min_u8(nps_ship.railguns, 2);
                            pdcs = min_u8(nps_ship.pdcs, 2);
                            if player_ship.shield > 100 && nps_ship.torpedo_ammo > 0 {
                                torpedoes = 1;
                            }
                        },
                        ShipClass::Cruiser => {
                            railguns = min_u8(nps_ship.railguns, 2);
                            pdcs = min_u8(nps_ship.pdcs, 1);
                        },
                        ShipClass::Destroyer => {
                            railguns = min_u8(nps_ship.railguns, 2);
                            pdcs = min_u8(nps_ship.pdcs, 2);
                        },
                        ShipClass::Frigate => {
                            railguns = 1;
                            pdcs = min_u8(nps_ship.pdcs, 3);
                        },
                        ShipClass::Corvette => {
                            railguns = min_u8(nps_ship.railguns, 1);
                            pdcs = 1;
                        },
                        ShipClass::PirateSkiff => {
                            railguns = 1;
                            pdcs = 1;
                        },
                        _ => {
                            railguns = min_u8(nps_ship.railguns, 1);
                            pdcs = 1;
                        }
                    }
                },
                
                NPSAction::LaunchTorpedoes => {
                    // Torpedo-focused attack
                    if nps_ship.torpedo_ammo > 0 {
                        match nps_ship.s_class {
                            ShipClass::Battleship => {
                                torpedoes = min_u8(nps_ship.torpedoes, min_u8(nps_ship.torpedo_ammo, 3));
                                railguns = min_u8(nps_ship.railguns, 2);
                            },
                            ShipClass::Cruiser => {
                                torpedoes = min_u8(nps_ship.torpedoes, min_u8(nps_ship.torpedo_ammo, 2));
                                railguns = min_u8(nps_ship.railguns, 2);
                            },
                            ShipClass::Destroyer => {
                                torpedoes = min_u8(nps_ship.torpedoes, min_u8(nps_ship.torpedo_ammo, 2));
                                railguns = 1;
                            },
                            _ => {
                                torpedoes = min_u8(nps_ship.torpedoes, min_u8(nps_ship.torpedo_ammo, 1));
                                railguns = 1;
                            }
                        }
                    }
                },
                
                NPSAction::ActivatePDCs => {
                    // Defensive point defense - prioritize intercepting incoming threats
                    match nps_ship.s_class {
                        ShipClass::Carrier | ShipClass::Frigate => {
                            pdcs = nps_ship.pdcs;  // Full defensive suite
                        },
                        ShipClass::Battleship | ShipClass::Cruiser => {
                            pdcs = min_u8(nps_ship.pdcs, 4);
                        },
                        _ => {
                            pdcs = min_u8(nps_ship.pdcs, 2);
                        }
                    }
                    
                    // Counter-fire with torpedoes if we have spare capacity
                    if player_torpedoes_incoming == 0 && nps_ship.torpedo_ammo > 2 {
                        torpedoes = 1;
                    }
                },
                
                NPSAction::Threaten => {
                    // Show of force - limited weapon activation
                    match nps_ship.s_class {
                        ShipClass::Battleship => {
                            pdcs = min_u8(nps_ship.pdcs, 2);
                            railguns = 1;
                        },
                        _ => {
                            pdcs = min_u8(nps_ship.pdcs, 1);
                        }
                    }
                },
                
                NPSAction::ActivateShields => {
                    // Defensive posture with minimal point defense
                    pdcs = min_u8(nps_ship.pdcs, 1);
                },
                
                NPSAction::PrepareBoarding => {
                    // Suppression fire to enable boarding
                    match nps_ship.s_class {
                        ShipClass::Battleship | ShipClass::Cruiser => {
                            pdcs = min_u8(nps_ship.pdcs, 3);
                            railguns = min_u8(nps_ship.railguns, 2);
                        },
                        _ => {
                            pdcs = min_u8(nps_ship.pdcs, 2);
                            railguns = 1;
                        }
                    }
                },
                
                NPSAction::RamEnemy => {
                    // Kamikaze - fire everything you have
                    torpedoes = min_u8(nps_ship.torpedoes, nps_ship.torpedo_ammo);
                    railguns = nps_ship.railguns;
                    pdcs = nps_ship.pdcs;
                },
                
                _ => {
                    // Non-combat actions
                    torpedoes = 0;
                    railguns = 0;
                    pdcs = 0;
                }
            }
            
            // CRITICAL DEFENSIVE LOGIC - React to incoming threats
            if player_torpedoes_incoming > 0 || player_railguns_active > 0 || player_pdcs_active > 0 {
                // PRIORITY 1: Intercept incoming torpedoes with PDCs
                if player_torpedoes_incoming > 0 {
                    let pdc_intercept_capacity = match nps_ship.s_class {
                        ShipClass::Carrier | ShipClass::Frigate => nps_ship.pdcs,  // PDS specialists
                        ShipClass::Battleship => min_u8(nps_ship.pdcs, 6),
                        ShipClass::Cruiser => min_u8(nps_ship.pdcs, 5),
                        _ => min_u8(nps_ship.pdcs, 3)
                    };
                    // Allocate PDCs to intercept - try to match incoming torpedo count
                    pdcs = max_u8(pdcs, min_u8(pdc_intercept_capacity, player_torpedoes_incoming));
                }
                
                // PRIORITY 2: Counter heavy railgun fire with our own
                if player_railguns_active > 2 && nps_ship.railguns > 0 {
                    // Player is hitting us hard with railguns, return fire
                    let counter_railguns = min_u8(nps_ship.railguns, player_railguns_active);
                    railguns = max_u8(railguns, counter_railguns);
                }
                
                // PRIORITY 3: Launch counter-torpedoes if being heavily attacked
                if player_torpedoes_incoming > 2 && nps_ship.torpedo_ammo > 3 && torpedoes == 0 {
                    // Heavy torpedo attack - counter with our own offensive strike
                    torpedoes = min_u8(2, nps_ship.torpedoes);
                }
                
                // Boost PDCs baseline when under any fire
                if player_pdcs_active > 0 || player_railguns_active > 0 {
                    let defensive_pdcs = match nps_ship.s_class {
                        ShipClass::Carrier | ShipClass::Frigate => min_u8(nps_ship.pdcs, 4),
                        _ => min_u8(nps_ship.pdcs, 2)
                    };
                    pdcs = max_u8(pdcs, defensive_pdcs);
                }
            }
            
            // Ammo conservation for pirates
            if nps_ship.faction == Faction::Pirates && nps_morality < 40 {
                if power_diff < 1000 && player_torpedoes_incoming == 0 {
                    torpedoes = min_u8(torpedoes, 1);  // Save ammo unless under heavy attack
                }
            }
            
            // Low torpedo ammo warning - conserve unless critical
            if nps_ship.torpedo_ammo < 3 && action != NPSAction::Destroy && action != NPSAction::RamEnemy && player_torpedoes_incoming < 2 {
                torpedoes = min_u8(torpedoes, 1);
            }
            
            (torpedoes, railguns, pdcs)
        }



         fn station_action_response(
            ref self: ContractState,
            player_ship_id: ContractAddress,
            station_id: u64,
            player_action: PlayerStationAction
        ) -> StationAction {
            let mut world = self.world_default();
            
            let player_ship: ShipOberon = world.read_model(player_ship_id);
            let station: Station = world.read_model(station_id);
            
            // Calculate station's assessment of the player
            let player_threat_level = self.calculate_player_threat(player_ship);
            let station_strength = self.calculate_station_strength(station);
            let power_diff = station_strength - player_threat_level;
            
            // Determine station's tolerance based on type and player morality
            let station_tolerance = self.get_station_tolerance(station.station_type);
            let player_morality = player_ship.morarity;
            
            // Check if player seems hostile or suspicious
            let player_seems_hostile = player_morality < 30;
            let player_seems_lawful = player_morality > 70;
            
            // Determine station response
            self.determine_station_response(
                player_action,
                station.station_type,
                station_tolerance,
                player_morality,
                player_seems_hostile,
                player_seems_lawful,
                power_diff,
                station.defense_level
            )
        }

        // Main decision logic for station responses
        fn determine_station_response(
            self: @ContractState,
            player_action: PlayerStationAction,
            station_type: StationType,
            tolerance: u8,
            player_morality: u8,
            player_seems_hostile: bool,
            player_seems_lawful: bool,
            power_diff: u32,
            defense_level: u16
        ) -> StationAction {
            match player_action {
                PlayerStationAction::None => {
                    // Initial contact - station hails
                    StationAction::Hail
                },
                
                PlayerStationAction::RequestDocking => {
                    self.handle_docking_request(
                        station_type,
                        tolerance,
                        player_morality,
                        player_seems_hostile,
                        player_seems_lawful,
                        power_diff
                    )
                },
                
                PlayerStationAction::ProvideClearance => {
                    self.handle_clearance(
                        station_type,
                        player_seems_lawful,
                        player_seems_hostile
                    )
                },
                
                PlayerStationAction::PayDockingFee => {
                    // Payment accepted - grant docking
                    StationAction::GrantDocking
                },
                
                PlayerStationAction::BribeOfficer => {
                    self.handle_bribe_station(
                        station_type,
                        tolerance,
                        player_morality,
                        power_diff
                    )
                },
                
                PlayerStationAction::FalsifyCredentials => {
                    self.handle_false_credentials(
                        station_type,
                        defense_level,
                        player_seems_hostile
                    )
                },
                
                PlayerStationAction::RequestTrade => {
                    self.handle_trade_request(station_type, player_morality)
                },
                
                PlayerStationAction::RequestRefuel => {
                    self.handle_refuel_request(station_type, player_morality)
                },
                
                PlayerStationAction::RequestRepairs => {
                    self.handle_repair_request(station_type, player_morality)
                },
                
                PlayerStationAction::RequestUpgrade => {
                    self.handle_upgrade_request(station_type, player_morality)
                },
                
                PlayerStationAction::DumpCargo => {
                    // Suspicious behavior - scan the ship
                    if player_seems_hostile {
                        StationAction::AlertAuthorities
                    } else {
                        StationAction::ScanShip
                    }
                },
                
                PlayerStationAction::ForceEntry => {
                    self.handle_force_entry(power_diff, defense_level)
                },
                
                PlayerStationAction::AttackStation => {
                    self.handle_station_attack(power_diff, defense_level, station_type)
                },
                
                PlayerStationAction::HackDockingBay => {
                    self.handle_hacking_attempt(defense_level, station_type)
                },
                
                PlayerStationAction::EmergencyUndock => {
                    // Let them go but might alert authorities
                    if player_seems_hostile {
                        StationAction::AlertAuthorities
                    } else {
                        StationAction::None
                    }
                },
                
                PlayerStationAction::Withdraw => {
                    // Peaceful withdrawal
                    StationAction::None
                },
                
                PlayerStationAction::SurrenderToAuthority => {
                    StationAction::NegotiateSurrender
                },
                
                _ => StationAction::None
            }
        }

        // Handle docking request based on station type and player reputation
        fn handle_docking_request(
            self: @ContractState,
            station_type: StationType,
            tolerance: u8,
            player_morality: u8,
            player_seems_hostile: bool,
            player_seems_lawful: bool,
            power_diff: u32
        ) -> StationAction {
            match station_type {
                StationType::MilitaryBase => {
                    // Military bases are strict
                    if player_seems_hostile {
                        StationAction::DenyDocking
                    } else if player_morality < 50 {
                        StationAction::DemandIdentification
                    } else {
                        StationAction::ScanShip
                    }
                },
                
                StationType::SmugglerDen => {
                    // Smuggler dens prefer outlaws
                    if player_seems_lawful {
                        StationAction::DenyDocking  // Too clean, suspicious
                    } else if player_seems_hostile && power_diff > 500 {
                        StationAction::GrantDocking  // Dangerous but station is stronger
                    } else if player_seems_hostile && power_diff < 0 {
                        StationAction::GrantDocking  // Don't want trouble with strong pirate
                    } else {
                        StationAction::GrantDocking
                    }
                },
                
                StationType::TradeHub => {
                    // Trade hubs are open to everyone with money
                    if player_seems_hostile && power_diff > 1000 {
                        StationAction::DemandIdentification
                    } else {
                        StationAction::ScanShip
                    }
                },
                
                StationType::Habitat => {
                    // Civilian stations are cautious
                    if player_seems_hostile {
                        StationAction::DenyDocking
                    } else if player_morality < 40 {
                        StationAction::DemandIdentification
                    } else {
                        StationAction::GrantDocking
                    }
                },
                
                StationType::Shipyard => {
                    // Shipyards want paying customers
                    if player_morality < 20 {
                        StationAction::DemandIdentification
                    } else {
                        StationAction::ScanShip
                    }
                },
                
                StationType::ResearchLab => {
                    // Research labs are selective
                    if player_morality < 60 {
                        StationAction::DenyDocking
                    } else {
                        StationAction::DemandIdentification
                    }
                },
                
                _ => {
                    // Default: scan then decide
                    StationAction::ScanShip
                }
            }
        }

        // Handle clearance provision
        fn handle_clearance(
            self: @ContractState,
            station_type: StationType,
            player_seems_lawful: bool,
            player_seems_hostile: bool
        ) -> StationAction {
            if player_seems_hostile {
                StationAction::ScanShip  // Don't trust hostile ships even with clearance
            } else if player_seems_lawful {
                StationAction::GrantDocking  // Good reputation = easy access
            } else {
                match station_type {
                    StationType::MilitaryBase | StationType::ResearchLab => {
                        StationAction::ScanShip  // Extra scrutiny at secure stations
                    },
                    _ => StationAction::GrantDocking
                }
            }
        }

        // Handle bribe attempts
        fn handle_bribe_station(
            self: @ContractState,
            station_type: StationType,
            tolerance: u8,
            player_morality: u8,
            power_diff: u32
        ) -> StationAction {
            match station_type {
                StationType::SmugglerDen => {
                    // Always accept bribes at smuggler dens
                    StationAction::GrantDocking
                },
                
                StationType::MilitaryBase => {
                    // Military doesn't take bribes - arrest attempt
                    StationAction::AlertAuthorities
                },
                
                StationType::TradeHub => {
                    // Trade hubs are pragmatic
                    if tolerance < 40 {
                        StationAction::GrantDocking  // Corrupt station
                    } else {
                        StationAction::ImposeQuarantine  // Clean station reports it
                    }
                },
                
                StationType::Habitat => {
                    // Civilians might accept if desperate or corrupt
                    if power_diff < 500 {
                        StationAction::GrantDocking  // Scared of strong pirate
                    } else if tolerance < 30 {
                        StationAction::GrantDocking  // Corrupt officials
                    } else {
                        StationAction::DenyDocking
                    }
                },
                
                _ => {
                    // Default: depends on station corruption (tolerance)
                    if tolerance < 50 {
                        StationAction::GrantDocking
                    } else {
                        StationAction::DenyDocking
                    }
                }
            }
        }

        // Handle false credentials
        fn handle_false_credentials(
            self: @ContractState,
            station_type: StationType,
            defense_level: u16,
            player_seems_hostile: bool
        ) -> StationAction {
            // High defense stations detect fakes better
            if defense_level > 150 {
                StationAction::AlertAuthorities
            } else if defense_level > 80 {
                StationAction::DenyDocking
            } else {
                // Low security might fall for it
                if player_seems_hostile {
                    StationAction::ScanShip  // Suspicious
                } else {
                    StationAction::GrantDocking  // Got away with it
                }
            }
        }

        // Handle trade requests
        fn handle_trade_request(self: @ContractState,station_type: StationType, player_morality: u8) -> StationAction {
            match station_type {
                StationType::TradeHub | StationType::MiningOutpost => {
                    StationAction::OpenTradingTerminal
                },
                StationType::SmugglerDen => {
                    StationAction::OpenTradingTerminal  // Black market always open
                },
                StationType::MilitaryBase => {
                    StationAction::DenyDocking  // Not a store
                },
                _ => {
                    if player_morality > 40 {
                        StationAction::OpenTradingTerminal
                    } else {
                        StationAction::DenyDocking
                    }
                }
            }
        }

        // Handle refuel requests
        fn handle_refuel_request(self: @ContractState,station_type: StationType, player_morality: u8) -> StationAction {
            match station_type {
                StationType::MilitaryBase => {
                    if player_morality > 60 {
                        StationAction::ProvideRefuel
                    } else {
                        StationAction::DenyDocking
                    }
                },
                StationType::ResearchLab => StationAction::DenyDocking,
                _ => StationAction::ProvideRefuel  // Most stations sell fuel
            }
        }

        // Handle repair requests
        fn handle_repair_request(self: @ContractState,station_type: StationType, player_morality: u8) -> StationAction {
            match station_type {
                StationType::Shipyard => StationAction::ProvideRepairs,
                StationType::MilitaryBase => {
                    if player_morality > 70 {
                        StationAction::ProvideRepairs
                    } else {
                        StationAction::DenyDocking
                    }
                },
                StationType::SmugglerDen => StationAction::ProvideRepairs,  // Shady repairs
                _ => StationAction::DenyDocking  // Can't help
            }
        }

        // Handle upgrade requests
        fn handle_upgrade_request(self: @ContractState,station_type: StationType, player_morality: u8) -> StationAction {
            match station_type {
                StationType::Shipyard => StationAction::OfferUpgrades,
                StationType::MilitaryBase => {
                    if player_morality > 80 {
                        StationAction::OfferUpgrades  // Military-grade gear
                    } else {
                        StationAction::DenyDocking
                    }
                },
                StationType::SmugglerDen => StationAction::OfferUpgrades,  // Illegal mods
                _ => StationAction::DenyDocking
            }
        }

        // Handle forced entry attempts
        fn handle_force_entry(self: @ContractState,power_diff: u32, defense_level: u16) -> StationAction {
            if power_diff > 2000 {
                // Station much stronger - defend aggressively
                StationAction::LaunchDefenseFighters
            } else if power_diff > 500 {
                // Station stronger - warn and prepare
                StationAction::ActivatePointDefense
            } else if power_diff < 1000 {
                // Player much stronger - lockdown and alert
                StationAction::LockdownDockingBays
            } else {
                // Close fight - call for help
                StationAction::AlertAuthorities
            }
        }

        // Handle station attack
        fn handle_station_attack(
            self: @ContractState,
            power_diff: u32,
            defense_level: u16,
            station_type: StationType
        ) -> StationAction {
            match station_type {
                StationType::MilitaryBase => {
                    // Military always fights back hard
                    if defense_level > 100 {
                        StationAction::LaunchDefenseFighters
                    } else {
                        StationAction::OpenFire
                    }
                },
                _ => {
                    if power_diff > 1500 {
                        StationAction::LaunchDefenseFighters
                    } else if power_diff > 0 {
                        StationAction::OpenFire
                    } else {
                        // Station weaker - call for help
                        StationAction::AlertAuthorities
                    }
                }
            }
        }

        // Handle hacking attempts
        fn handle_hacking_attempt(self: @ContractState,defense_level: u16, station_type: StationType) -> StationAction {
            if defense_level > 150 {
                // High security detects immediately
                StationAction::AlertAuthorities
            } else if defense_level > 80 {
                // Medium security locks down
                StationAction::LockdownDockingBays
            } else {
                // Low security might not notice right away
                match station_type {
                    StationType::SmugglerDen => StationAction::None,  // Don't care
                    _ => StationAction::ScanShip
                }
            }
        }

        // Get station tolerance (how corrupt/lenient they are)
        fn get_station_tolerance(self: @ContractState,station_type: StationType) -> u8 {
            match station_type {
                StationType::MilitaryBase => 90,        // Very strict
                StationType::ResearchLab => 85,         // Very strict
                StationType::Habitat => 70,             // Moderately strict
                StationType::TradeHub => 50,            // Neutral
                StationType::MiningOutpost => 45,       // Slightly lenient
                StationType::Shipyard => 40,            // Lenient (want business)
                StationType::RelayStation => 55,        // Neutral
                StationType::SmugglerDen => 10,         // Very corrupt
                StationType::None => 50,
            }
        }

        // Calculate player threat level
        fn calculate_player_threat(self: @ContractState,ship: ShipOberon) -> u32 {
            let mut threat: u32 = 0;
            
            threat += ship.hull;
            threat += ship.shield * 2;
            threat += (ship.point_defense.into() * 100);
            threat += (ship.torpedoes.into() * 200);
            if ship.railgun { threat += 300; }
            threat += (ship.crew_capacity.into() / 10);
            
            // Low morality increases perceived threat
            if ship.morarity < 30 {
                threat += 500;  // Known pirate = dangerous
            } else if ship.morarity > 80 {
                threat -= 200;  // Lawful = less threatening
            }
            
            threat
        }

        // Calculate station defensive strength
        fn calculate_station_strength(self: @ContractState,station: Station) -> u32 {
            let mut strength: u32 = 0;
            
            strength += (station.defense_level.into() * 10);
            strength += (station.crew / 5);
            strength += (station.capacity / 10);
            
            // Station type bonuses
            strength = match station.station_type {
                StationType::MilitaryBase => strength * 3,      // Heavily defended
                StationType::Shipyard => (strength * 3) / 2,    // Well armed
                StationType::TradeHub => (strength * 5) / 4,    // Some defenses
                StationType::SmugglerDen => strength,           // Normal
                StationType::Habitat => (strength * 3) / 4,     // Light defenses
                StationType::ResearchLab => (strength * 4) / 3, // Good defenses
                StationType::MiningOutpost => strength / 2,     // Weak
                StationType::RelayStation => strength / 2,      // Weak
                _ => strength
            };
            
            strength
        }

        fn compare_ship_power(
            self: @ContractState,
            nps_power: u32,
            player_power: u32
        ) -> (bool, u32) {
            // Returns (is_nps_stronger, power_difference)
            if nps_power > player_power {
                (true, nps_power - player_power)
            } else {
                (false, player_power - nps_power)
            }
        }

        fn calculate_damage_effects(
            self: @ContractState,
            npc_ship: Ship,
            npc_position: Vec2,
            player_position: Vec2,
            npc_action: NPSAction,              // What the NPC chose to do (their defense)
            player_torpedoes_incoming: u8,      // Player's torpedoes heading to NPC
            player_railguns_active: u8,         // Player's railguns firing
            player_pdcs_active: u8,             // Player's PDCs firing
            torpedo_damage: u32,
            railgun_damage: u32,
            pdc_damage: u32,
        ) -> (u32, u32, u32, u32, u32) {  // Returns (hull_damage, shield_damage, speed_loss, crew_casualties, power_damage)
            
            let mut hull_damage: u32 = 0;
            let mut shield_damage: u32 = 0;
            let mut speed_loss: u32 = 0;
            let mut crew_casualties: u32 = 0;
            let mut power_damage: u32 = 0;
            
            // Calculate squared distance
            let dx = if npc_position.x > player_position.x { 
                npc_position.x - player_position.x 
            } else { 
                player_position.x - npc_position.x 
            };
            
            let dy = if npc_position.y > player_position.y { 
                npc_position.y - player_position.y 
            } else { 
                player_position.y - npc_position.y 
            };
            
            let distance_squared = dx * dx + dy * dy;
            
            // Check if player's weapons are aligned with NPC
            let weapons_aligned = self.check_weapon_alignment(player_position, npc_position);
            
            // Distance effectiveness
            let distance_modifier = self.calculate_distance_modifier(distance_squared);
            
            // NPC's combat effectiveness (degraded if damaged)
            let npc_effectiveness = self.calculate_combat_effectiveness(npc_ship);
            
            // NPC's defensive capabilities based on their chosen action
            let npc_evasion = self.get_evasion_modifier(npc_action);
            let npc_defensive_bonus = self.get_defensive_bonus(npc_action);
            
            // TORPEDOES - Incoming guided missiles
            let mut torpedoes_hit: u8 = 0;
            
            if player_torpedoes_incoming > 0 {
                let torpedo_hit_chance = self.calculate_torpedo_interception(
                    npc_ship,
                    npc_action,
                    player_torpedoes_incoming,
                    distance_squared,
                    npc_effectiveness,
                    npc_evasion,
                    npc_defensive_bonus
                );
                
                torpedoes_hit = (player_torpedoes_incoming * torpedo_hit_chance) / 100;
                
                if torpedoes_hit > 0 {
                    let torpedo_total = torpedoes_hit.into() * torpedo_damage;
                    
                    // Torpedoes - massive damage
                    hull_damage += torpedo_total;
                    crew_casualties += torpedoes_hit.into() * 8;
                    power_damage += torpedoes_hit.into() * 150;
                    
                    if torpedoes_hit >= 2 {
                        speed_loss += 20;
                    }
                }
            }
            
            // RAILGUNS - Kinetic strikes
            let mut railgun_hits: u8 = 0;
            let mut railgun_dmg: u32 = 0;
            
            if player_railguns_active > 0 {
                // Base hit chance
                let mut hit_chance: u32 = if weapons_aligned { 90 } else { 60 };
                
                // Distance matters
                hit_chance = (hit_chance * distance_modifier) / 100;
                
                // Evasion reduces hit chance
                let effective_evasion = (npc_evasion * npc_effectiveness) / 100;
                if effective_evasion > 0 {
                    hit_chance = hit_chance - min_u32(hit_chance / 3, effective_evasion);
                }
                
                // Defensive actions reduce hit chance
                if npc_defensive_bonus > 0 {
                    hit_chance = hit_chance - min_u32(hit_chance / 4, npc_defensive_bonus);
                }
                
                // Cap hit chance
                hit_chance = min_u32(95, max_u32(10, hit_chance));
                
                // Calculate hits
                railgun_hits = (player_railguns_active * hit_chance.try_into().unwrap()) / 100;
                
                if railgun_hits > 0 {
                    if weapons_aligned {
                        // Aligned - devastating
                        let class_multiplier = self.get_railgun_vulnerability(npc_ship.s_class);
                        railgun_dmg = railgun_hits.into() * railgun_damage * class_multiplier;
                        railgun_dmg = (railgun_dmg * distance_modifier) / 100;
                        
                        crew_casualties += railgun_hits.into() * 10;
                        power_damage += railgun_hits.into() * 100;
                        speed_loss += railgun_hits.into() * 15;
                    } else {
                        // Misaligned
                        railgun_dmg = railgun_hits.into() * railgun_damage;
                        railgun_dmg = (railgun_dmg * distance_modifier) / 100;
                        
                        crew_casualties += railgun_hits.into() * 3;
                        power_damage += railgun_hits.into() * 30;
                        speed_loss += railgun_hits.into() * 5;
                    }
                }
            }
            
            // PDCs - Close range defensive fire
            let mut pdc_hits: u8 = 0;
            let mut pdc_dmg: u32 = 0;
            
            if player_pdcs_active > 0 {
                // Base hit chance
                let mut hit_chance: u32 = if weapons_aligned { 75 } else { 40 };
                
                // PDCs very distance-dependent
                let pdc_distance_mod = if distance_squared < 100 {
                    120  // Point blank
                } else if distance_squared < 500 {
                    100  // Optimal
                } else if distance_squared < 2000 {
                    60   // Long range
                } else {
                    20   // Too far
                };
                
                hit_chance = (hit_chance * pdc_distance_mod) / 100;
                
                let effective_evasion = (npc_evasion * npc_effectiveness) / 100;
                if effective_evasion > 0 {
                    hit_chance = hit_chance - min_u32(hit_chance / 3, effective_evasion);
                }
                
                hit_chance = min_u32(90, max_u32(5, hit_chance));
                
                pdc_hits = (player_pdcs_active * hit_chance.try_into().unwrap()) / 100;
                
                if pdc_hits > 0 {
                    pdc_dmg = pdc_hits.into() * pdc_damage;
                    
                    if weapons_aligned {
                        crew_casualties += pdc_hits.into() / 3;
                        power_damage += pdc_hits.into() * 5;
                    } else {
                        crew_casualties += pdc_hits.into() / 8;
                        power_damage += pdc_hits.into() * 2;
                    }
                }
            }
            
            // Total kinetic damage
            let total_damage = railgun_dmg + pdc_dmg;
            
            // SHIELD ABSORPTION
            if npc_ship.shield_points > 0 {
                // Shield effectiveness based on power
                let shield_effectiveness = if npc_ship.power_output < 100 {
                    50  // Low power
                } else if npc_ship.power_output < npc_ship.power_output / 2 {
                    75  // Half power
                } else {
                    100  // Full power
                };
                
                let effective_shields = (npc_ship.shield_points * shield_effectiveness) / 100;
                
                // Shields absorb kinetic damage
                if weapons_aligned && railgun_hits > 0 {
                    // Aligned railguns penetrate shields
                    let shield_penetration = railgun_dmg / 2;
                    let shield_absorbed = railgun_dmg - shield_penetration;
                    
                    if effective_shields >= shield_absorbed {
                        shield_damage = shield_absorbed;
                        hull_damage += shield_penetration;
                    } else {
                        shield_damage = effective_shields;
                        hull_damage += shield_penetration + (shield_absorbed - effective_shields);
                    }
                    
                    // Add torpedo and PDC damage
                    let remaining_dmg = torpedoes_hit.into() * torpedo_damage + pdc_dmg;
                    let remaining_shield = effective_shields - shield_damage;
                    
                    if remaining_dmg <= remaining_shield {
                        shield_damage += remaining_dmg;
                    } else {
                        shield_damage += remaining_shield;
                        hull_damage += remaining_dmg - remaining_shield;
                    }
                } else {
                    // Normal shield absorption
                    let total = total_damage + torpedoes_hit.into() * torpedo_damage;
                    if total <= effective_shields {
                        shield_damage = total;
                    } else {
                        shield_damage = effective_shields;
                        hull_damage += total - effective_shields;
                    }
                }
            } else {
                // No shields - all damage to hull
                hull_damage += total_damage;
            }
            
            // CRITICAL DAMAGE CASCADES
            if npc_ship.hull_points > 0 {
                let hull_percentage_lost = (hull_damage * 100) / npc_ship.hull_points;
                
                if hull_percentage_lost > 50 {
                    crew_casualties += (hull_damage / 200) * 5;
                    power_damage += (hull_damage / 100) * 50;
                    speed_loss += 25;
                }
                
                if hull_percentage_lost > 75 {
                    crew_casualties += npc_ship.crew_size / 3;
                    power_damage += npc_ship.power_output / 2;
                    speed_loss += 40;
                }
            }
            
            // Ship class vulnerability
            let (extra_hull, extra_crew, extra_power) = self.apply_class_vulnerability(
                npc_ship.s_class,
                hull_damage,
                weapons_aligned
            );
            
            hull_damage += extra_hull;
            crew_casualties += extra_crew;
            power_damage += extra_power;
            
            // Cap values
            hull_damage = min_u32(hull_damage, npc_ship.hull_points);
            shield_damage = min_u32(shield_damage, npc_ship.shield_points);
            speed_loss = min_u32(speed_loss, npc_ship.speed);
            crew_casualties = min_u32(crew_casualties, npc_ship.crew_size);
            power_damage = min_u32(power_damage, npc_ship.power_output);
            
            (hull_damage, shield_damage, speed_loss, crew_casualties, power_damage)
        }

        // Check if weapons are aligned (horizontal, vertical, or diagonal)
        fn check_weapon_alignment(self: @ContractState,attacker: Vec2, target: Vec2) -> bool {
            let dx = if target.x > attacker.x { 
                target.x - attacker.x 
            } else { 
                attacker.x - target.x 
            };
            
            let dy = if target.y > attacker.y { 
                target.y - attacker.y 
            } else { 
                attacker.y - target.y 
            };
            
            // Horizontal alignment
            if dy == 0 {
                return true;
            }
            
            // Vertical alignment
            if dx == 0 {
                return true;
            }
            
            // Diagonal alignment (45 degrees)
            if dx == dy {
                return true;
            }
            
            false
        }


        // Calculate distance modifier (closer = more deadly)
        fn calculate_distance_modifier(self: @ContractState, distance_squared: u32) -> u32 {
            if distance_squared < 100 {
                150  // Point blank - 50% bonus damage
            } else if distance_squared < 500 {
                120  // Close range - 20% bonus
            } else if distance_squared < 2000 {
                100  // Optimal range - normal damage
            } else if distance_squared < 5000 {
                80   // Medium range - 20% reduction
            } else if distance_squared < 10000 {
                60   // Long range - 40% reduction
            } else {
                40   // Extreme range - 60% reduction
            }
        }

        // Calculate target's combat effectiveness based on ship status
        fn calculate_combat_effectiveness(self: @ContractState, ship: Ship) -> u32 {
            let mut effectiveness: u32 = 100;
            
            // Low hull = reduced effectiveness
            if ship.hull_points < 1000 {
                effectiveness -= 30;
            } else if ship.hull_points < 2000 {
                effectiveness -= 15;
            }
            
            // Low shields = easier to hit
            if ship.shield_points < 500 {
                effectiveness -= 20;
            }
            
            // Low power = systems degraded
            if ship.power_output < 200 {
                effectiveness -= 25;
            } else if ship.power_output < 500 {
                effectiveness -= 10;
            }
            
            // Low speed = can't evade
            if ship.speed < 20 {
                effectiveness -= 20;
            } else if ship.speed < 50 {
                effectiveness -= 10;
            }
            
            max_u32(20, effectiveness)  // Minimum 20% effectiveness
        }

        // Get evasion modifier based on action
        fn get_evasion_modifier(self: @ContractState, action: NPSAction) -> u32 {
            match action {
                NPSAction::Burn => 40,              // Full evasion
                NPSAction::Retreat => 30,           // Tactical withdrawal with evasion
                NPSAction::ActivateShields => 10,   // Defensive, not evading
                NPSAction::ActivatePDCs => 5,       // Point defense, minimal evasion
                NPSAction::OpenFire => 0,           // Trading blows
                NPSAction::Destroy => 0,            // All-out attack
                NPSAction::LaunchTorpedoes => 5,    // Focused on attack
                NPSAction::Disable => 10,           // Careful targeting
                NPSAction::RamEnemy => 0,           // No evasion, kamikaze
                _ => 15                             // Default minimal evasion
            }
        }

        // Get defensive bonus based on action
        fn get_defensive_bonus(self: @ContractState, action: NPSAction) -> u32 {
            match action {
                NPSAction::ActivateShields => 30,   // Maximum defense
                NPSAction::ActivatePDCs => 25,      // Active interception
                NPSAction::Retreat => 15,           // Defensive posture
                NPSAction::Burn => 10,              // Some defense while fleeing
                NPSAction::Disable => 10,           // Balanced approach
                NPSAction::OpenFire => 5,           // Minimal defense
                NPSAction::Destroy => 0,            // All offense
                NPSAction::RamEnemy => 0,           // No defense
                _ => 10                             // Default
            }
        }

        // Get accuracy modifier based on attacker action
        fn get_accuracy_modifier(self: @ContractState, action: NPSAction, ship: Ship) -> u32 {
            let base_accuracy = match action {
                NPSAction::Destroy => 120,          // All-out attack - bonus accuracy
                NPSAction::OpenFire => 110,         // Focused fire
                NPSAction::Disable => 130,          // Precise targeting - highest accuracy
                NPSAction::LaunchTorpedoes => 100,  // Normal
                NPSAction::ActivatePDCs => 90,      // Defensive fire
                NPSAction::Threaten => 80,          // Warning shots
                NPSAction::RamEnemy => 150,         // Kamikaze - will hit
                _ => 100                            // Default
            };
            
            // Degraded ship = reduced accuracy
            let mut final_accuracy = base_accuracy;
            
            if ship.power_output < 200 {
                final_accuracy = (final_accuracy * 70) / 100;
            } else if ship.power_output < 500 {
                final_accuracy = (final_accuracy * 85) / 100;
            }
            
            if ship.hull_points < 1000 {
                final_accuracy = (final_accuracy * 80) / 100;
            }
            
            final_accuracy
        }

        // Calculate torpedo hit chance (guided weapons)
        fn calculate_torpedo_hit_chance(
            self: @ContractState,
            torpedoes_fired: u8,
            distance_squared: u32,
            target_action: NPSAction,
            target_defensive: u32,
            target_effectiveness: u32
        ) -> u8 {
            let mut hit_chance: u32 = 85;  // Torpedoes are guided - high base hit chance
            
            // Distance affects torpedoes less than kinetic weapons
            if distance_squared > 10000 {
                hit_chance -= 20;  // Long range
            } else if distance_squared > 5000 {
                hit_chance -= 10;  // Medium range
            }
            
            // PDCs can shoot down torpedoes
            if target_action == NPSAction::ActivatePDCs {
                hit_chance -= 30;  // PDCs intercepting
            }
            
            // Evasive maneuvers
            let evasion = self.get_evasion_modifier(target_action);
            let effective_evasion = (evasion * target_effectiveness) / 100;
            hit_chance = hit_chance - (effective_evasion / 2);  // Torpedoes harder to evade
            
            // Defensive posture
            hit_chance = hit_chance - (target_defensive / 2);
            
            min_u32(95, max_u32(30, hit_chance)).try_into().unwrap()
        }

        fn calculate_torpedo_interception(
            self: @ContractState,
            npc_ship: Ship,
            npc_action: NPSAction,
            torpedoes_incoming: u8,
            distance_squared: u32,
            npc_effectiveness: u32,
            npc_evasion: u32,
            npc_defensive: u32
        ) -> u8 {
            let mut hit_chance: u32 = 85;  // Torpedoes are guided
            
            // ActivatePDCs - BEST defense against torpedoes
            if npc_action == NPSAction::ActivatePDCs {
                // PDC interception based on ship class
                let interception_rate = match npc_ship.s_class {
                    ShipClass::Carrier | ShipClass::Frigate => 50,  // PDS specialists
                    ShipClass::Battleship | ShipClass::Cruiser => 35,
                    ShipClass::Destroyer => 30,
                    ShipClass::Corvette => 20,
                    _ => 10
                };
                hit_chance = hit_chance - interception_rate;
            }
            
            // Burn - Evasive maneuvers
            if npc_action == NPSAction::Burn {
                let effective_evasion = (npc_evasion * npc_effectiveness) / 100;
                hit_chance = hit_chance - (effective_evasion / 2);  // Torpedoes harder to dodge
            }
            
            // LaunchTorpedoes - Counter-missiles (pre-detonation)
            if npc_action == NPSAction::LaunchTorpedoes {
                if npc_ship.torpedo_ammo > 0 {
                    hit_chance = hit_chance - 25;  // Counter-torpedo interception
                }
            }
            
            // ActivateShields - Minimal help vs torpedoes
            if npc_action == NPSAction::ActivateShields {
                hit_chance = hit_chance - 10;
            }
            
            // Distance
            if distance_squared > 10000 {
                hit_chance = hit_chance - 15;  // Long flight time = more time to intercept
            }
            
            min_u32(95, max_u32(30, hit_chance)).try_into().unwrap()
        }


        // Get damage multiplier based on ship class vulnerability
        fn get_railgun_vulnerability(self: @ContractState,ship_class: ShipClass) -> u32 {
            match ship_class {
                ShipClass::Freighter => 3,      // Unarmored civilian ship - devastating
                ShipClass::PirateSkiff => 3,    // Light armor
                ShipClass::Corvette => 2,       // Light warship
                ShipClass::Frigate => 2,        // Medium armor
                ShipClass::Carrier => 2,        // Large but lightly armored
                ShipClass::Destroyer => 1,      // Standard armor
                ShipClass::Cruiser => 1,        // Heavy armor
                ShipClass::Battleship => 1,     // Heavily armored - base damage only
                _ => 1
            }
        }

        // Apply additional vulnerability based on ship class
        fn apply_class_vulnerability(
            self: @ContractState,
            ship_class: ShipClass,
            base_hull_damage: u32,
            railgun_aligned: bool
        ) -> (u32, u32, u32) {  // Returns (extra_hull, extra_crew, extra_power)
            
            if !railgun_aligned {
                return (0, 0, 0);  // No extra damage if not aligned
            }
            
            match ship_class {
                ShipClass::Freighter => {
                    // Freighters are extremely vulnerable - no armor
                    let extra_hull = base_hull_damage / 2;  // 50% extra hull damage
                    let extra_crew = 15;                     // High crew exposure
                    let extra_power = 200;                   // Civilian power systems fragile
                    (extra_hull, extra_crew, extra_power)
                },
                ShipClass::PirateSkiff => {
                    // Light ships take extra damage
                    let extra_hull = base_hull_damage / 3;
                    let extra_crew = 10;
                    let extra_power = 150;
                    (extra_hull, extra_crew, extra_power)
                },
                ShipClass::Corvette | ShipClass::Frigate => {
                    // Light warships - moderate vulnerability
                    let extra_hull = base_hull_damage / 4;
                    let extra_crew = 8;
                    let extra_power = 100;
                    (extra_hull, extra_crew, extra_power)
                },
                ShipClass::Carrier => {
                    // Large target, less armored
                    let extra_hull = base_hull_damage / 5;
                    let extra_crew = 12;  // More crew = more casualties
                    let extra_power = 80;
                    (extra_hull, extra_crew, extra_power)
                },
                ShipClass::Destroyer | ShipClass::Cruiser => {
                    // Well armored, minimal extra damage
                    let extra_hull = base_hull_damage / 10;
                    let extra_crew = 3;
                    let extra_power = 50;
                    (extra_hull, extra_crew, extra_power)
                },
                ShipClass::Battleship => {
                    // Heavily armored - no extra damage
                    (0, 0, 0)
                },
                _ => (0, 0, 0)
            }
        }




        
    }

   
}

