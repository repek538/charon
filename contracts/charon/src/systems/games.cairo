use charon::models::game::{Game, GameTrait};

#[starknet::interface]
pub trait IGame<T> {
    fn create_game(ref self: T, game_id: u32);
    fn end_game(ref self: T, game_id: u32);
}

#[dojo::contract]
pub mod game {
    use super::{IGame, Game, GameTrait};
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use dojo::model::{ModelStorage, Model};
    use dojo::event::EventStorage;

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        GameCreated: GameCreated,
        GameEnded: GameEnded,
    }

    #[derive(Drop, starknet::Event)]
    pub struct GameCreated {
        pub game_id: u32,
        pub creator: ContractAddress,
        pub timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct GameEnded {
        pub game_id: u32,
        pub timestamp: u64,
    }

    #[abi(embed_v0)]
    impl GameImpl of IGame<ContractState> {
        fn create_game(ref self: ContractState, game_id: u32) {
            let mut world = self.world_default();
            let caller = get_caller_address();

            // Check if game already exists
            let existing_game: Game = world.read_model(game_id);
            assert!(existing_game.game_id == 0, "Game already exists");

            // Create new game with timestamp
            let mut game = GameTrait::new(game_id,caller);
            game.clock = get_block_timestamp();

            world.write_model(@game);

            // Emit event
           self.emit(Event::GameCreated(
                GameCreated { 
                    game_id, 
                    creator: caller, 
                    timestamp: game.clock 
                }
            ));
        }

        fn end_game(ref self: ContractState, game_id: u32) {
            let mut world = self.world_default();

            // Read existing game
            let mut game: Game = world.read_model(game_id);
            assert!(game.game_id != 0, "Game does not exist");
            assert!(!game.over, "Game already ended");

            // End the game
            game.end_game();
            game.clock = get_block_timestamp();

            world.write_model(@game);

            // Emit event
            self.emit(Event::GameEnded(
                GameEnded { 
                    game_id, 
                    timestamp: game.clock 
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