use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Engagement {
    #[key]
    pub player: ContractAddress,
    pub player_ship_id: ContractAddress,
    pub nps_ship_id: ContractAddress,
    pub current_phase: EngagementPhase,
    pub initiated_at: u64,              // Block timestamp
    pub phase_deadline: u64,            // When player must respond
    pub player_action: PlayerAction,    // Last action taken
    pub nps_action: NPSAction,      // Enemy's response/action
    pub engagement_range: u32,          // Distance between ships in km
    pub player_hull: u32,              // Current hull points
    pub nps_hull: u32,               // Enemy hull points
    pub player_shields: u32,           // Current shield points
    pub nps_shields: u32,            // Enemy shield points
    pub consequences_applied: bool,     // Whether outcome has been processed
    pub outcome: EngagementOutcome,    // Final result
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct StationEngagement {
    #[key]
    pub player: ContractAddress,
    pub player_ship_id: ContractAddress,
    pub station_id: u64,
    pub current_phase: StationEngagementPhase,
    pub initiated_at: u64,              // Block timestamp
    pub phase_deadline: u64,            // When player must respond
    pub player_action: PlayerStationAction,
    pub station_action: StationAction,
    pub engagement_range: u32,          // Distance from station in km
    pub player_hull: u32,
    pub player_shields: u32,
    pub station_hull: u32,              // Station structural integrity
    pub station_shields: u32,           // Station defenses
    pub docking_status: DockingStatus,
    pub consequences_applied: bool,
    pub outcome: StationEngagementOutcome,
    pub reputation_change: i32,         // Impact on faction standing
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
pub enum NPSAction {
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

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug, DojoStore, Default)]
pub enum StationEngagementPhase {
    #[default]
    Approach,                   // Initial approach to station
    DockingRequest,            // Requesting permission to dock
    Challenged,                // Station demands identification
    Denied,                    // Access denied
    Inspection,                // Station scanning ship/cargo
    Trading,                   // At trade terminal
    Refueling,                 // Docked and refueling
    UnderStationFire,          // Station shooting at player
    StationSiege,              // Player attacking station
    Evacuating,                // Emergency undocking
    Resolved,
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug, DojoStore, Default)]
pub enum PlayerStationAction {
    #[default]
    None,
    RequestDocking,            // Ask permission to dock
    ProvideClearance,          // Show credentials/permits
    PayDockingFee,             // Pay to dock
    BribeOfficer,              // Bribe for access
    FalsifyCredentials,        // Fake identification
    RequestTrade,              // Access marketplace
    RequestRefuel,             // Buy fuel
    RequestRepairs,            // Fix ship damage
    RequestUpgrade,            // Buy ship upgrades
    DumpCargo,                 // Jettison illegal goods
    ForceEntry,                // Attempt unauthorized docking
    AttackStation,             // Open fire on station
    HackDockingBay,            // Illegal access attempt
    EmergencyUndock,           // Quick escape
    Withdraw,                  // Leave peacefully
    SurrenderToAuthority,      // Give up to station security
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug, DojoStore, Default)]
pub enum StationAction {
    #[default]
    None,
    Hail,                      // Initial contact
    GrantDocking,              // Allow ship to dock
    DenyDocking,               // Refuse access
    DemandIdentification,      // Request credentials
    ScanShip,                  // Inspect for contraband
    ConfiscateCargo,           // Seize illegal goods
    ImposeQuarantine,          // Force quarantine period
    OpenTradingTerminal,       // Allow market access
    ProvideRefuel,             // Sell fuel
    ProvideRepairs,            // Fix ship
    OfferUpgrades,             // Sell equipment
    LaunchDefenseFighters,     // Deploy defense ships
    ActivatePointDefense,      // Anti-missile systems
    OpenFire,                  // Station weapons fire
    LockdownDockingBays,       // Seal all access
    AlertAuthorities,          // Call for backup
    NegotiateSurrender,        // Accept player surrender
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug, DojoStore, Default)]
pub enum DockingStatus {
    #[default]
    NotDocked,
    DockingApproved,
    Docked,
    DockingDenied,
    ForcedDocking,             // Illegal docking
    EmergencyDocked,           // Emergency landing
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug, DojoStore, Default)]
pub enum StationEngagementOutcome {
    #[default]
    Ongoing,
    SuccessfulDocking,         // Docked normally
    TradingComplete,           // Finished business
    RepairsComplete,           // Ship repaired
    AccessDenied,              // Turned away
    PlayerEscaped,             // Got away
    PlayerDestroyed,           // Ship destroyed by station
    PlayerCaptured,            // Arrested/detained
    StationDestroyed,          // Player destroyed station
    StationDamaged,            // Station damaged, player fled
    ContrabandSeized,          // Lost illegal cargo
    FinesImposed,              // Had to pay fines
    ReputationGained,          // Positive outcome
    ReputationLost,            // Negative outcome
}

