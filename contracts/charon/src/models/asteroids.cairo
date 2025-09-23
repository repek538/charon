use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Asteroid {
    #[key]
    pub id: u64,                  // Unique asteroid ID
    pub name: felt252,            // Optional name/identifier
    pub asteroid_type: AsteroidType, // What kind of asteroid
    pub size: u32,                // Relative size (affects resources & durability)
    pub resources: u32,           // Total extractable resources
    pub mined: u32,               // Already extracted
    pub has_station: bool,        // Outpost / base present?
    pub owner: ContractAddress, // Who controls it
    pub defense_level: u16,       // Defenses if fortified
    pub x: i32,                   // Position in space
    pub y: i32,
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug, DojoStore, Default)]
pub enum AsteroidType {
    #[default]
    Dust,
    IronRich,     // Heavy metals
    Carbonaceous, // Fuel & carbon compounds
    Ice,          // Water / oxygen sources
    Radioactive,  // Rare radioactive elements
    Hollow,       // Hideouts / secret bases
}
