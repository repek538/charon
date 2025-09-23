use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct ShipsMessage {
    #[key]
    pub receiver: ContractAddress,      // Player/contract receiving the message
    #[key] 
    pub message_id: u64,               // Unique message identifier
    pub sender: ContractAddress,        // Player/contract sending the message
    pub sender_ship_id: u64,           // ID of the ship sending the message
    pub sender_ship_name: felt252,     // Name of the sending ship
    pub sender_faction: Faction,       // Faction of the sender
    pub message_type: MessageType,     // Type of communication
    pub content: felt252,              // Message content
    pub timestamp: u64,                // When message was sent
    pub priority: MessagePriority,     // Message urgency level
    pub is_encrypted: bool,            // Whether message is encrypted
    pub requires_response: bool,       // Whether sender expects a reply
    pub location: Vec2,                // Location where message was sent from
    pub transmission_range: u32,       // Range of transmission in km
    pub is_broadcast: bool,            // Whether this is a broadcast message
    pub is_read: bool,                 // Whether receiver has read the message
    pub expires_at: u64,               // When message expires (0 = never)
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug)]
pub enum MessageType {
    Hail,                   // Standard greeting/contact
    Surrender,              // Surrender offer/demand
    Threat,                 // Hostile warning
    TradeOffer,             // Commercial proposition
    Alliance,               // Diplomatic alliance proposal
    Ceasefire,             // Temporary peace agreement
    Intelligence,           // Information sharing
    Distress,              // Emergency/help request
    Navigation,            // Traffic control/navigation info
    Identification,        // Identity verification request
    Tactical,              // Combat coordination
    Broadcast,             // Public announcement
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug)]
pub enum MessagePriority {
    Low,                   // Non-urgent information
    Normal,                // Standard communication
    High,                  // Important message
    Critical,              // Emergency/combat priority
    Flash,                 // Immediate action required
}

#[generate_trait]
pub impl ShipsMessageImpl of ShipsMessageTrait {
    #[inline(always)]
    fn new(
        receiver: ContractAddress,
        message_id: u64,
        sender: ContractAddress,
        sender_ship_id: u64,
        sender_ship_name: felt252,
        sender_faction: Faction,
        message_type: MessageType,
        content: felt252,
        timestamp: u64,
        priority: MessagePriority,
        is_encrypted: bool,
        requires_response: bool,
        location: Vec2,
        transmission_range: u32,
        is_broadcast: bool,
    ) -> ShipsMessage {
        ShipsMessage {
            receiver,
            message_id,
            sender,
            sender_ship_id,
            sender_ship_name,
            sender_faction,
            message_type,
            content,
            timestamp,
            priority,
            is_encrypted,
            requires_response,
            location,
            transmission_range,
            is_broadcast,
            is_read: false,
            expires_at: 0,
        }
    }

    #[inline(always)]
    fn is_expired(self: ShipsMessage, current_time: u64) -> bool {
        if self.expires_at == 0 {
            return false;
        }
        current_time >= self.expires_at
    }

    #[inline(always)]
    fn is_hostile_message(self: ShipsMessage) -> bool {
        if self.message_type == MessageType::Threat || self.message_type == MessageType::Surrender {
            return true;
        }
        false
    }

    #[inline(always)]
    fn is_diplomatic_message(self: ShipsMessage) -> bool {
        if self.message_type == MessageType::Alliance 
            || self.message_type == MessageType::Ceasefire 
            || self.message_type == MessageType::TradeOffer {
            return true;
        }
        false
    }

    #[inline(always)]
    fn is_emergency_message(self: ShipsMessage) -> bool {
        if self.message_type == MessageType::Distress {
            return true;
        }
        if self.priority == MessagePriority::Critical || self.priority == MessagePriority::Flash {
            return true;
        }
        false
    }

    #[inline(always)]
    fn can_be_intercepted(self: ShipsMessage) -> bool {
        // Encrypted messages are harder to intercept
        if self.is_encrypted {
            return false;
        }
        
        // Broadcast messages can always be intercepted
        if self.is_broadcast {
            return true;
        }
        
        // High power transmissions are easier to detect
        if self.transmission_range > 10000 {
            return true;
        }
        
        false
    }

