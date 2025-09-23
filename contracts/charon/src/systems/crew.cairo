use charon::models::oberon::{Crew,CrewTrait,ShipOberon};


#[starknet::interface]
pub trait ICrew<T> {
    fn create_crew(
        ref self: T,
        members: u8,
        engineers: u8,
        gunners: u8,
        medics: u8,
    );
}

#[dojo::contract]

pub mod  crew {

    use super::{ICrew,Crew,CrewTrait,ShipOberon};

    use starknet::{ContractAddress,get_caller_address};
    use dojo::model::{ModelStorage};
    use dojo::event::EventStorage;

    #[abi(embed_v0)]
    impl CrewImpl of ICrew<ContractState> { 

        fn create_crew(
            ref self: ContractState,
            members: u8,
            engineers: u8,
            gunners: u8,
            medics: u8, 
            ){
                let mut world = self.world_default();
                let captain = get_caller_address();
                let ship = get_caller_address();

                let existing_ship: ShipOberon = world.read_model(captain);
                assert(existing_ship.point_defense > 0, 'Ship Not Created');

                let crew = CrewTrait::new(
                ship,
                captain,
                members,
                engineers,
                gunners,
                medics,
                );

                world.write_model(@crew);

            }

    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"charon")
        }
    }

}