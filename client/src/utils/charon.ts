import { create } from 'zustand';
import GameState from './gamestate';



export type ScreenPage =
  | "start"
  | "play"
  | "market"
  | "inventory"
  | "beast"
  | "leaderboard"
  | "upgrade"
  | "profile"
  | "encounters"
  | "guide"
  | "settings"
  | "player"
  | "wallet"
  | "tutorial"
  | "onboarding"
  | "create adventurer"
  | "future";

interface State {
  onboarded: boolean;
  handleOnboarded: () => void;
  handleOffboarded: () => void;
  game_id: number | undefined;
  set_game_id: (game_id: number) => void;
  match_id: number | undefined;
  set_match_id: (match_id: number) => void;
  squad_id: number | undefined;
  set_squad_id: (squad_id: number) => void;
  game_state: GameState;
  set_game_state: (game_state: GameState) => void;
  current_source: number | null;
  set_current_source: (source: number | null) => void;
  current_target: number | null;
  set_current_target: (target: number | null) => void;
  isContinentMode: boolean;
  setContinentMode: (mode: boolean) => void;
  highlighted_region: number | null;
  setHighlightedRegion: (region: number | null) => void;
//   battleReport: Battle | null;
//   setBattleReport: (report: Battle | null) => void;
  player_name: string;
  setPlayerName: (name: string) => void;
  lastDefendResult: Event | null;
  setLastDefendResult: (result: Event | null) => void;
//   lastBattleResult: Battle | null;
//   setLastBattleResult: (battle: Battle | null) => void;
  tilesConqueredThisTurn: number[];
  setTilesConqueredThisTurn: (tile: number[]) => void;
  round_limit: number;
  setRoundLimit: (limit: number) => void;
  username: string;
  setUsername: (value: string) => void;
  isWalletPanelOpen: boolean;
  setWalletPanelOpen: (isOpen: boolean) => void;
  network: Network;
  setNetwork: (value: Network) => void;
  onMainnet: boolean;
  onSepolia: boolean;
  onKatana: boolean;
  isMuted: boolean;
  setIsMuted: (value: boolean) => void;
  loginScreen: boolean;
  dojoConfig: any;
  setDojoConfig: (value: any) => void;
  setLoginScreen: (value: boolean) => void;
  screen: ScreenPage;
  setScreen: (value: ScreenPage) => void;
}

export const useCharonStore = create<State>((set) => ({

  game_id: -1,
  set_game_id: (game_id: number) => {
    set(() => ({ game_id }));
  },
  match_id: -1,
  set_match_id: (match_id: number) => {
    set(() => ({ match_id }));
  },
    squad_id: -1,
  set_squad_id: (squad_id: number) => {
    set(() => ({ squad_id }));
  },
  game_state: GameState.MainMenu,
  set_game_state: (game_state: GameState) => set(() => ({ game_state })),
  current_source: null,
  set_current_source: (source: number | null) => set(() => ({ current_source: source })),
  current_target: null,
  set_current_target: (target: number | null) => set(() => ({ current_target: target })),
  isContinentMode: false,
  setContinentMode: (mode: boolean) => set(() => ({ isContinentMode: mode })),
  highlighted_region: null,
  setHighlightedRegion: (region: number | null) => set(() => ({ highlighted_region: region })),
//   battleReport: null,
//   setBattleReport: (report: Battle | null) => set(() => ({ battleReport: report })),
  player_name: '',
  setPlayerName: (name: string) => set(() => ({ player_name: name })),
  onboarded: false,
  handleOnboarded: () => {
    set({ onboarded: true });
  },
  handleOffboarded: () => {
    set({ onboarded: false });
  },
  lastDefendResult: null,
  setLastDefendResult: (result: Event | null) => set(() => ({ lastDefendResult: result })),
//   lastBattleResult: null,
//   setLastBattleResult: (battle: Battle | null) => set(() => ({ lastBattleResult: battle })),
  username: "",
  setUsername: (value) => set({ username: value }),
  tilesConqueredThisTurn: [],
  setTilesConqueredThisTurn: (tile: number[]) => set(() => ({ tilesConqueredThisTurn: tile })),
  round_limit: 15,
  setRoundLimit: (limit: number) => set(() => ({ round_limit: limit })),
  isWalletPanelOpen: false,
  setWalletPanelOpen: (isOpen: boolean) => set(() => ({ isWalletPanelOpen: isOpen })),
  network: undefined,
  setNetwork: (value) => {
    set({ network: value });
    set({ onMainnet: value === "mainnet" });
    set({ onSepolia: value === "sepolia" });
    set({ onKatana: value === "katana" || value === "localKatana" });
  },
  onMainnet: false,
  onSepolia: false,
  onKatana: false,
  isMuted: false,
  setIsMuted: (value) => set({ isMuted: value }),
  loginScreen: false,
  dojoConfig: undefined,
  setDojoConfig: (value) => {
    set({ dojoConfig: value });
  },
  setLoginScreen: (value) => set({ loginScreen: value }),
  screen: "start",
  setScreen: (value) => set({ screen: value }),
}));


