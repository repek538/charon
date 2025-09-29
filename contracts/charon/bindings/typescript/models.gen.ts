import type { SchemaType as ISchemaType } from "@dojoengine/sdk";

import { CairoCustomEnum, BigNumberish } from 'starknet';

// Type definition for `charon::models::asteroids::Asteroid` struct
export interface Asteroid {
	id: BigNumberish;
	name: BigNumberish;
	asteroid_type: AsteroidTypeEnum;
	size: BigNumberish;
	resources: BigNumberish;
	mined: BigNumberish;
	has_station: boolean;
	owner: string;
	defense_level: BigNumberish;
	x: BigNumberish;
	y: BigNumberish;
}

// Type definition for `charon::models::engagements::Engagement` struct
export interface Engagement {
	player: string;
	engagement_id: BigNumberish;
	player_ship_id: string;
	enemy_ship_id: string;
	current_phase: EngagementPhaseEnum;
	initiated_at: BigNumberish;
	phase_deadline: BigNumberish;
	player_action: PlayerActionEnum;
	enemy_action: EnemyActionEnum;
	engagement_range: BigNumberish;
	player_hull: BigNumberish;
	enemy_hull: BigNumberish;
	player_shields: BigNumberish;
	enemy_shields: BigNumberish;
	consequences_applied: boolean;
	outcome: EngagementOutcomeEnum;
}

// Type definition for `charon::models::game::Game` struct
export interface Game {
	game_id: BigNumberish;
	minimum_moves: BigNumberish;
	over: boolean;
	player_count: BigNumberish;
	unit_count: BigNumberish;
	engagements_count: BigNumberish;
	clock: BigNumberish;
	penalty: BigNumberish;
}

// Type definition for `charon::models::moons::Moon` struct
export interface Moon {
	id: BigNumberish;
	name: BigNumberish;
	planet_id: BigNumberish;
	moon_type: MoonTypeEnum;
	size: BigNumberish;
	resources: BigNumberish;
	mined: BigNumberish;
	owner: string;
	population: BigNumberish;
	defense_level: BigNumberish;
	structures: BigNumberish;
	x: BigNumberish;
	y: BigNumberish;
}

// Type definition for `charon::models::oberon::Crew` struct
export interface Crew {
	ship: string;
	captain: string;
	members: BigNumberish;
	engineers: BigNumberish;
	gunners: BigNumberish;
	medics: BigNumberish;
}

// Type definition for `charon::models::oberon::OberonPDC` struct
export interface OberonPDC {
	pdc_id: BigNumberish;
	ship: string;
	damage: BigNumberish;
	max_range: BigNumberish;
	optimal_range: BigNumberish;
	rate_of_fire: BigNumberish;
	power_cost: BigNumberish;
	tracking_speed: BigNumberish;
	ammunition: BigNumberish;
	heat_buildup: BigNumberish;
	compatible_classes: BigNumberish;
	ship_class: ShipClassEnum;
}

// Type definition for `charon::models::oberon::OberonRailgun` struct
export interface OberonRailgun {
	ship: string;
	damage: BigNumberish;
	max_range: BigNumberish;
	optimal_range: BigNumberish;
	rate_of_fire: BigNumberish;
	power_cost: BigNumberish;
	tracking_speed: BigNumberish;
	ammunition: BigNumberish;
	barrel_wear: BigNumberish;
	compatible_classes: BigNumberish;
	ship_class: ShipClassEnum;
}

// Type definition for `charon::models::oberon::OberonScanResult` struct
export interface OberonScanResult {
	ship: string;
	detection_time: BigNumberish;
	confidence: BigNumberish;
	distance: BigNumberish;
	bearing: BigNumberish;
	velocity: BigNumberish;
	ship_class_known: boolean;
	faction_known: boolean;
	armament_known: boolean;
	hull_status_known: boolean;
	shield_status_known: boolean;
	is_stealthed: boolean;
	last_updated: BigNumberish;
}

// Type definition for `charon::models::oberon::OberonScanner` struct
export interface OberonScanner {
	ship: string;
	max_range: BigNumberish;
	resolution: BigNumberish;
	scan_time: BigNumberish;
	power_cost: BigNumberish;
	passive_range: BigNumberish;
	active_range: BigNumberish;
	stealth_detection: BigNumberish;
	electronic_warfare: BigNumberish;
	target_lock_strength: BigNumberish;
	scan_signature: BigNumberish;
	compatible_classes: BigNumberish;
	ship_class: ShipClassEnum;
	scanner_health: BigNumberish;
}

// Type definition for `charon::models::oberon::OberonShield` struct
export interface OberonShield {
	ship_id: string;
	max_strength: BigNumberish;
	current_strength: BigNumberish;
	recharge_rate: BigNumberish;
	power_cost: BigNumberish;
	coverage: BigNumberish;
	frequency: BigNumberish;
	generator_health: BigNumberish;
	compatible_classes: BigNumberish;
	ship_class: ShipClassEnum;
}

