use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct CrewMember {
    #[key]
    pub id: u64,           
    pub ship: ContractAddress,  
    pub role: CrewRole,         
    pub health: u8,             
    pub morale: u8,            
    pub stamina: u8,            
    pub intelligence: u8,      
    pub strength: u8,           
    pub dexterity: u8,          
    pub experience: u16,        
    pub active: bool,           
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug, DojoStore, Default)]
pub enum CrewRole {
    #[default]
    Captain,
    Pilot,
    Engineer,
    Gunner,
    Medic,
    Scientist,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct CrewAbility {
    #[key]
    pub crew_id: u64,    
    #[key]
    pub ability_id: u8,  
    pub ability_type: AbilityType,
    pub level: u8,      
    pub cooldown: u16,   
    pub is_active: bool, 
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug, DojoStore, Default)]
pub enum AbilityType {
    #[default]
    NavigationBoost,   
    RepairExpertise,  
    WeaponMastery,     
    MedicalAid,       
    ScienceScan,       
    Leadership,        
}


// Implementation traits
#[generate_trait]
pub impl CrewMemberImpl of CrewMemberTrait {
    fn new(
        id: u64,
        ship: ContractAddress,
        role: CrewRole,
        health: u8,
        morale: u8,
        stamina: u8,
        intelligence: u8,
        strength: u8,
        dexterity: u8,
    ) -> CrewMember {
        CrewMember {
            id,
            ship,
            role,
            health,
            morale,
            stamina,
            intelligence,
            strength,
            dexterity,
            experience: 0,
            active: true,
        }
    }

    // Optional helper for suggested role stats
    fn get_role_base_stats(role: CrewRole) -> (u8, u8, u8, u8, u8, u8) {
        match role {
            CrewRole::Captain => (90, 95, 85, 90, 75, 80),
            CrewRole::Pilot => (80, 85, 90, 85, 70, 95),
            CrewRole::Engineer => (85, 80, 85, 95, 85, 85),
            CrewRole::Gunner => (90, 85, 80, 70, 90, 90),
            CrewRole::Medic => (75, 90, 75, 95, 65, 85),
            CrewRole::Scientist => (70, 75, 70, 100, 60, 75),
        }
    }

    fn is_alive(self: @CrewMember) -> bool {
        *self.health > 0 && *self.active
    }

    fn is_effective(self: @CrewMember) -> bool {
        self.is_alive() && *self.morale > 30 && *self.stamina > 20
    }

    fn take_damage(ref self: CrewMember, damage: u8) {
        if self.health > damage {
            self.health -= damage;
        } else {
            self.health = 0;
            self.active = false;
        }
        
        // Taking damage affects morale
        if self.morale > 5 {
            self.morale -= 5;
        } else {
            self.morale = 0;
        }
    }

    fn heal(ref self: CrewMember, amount: u8) {
        let max_health = Self::get_max_health_for_role(self.role);
        if self.health + amount <= max_health {
            self.health += amount;
        } else {
            self.health = max_health;
        }
    }

    fn get_max_health_for_role(role: CrewRole) -> u8 {
        match role {
            CrewRole::Captain => 100,
            CrewRole::Pilot => 90,
            CrewRole::Engineer => 95,
            CrewRole::Gunner => 100,
            CrewRole::Medic => 85,
            CrewRole::Scientist => 80,
        }
    }

    fn drain_stamina(ref self: CrewMember, amount: u8) {
        if self.stamina > amount {
            self.stamina -= amount;
        } else {
            self.stamina = 0;
        }
    }

    fn restore_stamina(ref self: CrewMember, amount: u8) {
        if self.stamina + amount <= 100 {
            self.stamina += amount;
        } else {
            self.stamina = 100;
        }
    }

    fn gain_experience(ref self: CrewMember, exp: u16) {
        if self.experience + exp <= 65535 { // u16 max
            self.experience += exp;
        } else {
            self.experience = 65535;
        }
    }

    fn get_level(self: @CrewMember) -> u8 {
        // Simple leveling: every 100 exp = 1 level
        if *self.experience >= 100 {
            (*self.experience / 100).try_into().unwrap()
        } else {
            1
        }
    }

