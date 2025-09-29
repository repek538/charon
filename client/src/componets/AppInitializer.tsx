import { init, type SDK } from "@dojoengine/sdk";
import { DojoContextProvider } from "../dojo/DojoContext";
import { BurnerManager, setupBurnerManager } from "@dojoengine/create-burner";
import App from "../App";
import Intro from "./Intro";
import { useOnboarding } from "../context/OnboardingContext";
import type { CharonSchemaType } from "../dojogen/models.gen";
import { useEffect, useState } from "react";
import { AlertTriangle, Rocket, Shield, Satellite } from "lucide-react";
import LoadingScreen from "./LoadingScreen";
import { NetworkAccountProvider } from "../context/WalletContex";
import { useCharonStore, type PlayMode } from "../utils/charon";
import { DojoSdkProvider } from "@dojoengine/sdk/react";
import LandingPage from './LandingPage';
import { getNetworkConstants } from "../constants";
import { createDojoConfig } from "@dojoengine/core";
import { useNetwork } from "../context/NetworkContext";
import NetworkSelector from "./NetworkSelector";
import PlayModeSelector from "./PlayMode";
import { usePlayMode } from "../context/PlayModeContext";


interface AppInitializerProps {
    clientFn: any,
    skipNetworkSelection?: boolean,
}

interface InitializationError {
    code: 'VESSEL_SETUP_FAILED' | 'SERVER_ERROR' | 'AUTHENTICATION_FAILED' | 'UNKNOWN';
    message: string;
    details?: string;
}

const ErrorScreen: React.FC<{ error: InitializationError }> = ({ error }) => (
    <div className="min-h-screen bg-black flex items-center justify-center p-4">
        <div className="max-w-md w-full bg-black backdrop-blur-md rounded-xl border border-green-500/60 shadow-2xl p-8 relative">
            <div className="flex items-center justify-center space-x-4 mb-6">
                <div className="p-3 bg-transparent rounded-full border border-green-500/60">
                    <AlertTriangle className="w-8 h-8 text-green-500" />
                </div>
                <div className="p-3 bg-transparent rounded-full border border-green-500/60">
                    <Rocket className="w-8 h-8 text-green-500" />
                </div>
            </div>
            
            <div className="text-center mb-6">
                <h2 className="text-green-500 font-mono text-xl font-bold mb-2 tracking-wide">
                    CHARON CONNECTION FAILURE
                </h2>
                <div className="w-full h-px bg-green-500/60"></div>
            </div>
            
            <div className="space-y-4">
                <div className="bg-transparent rounded-lg p-4 border border-green-500/30">
                    <p className="text-green-500 font-mono text-sm font-semibold mb-2">
                        Error Code: <span className="text-green-500">{error.code}</span>
                    </p>
                    <p className="text-green-500/80 font-mono text-sm leading-relaxed">
                        {error.message}
                    </p>
                </div>
                
                {error.details && (
                    <div className="bg-transparent rounded-lg p-4 border border-green-500/30 font-mono text-xs">
                        <p className="text-green-500/80">$ {error.details}</p>
                    </div>
                )}
                
                <button 
                    onClick={() => window.location.reload()}
                    className="w-full bg-transparent hover:bg-green-500/10 
                             text-green-500 font-mono font-semibold text-sm py-3 px-6 
                             rounded-lg transition-all duration-300 
                             border border-green-500/60 hover:border-green-500
                             transform hover:scale-[1.02]"
                >
                    RETRY CONNECTION
                </button>
            </div>
        </div>
    </div>
);