// Type definition for `charon::models::oberon::OberonTorpedo` struct
export interface OberonTorpedo {
	torpedo_id: BigNumberish;
	ship: string;
	damage: BigNumberish;
	max_range: BigNumberish;
	optimal_range: BigNumberish;
	rate_of_fire: BigNumberish;
	power_cost: BigNumberish;
	tracking_speed: BigNumberish;
	ammunition: BigNumberish;
	fuel_per_torpedo: BigNumberish;
	compatible_classes: BigNumberish;
	ship_class: ShipClassEnum;
}

// Type definition for `charon::models::oberon::ShipOberon` struct
export interface ShipOberon {
	ship: string;
	owner: string;
	name: BigNumberish;
	hull: BigNumberish;
	shield: BigNumberish;
	point_defense: BigNumberish;
	torpedoes: BigNumberish;
	railgun: boolean;
	crew_capacity: BigNumberish;
	fuel: BigNumberish;
	cargo: BigNumberish;
	location: Vec2;
	state: ShipStateEnum;
}

// Type definition for `charon::models::oberon::Vec2` struct
export interface Vec2 {
	x: BigNumberish;
	y: BigNumberish;
}

// Type definition for `charon::models::oberon_crew::CrewAbility` struct
export interface CrewAbility {
	crew_id: BigNumberish;
	ability_id: BigNumberish;
	ability_type: AbilityTypeEnum;
	level: BigNumberish;
	cooldown: BigNumberish;
	is_active: boolean;
}

// Type definition for `charon::models::oberon_crew::CrewMember` struct
export interface CrewMember {
	id: BigNumberish;
	ship: string;
	owner: string;
	role: CrewRoleEnum;
	health: BigNumberish;
	morale: BigNumberish;
	stamina: BigNumberish;
	intelligence: BigNumberish;
	strength: BigNumberish;
	dexterity: BigNumberish;
	experience: BigNumberish;
	active: boolean;
}

// Type definition for `charon::models::planets::Planet` struct
export interface Planet {
	id: BigNumberish;
	name: BigNumberish;
	planet_type: PlanetTypeEnum;
	size: BigNumberish;
	resources: BigNumberish;
	owner: string;
	population: BigNumberish;
	defense_level: BigNumberish;
	x: BigNumberish;
	y: BigNumberish;
}

// Type definition for `charon::models::ships::MiniZoneShip` struct
export interface MiniZoneShip {
	mini_zone_id: BigNumberish;
	ship: string;
	is_active: boolean;
}

// Type definition for `charon::models::ships::PDC` struct
export interface PDC {
	ship_id: string;
	ship: string;
	damage: BigNumberish;
	max_range: BigNumberish;
	optimal_range: BigNumberish;
	rate_of_fire: BigNumberish;
	power_cost: BigNumberish;
	tracking_speed: BigNumberish;
	ammunition: BigNumberish;
	heat_buildup: BigNumberish;
	compatible_classes: BigNumberish;
	ship_class: ShipClassEnum;
}

// Type definition for `charon::models::ships::Railgun` struct
export interface Railgun {
	ship_id: string;
	ship: string;
	damage: BigNumberish;
	max_range: BigNumberish;
	optimal_range: BigNumberish;
	rate_of_fire: BigNumberish;
	power_cost: BigNumberish;
	tracking_speed: BigNumberish;
	ammunition: BigNumberish;
	barrel_wear: BigNumberish;
	compatible_classes: BigNumberish;
	ship_class: ShipClassEnum;
}

// Type definition for `charon::models::ships::ScanResult` struct
export interface ScanResult {
	scanning_ship_id: string;
	target_ship_id: string;
	detection_time: BigNumberish;
	confidence: BigNumberish;
	distance: BigNumberish;
	bearing: BigNumberish;
	velocity: BigNumberish;
	ship_class_known: boolean;
	faction_known: boolean;
	armament_known: boolean;
	hull_status_known: boolean;
	shield_status_known: boolean;
	is_stealthed: boolean;
	last_updated: BigNumberish;
}

// Type definition for `charon::models::ships::Scanner` struct
export interface Scanner {
	ship_id: string;
	max_range: BigNumberish;
	resolution: BigNumberish;
	scan_time: BigNumberish;
	power_cost: BigNumberish;
	passive_range: BigNumberish;
	active_range: BigNumberish;
	stealth_detection: BigNumberish;
	electronic_warfare: BigNumberish;
	target_lock_strength: BigNumberish;
	scan_signature: BigNumberish;
	compatible_classes: BigNumberish;
	ship_class: ShipClassEnum;
	scanner_health: BigNumberish;
}

// Type definition for `charon::models::ships::Shield` struct
export interface Shield {
	ship_id: string;
	max_strength: BigNumberish;
	current_strength: BigNumberish;
	recharge_rate: BigNumberish;
	power_cost: BigNumberish;
	coverage: BigNumberish;
	frequency: BigNumberish;
	generator_health: BigNumberish;
	compatible_classes: BigNumberish;
	ship_class: ShipClassEnum;
}

