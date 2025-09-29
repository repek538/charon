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
  playMode: PlayMode;
  setPlayMode: (value: PlayMode) => void;
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
  playMode: undefined,
  setPlayMode: (value) => {
    set({ playMode: value });
    set({ onMainnet: value === "multiplayer" });
    set({ onSepolia: value === "singleplayer" });
  },
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



export type PlayMode =
  | "multiplayer"
  | "singleplayer"
  | undefined;


export const tutorialContent = [
    {
        gType: 'section',
        data: {
            title: 'Welcome to Charon',
            content: 'The ultimate deep space rescue simulation built on Starknet. Command specialized vessels, manage expert crews, and execute critical rescue operations in the outer solar system.'
        }
    },
    {
        gType: 'image',
        data: {
            url: '/charon_intro.PNG',
            width: '400px',
            height: '225px'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Wallet Connection',
            content: 'Connect your Starknet wallet to access all features, manage your vessel fleet, and participate in rescue operations. Your wallet will hold your NFT vessels and handle transactions.'
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
            content: 'Use the top navigation to access different sections:\n\n• Command: Main dashboard and operations overview\n• Fleet: Manage your vessels and configurations\n• Missions: Find and accept rescue operations\n• Hangar: Buy, upgrade, and maintain vessels\n• Operations: Participate in coordinated rescue events\n• Network: Connect with other rescue operators'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Getting Started',
            content: 'Your rescue career begins with these options:\n\n• Launch Mission: Start an immediate rescue operation\n• Operations: Join coordinated fleet missions\n• Contracts: Accept specialized rescue contracts\n• Reports: Review your mission performance\n\nClick "Launch Mission" to begin your first rescue operation.'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Fleet Management',
            content: 'The Fleet section is where you manage your vessels. Here you can configure ships, assign crew, and prepare for different mission types.'
        }
    },
    {
        gType: 'image',
        data: {
            url: '/fleet.PNG',
            width: '400px',
            height: '225px'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Configuring Your First Vessel',
            content: 'To configure a vessel:\n\n1. Navigate to the Fleet section\n2. Click "Configure Vessel" or the + button\n3. Choose a vessel designation\n4. Select your ship class (Corvette, Interceptor, Heavy Rescue)\n5. Your vessel will be assigned a unique call sign for identification'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Vessel Classes',
            content: 'Each vessel class offers different operational advantages:\n\n• Corvette: Balanced multi-role vessel with moderate cargo\n• Interceptor: Fast response ship with advanced navigation\n• Heavy Rescue: Large capacity vessel with extended life support\n• Patrol Craft: Long-range vessel with enhanced sensors\n• Engineering Ship: Specialized vessel for complex operations\n\nChoose based on your mission preferences and operational style.'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Crew Specialists & Roles',
            content: 'Crew members have six main specializations:\n\n• Captain: Leadership and mission coordination\n• Pilot: Navigation and ship maneuvering\n• Engineer: Systems maintenance and repairs\n• Gunner: Defensive systems and threat response\n• Medic: Crew health and rescued personnel care\n• Scientist: Scanning and data recovery operations\n\nEach specialist has Health, Intelligence, and Experience stats that determine their effectiveness.'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Crew Experience System',
            content: 'Crew members progress through experience levels:\n\n• Rookie: Basic crew with standard abilities\n• Experienced: Proven crew with improved stats\n• Veteran: Skilled crew with advanced capabilities\n• Elite: Expert crew with exceptional performance\n• Legendary: Master crew with unique specializations\n\nHigher experience levels unlock special abilities and mission bonuses.'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Hangar',
            content: 'The Hangar is where you acquire new vessels and equipment to expand your rescue capabilities.'
        }
    },
    {
        gType: 'image',
        data: {
            url: '/hangar.PNG',
            width: '400px',
            height: '225px'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Acquiring Equipment',
            content: 'In the Hangar you can:\n\n• Browse available vessel configurations\n• View detailed ship specifications and capabilities\n• Purchase vessels using credits or tokens\n• Upgrade existing ship systems\n• Check vessel class and special equipment before buying'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Fleet Building Strategy',
            content: 'Build an effective fleet by:\n\n• Having vessels suited for different mission types\n• Maintaining backup crew for extended operations\n• Balancing fuel capacity, cargo space, and defensive systems\n• Considering crew specialization synergy\n• Planning for various emergency scenarios'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Mission System',
            content: 'Charon features a strategic resource management system where you execute time-critical rescue operations across the outer solar system.'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Mission Types',
            content: 'Different rescue operations require different approaches:\n\n• Emergency Extraction: Time-critical personnel rescue\n• Data Recovery: Retrieve vital research information\n• Equipment Salvage: Recover valuable technology\n• Station Evacuation: Large-scale emergency operations\n• Search and Rescue: Locate missing vessels or crew'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Resource Management',
            content: 'Successful missions require careful resource planning:\n\n1. FUEL: Limited fuel requires efficient navigation routes\n2. CARGO: Balance rescue capacity with equipment needs\n3. CREW STAMINA: Manage crew fatigue during long operations\n4. LIFE SUPPORT: Ensure adequate resources for rescued personnel\n5. EMERGENCY SUPPLIES: Medical supplies and repair materials'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Mission Phases',
            content: 'Four main phases in rescue operations:\n\n• Navigation: Plot course and manage fuel consumption\n• Assessment: Evaluate situation and plan approach\n• Execution: Perform rescue while managing hazards\n• Extraction: Return safely with rescued personnel\n\nEach phase presents different challenges and decision points.'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Environmental Hazards',
            content: 'Deep space presents multiple dangers:\n\n• Asteroid Fields: Navigate carefully to avoid hull damage\n• Hostile Encounters: Unknown threats in deep space\n• System Failures: Equipment malfunctions during critical moments\n• Radiation: Exposure risks in certain sectors\n• Time Limits: Life support failures create urgency'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Mission Flow',
            content: 'A typical rescue operation follows this pattern:\n\n1. Mission Briefing: Review objectives and hazard assessment\n2. Fleet Preparation: Select vessel and assign crew\n3. Navigation Phase: Plot route and manage resources\n4. Operation Execution: Perform rescue under time pressure\n5. Mission Complete: Return and debrief for rewards\n6. Crew Recovery: Manage crew fatigue and experience gain'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Advanced Fleet Operations',
            content: 'Optimize your rescue effectiveness:\n\n• Crew Synergy: Check how specialists work together\n• Mission Specialization: Configure vessels for specific operations\n• Resource Optimization: Maximize fuel and cargo efficiency\n• Risk Assessment: Balance speed versus safety\n• Emergency Protocols: Have contingency plans ready'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Blockchain Integration',
            content: 'Charon leverages Starknet for:\n\n• True ownership of vessel and crew NFTs\n• Permanent mission records and achievements\n• Transparent resource trading and transactions\n• Cross-platform fleet portability\n• Decentralized rescue operation coordination'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Crew Development',
            content: 'Improve your specialists over time:\n\n• Skill Enhancement: Increase Health, Intelligence, and Experience\n• Specialization Upgrades: Unlock advanced crew abilities\n• Cross-Training: Develop secondary specializations\n• Mission Experience: Crew improve through successful operations\n• Performance Tracking: Monitor individual crew statistics'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Operations & Coordination',
            content: 'Participate in large-scale rescue operations for greater rewards and recognition. Coordinated operations offer the highest stakes and best rewards in Charon.'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Successful Operations',
            content: 'Master these key concepts:\n\n• Resource Planning: Never underestimate fuel requirements\n• Crew Balance: Each specialist role is crucial\n• Risk Management: Know when to abort vs. push forward\n• Equipment Maintenance: Regular upkeep prevents failures\n• Market Intelligence: Trade resources efficiently\n• Experience Building: Regular missions develop crew expertise'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Deep Space Sector Updates',
            content: 'New sectors are now accessible in the outer system! These regions feature:\n\n• Enhanced mission complexity\n• Advanced rescue scenarios\n• Upgraded equipment requirements\n• Extended operational ranges\n• Limited access windows\n\nCheck mission briefings regularly for new opportunities.'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Tips for New Operators',
            content: 'Start your rescue career successfully:\n\n• Begin with local sector missions to build experience\n• Focus on crew training over expensive equipment initially\n• Learn resource management through practice operations\n• Study environmental hazards and plan accordingly\n• Invest in balanced crew rather than specialists only\n• Save resources for critical moments in emergency situations'
        }
    },
    {
        gType: 'section',
        data: {
            title: 'Getting Help',
            content: 'Need assistance? Access support through:\n\n• Network section for operator discussions\n• In-game help systems (look for "info" icons)\n• Official operation manuals and procedures\n• Operator forums and communication channels\n• Technical support for system issues\n\nWelcome to the frontier, Commander. Lives depend on your decisions.'
        }
    }
];


export const getElementStoreState = () => {
    return useCharonStore.getState();
  };