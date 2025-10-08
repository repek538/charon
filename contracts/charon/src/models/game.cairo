use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Game {
    #[key]
    pub game_id: u32,
    pub over: bool,
    pub player_count: u8,
    pub unit_count: u32,
    pub engagements_count: u64,
    pub clock: u64,
    pub penalty: u64,
    
    // Rescue Gauntlet Fields
    pub rescue_id: u32,              // Unique ID for this rescue mission
    pub creator_address: ContractAddress,     // Address of gauntlet creator
    pub creator_stake: u256,           // Amount staked by creator
    pub rescue_reward: u256,           // Reward for successful rescue
    pub attempt_fee: u256,             // Fee to attempt the rescue
    pub credits_required: u256,        // Credits needed to complete rescue
    pub ship_count: u8,               // Number of enemy ships placed
    pub station_count: u8,            // Number of stations placed
    pub mortality_level: u8,          // Required mortality/difficulty level to win (0-100)
    pub threat_budget_total: u32,     // Total threat points available
    pub threat_budget_used: u32,      // Threat points currently used
    pub attempt_count: u32,           // Total number of attempts
    pub success_count: u32,           // Number of successful rescues
}

// Generate trait for creating new games
#[generate_trait]
pub impl GameImpl of GameTrait {
    // Create a new game with default values
    fn new(game_id: u32) -> Game {
        Game {
            game_id,
            over: false,
            player_count: 0,
            unit_count: 0,
            engagements_count: 0,
            clock: 0,
            penalty: 0,
            rescue_id: 0,
            creator_address: 0,
            creator_stake: 0,
            rescue_reward: 0,
            attempt_fee: 0,
            credits_required: 0,
            ship_count: 0,
            station_count: 0,
            mortality_level: 0,
            threat_budget_total: 0,
            threat_budget_used: 0,
            attempt_count: 0,
            success_count: 0,
        }
    }
    
    // Create a new rescue gauntlet
    fn new_rescue_gauntlet(
        game_id: u32,
        rescue_id: u32,
        creator_address: felt252,
        creator_stake: u64,
        rescue_reward: u64,
        attempt_fee: u64,
        credits_required: u32,
        mortality_level: u8,
        threat_budget: u32
    ) -> Game {
        Game {
            game_id,
            rescue_id,
            creator_address,
            creator_stake,
            rescue_reward,
            attempt_fee,
            credits_required,
            mortality_level,
            threat_budget_total: threat_budget,
            threat_budget_used: 0,
            ship_count: 0,
            station_count: 0,
            over: false,
            player_count: 0,
            unit_count: 0,
            engagements_count: 0,
            clock: 0,
            penalty: 0,
            attempt_count: 0,
            success_count: 0,
        }
    }
    
    // Create a new game with custom parameters (existing function)
    fn new_with_params(
        game_id: u32,
        minimum_moves: u8,
        player_count: u8,
        unit_count: u32,
        clock: u64
    ) -> Game {
        Game {
            game_id,
            over: false,
            player_count,
            unit_count,
            engagements_count: 0,
            clock,
            penalty: 0,
            rescue_id: 0,
            creator_address: 0,
            creator_stake: 0,
            rescue_reward: 0,
            attempt_fee: 0,
            credits_required: 0,
            ship_count: 0,
            station_count: 0,
            mortality_level: 0,
            threat_budget_total: 0,
            threat_budget_used: 0,
            attempt_count: 0,
            success_count: 0,
        }
    }
    
    // Add a ship to the gauntlet
    fn add_ship(ref self: Game, threat_cost: u32) -> bool {
        if self.threat_budget_used + threat_cost > self.threat_budget_total {
            return false; // Not enough budget
        }
        self.ship_count += 1;
        self.threat_budget_used += threat_cost;
        true
    }
    
    // Add a station to the gauntlet
    fn add_station(ref self: Game, threat_cost: u32) -> bool {
        if self.threat_budget_used + threat_cost > self.threat_budget_total {
            return false; // Not enough budget
        }
        self.station_count += 1;
        self.threat_budget_used += threat_cost;
        true
    }
    
    // Remove a ship from the gauntlet
    fn remove_ship(ref self: Game, threat_cost: u32) -> bool {
        if self.ship_count == 0 {
            return false;
        }
        self.ship_count -= 1;
        if self.threat_budget_used >= threat_cost {
            self.threat_budget_used -= threat_cost;
        } else {
            self.threat_budget_used = 0;
        }
        true
    }
    
    // Remove a station from the gauntlet
    fn remove_station(ref self: Game, threat_cost: u32) -> bool {
        if self.station_count == 0 {
            return false;
        }
        self.station_count -= 1;
        if self.threat_budget_used >= threat_cost {
            self.threat_budget_used -= threat_cost;
        } else {
            self.threat_budget_used = 0;
        }
        true
    }
    