    #[inline(always)]
    fn get_transmission_delay(self: ShipsMessage, distance: u32) -> u64 {
        // Speed of light delay (simplified: 1 second per 300,000 km)
        let base_delay = distance / 300000;
        
        // Add processing delay based on encryption
        let processing_delay = if self.is_encrypted { 2 } else { 0 };
        
        // Add priority modifier
        let priority_modifier = match self.priority {
            MessagePriority::Flash => 0,
            MessagePriority::Critical => 0,
            MessagePriority::High => 1,
            MessagePriority::Normal => 2,
            MessagePriority::Low => 5,
        };
        
        base_delay.into() + processing_delay + priority_modifier
    }

    #[inline(always)]
    fn requires_line_of_sight(self: ShipsMessage) -> bool {
        // High frequency communications need line of sight
        if self.transmission_range < 1000 {
            return true;
        }
        
        // Tactical messages usually use directional comms
        if self.message_type == MessageType::Tactical {
            return true;
        }
        
        false
    }

    #[inline(always)]
    fn get_detection_chance(self: ShipsMessage, interceptor_scanner_quality: u8) -> u8 {
        let mut base_chance = 50;
        
        // Encryption makes detection harder
        if self.is_encrypted {
            base_chance -= 30;
        }
        
        // Range affects detection
        if self.transmission_range > 50000 {
            base_chance += 20;
        } else if self.transmission_range < 5000 {
            base_chance -= 20;
        }
        
        // Priority affects signal strength
        let priority_modifier = match self.priority {
            MessagePriority::Flash => 15,
            MessagePriority::Critical => 10,
            MessagePriority::High => 5,
            MessagePriority::Normal => 0,
            MessagePriority::Low => -10,
        };
        
        base_chance += priority_modifier;
        
        // Scanner quality affects detection
        let scanner_bonus = interceptor_scanner_quality / 10;
        base_chance += scanner_bonus.into();
        
        // Clamp between 0 and 100
        if base_chance > 100 {
            100
        } else if base_chance < 0 {
            0
        } else {
            base_chance.try_into().unwrap_or(50)
        }
    }

    #[inline(always)]
    fn mark_as_read(ref self: ShipsMessage) {
        self.is_read = true;
    }

    #[inline(always)]
    fn set_expiration(ref self: ShipsMessage, expires_at: u64) {
        self.expires_at = expires_at;
    }

    #[inline(always)]
    fn is_from_friendly_faction(self: ShipsMessage, my_faction: Faction) -> bool {
        // Same faction is always friendly
        if self.sender_faction == my_faction {
            return true;
        }
        
        // Define faction relationships
        match (my_faction, self.sender_faction) {
            // UN and Mars Federation are neutral to each other
            (Faction::UN, Faction::MarsFederation) => false,
            (Faction::MarsFederation, Faction::UN) => false,
            
            // Everyone hostile to Pirates
            (_, Faction::Pirates) => false,
            (Faction::Pirates, _) => false,
            
            // Independent traders are neutral to major factions
            (_, Faction::Independent) => false,
            (Faction::Independent, _) => false,
            
            // Kuiper Union hostile to inner system factions
            (Faction::KuiperUnion, Faction::UN) => false,
            (Faction::KuiperUnion, Faction::MarsFederation) => false,
            (Faction::UN, Faction::KuiperUnion) => false,
            (Faction::MarsFederation, Faction::KuiperUnion) => false,
            
            _ => false
        }
    }

    #[inline(always)]
    fn should_auto_respond(self: ShipsMessage) -> bool {
        // Emergency messages should trigger automatic responses
        if self.message_type == MessageType::Distress {
            return true;
        }
        
        // Identification requests need responses
        if self.message_type == MessageType::Identification {
            return true;
        }
        
        // Navigation messages often need acknowledgment
        if self.message_type == MessageType::Navigation && self.priority == MessagePriority::High {
            return true;
        }
        
        false
    }
}