use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Moon {
    #[key]
    pub id: u64,                  // Unique moon ID
    pub name: felt252,            // Moon name
    pub planet_id: u64,           // Parent planet
    pub moon_type: MoonType,      // Geological/structural type
    pub size: u32,                // Relative size
    pub resources: u32,           // Base resource richness
    pub mined: u32,               // Resources already extracted
    pub owner: ContractAddress, // Who controls it
    pub population: u64,          // Colonists/inhabitants
    pub defense_level: u16,       // Fortifications
    pub structures: u16,          // Stations, mines, bases
    pub x: i32,                   // Orbital position (relative or absolute)
    pub y: i32,
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug, DojoStore, Default)]
pub enum MoonType {
    #[default]
    Rocky,       // Dead rock, like our Moon
    Icy,         // Europa-like
    Volcanic,    // Io-like
    Habitable,   // Can support colonies
    Industrial,  // Already mined/urbanized
}
