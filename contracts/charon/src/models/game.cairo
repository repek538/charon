use starknet::ContractAddress;
use core::num::traits::Zero;

// Core game state
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Game {
    #[key]
    pub game_id: u32,
    pub creator: ContractAddress,   
    pub over: bool,
    pub player_count: u8,
    pub unit_count: u32,
    pub engagements_count: u64,
    pub clock: u64,
    pub penalty: u64,
}

// Rescue gauntlet configuration
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct RescueGauntlet {
    #[key]
    pub game_id: u32,
    #[key]
    pub rescue_id: u32,
    pub creator_address: ContractAddress,
    pub creator_stake: u256,
    pub rescue_reward: u256,
    pub attempt_fee: u256,
    pub credits_required: u256,
    pub mortality_level: u8,
    pub threat_budget_total: u32,
    pub threat_budget_used: u32,
    pub attempt_count: u32,
    pub rescuer_count: u8,                 // 0, 1, or 2 (current active attempts)
    pub rescue_deadline: u64,              // Overall gauntlet expires
    pub attempt_duration: u64,             // Time limit per attempt (e.g., 3600 seconds)
    pub is_rescued: bool,                  // True when someone completes
    pub rescurer_completed: ContractAddress, // WINNER - first to complete
    pub is_expired: bool,
}

// Track the two rescuers and their attempt windows
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Rescuers {
    #[key]
    pub game_id: u32,
    #[key]
    pub rescue_id: u32,
    pub first_rescuer: ContractAddress,
    pub second_rescuer: ContractAddress,
    pub first_attempt_start: u64,          // When first rescuer started
    pub second_attempt_start: u64,         // When second rescuer started
    pub first_rescue_time: u64,            // When completed (0 if not completed)
    pub second_rescue_time: u64,           // When completed (0 if not completed)
}

// Ship composition for a gauntlet
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct ShipComposition {
    #[key]
    pub game_id: u32,
    #[key]
    pub rescue_id: u32,
    pub corvette_count: u8,
    pub frigate_count: u8,
    pub destroyer_count: u8,
    pub cruiser_count: u8,
    pub battleship_count: u8,
    pub carrier_count: u8,
    pub freighter_count: u8,
    pub pirate_skiff_count: u8,
}

// Station composition for a gauntlet
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct StationComposition {
    #[key]
    pub game_id: u32,
    #[key]
    pub rescue_id: u32,
    pub shipyard_count: u8,
    pub tradehub_count: u8,
    pub mining_outpost_count: u8,
    pub research_lab_count: u8,
    pub military_base_count: u8,
    pub smuggler_den_count: u8,
    pub relay_station_count: u8,
    pub habitat_count: u8,
}



#[generate_trait]
pub impl GameImpl of GameTrait {
    fn new(game_id: u32,creator: ContractAddress) -> Game {
        Game {
            game_id,
            creator,
            over: false,
            player_count: 0,
            unit_count: 0,
            engagements_count: 0,
            clock: 0,
            penalty: 0,
        }
    }

    fn increment_player_count(ref self: Game) {
        self.player_count += 1;
    }

    fn increment_unit_count(ref self: Game) {
        self.unit_count += 1;
    }

    fn increment_engagements(ref self: Game) {
        self.engagements_count += 1;
    }

    fn update_clock(ref self: Game, new_clock: u64) {
        self.clock = new_clock;
    }

    fn end_game(ref self: Game) {
        self.over = true;
    }

    fn is_active(self: @Game) -> bool {
        !*self.over
    }
    fn is_creator(self: @Game, address: ContractAddress) -> bool {
        *self.creator == address
    }
}

#[generate_trait]
pub impl RescueGauntletImpl of RescueGauntletTrait {
    fn new(
        game_id: u32,
        rescue_id: u32,
        creator_address: ContractAddress,
        creator_stake: u256,
        rescue_reward: u256,
        attempt_fee: u256,
        credits_required: u256,
        mortality_level: u8,
        threat_budget_total: u32,
        rescue_deadline: u64,
        attempt_duration: u64,
    ) -> RescueGauntlet {
        RescueGauntlet {
            game_id,
            rescue_id,
            creator_address,
            creator_stake,
            rescue_reward,
            attempt_fee,
            credits_required,
            mortality_level,
            threat_budget_total,
            threat_budget_used: 0,
            attempt_count: 0,
            rescuer_count: 0,
            rescue_deadline,
            attempt_duration,
            is_rescued: false,
            rescurer_completed: Zero::zero(),
            is_expired: false,
        }
    }

