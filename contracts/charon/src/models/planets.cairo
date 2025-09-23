use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Planet {
    #[key]
    pub id: u64,                  // Unique planet ID
    pub name: felt252,            // Planet name
    pub planet_type: PlanetType,  // Class of planet
    pub size: u32,                // Relative size (affects population/capacity)
    pub resources: u32,           // Base resource richness
    pub owner: ContractAddress,   // Who controls the planet (None = neutral)
    pub population: u64,          // Civilians or colonists
    pub defense_level: u16,       // Planetary defenses (turrets, shields)
    pub x: i32,
    pub y: i32,
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug, DojoStore, Default)]
pub enum PlanetType {
    #[default]
    Terrestrial,  // Earth-like
    GasGiant,     // Jupiter-like
    IceWorld,     // Frozen
    Volcanic,     // Harsh lava planet
    Desert,       // Arid, resource-rich
    Ocean,        // Mostly water
    Barren,       // Dead rock
}

#[generate_trait]
pub impl PlanetImpl of PlanetTrait {
    #[inline(always)]
    fn new(
        id: u64,
        name: felt252,
        planet_type: PlanetType,
        size: u32,
        x: i32,
        y: i32
    ) -> Planet {
        let base_resources = Self::calculate_base_resources(planet_type, size);
        
        Planet {
            id,
            name,
            planet_type,
            size,
            resources: base_resources,
            owner: starknet::contract_address_const::<0>(), // Neutral initially
            population: 0,
            defense_level: 0,
            x,
            y,
        }
    }

    #[inline(always)]
    fn calculate_base_resources(planet_type: PlanetType, size: u32) -> u32 {
        let type_multiplier = match planet_type {
            PlanetType::Desert => 15,      // Rich in minerals
            PlanetType::Volcanic => 12,    // Rare metals
            PlanetType::Terrestrial => 10, // Balanced
            PlanetType::Ocean => 8,        // Limited land mining
            PlanetType::IceWorld => 6,     // Frozen resources
            PlanetType::GasGiant => 4,     // Gas harvesting only
            PlanetType::Barren => 2,       // Nearly depleted
        };
        size * type_multiplier
    }

    #[inline(always)]
    fn get_max_population(self: Planet) -> u64 {
        let base_capacity = (self.size * 1000).into();
        match self.planet_type {
            PlanetType::Terrestrial => base_capacity * 3, // Most habitable
            PlanetType::Ocean => base_capacity * 2,       // Water world
            PlanetType::Desert => base_capacity,          // Harsh but livable
            PlanetType::IceWorld => base_capacity / 2,    // Cold but manageable
            PlanetType::Volcanic => base_capacity / 3,    // Extreme conditions
            PlanetType::Barren => base_capacity / 4,      // Minimal life support
            PlanetType::GasGiant => base_capacity / 10,   // Floating cities only
        }
    }

    #[inline(always)]
    fn colonize(ref self: Planet, new_owner: ContractAddress, initial_population: u64) -> bool {
        if !self.is_neutral() {
            return false; // Already owned
        }
        
        let max_pop = self.get_max_population();
        if initial_population > max_pop {
            return false; // Exceeds capacity
        }

        self.owner = new_owner;
        self.population = initial_population;
        true
    }

    #[inline(always)]
    fn is_neutral(self: Planet) -> bool {
        self.owner == starknet::contract_address_const::<0>()
    }

    #[inline(always)]
    fn is_owned_by(self: Planet, player: ContractAddress) -> bool {
        self.owner == player
    }

    #[inline(always)]
    fn grow_population(ref self: Planet, growth_rate: u8) -> u64 {
        if self.is_neutral() {
            return self.population;
        }

        let max_pop = self.get_max_population();
        let growth = (self.population * growth_rate.into()) / 100;
        let new_population = self.population + growth;
        
        if new_population > max_pop {
            self.population = max_pop;
        } else {
            self.population = new_population;
        }
        
        self.population
    }

    #[inline(always)]
    fn upgrade_defenses(ref self: Planet, amount: u16) -> bool {
        if self.is_neutral() {
            return false;
        }

        let max_defense = self.size.try_into().unwrap_or(0) * 10;
        if self.defense_level >= max_defense {
            return false; // Already at maximum
        }

        self.defense_level += amount;
        if self.defense_level > max_defense {
            self.defense_level = max_defense;
        }
        true
    }

    #[inline(always)]
    fn calculate_distance_to(self: Planet, other: Planet) -> u64 {
        let dx = if self.x > other.x { self.x - other.x } else { other.x - self.x };
        let dy = if self.y > other.y { self.y - other.y } else { other.y - self.y };
        
        // Manhattan distance for space travel
        (dx + dy).try_into().unwrap_or(0)
    }

    #[inline(always)]
    fn calculate_distance_to_coords(self: Planet, x: i32, y: i32) -> u64 {
        let dx = if self.x > x { self.x - x } else { x - self.x };
        let dy = if self.y > y { self.y - y } else { y - self.y };
        
        (dx + dy).try_into().unwrap_or(0)
    }