// Type definition for `charon::models::ships::Ship` struct
export interface Ship {
	id: string;
	owner: string;
	faction: FactionEnum;
	s_class: ShipClassEnum;
	hull_points: BigNumberish;
	shield_points: BigNumberish;
	speed: BigNumberish;
	crew_size: BigNumberish;
	cargo_capacity: BigNumberish;
	location: Vec2;
	railguns: BigNumberish;
	torpedoes: BigNumberish;
	pdcs: BigNumberish;
	torpedo_ammo: BigNumberish;
	railgun_ammo: BigNumberish;
	fuel_capacity: BigNumberish;
	current_fuel: BigNumberish;
	reactor_fuel: BigNumberish;
	power_output: BigNumberish;
}

// Type definition for `charon::models::ships::ShipArmament` struct
export interface ShipArmament {
	ship_id: string;
	ship_class: ShipClassEnum;
	railgun_count: BigNumberish;
	torpedo_count: BigNumberish;
	pdc_count: BigNumberish;
	has_shield: boolean;
	total_power_requirement: BigNumberish;
	total_ammunition_storage: BigNumberish;
	armament_mass: BigNumberish;
	crew_required: BigNumberish;
}

// Type definition for `charon::models::ships::Torpedo` struct
export interface Torpedo {
	ship_id: string;
	ship: string;
	damage: BigNumberish;
	max_range: BigNumberish;
	optimal_range: BigNumberish;
	rate_of_fire: BigNumberish;
	power_cost: BigNumberish;
	tracking_speed: BigNumberish;
	ammunition: BigNumberish;
	fuel_per_torpedo: BigNumberish;
	compatible_classes: BigNumberish;
	ship_class: ShipClassEnum;
}

// Type definition for `charon::models::ships::Vec2` struct
export interface Vec2 {
	x: BigNumberish;
	y: BigNumberish;
}

// Type definition for `charon::models::stations::MiniZoneStation` struct
export interface MiniZoneStation {
	mini_zone_id: BigNumberish;
	station: BigNumberish;
	is_active: boolean;
}

// Type definition for `charon::models::stations::Station` struct
export interface Station {
	id: BigNumberish;
	name: BigNumberish;
	station_type: StationTypeEnum;
	owner: string;
	defense_level: BigNumberish;
	capacity: BigNumberish;
	crew: BigNumberish;
	x: BigNumberish;
	y: BigNumberish;
}

// Type definition for `charon::models::zones::Zone` struct
export interface Zone {
	zone_id: BigNumberish;
	zone_type: ZoneTypeEnum;
	name: BigNumberish;
	min_x: BigNumberish;
	min_y: BigNumberish;
	max_x: BigNumberish;
	max_y: BigNumberish;
	resource_density: BigNumberish;
	danger_level: BigNumberish;
	patrol_frequency: BigNumberish;
	fuel_cost_modifier: BigNumberish;
	radiation_level: BigNumberish;
	asteroid_density: BigNumberish;
	gravity_wells: BigNumberish;
	controlling_faction: FactionEnum;
	security_level: BigNumberish;
	trade_hub_bonus: BigNumberish;
	sensor_coverage: BigNumberish;
	communication_delay: BigNumberish;
}

// Type definition for `charon::systems::oberon_crew::oberon_crew::AbilityActivated` struct
export interface AbilityActivated {
	crew_id: BigNumberish;
	ability_id: BigNumberish;
	ability_type: AbilityTypeEnum;
}

// Type definition for `charon::systems::oberon_crew::oberon_crew::AbilityAssigned` struct
export interface AbilityAssigned {
	crew_id: BigNumberish;
	ability_type: AbilityTypeEnum;
}

// Type definition for `charon::systems::oberon_crew::oberon_crew::CrewMemberCreated` struct
export interface CrewMemberCreated {
	crew_id: BigNumberish;
	ship: string;
	owner: string;
	role: CrewRoleEnum;
}

// Type definition for `charon::systems::oberon_crew::oberon_crew::CrewMemberHealed` struct
export interface CrewMemberHealed {
	crew_id: BigNumberish;
	amount: BigNumberish;
	new_health: BigNumberish;
}

// Type definition for `charon::systems::oberon_crew::oberon_crew::CrewMemberTrained` struct
export interface CrewMemberTrained {
	crew_id: BigNumberish;
	experience_gained: BigNumberish;
	new_level: BigNumberish;
}

// Type definition for `charon::models::asteroids::AsteroidType` enum
export const asteroidType = [
	'Dust',
	'IronRich',
	'Carbonaceous',
	'Ice',
	'Radioactive',
	'Hollow',
] as const;
export type AsteroidType = { [key in typeof asteroidType[number]]: string };
export type AsteroidTypeEnum = CairoCustomEnum;

// Type definition for `charon::models::engagements::EnemyAction` enum
export const enemyAction = [
	'None',
	'Demand',
	'Threaten',
	'OpenFire',
	'BoardingAction',
	'AcceptBribe',
	'Retreat',
	'Negotiate',
	'Destroy',
	'Disable',
	'Rob',
	'Hail',
	'Comply',
	'PayBribe',
	'ActivateShields',
	'Burn',
	'PrepareBoarding',
	'ActivatePDCs',
	'LaunchTorpedoes',
	'SurrenderCargo',
	'SurrenderShip',
	'RamEnemy',
] as const;
export type EnemyAction = { [key in typeof enemyAction[number]]: string };
export type EnemyActionEnum = CairoCustomEnum;