    fn use_threat_budget(ref self: RescueGauntlet, amount: u32) -> bool {
        if self.threat_budget_used + amount <= self.threat_budget_total {
            self.threat_budget_used += amount;
            true
        } else {
            false
        }
    }

    fn increment_attempt(ref self: RescueGauntlet) {
        self.attempt_count += 1;
    }

    fn add_rescuer(ref self: RescueGauntlet) -> bool {
        if self.rescuer_count < 2 && !self.is_expired && !self.is_rescued {
            self.rescuer_count += 1;
            true
        } else {
            false
        }
    }

    fn remove_rescuer(ref self: RescueGauntlet) {
        if self.rescuer_count > 0 {
            self.rescuer_count -= 1;
        }
    }

    fn complete_rescue(ref self: RescueGauntlet, rescuer: ContractAddress) {
        self.is_rescued = true;
        self.rescurer_completed = rescuer;
    }

    fn is_full(self: @RescueGauntlet) -> bool {
        *self.rescuer_count >= 2
    }

    fn is_active(self: @RescueGauntlet) -> bool {
        !*self.is_rescued && !*self.is_expired
    }

    fn check_expired(ref self: RescueGauntlet, current_time: u64) {
        if current_time >= self.rescue_deadline {
            self.is_expired = true;
        }
    }

    fn remaining_threat_budget(self: @RescueGauntlet) -> u32 {
        *self.threat_budget_total - *self.threat_budget_used
    }
}

#[generate_trait]
pub impl RescuersImpl of RescuersTrait {
    fn new(game_id: u32, rescue_id: u32) -> Rescuers {
        Rescuers {
            game_id,
            rescue_id,
            first_rescuer: Zero::zero(),
            second_rescuer: Zero::zero(),
            first_attempt_start: 0,
            second_attempt_start: 0,
            first_rescue_time: 0,
            second_rescue_time: 0,
        }
    }

    fn start_first_attempt(ref self: Rescuers, rescuer: ContractAddress, start_time: u64) {
        self.first_rescuer = rescuer;
        self.first_attempt_start = start_time;
        self.first_rescue_time = 0;
    }

    fn start_second_attempt(ref self: Rescuers, rescuer: ContractAddress, start_time: u64) {
        self.second_rescuer = rescuer;
        self.second_attempt_start = start_time;
        self.second_rescue_time = 0;
    }

    fn complete_first_rescue(ref self: Rescuers, completion_time: u64) {
        self.first_rescue_time = completion_time;
    }

    fn complete_second_rescue(ref self: Rescuers, completion_time: u64) {
        self.second_rescue_time = completion_time;
    }

    fn fail_first_attempt(ref self: Rescuers) {
        self.first_rescuer =Zero::zero();
        self.first_attempt_start = 0;
        self.first_rescue_time = 0;
    }

    fn fail_second_attempt(ref self: Rescuers) {
        self.second_rescuer = Zero::zero();
        self.second_attempt_start = 0;
        self.second_rescue_time = 0;
    }

    fn is_first_attempt_expired(self: @Rescuers, current_time: u64, attempt_duration: u64) -> bool {
        if *self.first_attempt_start == 0 || *self.first_rescue_time > 0 {
            return false;
        }
        current_time >= *self.first_attempt_start + attempt_duration
    }

    fn is_second_attempt_expired(self: @Rescuers, current_time: u64, attempt_duration: u64) -> bool {
        if *self.second_attempt_start == 0 || *self.second_rescue_time > 0 {
            return false;
        }
        current_time >= *self.second_attempt_start + attempt_duration
    }

    fn has_first_rescuer(self: @Rescuers) -> bool {
        *self.first_rescuer != Zero::zero()
    }

    fn has_second_rescuer(self: @Rescuers) -> bool {
        *self.second_rescuer != Zero::zero()
    }

    fn is_first_completed(self: @Rescuers) -> bool {
        *self.first_rescue_time > 0
    }

    fn is_second_completed(self: @Rescuers) -> bool {
        *self.second_rescue_time > 0
    }

