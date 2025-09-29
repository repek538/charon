
import { MANIFEST_DEV, MANIFEST_MAINNET, MANIFEST_SEPOLIA } from '../../dojoConfig';
import type { Network } from '../utils/charon';


// Sepolia network constants
export const SEPOLIA = {
    TORII_RPC_URL: "https://api.cartridge.gg/x/starknet/sepolia",
    TORII_URL: "https://api.cartridge.gg/x/touchline-1/torii",
    ACTIONS_ADDRESS: "0x384af900ce628b8a934838bde8278f5fb589ac8f4dc961a3f0a2c318dfe3b5d",
    CREW_ADDRESS: "0x3fe48c481e26c3e81e66f4d03eaaca0c6fe00e243e3689ffa58b0537e74e926",
    GAMES_ADDRESS: "0x6415d4cb3e43ef6ffe42bdec7d095d090eee7b06b8d4c7b827652d89922dd70",
    OBERON_CREW_ADDRESS: "0x5859dba499bb714d71bf80041c8f7ef2208110ca685381e520f0822d43adc13",
    OBERON_ADDRESS: "0x4788057c2fe04f214390511a52f5527fadf1ad3928744d8eacd4570d049f29a",
    SHIPS_ADDRESS: "0x4661a992a6135a95687851be7056f38360fc0bad5cee8b96e124992ec52e3cb",
    STAION_ADDRESS: "0x5859dba499bb714d71bf80041c8f7ef2208110ca685381e520f0822d43adc13",
    WORLD_ADDRESS: MANIFEST_SEPOLIA.world.address,//,
    MANIFEST: MANIFEST_SEPOLIA, 
  };
  
  // Mainnet network constants
  export const MAINNET = {
    TORII_RPC_URL: "https://api.cartridge.gg/x/starknet/mainnet", 
    TORII_URL: "https://api.cartridge.gg/x/command-nexus-2/torii", 
    ACTIONS_ADDRESS: "0x384af900ce628b8a934838bde8278f5fb589ac8f4dc961a3f0a2c318dfe3b5d",
    CREW_ADDRESS: "0x3fe48c481e26c3e81e66f4d03eaaca0c6fe00e243e3689ffa58b0537e74e926",
    GAMES_ADDRESS: "0x6415d4cb3e43ef6ffe42bdec7d095d090eee7b06b8d4c7b827652d89922dd70",
    OBERON_CREW_ADDRESS: "0x5859dba499bb714d71bf80041c8f7ef2208110ca685381e520f0822d43adc13",
    OBERON_ADDRESS: "0x4788057c2fe04f214390511a52f5527fadf1ad3928744d8eacd4570d049f29a",
    SHIPS_ADDRESS: "0x4661a992a6135a95687851be7056f38360fc0bad5cee8b96e124992ec52e3cb",
    STAION_ADDRESS: "0x5859dba499bb714d71bf80041c8f7ef2208110ca685381e520f0822d43adc13",
    WORLD_ADDRESS: MANIFEST_MAINNET.world.address,//MANIFEST_MAINNET.world.address,
    MANIFEST: MANIFEST_MAINNET, 
  };


  // Katana/local network constants
export const KATANA = {
    TORII_RPC_URL: "", // Default Katana RPC
    TORII_URL: "http://localhost:8080",
    ACTIONS_ADDRESS: "0x0",
    CREW_ADDRESS: "0x0",
    GAMES_ADDRESS: "0x0",
    OBERON_CREW_ADDRESS: "0x0",
    OBERON_ADDRESS: "0x0",
    SHIPS_ADDRESS: "0x0",
    STAION_ADDRESS: "0x0",
    WORLD_ADDRESS: MANIFEST_DEV.world.address,
    MANIFEST: MANIFEST_DEV,  
  };
  
  // Helper function to get constants based on network
export const getNetworkConstants = (network: Network) => {
    switch (network) {
      case 'sepolia':
        return SEPOLIA;
      case 'mainnet':
        return MAINNET;
      case 'katana':
      default:
        return KATANA;
    }
  };