#[generate_trait]
pub impl EngagementImpl of EngagementTrait {
    #[inline(always)]
    fn new(
        player: ContractAddress,
        player_ship_id: ContractAddress,
        nps_ship_id: ContractAddress,
        current_time: u64,
        engagement_range: u32,
        player_hull: u32,
        nps_hull: u32,
        player_shields: u32,
        nps_shields: u32,
        nps_action: NPSAction
    ) -> Engagement {
        Engagement {
            player,
            player_ship_id,
            nps_ship_id,
            current_phase: EngagementPhase::Initial,
            initiated_at: current_time,
            phase_deadline: 0, // 30 second response time
            player_action: PlayerAction::None,
            nps_action,
            engagement_range,
            player_hull,
            nps_hull,
            player_shields,
            nps_shields,
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
    fn calculate_nps_response(self: Engagement, player_action: PlayerAction) -> NPSAction {
        match (self.current_phase, player_action) {
            // Initial contact responses
            (EngagementPhase::Initial, PlayerAction::Hail) => NPSAction::Demand,
            (EngagementPhase::Initial, PlayerAction::Threaten) => NPSAction::Threaten,
            (EngagementPhase::Initial, PlayerAction::OpenFire) => NPSAction::OpenFire,
            (EngagementPhase::Initial, PlayerAction::Burn) => NPSAction::OpenFire,
            
            // Threatened phase responses
            (EngagementPhase::Threatened, PlayerAction::Comply) => NPSAction::Rob,
            (EngagementPhase::Threatened, PlayerAction::PayBribe) => NPSAction::AcceptBribe,
            (EngagementPhase::Threatened, PlayerAction::Negotiate) => NPSAction::Negotiate,
            (EngagementPhase::Threatened, PlayerAction::OpenFire) => NPSAction::OpenFire,
            (EngagementPhase::Threatened, PlayerAction::Burn) => NPSAction::OpenFire,
            
            // Under fire responses
            (EngagementPhase::UnderFire, PlayerAction::ActivateShields) => NPSAction::OpenFire,
            (EngagementPhase::UnderFire, PlayerAction::ActivatePDCs) => NPSAction::LaunchTorpedoes,
            (EngagementPhase::UnderFire, PlayerAction::LaunchTorpedoes) => NPSAction::Destroy,
            (EngagementPhase::UnderFire, PlayerAction::Burn) => NPSAction::OpenFire,
            (EngagementPhase::UnderFire, PlayerAction::SurrenderCargo) => NPSAction::Rob,
            (EngagementPhase::UnderFire, PlayerAction::SurrenderShip) => NPSAction::Rob,
            
            // Default aggressive response
            _ => NPSAction::OpenFire,
        }
    }

    #[inline(always)]
    fn calculate_outcome(self: Engagement, player_action: PlayerAction, nps_action: NPSAction) -> EngagementOutcome {
        match (player_action, nps_action) {
            // Peaceful resolutions
            (PlayerAction::PayBribe, NPSAction::AcceptBribe) => EngagementOutcome::BribePaid,
            (PlayerAction::Negotiate, NPSAction::Negotiate) => EngagementOutcome::Negotiated,
            (PlayerAction::SurrenderCargo, NPSAction::Rob) => EngagementOutcome::PlayerRobbed,
            
            // Combat outcomes - simplified for now
            (PlayerAction::OpenFire, NPSAction::OpenFire) => {
                // This would use ship stats to determine winner
                if self.player_hull > self.nps_hull {
                    EngagementOutcome::EnemyDestroyed
                } else {
                    EngagementOutcome::PlayerDestroyed
                }
            },
            
            // Escape attempts
            (PlayerAction::Burn, NPSAction::OpenFire) => {
                // Success depends on ship speed/s_class
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
        self.nps_action = self.calculate_nps_response(action);
        
        // Determine new phase based on nps response
        let new_phase = match self.nps_action {
            NPSAction::Threaten => EngagementPhase::Threatened,
            NPSAction::OpenFire => EngagementPhase::UnderFire,
            NPSAction::BoardingAction => EngagementPhase::Boarding,
            NPSAction::Negotiate => EngagementPhase::Negotiations,
            NPSAction::Retreat => EngagementPhase::Resolved,
            NPSAction::AcceptBribe => EngagementPhase::Resolved,
            NPSAction::Rob => EngagementPhase::Resolved,
            _ => self.current_phase,
        };
        
        self.update_phase(new_phase, current_time);
        self.outcome = self.calculate_outcome(action, self.nps_action);
    }

    #[inline(always)]
    fn apply_damage(ref self: Engagement, damage_to_player: u32, damage_to_nps: u32) {
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
        
        // Same for nps
        if self.nps_shields > 0 && damage_to_nps > 0 {
            let shield_absorbed = if damage_to_nps <= self.nps_shields.into() { 
                damage_to_nps 
            } else { 
                self.nps_shields.into() 
            };
            self.nps_shields -= shield_absorbed.try_into().unwrap_or(0);
            let remaining_damage = damage_to_nps - shield_absorbed;
            if remaining_damage < self.nps_hull {
                self.nps_hull -= remaining_damage;
            } else {
                self.nps_hull = 0;
            }
        } else if damage_to_nps > 0 {
            if damage_to_nps < self.nps_hull {
                self.nps_hull -= damage_to_nps;
            } else {
                self.nps_hull = 0;
            }
        }
    }

    #[inline(always)]
    fn is_player_defeated(self: Engagement) -> bool {
        self.player_hull == 0
    }

    #[inline(always)]
    fn is_nps_defeated(self: Engagement) -> bool {
        self.nps_hull == 0
    }

    #[inline(always)]
    fn mark_consequences_applied(ref self: Engagement) {
        self.consequences_applied = true;
    }
}

#[generate_trait]
pub impl StationEngagementImpl of StationEngagementTrait {
    #[inline(always)]
    fn new(
        player: ContractAddress,
        player_ship_id: ContractAddress,
        station_id: u64,
        current_time: u64,
        engagement_range: u32,
        player_hull: u32,
        player_shields: u32,
        station_hull: u32,
        station_shields: u32,
    ) -> StationEngagement {
        StationEngagement {
            player,
            player_ship_id,
            station_id,
            current_phase: StationEngagementPhase::Approach,
            initiated_at: current_time,
            phase_deadline: current_time + 60, // 60 seconds for initial approach
            player_action: PlayerStationAction::None,
            station_action: StationAction::Hail,
            engagement_range,
            player_hull,
            player_shields,
            station_hull,
            station_shields,
            docking_status: DockingStatus::NotDocked,
            consequences_applied: false,
            outcome: StationEngagementOutcome::Ongoing,
            reputation_change: 0,
        }
    }

    #[inline(always)]
    fn is_response_overdue(self: StationEngagement, current_time: u64) -> bool {
        current_time > self.phase_deadline && self.outcome == StationEngagementOutcome::Ongoing
    }

    #[inline(always)]
    fn get_response_time_left(self: StationEngagement, current_time: u64) -> u64 {
        if current_time >= self.phase_deadline {
            0
        } else {
            self.phase_deadline - current_time
        }
    }

    #[inline(always)]
    fn escalate_phase(self: StationEngagement) -> StationEngagementPhase {
        match self.current_phase {
            StationEngagementPhase::Approach => StationEngagementPhase::Challenged,
            StationEngagementPhase::DockingRequest => StationEngagementPhase::Denied,
            StationEngagementPhase::Challenged => StationEngagementPhase::UnderStationFire,
            StationEngagementPhase::Denied => StationEngagementPhase::UnderStationFire,
            StationEngagementPhase::Inspection => StationEngagementPhase::Challenged,
            StationEngagementPhase::UnderStationFire => StationEngagementPhase::UnderStationFire,
            StationEngagementPhase::StationSiege => StationEngagementPhase::StationSiege,
            StationEngagementPhase::Evacuating => StationEngagementPhase::UnderStationFire,
            _ => self.current_phase,
        }
    }

    #[inline(always)]
    fn get_default_timeout_action(self: StationEngagement) -> PlayerStationAction {
        match self.current_phase {
            StationEngagementPhase::Approach => PlayerStationAction::None,
            StationEngagementPhase::DockingRequest => PlayerStationAction::Withdraw,
            StationEngagementPhase::Challenged => PlayerStationAction::ProvideClearance,
            StationEngagementPhase::Denied => PlayerStationAction::Withdraw,
            StationEngagementPhase::Inspection => PlayerStationAction::None,
            StationEngagementPhase::UnderStationFire => PlayerStationAction::EmergencyUndock,
            StationEngagementPhase::StationSiege => PlayerStationAction::AttackStation,
            StationEngagementPhase::Evacuating => PlayerStationAction::EmergencyUndock,
            _ => PlayerStationAction::None,
        }
    }

    #[inline(always)]
    fn calculate_station_response(
        self: StationEngagement, 
        player_action: PlayerStationAction
    ) -> StationAction {
        match (self.current_phase, player_action) {
            // Approach phase
            (StationEngagementPhase::Approach, PlayerStationAction::RequestDocking) => 
                StationAction::DemandIdentification,
            (StationEngagementPhase::Approach, PlayerStationAction::AttackStation) => 
                StationAction::OpenFire,
            
            // Docking request phase
            (StationEngagementPhase::DockingRequest, PlayerStationAction::ProvideClearance) => 
                StationAction::GrantDocking,
            (StationEngagementPhase::DockingRequest, PlayerStationAction::BribeOfficer) => 
                StationAction::GrantDocking,
            (StationEngagementPhase::DockingRequest, PlayerStationAction::FalsifyCredentials) => 
                StationAction::ScanShip,
            
            // Challenged phase
            (StationEngagementPhase::Challenged, PlayerStationAction::ProvideClearance) => 
                StationAction::ScanShip,
            (StationEngagementPhase::Challenged, PlayerStationAction::PayDockingFee) => 
                StationAction::GrantDocking,
            (StationEngagementPhase::Challenged, PlayerStationAction::ForceEntry) => 
                StationAction::OpenFire,
            
            // Inspection phase
            (StationEngagementPhase::Inspection, PlayerStationAction::DumpCargo) => 
                StationAction::GrantDocking,
            (StationEngagementPhase::Inspection, PlayerStationAction::None) => 
                StationAction::ConfiscateCargo,
            
            // Combat responses
            (_, PlayerStationAction::AttackStation) => StationAction::OpenFire,
            (_, PlayerStationAction::HackDockingBay) => StationAction::AlertAuthorities,
            (_, PlayerStationAction::SurrenderToAuthority) => StationAction::NegotiateSurrender,
            
            // Default
            _ => StationAction::DenyDocking,
        }
    }

    #[inline(always)]
    fn calculate_outcome(
        self: StationEngagement,
        player_action: PlayerStationAction,
        station_action: StationAction
    ) -> StationEngagementOutcome {
        match (player_action, station_action) {
            // Successful docking
            (PlayerStationAction::RequestDocking, StationAction::GrantDocking) => 
                StationEngagementOutcome::SuccessfulDocking,
            (PlayerStationAction::PayDockingFee, StationAction::GrantDocking) => 
                StationEngagementOutcome::SuccessfulDocking,
            
            // Trading outcomes
            (PlayerStationAction::RequestTrade, StationAction::OpenTradingTerminal) => 
                StationEngagementOutcome::TradingComplete,
            (PlayerStationAction::RequestRepairs, StationAction::ProvideRepairs) => 
                StationEngagementOutcome::RepairsComplete,
            
            // Denied access
            (PlayerStationAction::RequestDocking, StationAction::DenyDocking) => 
                StationEngagementOutcome::AccessDenied,
            
            // Combat outcomes
            (PlayerStationAction::AttackStation, StationAction::OpenFire) => {
                if self.station_hull == 0 {
                    StationEngagementOutcome::StationDestroyed
                } else if self.player_hull == 0 {
                    StationEngagementOutcome::PlayerDestroyed
                } else {
                    StationEngagementOutcome::Ongoing
                }
            },
            
            // Contraband seized
            (_, StationAction::ConfiscateCargo) => 
                StationEngagementOutcome::ContrabandSeized,
            
            // Escape
            (PlayerStationAction::EmergencyUndock, _) => 
                StationEngagementOutcome::PlayerEscaped,
            (PlayerStationAction::Withdraw, _) => 
                StationEngagementOutcome::PlayerEscaped,
            
            // Capture
            (PlayerStationAction::SurrenderToAuthority, StationAction::NegotiateSurrender) => 
                StationEngagementOutcome::PlayerCaptured,
            
            _ => StationEngagementOutcome::Ongoing,
        }
    }

    #[inline(always)]
    fn get_phase_timeout(self: StationEngagement) -> u64 {
        match self.current_phase {
            StationEngagementPhase::Approach => 60,
            StationEngagementPhase::DockingRequest => 45,
            StationEngagementPhase::Challenged => 30,
            StationEngagementPhase::Denied => 20,
            StationEngagementPhase::Inspection => 40,
            StationEngagementPhase::Trading => 300, // 5 minutes for trading
            StationEngagementPhase::Refueling => 120,
            StationEngagementPhase::UnderStationFire => 15,
            StationEngagementPhase::StationSiege => 20,
            StationEngagementPhase::Evacuating => 10,
            StationEngagementPhase::Resolved => 0,
        }
    }

    #[inline(always)]
    fn update_phase(
        ref self: StationEngagement, 
        new_phase: StationEngagementPhase, 
        current_time: u64
    ) {
        self.current_phase = new_phase;
        self.phase_deadline = current_time + self.get_phase_timeout();
    }

    #[inline(always)]
    fn process_player_action(
        ref self: StationEngagement, 
        action: PlayerStationAction, 
        current_time: u64
    ) {
        self.player_action = action;
        self.station_action = self.calculate_station_response(action);
        
        // Update docking status
        match self.station_action {
            StationAction::GrantDocking => {
                self.docking_status = DockingStatus::DockingApproved;
            },
            StationAction::DenyDocking => {
                self.docking_status = DockingStatus::DockingDenied;
            },
            _ => {},
        }
        
        // Determine new phase
        let new_phase = match self.station_action {
            StationAction::DemandIdentification => StationEngagementPhase::Challenged,
            StationAction::ScanShip => StationEngagementPhase::Inspection,
            StationAction::GrantDocking => StationEngagementPhase::Trading,
            StationAction::DenyDocking => StationEngagementPhase::Denied,
            StationAction::OpenFire => StationEngagementPhase::UnderStationFire,
            StationAction::OpenTradingTerminal => StationEngagementPhase::Trading,
            StationAction::ProvideRefuel => StationEngagementPhase::Refueling,
            _ => self.current_phase,
        };
        
        self.update_phase(new_phase, current_time);
        self.outcome = self.calculate_outcome(action, self.station_action);
    }

    #[inline(always)]
    fn apply_damage(ref self: StationEngagement, damage_to_player: u32, damage_to_station: u32) {
        // Player damage
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
        
        // Station damage
        if self.station_shields > 0 && damage_to_station > 0 {
            let shield_absorbed = if damage_to_station <= self.station_shields.into() { 
                damage_to_station 
            } else { 
                self.station_shields.into() 
            };
            self.station_shields -= shield_absorbed.try_into().unwrap_or(0);
            let remaining_damage = damage_to_station - shield_absorbed;
            if remaining_damage < self.station_hull {
                self.station_hull -= remaining_damage;
            } else {
                self.station_hull = 0;
            }
        } else if damage_to_station > 0 {
            if damage_to_station < self.station_hull {
                self.station_hull -= damage_to_station;
            } else {
                self.station_hull = 0;
            }
        }
    }

    #[inline(always)]
    fn is_player_defeated(self: StationEngagement) -> bool {
        self.player_hull == 0
    }

    #[inline(always)]
    fn is_station_destroyed(self: StationEngagement) -> bool {
        self.station_hull == 0
    }

    #[inline(always)]
    fn is_docked(self: StationEngagement) -> bool {
        self.docking_status == DockingStatus::Docked
    }

    #[inline(always)]
    fn mark_consequences_applied(ref self: StationEngagement) {
        self.consequences_applied = true;
    }

    #[inline(always)]
    fn update_reputation(ref self: StationEngagement, change: i32) {
        self.reputation_change = change;
    }
}