    fn has_available_slot(self: @Rescuers, current_time: u64, attempt_duration: u64) -> bool {
        // Slot 1 available if: empty OR expired
        let slot1_available = !self.has_first_rescuer() 
            || self.is_first_attempt_expired(current_time, attempt_duration);
        
        // Slot 2 available if: empty OR expired
        let slot2_available = !self.has_second_rescuer() 
            || self.is_second_attempt_expired(current_time, attempt_duration);
        
        slot1_available || slot2_available
    }
}

#[generate_trait]
pub impl ShipCompositionImpl of ShipCompositionTrait {
    fn new(game_id: u32,rescue_id: u32,) -> ShipComposition {
        ShipComposition {
            game_id,
            rescue_id,
            corvette_count: 0,
            frigate_count: 0,
            destroyer_count: 0,
            cruiser_count: 0,
            battleship_count: 0,
            carrier_count: 0,
            freighter_count: 0,
            pirate_skiff_count: 0,
        }
    }

    fn add_corvettes(ref self: ShipComposition, count: u8) {
        self.corvette_count += count;
    }

    fn add_frigates(ref self: ShipComposition, count: u8) {
        self.frigate_count += count;
    }

    fn add_destroyers(ref self: ShipComposition, count: u8) {
        self.destroyer_count += count;
    }

    fn add_cruisers(ref self: ShipComposition, count: u8) {
        self.cruiser_count += count;
    }

    fn add_battleships(ref self: ShipComposition, count: u8) {
        self.battleship_count += count;
    }

    fn add_carriers(ref self: ShipComposition, count: u8) {
        self.carrier_count += count;
    }

    fn add_freighters(ref self: ShipComposition, count: u8) {
        self.freighter_count += count;
    }

    fn add_pirate_skiffs(ref self: ShipComposition, count: u8) {
        self.pirate_skiff_count += count;
    }

    fn total_ships(self: @ShipComposition) -> u32 {
        (*self.corvette_count).into()
            + (*self.frigate_count).into()
            + (*self.destroyer_count).into()
            + (*self.cruiser_count).into()
            + (*self.battleship_count).into()
            + (*self.carrier_count).into()
            + (*self.freighter_count).into()
            + (*self.pirate_skiff_count).into()
    }

    fn military_ships(self: @ShipComposition) -> u32 {
        (*self.corvette_count).into()
            + (*self.frigate_count).into()
            + (*self.destroyer_count).into()
            + (*self.cruiser_count).into()
            + (*self.battleship_count).into()
            + (*self.carrier_count).into()
            + (*self.pirate_skiff_count).into()
    }
}

#[generate_trait]
pub impl StationCompositionImpl of StationCompositionTrait {
    fn new(game_id: u32,rescue_id: u32,) -> StationComposition {
        StationComposition {
            game_id,
            rescue_id,
            shipyard_count: 0,
            tradehub_count: 0,
            mining_outpost_count: 0,
            research_lab_count: 0,
            military_base_count: 0,
            smuggler_den_count: 0,
            relay_station_count: 0,
            habitat_count: 0,
        }
    }

    fn add_shipyards(ref self: StationComposition, count: u8) {
        self.shipyard_count += count;
    }

    fn add_tradehubs(ref self: StationComposition, count: u8) {
        self.tradehub_count += count;
    }

    fn add_mining_outposts(ref self: StationComposition, count: u8) {
        self.mining_outpost_count += count;
    }

    fn add_research_labs(ref self: StationComposition, count: u8) {
        self.research_lab_count += count;
    }

    fn add_military_bases(ref self: StationComposition, count: u8) {
        self.military_base_count += count;
    }

    fn add_smuggler_dens(ref self: StationComposition, count: u8) {
        self.smuggler_den_count += count;
    }

    fn add_relay_stations(ref self: StationComposition, count: u8) {
        self.relay_station_count += count;
    }

    fn add_habitats(ref self: StationComposition, count: u8) {
        self.habitat_count += count;
    }

    fn total_stations(self: @StationComposition) -> u32 {
        (*self.shipyard_count).into()
            + (*self.tradehub_count).into()
            + (*self.mining_outpost_count).into()
            + (*self.research_lab_count).into()
            + (*self.military_base_count).into()
            + (*self.smuggler_den_count).into()
            + (*self.relay_station_count).into()
            + (*self.habitat_count).into()
    }

    fn military_stations(self: @StationComposition) -> u32 {
        (*self.military_base_count).into()
    }
}