    fn get_effectiveness_multiplier(self: @CrewMember) -> u8 {
        if !self.is_effective() {
            return 50; // 50% effectiveness when not in good condition
        }
        
        let morale_bonus = if *self.morale >= 80 { 20 } else if *self.morale >= 60 { 10 } else { 0 };
        let stamina_bonus = if *self.stamina >= 80 { 10 } else if *self.stamina >= 60 { 5 } else { 0 };
        let level_bonus = self.get_level() * 2;
        
        100 + morale_bonus + stamina_bonus + level_bonus
    }
}

#[generate_trait]
pub impl CrewAbilityImpl of CrewAbilityTrait {
    fn new(
        crew_id: u64,
        ability_id: u8,
        ability_type: AbilityType,
    ) -> CrewAbility {
        CrewAbility {
            crew_id,
            ability_id,
            ability_type,
            level: 1,
            cooldown: 0,
            is_active: false,
        }
    }

    fn can_activate(self: @CrewAbility) -> bool {
        *self.cooldown == 0 && !*self.is_active
    }

    fn activate(ref self: CrewAbility) {
        assert(self.can_activate(), 'Ability on cooldown or active');
        self.is_active = true;
        self.cooldown = Self::get_base_cooldown(self.ability_type);
    }

    fn deactivate(ref self: CrewAbility) {
        self.is_active = false;
    }

    fn tick_cooldown(ref self: CrewAbility) {
        if self.cooldown > 0 {
            self.cooldown -= 1;
        }
    }

    fn get_base_cooldown(ability_type: AbilityType) -> u16 {
        match ability_type {
            AbilityType::NavigationBoost => 300,   // 5 minutes
            AbilityType::RepairExpertise => 600,   // 10 minutes
            AbilityType::WeaponMastery => 180,     // 3 minutes
            AbilityType::MedicalAid => 120,        // 2 minutes
            AbilityType::ScienceScan => 240,       // 4 minutes
            AbilityType::Leadership => 900,        // 15 minutes
        }
    }

    fn get_effect_strength(self: @CrewAbility) -> u8 {
        // Base effect + level bonus
        let base_effect = match *self.ability_type {
            AbilityType::NavigationBoost => 20,
            AbilityType::RepairExpertise => 25,
            AbilityType::WeaponMastery => 30,
            AbilityType::MedicalAid => 15,
            AbilityType::ScienceScan => 35,
            AbilityType::Leadership => 40,
        };
        
        base_effect + (*self.level - 1) * 5
    }

    fn upgrade(ref self: CrewAbility) {
        assert(self.level < 10, 'Max level reached');
        self.level += 1;
    }
}

#[generate_trait]
pub impl CrewRoleImpl of CrewRoleTrait {
    fn get_primary_stat(self: CrewRole) -> u8 {
        match self {
            CrewRole::Captain => 4,      // Leadership (composite)
            CrewRole::Pilot => 5,        // Dexterity
            CrewRole::Engineer => 3,     // Intelligence
            CrewRole::Gunner => 4,       // Strength
            CrewRole::Medic => 3,        // Intelligence
            CrewRole::Scientist => 3,    // Intelligence
        }
    }

    fn can_use_ability(self: CrewRole, ability_type: AbilityType) -> bool {
        match self {
            CrewRole::Captain => {
                match ability_type {
                    AbilityType::Leadership => true,
                    _ => false,
                }
            },
            CrewRole::Pilot => {
                match ability_type {
                    AbilityType::NavigationBoost => true,
                    _ => false,
                }
            },
            CrewRole::Engineer => {
                match ability_type {
                    AbilityType::RepairExpertise => true,
                    _ => false,
                }
            },
            CrewRole::Gunner => {
                match ability_type {
                    AbilityType::WeaponMastery => true,
                    _ => false,
                }
            },
            CrewRole::Medic => {
                match ability_type {
                    AbilityType::MedicalAid => true,
                    _ => false,
                }
            },
            CrewRole::Scientist => {
                match ability_type {
                    AbilityType::ScienceScan => true,
                    _ => false,
                }
            },
        }
    }
}