    #[inline(always)]
    fn get_resource_income(self: Planet) -> u32 {
        if self.is_neutral() {
            return 0;
        }

        let base_income = self.resources / 10; // 10% of base resources per turn
        let population_bonus = (self.population / 5000).try_into().unwrap_or(0);
        
        base_income + population_bonus
    }

    #[inline(always)]
    fn get_defense_strength(self: Planet) -> u32 {
        let base_defense = self.defense_level.into();
        let population_militia = (self.population / 10000).try_into().unwrap_or(0);
        
        // Terrain bonus based on planet type
        let terrain_bonus = match self.planet_type {
            PlanetType::Volcanic => base_defense / 4,    // Natural hazards help defense
            PlanetType::IceWorld => base_defense / 6,    // Cold weather advantage
            PlanetType::Desert => base_defense / 8,      // Harsh conditions
            PlanetType::GasGiant => base_defense / 2,    // Difficult to assault
            PlanetType::Terrestrial => 0,               // No terrain advantage
            PlanetType::Ocean => base_defense / 10,      // Naval defenses
            PlanetType::Barren => 0,                     // No natural defenses
        };

        base_defense + population_militia + terrain_bonus
    }

    #[inline(always)]
    fn get_habitability_rating(self: Planet) -> u8 {
        match self.planet_type {
            PlanetType::Terrestrial => 10, // Perfect
            PlanetType::Ocean => 8,        // Excellent
            PlanetType::Desert => 6,       // Good
            PlanetType::IceWorld => 4,     // Challenging
            PlanetType::Volcanic => 3,     // Difficult
            PlanetType::Barren => 2,       // Harsh
            PlanetType::GasGiant => 1,     // Extreme
        }
    }

    #[inline(always)]
    fn attack_planet(ref self: Planet, attack_power: u32) -> bool {
        let defense_strength = self.get_defense_strength();
        
        if attack_power > defense_strength {
            // Successful conquest - reduce population and defenses
            self.population = self.population * 8 / 10; // 20% casualties
            if self.defense_level > 3 {
                self.defense_level -= 3; // Defenses damaged
            }
            return true;
        }
        
        // Failed attack - minor damage to defenses
        if self.defense_level > 1 {
            self.defense_level -= 1;
        }
        false
    }

    #[inline(always)]
    fn change_ownership(ref self: Planet, new_owner: ContractAddress) {
        self.owner = new_owner;
    }

    #[inline(always)]
    fn is_in_range(self: Planet, x: i32, y: i32, range: u64) -> bool {
        let distance = self.calculate_distance_to_coords(x, y);
        distance <= range
    }

    #[inline(always)]
    fn get_strategic_value(self: Planet) -> u32 {
        let resource_value = self.resources;
        let size_value = self.size * 5;
        let population_value = (self.population / 1000).try_into().unwrap_or(0);
        let habitability_bonus = self.get_habitability_rating().into() * 10;
        
        resource_value + size_value + population_value + habitability_bonus
    }

    #[inline(always)]
    fn can_support_population(self: Planet, target_population: u64) -> bool {
        target_population <= self.get_max_population()
    }

    #[inline(always)]
    fn is_overcrowded(self: Planet) -> bool {
        let max_pop = self.get_max_population();
        self.population > (max_pop * 9 / 10) // 90% capacity = overcrowded
    }

    #[inline(always)]
    fn get_population_growth_modifier(self: Planet) -> u8 {
        let habitability = self.get_habitability_rating();
        let crowding_penalty = if self.is_overcrowded() { 50 } else { 0 };
        
        if habitability * 10 > crowding_penalty {
            (habitability * 10) - crowding_penalty
        } else {
            10 // Minimum 1% growth
        }
    }

    #[inline(always)]
    fn migrate_population_to(ref self: Planet, ref target: Planet, amount: u64) -> bool {
        if self.is_neutral() || target.is_neutral() {
            return false;
        }
        
        if self.owner != target.owner {
            return false; // Can only migrate between owned planets
        }
        
        if self.population < amount {
            return false; // Not enough population
        }
        
        if !target.can_support_population(target.population + amount) {
            return false; // Target can't support more population
        }
        
        self.population -= amount;
        target.population += amount;
        true
    }

    #[inline(always)]
    fn reinforce_defenses(ref self: Planet, amount: u16, max_upgrade: u16) -> u16 {
        if self.is_neutral() {
            return 0;
        }
        
        let current_max = self.size.try_into().unwrap_or(0) * 10;
        let absolute_max = if max_upgrade > 0 { max_upgrade } else { current_max };
        
        if self.defense_level >= absolute_max {
            return 0; // No upgrade possible
        }
        
        let actual_upgrade = if self.defense_level + amount > absolute_max {
            absolute_max - self.defense_level
        } else {
            amount
        };
        
        self.defense_level += actual_upgrade;
        actual_upgrade
    }
}