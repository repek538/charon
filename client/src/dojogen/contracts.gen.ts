import { DojoProvider, type DojoCall } from "@dojoengine/core";
import { Account, AccountInterface, type BigNumberish, CairoOption, CairoCustomEnum } from "starknet";
import * as models from "./models.gen";

export function client(provider: DojoProvider) {

	const build_actions_activeScan_calldata = (targetShip: string): DojoCall => {
		return {
			contractName: "actions",
			entrypoint: "active_scan",
			calldata: [targetShip],
		};
	};

	const actions_activeScan = async (snAccount: any, targetShip: string) => {
		try {
			return await provider.execute(
				snAccount,
				build_actions_activeScan_calldata(targetShip),
				"charon",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_actions_moveShip_calldata = (gameId: BigNumberish, locationX: BigNumberish, locationY: BigNumberish): DojoCall => {
		return {
			contractName: "actions",
			entrypoint: "move_ship",
			calldata: [gameId, locationX, locationY],
		};
	};

	const actions_moveShip = async (snAccount: any, gameId: BigNumberish, locationX: BigNumberish, locationY: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_actions_moveShip_calldata(gameId, locationX, locationY),
				"charon",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_actions_passiveScan_calldata = (): DojoCall => {
		return {
			contractName: "actions",
			entrypoint: "passive_scan",
			calldata: [],
		};
	};

	const actions_passiveScan = async (snAccount: any) => {
		try {
			return await provider.execute(
				snAccount,
				build_actions_passiveScan_calldata(),
				"charon",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_crew_createCrew_calldata = (members: BigNumberish, engineers: BigNumberish, gunners: BigNumberish, medics: BigNumberish): DojoCall => {
		return {
			contractName: "crew",
			entrypoint: "create_crew",
			calldata: [members, engineers, gunners, medics],
		};
	};

	const crew_createCrew = async (snAccount: any, members: BigNumberish, engineers: BigNumberish, gunners: BigNumberish, medics: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_crew_createCrew_calldata(members, engineers, gunners, medics),
				"charon",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_game_createGame_calldata = (gameId: BigNumberish): DojoCall => {
		return {
			contractName: "game",
			entrypoint: "create_game",
			calldata: [gameId],
		};
	};

	const game_createGame = async (snAccount: any, gameId: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_game_createGame_calldata(gameId),
				"charon",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_oberon_crew_activateAbility_calldata = (crewId: BigNumberish, abilityId: BigNumberish): DojoCall => {
		return {
			contractName: "oberon_crew",
			entrypoint: "activate_ability",
			calldata: [crewId, abilityId],
		};
	};

	const oberon_crew_activateAbility = async (snAccount: any, crewId: BigNumberish, abilityId: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_oberon_crew_activateAbility_calldata(crewId, abilityId),
				"charon",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_oberon_crew_assignAbility_calldata = (crewId: BigNumberish, abilityType: CairoCustomEnum): DojoCall => {
		return {
			contractName: "oberon_crew",
			entrypoint: "assign_ability",
			calldata: [crewId, abilityType],
		};
	};

	const oberon_crew_assignAbility = async (snAccount: any, crewId: BigNumberish, abilityType: CairoCustomEnum) => {
		try {
			return await provider.execute(
				snAccount,
				build_oberon_crew_assignAbility_calldata(crewId, abilityType),
				"charon",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_oberon_crew_createCrewMember_calldata = (ship: string, role: CairoCustomEnum, health: BigNumberish, morale: BigNumberish, stamina: BigNumberish, intelligence: BigNumberish, strength: BigNumberish, dexterity: BigNumberish): DojoCall => {
		return {
			contractName: "oberon_crew",
			entrypoint: "create_crew_member",
			calldata: [ship, role, health, morale, stamina, intelligence, strength, dexterity],
		};
	};

	const oberon_crew_createCrewMember = async (snAccount: any, ship: string, role: CairoCustomEnum, health: BigNumberish, morale: BigNumberish, stamina: BigNumberish, intelligence: BigNumberish, strength: BigNumberish, dexterity: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_oberon_crew_createCrewMember_calldata(ship, role, health, morale, stamina, intelligence, strength, dexterity),
				"charon",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_oberon_crew_getCrewEffectiveness_calldata = (ship: string, role: CairoCustomEnum): DojoCall => {
		return {
			contractName: "oberon_crew",
			entrypoint: "get_crew_effectiveness",
			calldata: [ship, role],
		};
	};

	const oberon_crew_getCrewEffectiveness = async (ship: string, role: CairoCustomEnum) => {
		try {
			return await provider.call("charon", build_oberon_crew_getCrewEffectiveness_calldata(ship, role));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_oberon_crew_healCrewMember_calldata = (crewId: BigNumberish, amount: BigNumberish): DojoCall => {
		return {
			contractName: "oberon_crew",
			entrypoint: "heal_crew_member",
			calldata: [crewId, amount],
		};
	};

	const oberon_crew_healCrewMember = async (snAccount: any, crewId: BigNumberish, amount: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_oberon_crew_healCrewMember_calldata(crewId, amount),
				"charon",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_oberon_crew_processCrewTurn_calldata = (ship: string): DojoCall => {
		return {
			contractName: "oberon_crew",
			entrypoint: "process_crew_turn",
			calldata: [ship],
		};
	};

	const oberon_crew_processCrewTurn = async (snAccount: any, ship: string) => {
		try {
			return await provider.execute(
				snAccount,
				build_oberon_crew_processCrewTurn_calldata(ship),
				"charon",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_oberon_crew_trainCrewMember_calldata = (crewId: BigNumberish, experience: BigNumberish): DojoCall => {
		return {
			contractName: "oberon_crew",
			entrypoint: "train_crew_member",
			calldata: [crewId, experience],
		};
	};

	const oberon_crew_trainCrewMember = async (snAccount: any, crewId: BigNumberish, experience: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_oberon_crew_trainCrewMember_calldata(crewId, experience),
				"charon",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_ship_createShip_calldata = (id: string, faction: CairoCustomEnum, s_class: CairoCustomEnum, hullPoints: BigNumberish, shieldPoints: BigNumberish, speed: BigNumberish, crewSize: BigNumberish, cargoCapacity: BigNumberish, locationX: BigNumberish, locationY: BigNumberish, railguns: BigNumberish, torpedoes: BigNumberish, pdcs: BigNumberish, torpedoAmmo: BigNumberish, railgunAmmo: BigNumberish, fuelCapacity: BigNumberish, currentFuel: BigNumberish, reactorFuel: BigNumberish, powerOutput: BigNumberish): DojoCall => {
		return {
			contractName: "ship",
			entrypoint: "create_ship",
			calldata: [id, faction, s_class, hullPoints, shieldPoints, speed, crewSize, cargoCapacity, locationX, locationY, railguns, torpedoes, pdcs, torpedoAmmo, railgunAmmo, fuelCapacity, currentFuel, reactorFuel, powerOutput],
		};
	};

	const ship_createShip = async (snAccount: any, id: string, faction: CairoCustomEnum, s_class: CairoCustomEnum, hullPoints: BigNumberish, shieldPoints: BigNumberish, speed: BigNumberish, crewSize: BigNumberish, cargoCapacity: BigNumberish, locationX: BigNumberish, locationY: BigNumberish, railguns: BigNumberish, torpedoes: BigNumberish, pdcs: BigNumberish, torpedoAmmo: BigNumberish, railgunAmmo: BigNumberish, fuelCapacity: BigNumberish, currentFuel: BigNumberish, reactorFuel: BigNumberish, powerOutput: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_ship_createShip_calldata(id, faction, s_class, hullPoints, shieldPoints, speed, crewSize, cargoCapacity, locationX, locationY, railguns, torpedoes, pdcs, torpedoAmmo, railgunAmmo, fuelCapacity, currentFuel, reactorFuel, powerOutput),
				"charon",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_shipoberon_createShip_calldata = (name: BigNumberish, hull: BigNumberish, shield: BigNumberish, pointDefense: BigNumberish, torpedoes: BigNumberish, railgun: boolean, crewCapacity: BigNumberish, fuel: BigNumberish, cargo: BigNumberish, locationX: BigNumberish, locationY: BigNumberish): DojoCall => {
		return {
			contractName: "shipoberon",
			entrypoint: "create_ship",
			calldata: [name, hull, shield, pointDefense, torpedoes, railgun, crewCapacity, fuel, cargo, locationX, locationY],
		};
	};

	const shipoberon_createShip = async (snAccount: any, name: BigNumberish, hull: BigNumberish, shield: BigNumberish, pointDefense: BigNumberish, torpedoes: BigNumberish, railgun: boolean, crewCapacity: BigNumberish, fuel: BigNumberish, cargo: BigNumberish, locationX: BigNumberish, locationY: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_shipoberon_createShip_calldata(name, hull, shield, pointDefense, torpedoes, railgun, crewCapacity, fuel, cargo, locationX, locationY),
				"charon",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};



	return {
		actions: {
			activeScan: actions_activeScan,
			buildActiveScanCalldata: build_actions_activeScan_calldata,
			moveShip: actions_moveShip,
			buildMoveShipCalldata: build_actions_moveShip_calldata,
			passiveScan: actions_passiveScan,
			buildPassiveScanCalldata: build_actions_passiveScan_calldata,
		},
		crew: {
			createCrew: crew_createCrew,
			buildCreateCrewCalldata: build_crew_createCrew_calldata,
		},
		game: {
			createGame: game_createGame,
			buildCreateGameCalldata: build_game_createGame_calldata,
		},
		oberon_crew: {
			activateAbility: oberon_crew_activateAbility,
			buildActivateAbilityCalldata: build_oberon_crew_activateAbility_calldata,
			assignAbility: oberon_crew_assignAbility,
			buildAssignAbilityCalldata: build_oberon_crew_assignAbility_calldata,
			createCrewMember: oberon_crew_createCrewMember,
			buildCreateCrewMemberCalldata: build_oberon_crew_createCrewMember_calldata,
			getCrewEffectiveness: oberon_crew_getCrewEffectiveness,
			buildGetCrewEffectivenessCalldata: build_oberon_crew_getCrewEffectiveness_calldata,
			healCrewMember: oberon_crew_healCrewMember,
			buildHealCrewMemberCalldata: build_oberon_crew_healCrewMember_calldata,
			processCrewTurn: oberon_crew_processCrewTurn,
			buildProcessCrewTurnCalldata: build_oberon_crew_processCrewTurn_calldata,
			trainCrewMember: oberon_crew_trainCrewMember,
			buildTrainCrewMemberCalldata: build_oberon_crew_trainCrewMember_calldata,
		},
		ship: {
			createShip: ship_createShip,
			buildCreateShipCalldata: build_ship_createShip_calldata,
		},
		shipoberon: {
			createShip: shipoberon_createShip,
			buildCreateShipCalldata: build_shipoberon_createShip_calldata,
		},
	};
}