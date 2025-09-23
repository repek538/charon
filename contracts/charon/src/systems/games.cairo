use charon::models::game::{Game,GameTrait};

#[starknet::interface]
pub trait IGame<T> {
    fn create_game(
        ref self: T,
         game_id: u32,
    );
}

#[dojo::contract]

pub mod  game {

    use super::{IGame,Game,GameTrait};

    use starknet::{ContractAddress,get_caller_address};
    use dojo::model::{ModelStorage};
    use dojo::event::EventStorage;

    #[abi(embed_v0)]
    impl GameImpl of IGame<ContractState> { 

        fn create_game(
            ref self: ContractState,
            game_id: u32 
            ){
                let mut world = self.world_default();

                let game = GameTrait::new(
                game_id
                );

                world.write_model(@game);

            }

    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"charon")
        }
    }

}