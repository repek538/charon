import { useAccount, useConnect, useDisconnect } from "@starknet-react/core";
import { useUiSounds, soundSelector } from "../hooks/useUiSound";
import { useCharonStore } from "../utils/charon";
import { useNetwork } from "../context/NetworkContext";

interface IntroProps {
  onOnboardComplete: () => void;
}

const Intro: React.FC<IntroProps> = ({ onOnboardComplete }) => {
  const {
    setLoginScreen,
    setScreen,
    handleOnboarded,
    setIsMuted,
    isMuted,
  } = useCharonStore();
  const { network } = useNetwork(); // Get the already selected network
  const { connect, connectors } = useConnect();
  const { disconnect } = useDisconnect();
  const { account, status } = useAccount();
  const cartridgeConnector = connectors[0];
  const { play: clickPlay } = useUiSounds(soundSelector.bg);

  // Handle continue button click
  const handleContinue = () => {
    // For mainnet/sepolia, check wallet connection
    if ((network === "mainnet" || network === "sepolia") && status !== "connected") {
      // Attempt to connect wallet
      connect({ connector: cartridgeConnector });
    } else {
      // For testnet or already connected wallets, proceed
      setScreen("start");
      handleOnboarded();
      onOnboardComplete();
      if (network !== "katana") {
        setLoginScreen(true);
      }
    }
  };

  // Toggle sound
  const toggleSound = () => {
    setIsMuted(!isMuted);
  };

  return (
    <div className="min-h-screen flex flex-col items-center bg-black">
      {/* Sound toggle button */}
      <div className="absolute top-4 right-4 z-20">
        <button
          onClick={() => {
            if (!isMuted) {
              //clickPlay(); // Only play sound if not muted
            }
            toggleSound();
          }}
          className="p-2 rounded-full bg-transparent border border-green-500/60 
                   text-green-500 hover:bg-green-500/10 hover:border-green-500"
        >
          {isMuted ? (
            <span className="text-xl">🔇</span>
          ) : (
            <span className="text-xl">🔊</span>
          )}
        </button>
      </div>

      <div className="relative z-10 flex flex-col items-center gap-8 py-12 w-full max-w-7xl px-4 sm:px-6 lg:px-8">
        <h1 className="text-5xl sm:text-6xl font-bold text-green-500 tracking-[0.2em] font-mono">
          CHARON
        </h1>
        
        <div className="w-full max-w-2xl bg-black border border-green-500/60 backdrop-blur-sm p-6 rounded-lg">
          <h2 className="text-xl font-mono text-green-500 mb-4">RESCUE OPERATOR BRIEFING</h2>
          <p className="text-green-500/80 mb-6 font-mono text-sm">
            Welcome, Commander. You are a freelance rescue operator tasked with deep space extractions in the outer solar system. Time is critical - lives depend on your decisions.
          </p>
          
          <div className="mb-4">
            <div className="flex items-center gap-2 mb-4">
              <div className="flex items-center gap-2 px-3 py-1 rounded-full bg-transparent border border-green-500/60">
                <div className={`w-2 h-2 rounded-full ${
                  network === "mainnet" ? "bg-green-500" : 
                  network === "sepolia" ? "bg-green-500" : "bg-green-500"
                }`} />
                <span className="text-xs font-mono uppercase tracking-wider text-green-500">
                  {network === "mainnet" ? "OUTER SYSTEM" : 
                   network === "sepolia" ? "INNER SYSTEM" : "LOCAL SPACE"}
                </span>
              </div>
              
              {(network === "mainnet" || network === "sepolia") && (
                <div className={`px-2 py-1 rounded-full text-xs font-mono border ${
                  status === "connected" 
                    ? "bg-transparent text-green-500 border-green-500/60" 
                    : "bg-transparent text-green-500/60 border-green-500/30"
                }`}>
                  {status === "connected" ? "AUTHENTICATED" : "AUTH REQUIRED"}
                </div>
              )}
            </div>
          </div>
          
          <button
            onClick={handleContinue}
            className="w-full py-4 bg-transparent text-green-500 font-mono tracking-wider 
                  border border-green-500/60 rounded-lg
                  transition-all duration-300 hover:bg-green-500/10 hover:border-green-500
                  active:scale-95"
          >
            {(network === "mainnet" || network === "sepolia") && status !== "connected" 
              ? "CONNECT WALLET" 
              : "LAUNCH"}
          </button>
        </div>
      </div>
    </div>
  );
};

export default Intro;