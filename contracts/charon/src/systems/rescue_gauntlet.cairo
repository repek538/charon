use charon::models::game::{
    RescueGauntlet, RescueGauntletTrait,
    Rescuers, RescuersTrait,
    ShipComposition, ShipCompositionTrait,
    StationComposition, StationCompositionTrait,

};

#[starknet::interface]
pub trait IRescueGauntlet<T> {
    fn create_gauntlet(
        ref self: T,
        game_id: u32,
        rescue_id: u32,
        creator_stake: u256,
        rescue_reward: u256,
        attempt_fee: u256,
        credits_required: u256,
        mortality_level: u8,
        threat_budget_total: u32,
        rescue_deadline: u64,
        attempt_duration: u64,
    );
    fn start_rescue_attempt(ref self: T, game_id: u32, rescue_id: u32);
    fn complete_rescue(ref self: T, game_id: u32, rescue_id: u32);
    fn fail_rescue_attempt(ref self: T, game_id: u32, rescue_id: u32);
    fn cancel_gauntlet(ref self: T, game_id: u32, rescue_id: u32);
    fn claim_expired_stake(ref self: T, game_id: u32, rescue_id: u32);
}

#[dojo::contract]
pub mod rescue_gauntlet {
    use super::{
        IRescueGauntlet, RescueGauntlet, RescueGauntletTrait,
        Rescuers, RescuersTrait,
        ShipComposition, ShipCompositionTrait,
        StationComposition, StationCompositionTrait
    };
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use dojo::model::{ModelStorage, Model};

