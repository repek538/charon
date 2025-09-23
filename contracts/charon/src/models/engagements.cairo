use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Engagement {
    #[key]
    pub player: ContractAddress,
    #[key]
    pub engagement_id: u64,
    pub player_ship_id: ContractAddress,
    pub enemy_ship_id: ContractAddress,
    pub current_phase: EngagementPhase,
    pub initiated_at: u64,              // Block timestamp
    pub phase_deadline: u64,            // When player must respond
    pub player_action: PlayerAction,    // Last action taken
    pub enemy_action: EnemyAction,      // Enemy's response/action
    pub engagement_range: u32,          // Distance between ships in km
    pub player_hull: u32,              // Current hull points
    pub enemy_hull: u32,               // Enemy hull points
    pub player_shields: u32,           // Current shield points
    pub enemy_shields: u32,            // Enemy shield points
    pub consequences_applied: bool,     // Whether outcome has been processed
    pub outcome: EngagementOutcome,    // Final result
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug, DojoStore, Default)]
pub enum EngagementPhase {
    #[default]
    Initial,                    // First contact/hail
    Threatened,                // Enemy shows hostility
    UnderFire,                 // Being actively shot at
    Boarding,                  // Enemy attempting to board
    Negotiations,              // Trying to talk it out
    Retreat,                   // Attempting to flee
    Resolved,                  // Engagement over
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug, DojoStore, Default)]
pub enum PlayerAction {
    #[default]
    None,                      // No action taken yet
    Hail,                      // Send greeting/message
    Comply,                    // Submit to demands
    Negotiate,                 // Try to bargain
    PayBribe,                  // Offer money/cargo
    Threaten,                  // Show force/intimidate
    OpenFire,                  // Shoot first
    ActivateShields,           // Raise defenses
    Burn,                      // Full throttle escape
    PrepareBoarding,           // Ready for boarding action
    ActivatePDCs,             // Point defense systems
    LaunchTorpedoes,          // Heavy weapons
    SurrenderCargo,           // Give up goods
    SurrenderShip,            // Total surrender
    RamEnemy,                 // Desperate kamikaze
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug, DojoStore, Default)]
pub enum EnemyAction {
    #[default]
    None,                    // Contact attempt
    Demand,                   // Make demands
    Threaten,                 // Show weapons
    OpenFire,                 // Start shooting
    BoardingAction,           // Attempt boarding
    AcceptBribe,              // Take payment and leave
    Retreat,                  // Enemy flees
    Negotiate,                // Willing to talk
    Destroy,                  // Going for the kill
    Disable,                  // Trying to disable, not kill
    Rob,                      // Taking cargo/supplies
    Hail,                      // Send greeting/message
    Comply,                    // Submit to demands                // Try to bargain
    PayBribe,                  // Offer money/cargo                 // Show force/intimidate                  // Shoot first
    ActivateShields,           // Raise defenses
    Burn,                      // Full throttle escape
    PrepareBoarding,           // Ready for boarding action
    ActivatePDCs,             // Point defense systems
    LaunchTorpedoes,          // Heavy weapons
    SurrenderCargo,           // Give up goods
    SurrenderShip,            // Total surrender
    RamEnemy,                 // Desperate kamikaze
}


#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug, DojoStore, Default)]
pub enum EngagementOutcome {
    #[default]
    Ongoing,                  // Still in progress
    PlayerEscaped,           // Got away clean
    PlayerDestroyed,         // Ship destroyed
    PlayerDisabled,          // Ship crippled
    PlayerRobbed,            // Lost cargo/money
    PlayerCaptured,          // Ship taken
    EnemyDestroyed,          // Won the fight
    EnemyRetreated,          // Enemy fled
    Negotiated,              // Peaceful resolution
    BribePaid,               // Bought your way out
}

#[generate_trait]
pub impl EngagementImpl of EngagementTrait {
    #[inline(always)]
    fn new(
        player: ContractAddress,
        engagement_id: u64,
        player_ship_id: ContractAddress,
        enemy_ship_id: ContractAddress,
        current_time: u64,
        engagement_range: u32,
        player_hull: u32,
        enemy_hull: u32,
        player_shields: u32,
        enemy_shields: u32,
    ) -> Engagement {
        Engagement {
            player,
            engagement_id,
            player_ship_id,
            enemy_ship_id,
            current_phase: EngagementPhase::Initial,
            initiated_at: current_time,
            phase_deadline: current_time + 30, // 30 second response time
            player_action: PlayerAction::None,
            enemy_action: EnemyAction::Hail,
            engagement_range,
            player_hull,
            enemy_hull,
            player_shields,
            enemy_shields,
            consequences_applied: false,
            outcome: EngagementOutcome::Ongoing,
        }
    }