// Type definition for `charon::models::engagements::EngagementOutcome` enum
export const engagementOutcome = [
	'Ongoing',
	'PlayerEscaped',
	'PlayerDestroyed',
	'PlayerDisabled',
	'PlayerRobbed',
	'PlayerCaptured',
	'EnemyDestroyed',
	'EnemyRetreated',
	'Negotiated',
	'BribePaid',
] as const;
export type EngagementOutcome = { [key in typeof engagementOutcome[number]]: string };
export type EngagementOutcomeEnum = CairoCustomEnum;

// Type definition for `charon::models::engagements::EngagementPhase` enum
export const engagementPhase = [
	'Initial',
	'Threatened',
	'UnderFire',
	'Boarding',
	'Negotiations',
	'Retreat',
	'Resolved',
] as const;
export type EngagementPhase = { [key in typeof engagementPhase[number]]: string };
export type EngagementPhaseEnum = CairoCustomEnum;

// Type definition for `charon::models::engagements::PlayerAction` enum
export const playerAction = [
	'None',
	'Hail',
	'Comply',
	'Negotiate',
	'PayBribe',
	'Threaten',
	'OpenFire',
	'ActivateShields',
	'Burn',
	'PrepareBoarding',
	'ActivatePDCs',
	'LaunchTorpedoes',
	'SurrenderCargo',
	'SurrenderShip',
	'RamEnemy',
] as const;
export type PlayerAction = { [key in typeof playerAction[number]]: string };
export type PlayerActionEnum = CairoCustomEnum;

// Type definition for `charon::models::moons::MoonType` enum
export const moonType = [
	'Rocky',
	'Icy',
	'Volcanic',
	'Habitable',
	'Industrial',
] as const;
export type MoonType = { [key in typeof moonType[number]]: string };
export type MoonTypeEnum = CairoCustomEnum;

// Type definition for `charon::models::oberon::ShipState` enum
export const shipState = [
	'Idle',
	'Moving',
	'InCombat',
	'Contacted',
	'InCommunication',
	'Hailing',
	'AwaitingResponse',
	'Docked',
	'Refueling',
	'Loading',
	'Damaged',
	'Disabled',
] as const;
export type ShipState = { [key in typeof shipState[number]]: string };
export type ShipStateEnum = CairoCustomEnum;

// Type definition for `charon::models::oberon_crew::AbilityType` enum
export const abilityType = [
	'NavigationBoost',
	'RepairExpertise',
	'WeaponMastery',
	'MedicalAid',
	'ScienceScan',
	'Leadership',
] as const;
export type AbilityType = { [key in typeof abilityType[number]]: string };
export type AbilityTypeEnum = CairoCustomEnum;

// Type definition for `charon::models::oberon_crew::CrewRole` enum
export const crewRole = [
	'Captain',
	'Pilot',
	'Engineer',
	'Gunner',
	'Medic',
	'Scientist',
] as const;
export type CrewRole = { [key in typeof crewRole[number]]: string };
export type CrewRoleEnum = CairoCustomEnum;

// Type definition for `charon::models::planets::PlanetType` enum
export const planetType = [
	'Terrestrial',
	'GasGiant',
	'IceWorld',
	'Volcanic',
	'Desert',
	'Ocean',
	'Barren',
] as const;
export type PlanetType = { [key in typeof planetType[number]]: string };
export type PlanetTypeEnum = CairoCustomEnum;

// Type definition for `charon::models::ships::Faction` enum
export const faction = [
	'Pirates',
	'UN',
	'MarsFederation',
	'KuiperUnion',
	'Independent',
] as const;
export type Faction = { [key in typeof faction[number]]: string };
export type FactionEnum = CairoCustomEnum;

// Type definition for `charon::models::ships::ShipClass` enum
export const shipClass = [
	'Corvette',
	'Frigate',
	'Destroyer',
	'Cruiser',
	'Battleship',
	'Carrier',
	'Freighter',
	'PirateSkiff',
] as const;
export type ShipClass = { [key in typeof shipClass[number]]: string };
export type ShipClassEnum = CairoCustomEnum;

// Type definition for `charon::models::stations::StationType` enum
export const stationType = [
	'Shipyard',
	'TradeHub',
	'MiningOutpost',
	'ResearchLab',
	'MilitaryBase',
	'SmugglerDen',
	'RelayStation',
	'Habitat',
] as const;
export type StationType = { [key in typeof stationType[number]]: string };
export type StationTypeEnum = CairoCustomEnum;

// Type definition for `charon::models::zones::ZoneType` enum
export const zoneType = [
	'Cislunar',
	'InnerPlanets',
	'AsteroidBelt',
	'Jupiter',
	'Saturn',
	'OuterPlanets',
	'KuiperBelt',
	'Void',
] as const;
export type ZoneType = { [key in typeof zoneType[number]]: string };
export type ZoneTypeEnum = CairoCustomEnum;