    // Get remaining threat budget
    fn remaining_budget(self: @Game) -> u32 {
        if *self.threat_budget_total > *self.threat_budget_used {
            *self.threat_budget_total - *self.threat_budget_used
        } else {
            0
        }
    }
    
    // Record a rescue attempt
    fn record_attempt(ref self: Game) {
        self.attempt_count += 1;
    }
    
    // Record a successful rescue
    fn record_success(ref self: Game) {
        self.success_count += 1;
    }
    
    // Calculate success rate (returns percentage 0-100)
    fn success_rate(self: @Game) -> u8 {
        if *self.attempt_count == 0 {
            return 0;
        }
        let rate = (*self.success_count * 100) / *self.attempt_count;
        if rate > 100 {
            100
        } else {
            rate.try_into().unwrap()
        }
    }
    
    // Check if gauntlet meets mortality level requirement
    fn check_mortality_requirement(self: @Game, achieved_mortality: u8) -> bool {
        achieved_mortality >= *self.mortality_level
    }
    
    // Calculate creator earnings from failed attempts
    fn creator_earnings(self: @Game) -> u64 {
        let failed_attempts = *self.attempt_count - *self.success_count;
        failed_attempts.into() * *self.attempt_fee
    }
    
    // Calculate net profit/loss for creator
    fn creator_net_result(self: @Game) -> i64 {
        let earnings: i64 = self.creator_earnings().try_into().unwrap();
        let stake: i64 = (*self.creator_stake).try_into().unwrap();
        let losses: i64 = ((*self.success_count).into() * *self.rescue_reward).try_into().unwrap();
        
        earnings - losses
    }
    
    // Check if gauntlet is still active (creator hasn't lost all stake)
    fn is_gauntlet_active(self: @Game) -> bool {
        !*self.over && self.creator_net_result() > -(*self.creator_stake).try_into().unwrap()
    }
    
    // Validate gauntlet is ready to publish
    fn validate_gauntlet(self: @Game) -> bool {
        // Must have placed at least some obstacles
        let has_obstacles = *self.ship_count > 0 || *self.station_count > 0;
        
        // Must have used threat budget
        let budget_used = *self.threat_budget_used > 0;
        
        // Must have set required fields
        let has_stake = *self.creator_stake > 0;
        let has_reward = *self.rescue_reward > 0;
        let has_fee = *self.attempt_fee > 0;
        
        has_obstacles && budget_used && has_stake && has_reward && has_fee
    }

    // Check if game is active
    fn is_active(self: @Game) -> bool {
        !*self.over && *self.player_count > 0
    }

    // Check if game is full (assuming max players)
    fn is_full(self: @Game, max_players: u8) -> bool {
        *self.player_count >= max_players
    }

    // Add a player to the game
    fn add_player(ref self: Game) -> bool {
        if self.over {
            return false;
        }
        self.player_count += 1;
        true
    }

    // Remove a player from the game
    fn remove_player(ref self: Game) -> bool {
        if self.player_count == 0 {
            return false;
        }
        self.player_count -= 1;
        
        // End game if no players left
        if self.player_count == 0 {
            self.over = true;
        }
        true
    }

    // Increment engagement count
    fn new_engagement(ref self: Game) {
        self.engagements_count += 1;
    }

    // Update game clock
    fn update_clock(ref self: Game, new_time: u64) {
        self.clock = new_time;
    }

    // Add penalty time
    fn add_penalty(ref self: Game, penalty_time: u64) {
        self.penalty += penalty_time;
    }

    // End the game
    fn end_game(ref self: Game) {
        self.over = true;
    }

    // Get total game time including penalties
    fn total_time(self: @Game) -> u64 {
        *self.clock + *self.penalty
    }

    // Reset game state (for restarting)
    fn reset(ref self: Game) {
        self.over = false;
        self.player_count = 0;
        self.unit_count = 0;
        self.engagements_count = 0;
        self.clock = 0;
        self.penalty = 0;
        self.attempt_count = 0;
        self.success_count = 0;
        self.threat_budget_used = 0;
    }

    // Update unit count
    fn set_unit_count(ref self: Game, count: u32) {
        self.unit_count = count;
    }

    // Add units to the game
    fn add_units(ref self: Game, count: u32) {
        self.unit_count += count;
    }

    // Remove units from the game
    fn remove_units(ref self: Game, count: u32) {
        if self.unit_count >= count {
            self.unit_count -= count;
        } else {
            self.unit_count = 0;
        }
    }
}