    #[inline(always)]
    fn is_response_overdue(self: Engagement, current_time: u64) -> bool {
        current_time > self.phase_deadline && self.outcome == EngagementOutcome::Ongoing
    }

    #[inline(always)]
    fn get_response_time_left(self: Engagement, current_time: u64) -> u64 {
        if current_time >= self.phase_deadline {
            0
        } else {
            self.phase_deadline - current_time
        }
    }

    #[inline(always)]
    fn escalate_phase(self: Engagement) -> EngagementPhase {
        match self.current_phase {
            EngagementPhase::Initial => EngagementPhase::Threatened,
            EngagementPhase::Threatened => EngagementPhase::UnderFire,
            EngagementPhase::UnderFire => EngagementPhase::UnderFire, // Stays here
            EngagementPhase::Negotiations => EngagementPhase::Threatened,
            EngagementPhase::Boarding => EngagementPhase::Boarding, // Terminal state
            EngagementPhase::Retreat => EngagementPhase::UnderFire, // Caught while fleeing
            EngagementPhase::Resolved => EngagementPhase::Resolved,
        }
    }

    #[inline(always)]
    fn get_default_timeout_action(self: Engagement) -> PlayerAction {
        // What happens if player doesn't respond in time
        match self.current_phase {
            EngagementPhase::Initial => PlayerAction::None, // Ignored the hail
            EngagementPhase::Threatened => PlayerAction::None, // Froze up
            EngagementPhase::UnderFire => PlayerAction::ActivateShields, // Panic defense
            EngagementPhase::Boarding => PlayerAction::SurrenderShip, // Overwhelmed
            EngagementPhase::Negotiations => PlayerAction::None, // Talks break down
            EngagementPhase::Retreat => PlayerAction::Burn, // Keep running
            EngagementPhase::Resolved => PlayerAction::None,
        }
    }

    #[inline(always)]
    fn calculate_enemy_response(self: Engagement, player_action: PlayerAction) -> EnemyAction {
        match (self.current_phase, player_action) {
            // Initial contact responses
            (EngagementPhase::Initial, PlayerAction::Hail) => EnemyAction::Demand,
            (EngagementPhase::Initial, PlayerAction::Threaten) => EnemyAction::Threaten,
            (EngagementPhase::Initial, PlayerAction::OpenFire) => EnemyAction::OpenFire,
            (EngagementPhase::Initial, PlayerAction::Burn) => EnemyAction::OpenFire,
            
            // Threatened phase responses
            (EngagementPhase::Threatened, PlayerAction::Comply) => EnemyAction::Rob,
            (EngagementPhase::Threatened, PlayerAction::PayBribe) => EnemyAction::AcceptBribe,
            (EngagementPhase::Threatened, PlayerAction::Negotiate) => EnemyAction::Negotiate,
            (EngagementPhase::Threatened, PlayerAction::OpenFire) => EnemyAction::OpenFire,
            (EngagementPhase::Threatened, PlayerAction::Burn) => EnemyAction::OpenFire,
            
            // Under fire responses
            (EngagementPhase::UnderFire, PlayerAction::ActivateShields) => EnemyAction::OpenFire,
            (EngagementPhase::UnderFire, PlayerAction::ActivatePDCs) => EnemyAction::LaunchTorpedoes,
            (EngagementPhase::UnderFire, PlayerAction::LaunchTorpedoes) => EnemyAction::Destroy,
            (EngagementPhase::UnderFire, PlayerAction::Burn) => EnemyAction::OpenFire,
            (EngagementPhase::UnderFire, PlayerAction::SurrenderCargo) => EnemyAction::Rob,
            (EngagementPhase::UnderFire, PlayerAction::SurrenderShip) => EnemyAction::Rob,
            
            // Default aggressive response
            _ => EnemyAction::OpenFire,
        }
    }