export interface SchemaType extends ISchemaType {
	charon: {
		Asteroid: Asteroid,
		Engagement: Engagement,
		Game: Game,
		Moon: Moon,
		Crew: Crew,
		OberonPDC: OberonPDC,
		OberonRailgun: OberonRailgun,
		OberonScanResult: OberonScanResult,
		OberonScanner: OberonScanner,
		OberonShield: OberonShield,
		OberonTorpedo: OberonTorpedo,
		ShipOberon: ShipOberon,
		Vec2: Vec2,
		CrewAbility: CrewAbility,
		CrewMember: CrewMember,
		Planet: Planet,
		MiniZoneShip: MiniZoneShip,
		PDC: PDC,
		Railgun: Railgun,
		ScanResult: ScanResult,
		Scanner: Scanner,
		Shield: Shield,
		Ship: Ship,
		ShipArmament: ShipArmament,
		Torpedo: Torpedo,
		MiniZoneStation: MiniZoneStation,
		Station: Station,
		Zone: Zone,
		AbilityActivated: AbilityActivated,
		AbilityAssigned: AbilityAssigned,
		CrewMemberCreated: CrewMemberCreated,
		CrewMemberHealed: CrewMemberHealed,
		CrewMemberTrained: CrewMemberTrained,
	},
}
export const schema: SchemaType = {
	charon: {
		Asteroid: {
			id: 0,
			name: 0,
		asteroid_type: new CairoCustomEnum({ 
					Dust: "",
				IronRich: undefined,
				Carbonaceous: undefined,
				Ice: undefined,
				Radioactive: undefined,
				Hollow: undefined, }),
			size: 0,
			resources: 0,
			mined: 0,
			has_station: false,
			owner: "",
			defense_level: 0,
			x: 0,
			y: 0,
		},
		Engagement: {
			player: "",
			engagement_id: 0,
			player_ship_id: "",
			enemy_ship_id: "",
		current_phase: new CairoCustomEnum({ 
					Initial: "",
				Threatened: undefined,
				UnderFire: undefined,
				Boarding: undefined,
				Negotiations: undefined,
				Retreat: undefined,
				Resolved: undefined, }),
			initiated_at: 0,
			phase_deadline: 0,
		player_action: new CairoCustomEnum({ 
					None: "",
				Hail: undefined,
				Comply: undefined,
				Negotiate: undefined,
				PayBribe: undefined,
				Threaten: undefined,
				OpenFire: undefined,
				ActivateShields: undefined,
				Burn: undefined,
				PrepareBoarding: undefined,
				ActivatePDCs: undefined,
				LaunchTorpedoes: undefined,
				SurrenderCargo: undefined,
				SurrenderShip: undefined,
				RamEnemy: undefined, }),
		enemy_action: new CairoCustomEnum({ 
					None: "",
				Demand: undefined,
				Threaten: undefined,
				OpenFire: undefined,
				BoardingAction: undefined,
				AcceptBribe: undefined,
				Retreat: undefined,
				Negotiate: undefined,
				Destroy: undefined,
				Disable: undefined,
				Rob: undefined,
				Hail: undefined,
				Comply: undefined,
				PayBribe: undefined,
				ActivateShields: undefined,
				Burn: undefined,
				PrepareBoarding: undefined,
				ActivatePDCs: undefined,
				LaunchTorpedoes: undefined,
				SurrenderCargo: undefined,
				SurrenderShip: undefined,
				RamEnemy: undefined, }),
			engagement_range: 0,
			player_hull: 0,
			enemy_hull: 0,
			player_shields: 0,
			enemy_shields: 0,
			consequences_applied: false,
		outcome: new CairoCustomEnum({ 
					Ongoing: "",
				PlayerEscaped: undefined,
				PlayerDestroyed: undefined,
				PlayerDisabled: undefined,
				PlayerRobbed: undefined,
				PlayerCaptured: undefined,
				EnemyDestroyed: undefined,
				EnemyRetreated: undefined,
				Negotiated: undefined,
				BribePaid: undefined, }),
		},
		Game: {
			game_id: 0,
			minimum_moves: 0,
			over: false,
			player_count: 0,
			unit_count: 0,
			engagements_count: 0,
			clock: 0,
			penalty: 0,
		},
		Moon: {
			id: 0,
			name: 0,
			planet_id: 0,
		moon_type: new CairoCustomEnum({ 
					Rocky: "",
				Icy: undefined,
				Volcanic: undefined,
				Habitable: undefined,
				Industrial: undefined, }),
			size: 0,
			resources: 0,
			mined: 0,
			owner: "",
			population: 0,
			defense_level: 0,
			structures: 0,
			x: 0,
			y: 0,
		},
		Crew: {
			ship: "",
			captain: "",
			members: 0,
			engineers: 0,
			gunners: 0,
			medics: 0,
		},
		OberonPDC: {
			pdc_id: 0,
			ship: "",
			damage: 0,
			max_range: 0,
			optimal_range: 0,
			rate_of_fire: 0,
			power_cost: 0,
			tracking_speed: 0,
			ammunition: 0,
			heat_buildup: 0,
			compatible_classes: 0,
		ship_class: new CairoCustomEnum({ 
					Corvette: "",
				Frigate: undefined,
				Destroyer: undefined,
				Cruiser: undefined,
				Battleship: undefined,
				Carrier: undefined,
				Freighter: undefined,
				PirateSkiff: undefined, }),
		},
		OberonRailgun: {
			ship: "",
			damage: 0,
			max_range: 0,
			optimal_range: 0,
			rate_of_fire: 0,
			power_cost: 0,
			tracking_speed: 0,
			ammunition: 0,
			barrel_wear: 0,
			compatible_classes: 0,
		ship_class: new CairoCustomEnum({ 
					Corvette: "",
				Frigate: undefined,
				Destroyer: undefined,
				Cruiser: undefined,
				Battleship: undefined,
				Carrier: undefined,
				Freighter: undefined,
				PirateSkiff: undefined, }),
		},
		OberonScanResult: {
			ship: "",
			detection_time: 0,
			confidence: 0,
			distance: 0,
			bearing: 0,
			velocity: 0,
			ship_class_known: false,
			faction_known: false,
			armament_known: false,
			hull_status_known: false,
			shield_status_known: false,
			is_stealthed: false,
			last_updated: 0,
		},
		OberonScanner: {
			ship: "",
			max_range: 0,
			resolution: 0,
			scan_time: 0,
			power_cost: 0,
			passive_range: 0,
			active_range: 0,
			stealth_detection: 0,
			electronic_warfare: 0,
			target_lock_strength: 0,
			scan_signature: 0,
			compatible_classes: 0,
		ship_class: new CairoCustomEnum({ 
					Corvette: "",
				Frigate: undefined,
				Destroyer: undefined,
				Cruiser: undefined,
				Battleship: undefined,
				Carrier: undefined,
				Freighter: undefined,
				PirateSkiff: undefined, }),
			scanner_health: 0,
		},
		OberonShield: {
			ship_id: "",
			max_strength: 0,
			current_strength: 0,
			recharge_rate: 0,
			power_cost: 0,
			coverage: 0,
			frequency: 0,
			generator_health: 0,
			compatible_classes: 0,
		ship_class: new CairoCustomEnum({ 
					Corvette: "",
				Frigate: undefined,
				Destroyer: undefined,
				Cruiser: undefined,
				Battleship: undefined,
				Carrier: undefined,
				Freighter: undefined,
				PirateSkiff: undefined, }),
		},
		OberonTorpedo: {
			torpedo_id: 0,
			ship: "",
			damage: 0,
			max_range: 0,
			optimal_range: 0,
			rate_of_fire: 0,
			power_cost: 0,
			tracking_speed: 0,
			ammunition: 0,
			fuel_per_torpedo: 0,
			compatible_classes: 0,
		ship_class: new CairoCustomEnum({ 
					Corvette: "",
				Frigate: undefined,
				Destroyer: undefined,
				Cruiser: undefined,
				Battleship: undefined,
				Carrier: undefined,
				Freighter: undefined,
				PirateSkiff: undefined, }),
		},
		ShipOberon: {
			ship: "",
			owner: "",
			name: 0,
			hull: 0,
			shield: 0,
			point_defense: 0,
			torpedoes: 0,
			railgun: false,
			crew_capacity: 0,
			fuel: 0,
			cargo: 0,
		location: { x: 0, y: 0, },
		state: new CairoCustomEnum({ 
					Idle: "",
				Moving: undefined,
				InCombat: undefined,
				Contacted: undefined,
				InCommunication: undefined,
				Hailing: undefined,
				AwaitingResponse: undefined,
				Docked: undefined,
				Refueling: undefined,
				Loading: undefined,
				Damaged: undefined,
				Disabled: undefined, }),
		},
		Vec2: {
			x: 0,
			y: 0,
		},
		CrewAbility: {
			crew_id: 0,
			ability_id: 0,
		ability_type: new CairoCustomEnum({ 
					NavigationBoost: "",
				RepairExpertise: undefined,
				WeaponMastery: undefined,
				MedicalAid: undefined,
				ScienceScan: undefined,
				Leadership: undefined, }),
			level: 0,
			cooldown: 0,
			is_active: false,
		},
		CrewMember: {
			id: 0,
			ship: "",
			owner: "",
		role: new CairoCustomEnum({ 
					Captain: "",
				Pilot: undefined,
				Engineer: undefined,
				Gunner: undefined,
				Medic: undefined,
				Scientist: undefined, }),
			health: 0,
			morale: 0,
			stamina: 0,
			intelligence: 0,
			strength: 0,
			dexterity: 0,
			experience: 0,
			active: false,
		},
		Planet: {
			id: 0,
			name: 0,
		planet_type: new CairoCustomEnum({ 
					Terrestrial: "",
				GasGiant: undefined,
				IceWorld: undefined,
				Volcanic: undefined,
				Desert: undefined,
				Ocean: undefined,
				Barren: undefined, }),
			size: 0,
			resources: 0,
			owner: "",
			population: 0,
			defense_level: 0,
			x: 0,
			y: 0,
		},
		MiniZoneShip: {
			mini_zone_id: 0,
			ship: "",
			is_active: false,
		},
		PDC: {
			ship_id: "",
			ship: "",
			damage: 0,
			max_range: 0,
			optimal_range: 0,
			rate_of_fire: 0,
			power_cost: 0,
			tracking_speed: 0,
			ammunition: 0,
			heat_buildup: 0,
			compatible_classes: 0,
		ship_class: new CairoCustomEnum({ 
					Corvette: "",
				Frigate: undefined,
				Destroyer: undefined,
				Cruiser: undefined,
				Battleship: undefined,
				Carrier: undefined,
				Freighter: undefined,
				PirateSkiff: undefined, }),
		},
		Railgun: {
			ship_id: "",
			ship: "",
			damage: 0,
			max_range: 0,
			optimal_range: 0,
			rate_of_fire: 0,
			power_cost: 0,
			tracking_speed: 0,
			ammunition: 0,
			barrel_wear: 0,
			compatible_classes: 0,
		ship_class: new CairoCustomEnum({ 
					Corvette: "",
				Frigate: undefined,
				Destroyer: undefined,
				Cruiser: undefined,
				Battleship: undefined,
				Carrier: undefined,
				Freighter: undefined,
				PirateSkiff: undefined, }),
		},
		ScanResult: {
			scanning_ship_id: "",
			target_ship_id: "",
			detection_time: 0,
			confidence: 0,
			distance: 0,
			bearing: 0,
			velocity: 0,
			ship_class_known: false,
			faction_known: false,
			armament_known: false,
			hull_status_known: false,
			shield_status_known: false,
			is_stealthed: false,
			last_updated: 0,
		},
		Scanner: {
			ship_id: "",
			max_range: 0,
			resolution: 0,
			scan_time: 0,
			power_cost: 0,
			passive_range: 0,
			active_range: 0,
			stealth_detection: 0,
			electronic_warfare: 0,
			target_lock_strength: 0,
			scan_signature: 0,
			compatible_classes: 0,
		ship_class: new CairoCustomEnum({ 
					Corvette: "",
				Frigate: undefined,
				Destroyer: undefined,
				Cruiser: undefined,
				Battleship: undefined,
				Carrier: undefined,
				Freighter: undefined,
				PirateSkiff: undefined, }),
			scanner_health: 0,
		},
		Shield: {
			ship_id: "",
			max_strength: 0,
			current_strength: 0,
			recharge_rate: 0,
			power_cost: 0,
			coverage: 0,
			frequency: 0,
			generator_health: 0,
			compatible_classes: 0,
		ship_class: new CairoCustomEnum({ 
					Corvette: "",
				Frigate: undefined,
				Destroyer: undefined,
				Cruiser: undefined,
				Battleship: undefined,
				Carrier: undefined,
				Freighter: undefined,
				PirateSkiff: undefined, }),
		},
		Ship: {
			id: "",
			owner: "",
		faction: new CairoCustomEnum({ 
					Pirates: "",
				UN: undefined,
				MarsFederation: undefined,
				KuiperUnion: undefined,
				Independent: undefined, }),
		s_class: new CairoCustomEnum({ 
					Corvette: "",
				Frigate: undefined,
				Destroyer: undefined,
				Cruiser: undefined,
				Battleship: undefined,
				Carrier: undefined,
				Freighter: undefined,
				PirateSkiff: undefined, }),
			hull_points: 0,
			shield_points: 0,
			speed: 0,
			crew_size: 0,
			cargo_capacity: 0,
		location: { x: 0, y: 0, },
			railguns: 0,
			torpedoes: 0,
			pdcs: 0,
			torpedo_ammo: 0,
			railgun_ammo: 0,
			fuel_capacity: 0,
			current_fuel: 0,
			reactor_fuel: 0,
			power_output: 0,
		},
		ShipArmament: {
			ship_id: "",
		ship_class: new CairoCustomEnum({ 
					Corvette: "",
				Frigate: undefined,
				Destroyer: undefined,
				Cruiser: undefined,
				Battleship: undefined,
				Carrier: undefined,
				Freighter: undefined,
				PirateSkiff: undefined, }),
			railgun_count: 0,
			torpedo_count: 0,
			pdc_count: 0,
			has_shield: false,
			total_power_requirement: 0,
			total_ammunition_storage: 0,
			armament_mass: 0,
			crew_required: 0,
		},
		Torpedo: {
			ship_id: "",
			ship: "",
			damage: 0,
			max_range: 0,
			optimal_range: 0,
			rate_of_fire: 0,
			power_cost: 0,
			tracking_speed: 0,
			ammunition: 0,
			fuel_per_torpedo: 0,
			compatible_classes: 0,
		ship_class: new CairoCustomEnum({ 
					Corvette: "",
				Frigate: undefined,
				Destroyer: undefined,
				Cruiser: undefined,
				Battleship: undefined,
				Carrier: undefined,
				Freighter: undefined,
				PirateSkiff: undefined, }),
		},
		MiniZoneStation: {
			mini_zone_id: 0,
			station: 0,
			is_active: false,
		},
		Station: {
			id: 0,
			name: 0,
		station_type: new CairoCustomEnum({ 
					Shipyard: "",
				TradeHub: undefined,
				MiningOutpost: undefined,
				ResearchLab: undefined,
				MilitaryBase: undefined,
				SmugglerDen: undefined,
				RelayStation: undefined,
				Habitat: undefined, }),
			owner: "",
			defense_level: 0,
			capacity: 0,
			crew: 0,
			x: 0,
			y: 0,
		},
		Zone: {
			zone_id: 0,
		zone_type: new CairoCustomEnum({ 
					Cislunar: "",
				InnerPlanets: undefined,
				AsteroidBelt: undefined,
				Jupiter: undefined,
				Saturn: undefined,
				OuterPlanets: undefined,
				KuiperBelt: undefined,
				Void: undefined, }),
			name: 0,
			min_x: 0,
			min_y: 0,
			max_x: 0,
			max_y: 0,
			resource_density: 0,
			danger_level: 0,
			patrol_frequency: 0,
			fuel_cost_modifier: 0,
			radiation_level: 0,
			asteroid_density: 0,
			gravity_wells: 0,
		controlling_faction: new CairoCustomEnum({ 
					Pirates: "",
				UN: undefined,
				MarsFederation: undefined,
				KuiperUnion: undefined,
				Independent: undefined, }),
			security_level: 0,
			trade_hub_bonus: 0,
			sensor_coverage: 0,
			communication_delay: 0,
		},
		AbilityActivated: {
			crew_id: 0,
			ability_id: 0,
		ability_type: new CairoCustomEnum({ 
					NavigationBoost: "",
				RepairExpertise: undefined,
				WeaponMastery: undefined,
				MedicalAid: undefined,
				ScienceScan: undefined,
				Leadership: undefined, }),
		},
		AbilityAssigned: {
			crew_id: 0,
		ability_type: new CairoCustomEnum({ 
					NavigationBoost: "",
				RepairExpertise: undefined,
				WeaponMastery: undefined,
				MedicalAid: undefined,
				ScienceScan: undefined,
				Leadership: undefined, }),
		},
		CrewMemberCreated: {
			crew_id: 0,
			ship: "",
			owner: "",
		role: new CairoCustomEnum({ 
					Captain: "",
				Pilot: undefined,
				Engineer: undefined,
				Gunner: undefined,
				Medic: undefined,
				Scientist: undefined, }),
		},
		CrewMemberHealed: {
			crew_id: 0,
			amount: 0,
			new_health: 0,
		},
		CrewMemberTrained: {
			crew_id: 0,
			experience_gained: 0,
			new_level: 0,
		},
	},
};
export enum ModelsMapping {
	Asteroid = 'charon-Asteroid',
	AsteroidType = 'charon-AsteroidType',
	EnemyAction = 'charon-EnemyAction',
	Engagement = 'charon-Engagement',
	EngagementOutcome = 'charon-EngagementOutcome',
	EngagementPhase = 'charon-EngagementPhase',
	PlayerAction = 'charon-PlayerAction',
	Game = 'charon-Game',
	Moon = 'charon-Moon',
	MoonType = 'charon-MoonType',
	Crew = 'charon-Crew',
	OberonPDC = 'charon-OberonPDC',
	OberonRailgun = 'charon-OberonRailgun',
	OberonScanResult = 'charon-OberonScanResult',
	OberonScanner = 'charon-OberonScanner',
	OberonShield = 'charon-OberonShield',
	OberonTorpedo = 'charon-OberonTorpedo',
	ShipOberon = 'charon-ShipOberon',
	ShipState = 'charon-ShipState',
	Vec2 = 'charon-Vec2',
	AbilityType = 'charon-AbilityType',
	CrewAbility = 'charon-CrewAbility',
	CrewMember = 'charon-CrewMember',
	CrewRole = 'charon-CrewRole',
	Planet = 'charon-Planet',
	PlanetType = 'charon-PlanetType',
	Faction = 'charon-Faction',
	MiniZoneShip = 'charon-MiniZoneShip',
	PDC = 'charon-PDC',
	Railgun = 'charon-Railgun',
	ScanResult = 'charon-ScanResult',
	Scanner = 'charon-Scanner',
	Shield = 'charon-Shield',
	Ship = 'charon-Ship',
	ShipArmament = 'charon-ShipArmament',
	ShipClass = 'charon-ShipClass',
	Torpedo = 'charon-Torpedo',
	MiniZoneStation = 'charon-MiniZoneStation',
	Station = 'charon-Station',
	StationType = 'charon-StationType',
	Zone = 'charon-Zone',
	ZoneType = 'charon-ZoneType',
	AbilityActivated = 'charon-AbilityActivated',
	AbilityAssigned = 'charon-AbilityAssigned',
	CrewMemberCreated = 'charon-CrewMemberCreated',
	CrewMemberHealed = 'charon-CrewMemberHealed',
	CrewMemberTrained = 'charon-CrewMemberTrained',
}