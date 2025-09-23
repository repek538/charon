#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Game {
    #[key]
    pub game_id: u32,
    pub minimum_moves: u8,
    pub over: bool,
    pub player_count: u8,
    pub unit_count: u32,
    pub engagements_count: u64,
    pub clock: u64,
    pub penalty: u64,
}

// Generate trait for creating new games
#[generate_trait]
pub impl GameImpl of GameTrait {
    // Create a new game with default values
    fn new(game_id: u32) -> Game {
        Game {
            game_id,
            minimum_moves: 0,
            over: false,
            player_count: 0,
            unit_count: 0,
            engagements_count: 0,
            clock: 0,
            penalty: 0,
        }
    }

    // Create a new game with custom parameters
    fn new_with_params(
        game_id: u32,
        minimum_moves: u8,
        player_count: u8,
        unit_count: u32,
        clock: u64
    ) -> Game {
        Game {
            game_id,
            minimum_moves,
            over: false,
            player_count,
            unit_count,
            engagements_count: 0,
            clock,
            penalty: 0,
        }
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

    // Check if minimum moves requirement is met
    fn meets_minimum_moves(self: @Game, moves_made: u8) -> bool {
        moves_made >= *self.minimum_moves
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