    #[inline(always)]
    fn calculate_outcome(self: Engagement, player_action: PlayerAction, enemy_action: EnemyAction) -> EngagementOutcome {
        match (player_action, enemy_action) {
            // Peaceful resolutions
            (PlayerAction::PayBribe, EnemyAction::AcceptBribe) => EngagementOutcome::BribePaid,
            (PlayerAction::Negotiate, EnemyAction::Negotiate) => EngagementOutcome::Negotiated,
            (PlayerAction::SurrenderCargo, EnemyAction::Rob) => EngagementOutcome::PlayerRobbed,
            
            // Combat outcomes - simplified for now
            (PlayerAction::OpenFire, EnemyAction::OpenFire) => {
                // This would use ship stats to determine winner
                if self.player_hull > self.enemy_hull {
                    EngagementOutcome::EnemyDestroyed
                } else {
                    EngagementOutcome::PlayerDestroyed
                }
            },
            
            // Escape attempts
            (PlayerAction::Burn, EnemyAction::OpenFire) => {
                // Success depends on ship speed/class
                EngagementOutcome::PlayerEscaped // Simplified
            },
            
            // Surrender outcomes
            (PlayerAction::SurrenderShip, _) => EngagementOutcome::PlayerCaptured,
            
            // Default to ongoing
            _ => EngagementOutcome::Ongoing,
        }
    }

    #[inline(always)]
    fn get_phase_timeout(self: Engagement) -> u64 {
        match self.current_phase {
            EngagementPhase::Initial => 45,      // More time for first decision
            EngagementPhase::Threatened => 30,   // Standard response time
            EngagementPhase::UnderFire => 15,    // Combat is fast
            EngagementPhase::Boarding => 10,     // Very urgent
            EngagementPhase::Negotiations => 60, // More time to talk
            EngagementPhase::Retreat => 20,      // Quick escape decisions
            EngagementPhase::Resolved => 0,      // No timeout needed
        }
    }

    #[inline(always)]
    fn update_phase(ref self: Engagement, new_phase: EngagementPhase, current_time: u64) {
        self.current_phase = new_phase;
        self.phase_deadline = current_time + self.get_phase_timeout();
    }

    #[inline(always)]
    fn process_player_action(ref self: Engagement, action: PlayerAction, current_time: u64) {
        self.player_action = action;
        self.enemy_action = self.calculate_enemy_response(action);
        
        // Determine new phase based on enemy response
        let new_phase = match self.enemy_action {
            EnemyAction::Threaten => EngagementPhase::Threatened,
            EnemyAction::OpenFire => EngagementPhase::UnderFire,
            EnemyAction::BoardingAction => EngagementPhase::Boarding,
            EnemyAction::Negotiate => EngagementPhase::Negotiations,
            EnemyAction::Retreat => EngagementPhase::Resolved,
            EnemyAction::AcceptBribe => EngagementPhase::Resolved,
            EnemyAction::Rob => EngagementPhase::Resolved,
            _ => self.current_phase,
        };
        
        self.update_phase(new_phase, current_time);
        self.outcome = self.calculate_outcome(action, self.enemy_action);
    }

    #[inline(always)]
    fn apply_damage(ref self: Engagement, damage_to_player: u32, damage_to_enemy: u32) {
        // Apply shield absorption first
        if self.player_shields > 0 && damage_to_player > 0 {
            let shield_absorbed = if damage_to_player <= self.player_shields.into() { 
                damage_to_player 
            } else { 
                self.player_shields.into() 
            };
            self.player_shields -= shield_absorbed.try_into().unwrap_or(0);
            let remaining_damage = damage_to_player - shield_absorbed;
            if remaining_damage < self.player_hull {
                self.player_hull -= remaining_damage;
            } else {
                self.player_hull = 0;
            }
        } else if damage_to_player > 0 {
            if damage_to_player < self.player_hull {
                self.player_hull -= damage_to_player;
            } else {
                self.player_hull = 0;
            }
        }
        
        // Same for enemy
        if self.enemy_shields > 0 && damage_to_enemy > 0 {
            let shield_absorbed = if damage_to_enemy <= self.enemy_shields.into() { 
                damage_to_enemy 
            } else { 
                self.enemy_shields.into() 
            };
            self.enemy_shields -= shield_absorbed.try_into().unwrap_or(0);
            let remaining_damage = damage_to_enemy - shield_absorbed;
            if remaining_damage < self.enemy_hull {
                self.enemy_hull -= remaining_damage;
            } else {
                self.enemy_hull = 0;
            }
        } else if damage_to_enemy > 0 {
            if damage_to_enemy < self.enemy_hull {
                self.enemy_hull -= damage_to_enemy;
            } else {
                self.enemy_hull = 0;
            }
        }
    }

    #[inline(always)]
    fn is_player_defeated(self: Engagement) -> bool {
        self.player_hull == 0
    }

    #[inline(always)]
    fn is_enemy_defeated(self: Engagement) -> bool {
        self.enemy_hull == 0
    }

    #[inline(always)]
    fn mark_consequences_applied(ref self: Engagement) {
        self.consequences_applied = true;
    }
}