const AppInitializer: React.FC<AppInitializerProps> = ({clientFn, skipNetworkSelection = false}) => {
    const { isOnboarded, completeOnboarding } = useOnboarding();
    const [burnerManager, setBurnerManager] = useState<BurnerManager | null>(null);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState<InitializationError | null>(null);
    const [initializationStep, setInitializationStep] = useState(0);
    const [showTitleScreen, setShowTitleScreen] = useState(true);
    const [serverSelected, setServerSelected] = useState(skipNetworkSelection);
    const [modeSelected, setModeSelected] = useState(false);
    
    const { network, dojoConfig } = useNetwork();
    const { playMode, setPlayMode } = usePlayMode();
    const [sdk, setSdk] = useState<SDK<CharonSchemaType>|null>(null);
    
    useEffect(() => {
        // Sync dojoConfig with CharonStore if needed
        if (dojoConfig) {
            useCharonStore.getState().setDojoConfig(dojoConfig);
        }
        
        // Sync network with CharonStore if needed
        if (network) {
            useCharonStore.getState().setNetwork(network);
        }

        if(playMode){
            useCharonStore.getState().setPlayMode(playMode);
        }

    }, [dojoConfig, network,playMode]);
  
    useEffect(() => {
        // Only start initialization after network is set and user is onboarded and mode is selected
        if (!isOnboarded || !network || !dojoConfig || !modeSelected) {
            return;
        }
        
        const networkConstants = getNetworkConstants(network);
        if (network === "sepolia" && import.meta.env.VITE_SEPOLIA !== 'true') {
            console.error("Server mismatch: Selected Sepolia but VITE_SEPOLIA is not set to true");
            throw new Error("Environment configuration mismatch for Sepolia server");
        }
        
        if (network === "mainnet" && import.meta.env.VITE_MAINNET !== 'true') {
            console.error("Server mismatch: Selected Mainnet but VITE_MAINNET is not set to true");
            throw new Error("Environment configuration mismatch for Mainnet server");
        }
        
        const initializeSDK = async () => {
            const sdk = await init<CharonSchemaType>(
                {
                    client: {
                        toriiUrl: networkConstants.TORII_URL,
                        worldAddress: dojoConfig.manifest.world.address,
                    },
                    domain: {
                        name: "CHARON_GAME",
                        version: "1.0",
                        chainId: "KATANA",
                        revision: "1",
                    },
                },
            );
            
            setSdk(sdk);
        }
        
        const initializeGame = async () => {
            try {
                setIsLoading(true);
                
                if (network === 'katana') {
                    // Step 1: Setup vessel systems
                    setInitializationStep(1);
                    console.log(dojoConfig)
                    const manager = await setupBurnerManager(dojoConfig);
                    if (!manager) {
                        throw {
                            code: 'VESSEL_SETUP_FAILED',
                            message: 'Failed to initialize your vessel systems'
                        };
                    }
                    console.log(manager)
                    setBurnerManager(manager);
                    
                    // Step 2: Verify server connection
                    setInitializationStep(2);
                    const serverStatus = await checkServerConnection();
                    if (!serverStatus.connected) {
                        throw {
                            code: 'SERVER_ERROR',
                            message: 'Deep space relay connection unstable',
                            details: serverStatus.error
                        };
                    }
                    
                    // Step 3: Authentication
                    setInitializationStep(3);
                    if (!manager.account) {
                        throw {
                            code: 'AUTHENTICATION_FAILED',
                            message: 'Failed to authenticate pilot credentials'
                        };
                    }
                }
                setIsLoading(false);
            } catch (err) {
                console.error("Charon initialization error:", err);
                setError(err as InitializationError || {
                    code: 'UNKNOWN',
                    message: 'Critical system failure',
                    details: err instanceof Error ? err.message : 'Unknown error occurred'
                });
                setIsLoading(false);
            }
        };
        
        initializeSDK();
        initializeGame();
    }, [isOnboarded, network, dojoConfig?.manifest?.world.address, modeSelected]);
    
    const getLoadingMessage = () => {
        switch (initializationStep) {
            case 1:
                return "Initializing vessel systems...";
            case 2:
                return "Connecting to deep space relay...";
            case 3:
                return "Authenticating pilot credentials...";
            default:
                return "Loading Charon Protocol...";
        }
    };
    
    // Flow control - each screen in sequence
    
    // 1. Landing page (if not skipping network selection)
    if (!skipNetworkSelection && showTitleScreen) {
        return <LandingPage onStartGame={() => setShowTitleScreen(false)} />;
    }
    
    // 2. Play mode selector (first choice after landing)
    if (!modeSelected) {
        return <PlayModeSelector onModeSelect={(mode: PlayMode) => {
            setPlayMode(mode);
            setModeSelected(true);
        }} />;
    }
    
    // 3. Network selector (after play mode is selected)
    if (!skipNetworkSelection && !serverSelected) {
        return <NetworkSelector onNetworkSelected={(selectedServer) => {
            useNetwork().setNetwork(selectedServer);
            setServerSelected(true);
        }} />;
    }
    
    // 4. Intro/onboarding (if not onboarded)
    if (!isOnboarded) {
        return <Intro onOnboardComplete={completeOnboarding} />;
    }
    
    // 5. Wait for network to be set
    if (!network) {
        return <LoadingScreen message="Establishing deep space connection..." />;
    }
    
    // 6. Loading state
    if (isLoading) {
        return <LoadingScreen message={getLoadingMessage()} />;
    }
    
    // 7. Error state
    if (error) {
        return <ErrorScreen error={error} />;
    }
    
    // 8. Final error check for katana network
    if (!burnerManager && network === 'katana') {
        return <ErrorScreen 
            error={{
                code: 'UNKNOWN',
                message: 'Critical vessel initialization failure',
                details: 'Unable to establish vessel control systems'
            }}
        />;
    }
    
    // 9. Success - render main app
    return (
        <DojoSdkProvider
            sdk={sdk}
            dojoConfig={dojoConfig}
            clientFn={clientFn}
        >
            <DojoContextProvider dojoConfig={dojoConfig} burnerManager={burnerManager}>
                <NetworkAccountProvider>
                    <App />
                </NetworkAccountProvider>
            </DojoContextProvider>
        </DojoSdkProvider>
    );
};

// Utility function to check server connection
const checkServerConnection = async () => {
    try {
        // Add your server checking logic here
        // For example, checking if you can reach the Charon game server
        return { connected: true };
    } catch (error) {
        return { 
            connected: false, 
            error: error instanceof Error ? error.message : 'Unknown server error' 
        };
    }
};

export default AppInitializer;