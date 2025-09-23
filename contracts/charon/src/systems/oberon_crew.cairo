use starknet::ContractAddress;
use charon::models::oberon_crew::{CrewMember, CrewMemberTrait, CrewAbility, CrewAbilityTrait, CrewRole, AbilityType};
use charon::models::oberon::{ShipOberon};

#[starknet::interface]
pub trait IOberonCrew<T> {
    fn create_crew_member(
        ref self: T,
        ship: ContractAddress,
        role: CrewRole,
        health: u8,
        morale: u8,
        stamina: u8,
        intelligence: u8,
        strength: u8,
        dexterity: u8,
    ) -> u64;
    
    fn assign_ability(
        ref self: T,
        crew_id: u64,
        ability_type: AbilityType,
    );
    
    fn activate_ability(
        ref self: T,
        crew_id: u64,
        ability_id: u8,
    );
    
    fn heal_crew_member(
        ref self: T,
        crew_id: u64,
        amount: u8,
    );
    
    fn train_crew_member(
        ref self: T,
        crew_id: u64,
        experience: u16,
    );
    
    fn get_crew_effectiveness(
        self: @T,
        ship: ContractAddress,
        role: CrewRole,
    ) -> u8;
    
    fn process_crew_turn(
        ref self: T,
        ship: ContractAddress,
    );
}