export type Network =
  | "mainnet"
  | "katana"
  | "sepolia"
  | "localKatana"
  | undefined;






export const tutorialContent = [
    {
        gType: 'section',
        data: {
            title: 'Welcome to Charon',
            content: 'The ultimate digital football card game built on Starknet. Collect player cards, build your squad, and compete in strategic matches to become a legendary manager.'
        }
    },
    {
        gType: 'image',
        data: {
            url: '/Charon_intro.PNG',
            width: '400px',
            height: '225px'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Wallet Connection',
            content: 'Connect your Starknet wallet to access all features, store your player cards, and participate in matches. Your wallet will hold your NFT cards and manage transactions.'
        }
    },
    {
        gType: 'image',
        data: {
            url: '/wallet_connect.png',
            width: '400px',
            height: '225px'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Connecting Your Wallet',
            content: 'Follow these steps to connect your Starknet wallet:\n\n1. Click the wallet address in the top-right corner\n2. Select your preferred Starknet wallet (ArgentX, Braavos, etc.)\n3. Confirm the connection request in your wallet\n4. Once connected, your address will be displayed as "0x3d...fae3"'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Navigation Menu',
            content: 'Use the top navigation to access different game sections:\n\n• Home: Main dashboard and game overview\n• Squad: Manage your player cards and formations\n• Matches: Find and join competitive matches\n• Marketplace: Buy, sell, and trade player cards\n• Tournaments: Participate in competitive events\n• Community: Connect with other managers'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Getting Started',
            content: 'Your journey begins with the main action buttons:\n\n• Play Now: Jump into a quick match\n• Tournaments: Enter competitive events\n• Events: Join special limited-time competitions\n• Rewards: Claim your earned prizes\n\nClick "Start Playing" or "New Game" to begin your manager career.'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Squad Management',
            content: 'The Squad section is where you build your team. Here you can create and manage multiple squads with different formations and strategies.'
        }
    },
    {
        gType: 'image',
        data: {
            url: '/squad.PNG',
            width: '400px',
            height: '225px'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Creating Your First Squad',
            content: 'To create a squad:\n\n1. Navigate to the Squad section\n2. Click "Create Squad" or the + button\n3. Choose a squad name\n4. Select your preferred formation (4-4-2, 4-3-3, 3-5-2, 5-3-2, 3-4-3)\n5. Your squad will be assigned a unique ID for identification'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Formation Types',
            content: 'Each formation offers different tactical advantages:\n\n• F442: Balanced 4-4-2 formation with strong midfield\n• F433: Attacking 4-3-3 with three forwards\n• F352: 3-5-2 with wing-backs for width\n• F532: Defensive 5-3-2 with extra defenders\n• F343: Ultra-attacking 3-4-3 formation\n\nChoose based on your playing style and available players.'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Player Cards & Positions',
            content: 'Player cards have four main positions:\n\n• Goalkeeper: Last line of defense\n• Defender: Protect your goal and start attacks\n• Midfielder: Control the game\'s tempo\n• Forward: Score goals and create chances\n\nEach player has Attack, Defense, and Special stats that determine their effectiveness.'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Card Rarity System',
            content: 'Player cards come in five rarity levels:\n\n• Common: Basic players with standard abilities\n• Rare: Above-average players with good stats\n• Epic: High-quality players with strong abilities\n• Legendary: Elite players with exceptional stats\n• Icon: Ultimate players with maximum potential\n\nHigher rarity cards have better stats and special abilities.'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Marketplace',
            content: 'The Marketplace is where you acquire new player cards to strengthen your squad.'
        }
    },
    {
        gType: 'image',
        data: {
            url: '/marketplace.PNG',
            width: '400px',
            height: '225px'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Acquiring Players',
            content: 'In the Marketplace you can:\n\n• Browse available player cards\n• View detailed player statistics and abilities\n• Purchase cards using in-game currency or tokens\n• Add players directly to your squad\n• Check player rarity and special abilities before buying'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Squad Building Strategy',
            content: 'Build a balanced squad by:\n\n• Filling all 11 starting positions according to your formation\n• Having backup players for substitutions\n• Balancing Attack, Defense, and Special stats across positions\n• Considering player chemistry - same team players work better together\n• Planning for different tactical situations'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Match System',
        content: 'Charon features a strategic turn-based match system where you compete against other managers in real-time.'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Creating and Joining Matches',
            content: 'To participate in matches:\n\n• Create Match: Start a new match with your selected squad\n• Join Match: Enter an existing match created by another manager\n• Choose your squad ID when creating or joining\n• Wait for your opponent to join (for created matches)\n• Match begins once both managers are ready'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Match Mechanics - Commit/Reveal System',
            content: 'Matches use a secure commit-reveal system:\n\n1. COMMIT Phase: Choose your action and submit a hidden commitment\n   • Select Attack, Defend, Special, or Substitute\n   • Your choice is encrypted until the reveal phase\n\n2. REVEAL Phase: Both players reveal their actions simultaneously\n   • Actions are resolved based on the combination\n   • Results determine the outcome of that turn'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Action Types',
            content: 'Four main actions available during matches:\n\n• Attack: Focus on scoring goals and creating chances\n• Defend: Strengthen your defense and block opponent attacks\n• Special: Use special abilities and tactical cards\n• Substitute: Replace players during the match for tactical advantages\n\nChoose your actions based on your strategy and opponent\'s likely moves.'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Special Abilities & Tactic Cards',
            content: 'Enhanced gameplay through special features:\n\n• Special Abilities: Unique powers attached to high-rarity cards\n• Tactic Cards: Strategic cards that provide temporary advantages\n• Player Substitutions: Swap players mid-match for tactical changes\n• Chemistry Bonuses: Team synergy affects overall performance'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Match Flow',
            content: 'A typical match progresses as follows:\n\n1. Pre-match: Select your squad and formation\n2. Match Start: Both managers commit their first actions\n3. Turn Resolution: Actions are revealed and resolved\n4. Ongoing Turns: Continue committing and revealing actions\n5. Match End: Final score determines the winner\n6. Rewards: Winner receives prizes and progression'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Advanced Squad Management',
            content: 'Optimize your team performance:\n\n• Calculate Chemistry: Check how well your players work together\n• Formation Changes: Adapt your formation mid-season\n• Player Positioning: Move players to optimize their effectiveness\n• Squad Rotation: Manage player fatigue and form\n• Backup Plans: Have substitute strategies ready'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Blockchain Integration',
            content: 'Charon leverages Starknet  for:\n\n• True ownership of player card NFTs\n• Secure match results and fair play\n• Transparent trading and marketplace transactions\n• Permanent record of achievements and statistics\n• Cross-platform compatibility and portability'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Player Development',
            content: 'Improve your cards over time:\n\n• Update Stats: Enhance Attack, Defense, and Special attributes\n• Rarity Upgrades: Increase card rarity through gameplay\n• Special Abilities: Unlock and create new abilities\n• Seasonal Updates: Cards can be updated with new seasons\n• Performance Tracking: Monitor your players\' match statistics'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Tournaments & Competition',
        content: 'Compete in organized tournaments for greater rewards and recognition. Tournament play offers the highest stakes and best prizes in Charon.'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Winning Strategies',
            content: 'Master these key concepts:\n\n• Squad Balance: Don\'t neglect any position\n• Chemistry Management: Team synergy is crucial\n• Formation Flexibility: Adapt to different opponents\n• Resource Management: Use special abilities wisely\n• Market Timing: Buy low, sell high in the marketplace\n• Practice: Regular matches improve your tactical skills'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Season 5 Cards',
            content: 'New Season 5 cards are now available in the store! These cards feature:\n\n• Updated player statistics\n• New special abilities\n• Enhanced artwork and designs\n• Seasonal bonus attributes\n• Limited-time availability\n\nCheck the marketplace regularly for new releases.'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Tips for New Managers',
        content: 'Start your Charon journey successfully:\n\n• Begin with a solid defensive formation\n• Focus on building chemistry over individual star players\n• Learn the commit-reveal system through practice matches\n• Study your opponents\' tendencies and adapt\n• Invest in a balanced squad rather than just forwards\n• Save resources for strategic moments in important matches'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Getting Help',
            content: 'Need assistance? Access support through:\n\n• Community section for player discussions\n• In-game help buttons (look for "i" icons)\n• Official documentation and guides\n• Community forums and Discord\n• Customer support for technical issues\n\nWelcome to the pitch, manager. Time to build your legacy!'
        }
    }
];


export const getElementStoreState = () => {
    return useCharonStore.getState();
  };