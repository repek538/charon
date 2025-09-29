import ControllerConnector from '@cartridge/connector/controller'
import { mainnet, sepolia } from '@starknet-react/chains'
import { Connector, StarknetConfig, starkscan } from '@starknet-react/core'
import { RpcProvider, constants } from 'starknet'
import type { Chain } from '@starknet-react/chains'
import type { PropsWithChildren } from 'react'
import type { Network } from '../utils/charon'
import { getNetworkConstants } from '../constants'
import type { ControllerOptions } from '@cartridge/controller'


interface StarknetProviderProps extends PropsWithChildren {
  network: Network;
}

export function StarknetProvider({ children, network }: StarknetProviderProps) {
  // Get network constants based on the current network
  const networkConstants = getNetworkConstants(network);
  console.log("StarknetProvider using network:", network);
  
  // Define session policies
  const policies = {
    contracts: {
      [networkConstants.ACTIONS_ADDRESS]: {
        methods: [
          { entrypoint: "move_ship" },
          { entrypoint: "passive_scan" },
          { entrypoint: "active_scan" },
        ],
      },
      [networkConstants.CREW_ADDRESS]: {
        methods: [
          { entrypoint: "create_crew" },
        //   { entrypoint: "update_stats" },
        //   { entrypoint: "update_rarity" },
        //   { entrypoint: "create_special_ability" },
        ],
      },
      [networkConstants.GAMES_ADDRESS]: {
        methods: [
          { entrypoint: "create_game" },
        //   { entrypoint: "change_formation" },
        //   { entrypoint: "add_card_to_position" },
        //   { entrypoint: "replace_card_to_position" },
        //   { entrypoint: "remove_card_from_position" },
        //   { entrypoint: "rename_squad" },
        //   { entrypoint: "calculate_chemistry" },
        ],
      },
      [networkConstants.OBERON_CREW_ADDRESS]: {
        methods: [
          { entrypoint: "create_crew_member"},
          { entrypoint: "assign_ability" },
          { entrypoint: "activate_ability" },
          { entrypoint: "heal_crew_member" },
          { entrypoint: "train_crew_member" },
          { entrypoint: "get_crew_effectiveness"},
          { entrypoint: "process_crew_turn" },
        ],
      },
    },
  };
  
  const theme = "";
  const namespace = "charon";
  
  const getChainIdForNetwork = (networkValue: Network) => {
    switch (networkValue) {
      case 'sepolia':
        return constants.StarknetChainId.SN_SEPOLIA;
      case 'mainnet':
        return constants.StarknetChainId.SN_MAIN;
      case 'katana':
      default:
        return constants.StarknetChainId.SN_MAIN;
    }
  };
  
  const options: ControllerOptions = {
    chains: [
      {
        rpcUrl: "https://api.cartridge.gg/x/starknet/sepolia",
      },
      {
        rpcUrl: "https://api.cartridge.gg/x/starknet/mainnet",
      },
    ],
    defaultChainId: getChainIdForNetwork(network),
    namespace,
    policies,
  };
  
  const cartridge = new ControllerConnector(
    options,
  ) as never as Connector;
  
  function provider(chain: Chain) {
    switch (chain) {
      case mainnet:
        return new RpcProvider({
          nodeUrl: 'https://api.cartridge.gg/x/starknet/mainnet',
        });
      case sepolia:
      default:
        return new RpcProvider({
          nodeUrl: 'https://api.cartridge.gg/x/starknet/sepolia',
        });
    }
  }

  const smainnet = {
  ...mainnet,
  paymasterRpcUrls: {
    default: { http: [] }
  }
} as Chain;


  
  return (
    <StarknetConfig
      autoConnect
      chains={[mainnet, sepolia]}
      connectors={[cartridge]}
      explorer={starkscan}
      provider={provider}
    >
      {children}
    </StarknetConfig>
  );
}