#[dojo::contract]
pub mod oberon_crew {
    use super::{IOberonCrew, CrewMember, CrewMemberTrait, CrewAbility, CrewAbilityTrait, CrewRole, AbilityType, ShipOberon};
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use dojo::model::{ModelStorage, Model};
    use dojo::event::EventStorage;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        CrewMemberCreated: CrewMemberCreated,
        AbilityAssigned: AbilityAssigned,
        AbilityActivated: AbilityActivated,
        CrewMemberHealed: CrewMemberHealed,
        CrewMemberTrained: CrewMemberTrained,
    }

    #[derive(Drop, starknet::Event)]
    struct CrewMemberCreated {
        crew_id: u64,
        ship: ContractAddress,
        owner: ContractAddress,
        role: CrewRole,
    }

    #[derive(Drop, starknet::Event)]
    struct AbilityAssigned {
        crew_id: u64,
        ability_type: AbilityType,
    }

    #[derive(Drop, starknet::Event)]
    struct AbilityActivated {
        crew_id: u64,
        ability_id: u8,
        ability_type: AbilityType,
    }

    #[derive(Drop, starknet::Event)]
    struct CrewMemberHealed {
        crew_id: u64,
        amount: u8,
        new_health: u8,
    }

    #[derive(Drop, starknet::Event)]
    struct CrewMemberTrained {
        crew_id: u64,
        experience_gained: u16,
        new_level: u8,
    }

    #[abi(embed_v0)]
    impl OberonCrewImpl of IOberonCrew<ContractState> {
        fn create_crew_member(
            ref self: ContractState,
            ship: ContractAddress,
            role: CrewRole,
            health: u8,
            morale: u8,
            stamina: u8,
            intelligence: u8,
            strength: u8,
            dexterity: u8,
        ) -> u64 {
            let mut world = self.world_default();
            let caller = get_caller_address();
            
            // Verify ship ownership
            let ship_data: ShipOberon = world.read_model(caller);
            assert(ship_data.owner == caller, 'Not ship owner');
            assert(ship == caller, 'Ship address mismatch');
            
            // Validate stats (1-100 range)
            assert(health <= 100 && health > 0, 'Invalid health');
            assert(morale <= 100 && morale > 0, 'Invalid morale');
            assert(stamina <= 100 && stamina > 0, 'Invalid stamina');
            assert(intelligence <= 100 && intelligence > 0, 'Invalid intelligence');
            assert(strength <= 100 && strength > 0, 'Invalid strength');
            assert(dexterity <= 100 && dexterity > 0, 'Invalid dexterity');
            
            // Generate unique crew ID (using timestamp + ship hash)
            let crew_id = self.generate_crew_id(ship, caller);
            
            let crew_member = CrewMemberTrait::new(
                crew_id,
                ship,
                caller,
                role,
                health,
                morale,
                stamina,
                intelligence,
                strength,
                dexterity,
            );
            
            world.write_model(@crew_member);
            
            // Emit event
            self.emit(Event::CrewMemberCreated(
                CrewMemberCreated {
                    crew_id,
                    ship,
                    owner: caller,
                    role,
                }
            ));
            
            crew_id
        }

        fn assign_ability(
            ref self: ContractState,
            crew_id: u64,
            ability_type: AbilityType,
        ) {
            let mut world = self.world_default();
            let caller = get_caller_address();
            
            // Get crew member
            let crew_member: CrewMember = world.read_model((crew_id, caller));
            assert(crew_member.owner == caller, 'Not crew owner');
            assert(crew_member.active, 'Crew member inactive');
            
            // Check if role can use this ability
         //   assert(crew_member.role.can_use_ability(ability_type), 'Role cannot use ability');
            
            // Generate ability ID
            let ability_id = self.generate_ability_id(crew_id, ability_type);
            
            let ability = CrewAbilityTrait::new(crew_id, ability_id, ability_type);
            world.write_model(@ability);
            
            // Emit event
            self.emit(Event::AbilityAssigned(
                AbilityAssigned {
                    crew_id,
                    ability_type,
                }
            ));
        }

        fn activate_ability(
            ref self: ContractState,
            crew_id: u64,
            ability_id: u8,
        ) {
            let mut world = self.world_default();
            let caller = get_caller_address();
            
            // Verify ownership
            let crew_member: CrewMember = world.read_model((crew_id, caller));
            assert(crew_member.owner == caller, 'Not crew owner');
            assert(crew_member.is_effective(), 'Crew not effective');
            
            // Get and activate ability
            let mut ability: CrewAbility = world.read_model((crew_id, ability_id));
            assert(ability.can_activate(), 'Cannot activate ability');
            
            ability.activate();
            world.write_model(@ability);
            
            // Emit event
            self.emit(Event::AbilityActivated(
                AbilityActivated {
                    crew_id,
                    ability_id,
                    ability_type: ability.ability_type,
                }
            ));
        }

        fn heal_crew_member(
            ref self: ContractState,
            crew_id: u64,
            amount: u8,
        ) {
            let mut world = self.world_default();
            let caller = get_caller_address();
            
            let mut crew_member: CrewMember = world.read_model((crew_id, caller));
            assert(crew_member.owner == caller, 'Not crew owner');
            
            let old_health = crew_member.health;
            crew_member.heal(amount);
            world.write_model(@crew_member);
            
            // Emit event
            self.emit(Event::CrewMemberHealed(
                CrewMemberHealed {
                    crew_id,
                    amount,
                    new_health: crew_member.health,
                }
            ));
        }

        fn train_crew_member(
            ref self: ContractState,
            crew_id: u64,
            experience: u16,
        ) {
            let mut world = self.world_default();
            let caller = get_caller_address();
            
            let mut crew_member: CrewMember = world.read_model((crew_id, caller));
            assert(crew_member.owner == caller, 'Not crew owner');
            assert(crew_member.active, 'Crew member inactive');
            
            let old_level = crew_member.get_level();
            crew_member.gain_experience(experience);
            let new_level = crew_member.get_level();
            
            world.write_model(@crew_member);
            
            // Emit event
            self.emit(Event::CrewMemberTrained(
                CrewMemberTrained {
                    crew_id,
                    experience_gained: experience,
                    new_level,
                }
            ));
        }

        fn get_crew_effectiveness(
            self: @ContractState,
            ship: ContractAddress,
            role: CrewRole,
        ) -> u8 {
            let world = self.world_default();
            let caller = get_caller_address();
            
            // This is a simplified version - in practice you'd need to query all crew members
            // For now, return a placeholder that would be implemented with proper queries
            let crew_member: CrewMember = world.read_model((1_u64, ship)); // Placeholder
            
            if crew_member.role == role {
                crew_member.get_effectiveness_multiplier()
            } else {
                50 // Base effectiveness if no matching role
            }
        }

        fn process_crew_turn(
            ref self: ContractState,
            ship: ContractAddress,
        ) {
            let mut world = self.world_default();
            let caller = get_caller_address();
            
            // Verify ship ownership
            let ship_data: ShipOberon = world.read_model(caller);
            assert(ship_data.owner == caller, 'Not ship owner');
            
            // In a real implementation, you'd iterate through all crew members
            // This is a placeholder for the turn processing logic
            // - Tick ability cooldowns
            // - Restore stamina
            // - Apply passive effects
            // - Check for crew events
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"charon")
        }
        
        fn generate_crew_id(self: @ContractState, ship: ContractAddress, owner: ContractAddress) -> u64 {
            let timestamp = get_block_timestamp();
            let ship_felt: felt252 = ship.into();
            let owner_felt: felt252 = owner.into();
            
            // Simple ID generation - in production you'd want something more robust
            (timestamp.into() + ship_felt + owner_felt).try_into().unwrap()
        }
        
        fn generate_ability_id(self: @ContractState, crew_id: u64, ability_type: AbilityType) -> u8 {
            // Simple ability ID generation
            let ability_type_id: u8 = match ability_type {
                AbilityType::NavigationBoost => 1,
                AbilityType::RepairExpertise => 2,
                AbilityType::WeaponMastery => 3,
                AbilityType::MedicalAid => 4,
                AbilityType::ScienceScan => 5,
                AbilityType::Leadership => 6,
            };
            
            ability_type_id
        }
    }
}