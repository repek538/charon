use charon::models::oberon::{Crew,CrewTrait,ShipOberon};


#[starknet::interface]
pub trait ICrew<T> {
    fn create_crew(
        ref self: T,
        crew_id: u64,
    );
}

#[dojo::contract]

pub mod  crew {

    use crate::models::oberon_crew::CrewRole;
    use crate::models::oberon_crew::CrewMember;
    use super::{ICrew,Crew,CrewTrait,ShipOberon};

    use starknet::{ContractAddress,get_caller_address};
    use dojo::model::{ModelStorage};
    use dojo::event::EventStorage;

    #[abi(embed_v0)]
    impl CrewImpl of ICrew<ContractState> { 

        fn create_crew(
            ref self: ContractState,
            crew_id: u64,
            ){
                let mut world = self.world_default();
                let captain = get_caller_address();
                let ship = get_caller_address();

                let existing_ship: ShipOberon = world.read_model(captain);
                assert(existing_ship.point_defense > 0, 'Ship Not Created');

                let crew: CrewMember = world.read_model((crew_id,ship));

                let mut ship_crew: Crew = world.read_model(ship);

                ship_crew.members += 1;
                

                match crew.role {
                    CrewRole::Captain => {
                        ship_crew.captain = captain;
                    },
                    CrewRole::Pilot => {
                        ship_crew.pilots += 1;
                    },
                    CrewRole::Engineer => {
                        ship_crew.engineers += 1;
                    },
                    CrewRole::Gunner => {
                        ship_crew.gunners += 1;
                    },
                    CrewRole::Medic => {
                        ship_crew.medics += 1;
                    },
                    CrewRole::Scientist => {
                        ship_crew.scientists += 1;
                    },
                }

                world.write_model(@ship_crew);

            }

    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"charon")
        }
    }

}