    use charon::utils::credit_helper::{CreditHelperTrait,CreditHelperImpl};

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        GauntletCreated: GauntletCreated,
        AttemptStarted: AttemptStarted,
        RescueCompleted: RescueCompleted,
        AttemptFailed: AttemptFailed,
        GauntletCancelled: GauntletCancelled,
        GauntletExpired: GauntletExpired,
    }

    #[derive(Drop, starknet::Event)]
    pub struct GauntletCreated {
        pub game_id: u32,
        pub rescue_id: u32,
        pub creator: ContractAddress,
        pub rescue_reward: u256,
        pub deadline: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct AttemptStarted {
        pub game_id: u32,
        pub rescue_id: u32,
        pub rescuer: ContractAddress,
        pub start_time: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct RescueCompleted {
        pub game_id: u32,
        pub rescue_id: u32,
        pub rescuer: ContractAddress,
        pub completion_time: u64,
        pub reward_amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct AttemptFailed {
        pub game_id: u32,
        pub rescue_id: u32,
        pub rescuer: ContractAddress,
        pub fail_time: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct GauntletCancelled {
        pub game_id: u32,
        pub rescue_id: u32,
        pub creator: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    pub struct GauntletExpired {
        pub game_id: u32,
        pub rescue_id: u32,
        pub final_time: u64,
    }

    #[abi(embed_v0)]
    impl RescueGauntletImpl of IRescueGauntlet<ContractState> {
        fn create_gauntlet(
            ref self: ContractState,
            game_id: u32,
            rescue_id: u32,
            creator_stake: u256,
            rescue_reward: u256,
            attempt_fee: u256,
            credits_required: u256,
            mortality_level: u8,
            threat_budget_total: u32,
            rescue_deadline: u64,
            attempt_duration: u64,
        ) {
            let mut world = self.world_default();
            let caller = get_caller_address();
            let current_time = get_block_timestamp();

            // Validate inputs
            assert!(rescue_deadline > current_time, "Deadline must be in future");
            assert!(attempt_duration > 0, "Attempt duration must be positive");
            assert!(rescue_reward > 0, "Reward must be positive");
            assert!(mortality_level <= 100, "Mortality level max 100");
            assert!(threat_budget_total > 0, "Threat budget must be positive");

            // Check if gauntlet already exists
            let existing_gauntlet: RescueGauntlet = world.read_model((game_id, rescue_id));
            assert!(existing_gauntlet.game_id == 0, "Gauntlet already exists");

            // Create gauntlet
            let gauntlet = RescueGauntletTrait::new(
                game_id,
                rescue_id,
                caller,
                creator_stake,
                rescue_reward,
                attempt_fee,
                credits_required,
                mortality_level,
                threat_budget_total,
                rescue_deadline,
                attempt_duration,
            );

            let (ships_composition, stations_composition) = CreditHelperTrait::get_recommended_composition(
                credits_required,
                mortality_level,
                rescue_id
            );

            // Initialize rescuers tracking
            let rescuers = RescuersTrait::new(game_id, rescue_id);

            // Save models
            world.write_model(@gauntlet);
            world.write_model(@rescuers);

            world.write_model(@ships_composition);
            world.write_model(@stations_composition);
            


            // Emit event
            self.emit(Event::GauntletCreated(
                GauntletCreated {
                    game_id,
                    rescue_id,
                    creator: caller,
                    rescue_reward,
                    deadline: rescue_deadline,
                }
            ));
        }

        fn start_rescue_attempt(ref self: ContractState, game_id: u32, rescue_id: u32) {
            let mut world = self.world_default();
            let caller = get_caller_address();
            let current_time = get_block_timestamp();

            // Load gauntlet
            let mut gauntlet: RescueGauntlet = world.read_model((game_id, rescue_id));
            assert!(gauntlet.game_id != 0, "Gauntlet does not exist");

            // Check expiration
            gauntlet.check_expired(current_time);
            assert!(gauntlet.is_active(), "Gauntlet not active");
            assert!(!gauntlet.is_full(), "Both slots occupied");

            // Load rescuers
            let mut rescuers: Rescuers = world.read_model((game_id, rescue_id));

            // Clean up expired attempts
            if rescuers.is_first_attempt_expired(current_time, gauntlet.attempt_duration) {
                rescuers.fail_first_attempt();
                gauntlet.remove_rescuer();
            }
            if rescuers.is_second_attempt_expired(current_time, gauntlet.attempt_duration) {
                rescuers.fail_second_attempt();
                gauntlet.remove_rescuer();
            }

            // Check caller not already attempting
            assert!(
                rescuers.first_rescuer != caller && rescuers.second_rescuer != caller,
                "Already attempting"
            );

            // TODO: Verify caller has required credits
            // TODO: Charge attempt fee

            // Assign to first available slot
            if !rescuers.has_first_rescuer() {
                rescuers.start_first_attempt(caller, current_time);
                gauntlet.add_rescuer();
            } else if !rescuers.has_second_rescuer() {
                rescuers.start_second_attempt(caller, current_time);
                gauntlet.add_rescuer();
            } else {
                panic!("No slots available");
            }

            gauntlet.increment_attempt();

            // Save models
            world.write_model(@gauntlet);
            world.write_model(@rescuers);

            // Emit event
            self.emit(Event::AttemptStarted(
                AttemptStarted {
                    game_id,
                    rescue_id,
                    rescuer: caller,
                    start_time: current_time,
                }
            ));
        }

        fn complete_rescue(ref self: ContractState, game_id: u32, rescue_id: u32) {
            let mut world = self.world_default();
            let caller = get_caller_address();
            let current_time = get_block_timestamp();

            // Load gauntlet
            let mut gauntlet: RescueGauntlet = world.read_model((game_id, rescue_id));
            assert!(gauntlet.game_id != 0, "Gauntlet does not exist");
            assert!(!gauntlet.is_rescued, "Already rescued");
            assert!(!gauntlet.is_expired, "Gauntlet expired");

            // Load rescuers
            let mut rescuers: Rescuers = world.read_model((game_id, rescue_id));

            // Verify caller is an active rescuer and mark completion
            if rescuers.first_rescuer == caller {
                assert!(!rescuers.is_first_completed(), "Already completed");
                assert!(
                    !rescuers.is_first_attempt_expired(current_time, gauntlet.attempt_duration),
                    "Attempt expired"
                );
                rescuers.complete_first_rescue(current_time);
            } else if rescuers.second_rescuer == caller {
                assert!(!rescuers.is_second_completed(), "Already completed");
                assert!(
                    !rescuers.is_second_attempt_expired(current_time, gauntlet.attempt_duration),
                    "Attempt expired"
                );
                rescuers.complete_second_rescue(current_time);
            } else {
                panic!("Not an active rescuer");
            }

            // TODO: Verify rescue objectives completed
            // TODO: Transfer reward to rescuer

            // Mark gauntlet as rescued - FIRST TO COMPLETE WINS
            gauntlet.complete_rescue(caller);

            // Save models
            world.write_model(@gauntlet);
            world.write_model(@rescuers);

            // Emit event
            self.emit(Event::RescueCompleted(
                RescueCompleted {
                    game_id,
                    rescue_id,
                    rescuer: caller,
                    completion_time: current_time,
                    reward_amount: gauntlet.rescue_reward,
                }
            ));
        }

        fn fail_rescue_attempt(ref self: ContractState, game_id: u32, rescue_id: u32) {
            let mut world = self.world_default();
            let caller = get_caller_address();
            let current_time = get_block_timestamp();

            // Load models
            let mut gauntlet: RescueGauntlet = world.read_model((game_id, rescue_id));
            assert!(gauntlet.game_id != 0, "Gauntlet does not exist");

            let mut rescuers: Rescuers = world.read_model((game_id, rescue_id));

            // Verify caller is an active rescuer and fail their attempt
            if rescuers.first_rescuer == caller {
                assert!(!rescuers.is_first_completed(), "Already completed");
                rescuers.fail_first_attempt();
                gauntlet.remove_rescuer();
            } else if rescuers.second_rescuer == caller {
                assert!(!rescuers.is_second_completed(), "Already completed");
                rescuers.fail_second_attempt();
                gauntlet.remove_rescuer();
            } else {
                panic!("Not an active rescuer");
            }

            // Save models
            world.write_model(@gauntlet);
            world.write_model(@rescuers);

            // Emit event
            self.emit(Event::AttemptFailed(
                AttemptFailed {
                    game_id,
                    rescue_id,
                    rescuer: caller,
                    fail_time: current_time,
                }
            ));
        }

        fn cancel_gauntlet(ref self: ContractState, game_id: u32, rescue_id: u32) {
            let mut world = self.world_default();
            let caller = get_caller_address();

            // Load gauntlet
            let mut gauntlet: RescueGauntlet = world.read_model((game_id, rescue_id));
            assert!(gauntlet.game_id != 0, "Gauntlet does not exist");
            assert!(gauntlet.creator_address == caller, "Only creator can cancel");
            assert!(!gauntlet.is_rescued, "Already rescued");

            // Load rescuers
            let rescuers: Rescuers = world.read_model((game_id, rescue_id));
            
            // Can only cancel if no active attempts
            assert!(
                !rescuers.has_first_rescuer() && !rescuers.has_second_rescuer(),
                "Active attempts in progress"
            );

            // TODO: Refund creator stake

            // Mark as expired to prevent new attempts
            gauntlet.is_expired = true;

            world.write_model(@gauntlet);

            // Emit event
            self.emit(Event::GauntletCancelled(
                GauntletCancelled {
                    game_id,
                    rescue_id,
                    creator: caller,
                }
            ));
        }

        fn claim_expired_stake(ref self: ContractState, game_id: u32, rescue_id: u32) {
            let mut world = self.world_default();
            let caller = get_caller_address();
            let current_time = get_block_timestamp();

            // Load gauntlet
            let mut gauntlet: RescueGauntlet = world.read_model((game_id, rescue_id));
            assert!(gauntlet.game_id != 0, "Gauntlet does not exist");
            assert!(gauntlet.creator_address == caller, "Only creator can claim");
            
            // Check if expired and not rescued
            gauntlet.check_expired(current_time);
            assert!(gauntlet.is_expired, "Gauntlet not expired");
            assert!(!gauntlet.is_rescued, "Gauntlet was rescued");

            // TODO: Return stake to creator

            world.write_model(@gauntlet);

            // Emit event
            self.emit(Event::GauntletExpired(
                GauntletExpired {
                    game_id,
                    rescue_id,
                    final_time: current_time,
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