import React from 'react';
import { type Network } from "../utils/charon";
import { Rocket, Satellite, Shield, Zap, Globe } from 'lucide-react';

interface NetworkSelectorProps {
  onNetworkSelected: (network: Network) => void;
}

const NetworkSelector: React.FC<NetworkSelectorProps> = ({ onNetworkSelected }) => {
  // Handle server selection
  const handleServerSelect = (selectedNetwork: Network) => {
    onNetworkSelected(selectedNetwork);
  };

  const ServerBadge = ({ type, name }: { type: string, name: string }) => (
    <div className="flex items-center gap-2">
      <div className="flex items-center gap-2 px-3 py-1 rounded-full bg-transparent border border-green-500/60">
        <div className={`w-2 h-2 rounded-full animate-pulse ${
          type === "mainnet" ? "bg-green-500" : 
          type === "sepolia" ? "bg-green-500" : "bg-green-500"
        }`} />
        <span className="text-xs font-semibold uppercase tracking-wider text-green-500 font-mono">
          {name}
        </span>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-black flex flex-col items-center relative overflow-hidden">
      {/* Background elements */}
      <div className="absolute inset-0">
        <div className="absolute top-10 left-10 w-1 h-1 bg-green-500/20 rounded-full animate-pulse"></div>
        <div className="absolute top-20 right-20 w-1 h-1 bg-green-500/30 rounded-full animate-ping"></div>
        <div className="absolute bottom-20 left-20 w-1 h-1 bg-green-500/20 rounded-full animate-pulse delay-500"></div>
        <div className="absolute bottom-10 right-10 w-1 h-1 bg-green-500/30 rounded-full animate-ping delay-700"></div>
        <div className="absolute top-1/2 left-5 w-1 h-1 bg-green-500/20 rounded-full animate-pulse delay-1000"></div>
        <div className="absolute top-1/3 right-5 w-1 h-1 bg-green-500/30 rounded-full animate-ping delay-300"></div>
      </div>
      
      {/* Floating decorative elements */}
      <div className="absolute top-20 left-10 text-green-500/10 animate-pulse">
        <Rocket size={60} />
      </div>
      <div className="absolute bottom-20 right-10 text-green-500/10 animate-pulse" style={{animationDelay: "1.5s"}}>
        <Shield size={50} />
      </div>
      <div className="absolute top-40 right-40 text-green-500/10 animate-pulse" style={{animationDelay: "0.8s"}}>
        <Satellite size={40} />
      </div>

      <div className="relative z-10 flex flex-col items-center gap-8 py-12 w-full max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="flex items-center space-x-3">
          <Rocket className="w-10 h-10 text-green-500" />
          <h1 className="text-5xl sm:text-6xl font-bold text-green-500 font-mono">
            CHARON
          </h1>
        </div>
        <h2 className="text-xl text-green-500 font-medium tracking-wide flex items-center font-mono">
          <Satellite className="w-5 h-5 mr-2" />
          SELECT BLOCKCHAIN NETWORK
        </h2>

        <div className={`grid grid-cols-1 ${
            import.meta.env.VITE_SEPOLIA === 'false' 
              ? 'md:grid-cols-3' 
              : 'md:grid-cols-2'
          } gap-6 w-full mt-8`}>
          {/* Mainnet Card */}
          <div className="flex flex-col rounded-xl overflow-hidden bg-black border border-green-500/60 backdrop-blur-sm
            transition-all duration-300 hover:border-green-500 hover:bg-green-500/5 group">
            <div className="p-6 flex flex-col gap-6 h-full">
              <div className="flex justify-between items-start">
                <ServerBadge type="mainnet" name="MAINNET" />
                <Globe className="w-8 h-8 text-green-500/70" />
              </div>
              <p className="text-green-500/80 text-lg font-mono">
                Production network with real transactions. Your assets have real value and permanence.
              </p>
              <div className="mt-auto flex flex-col gap-2">
                <button
                  disabled
                  onClick={() => handleServerSelect("mainnet")}
                  className="mt-auto w-full py-4 bg-transparent text-green-500/50 font-medium tracking-wider font-mono
                  border border-green-500/30 rounded-lg 
                  transition-all duration-300 cursor-not-allowed"
                >
                  UNAVAILABLE
                </button>
                <p className="text-xs text-green-500/50 text-center font-mono">System Offline</p>
              </div>
            </div>
          </div>

          {/* Sepolia Card */}
          <div className="flex flex-col rounded-xl overflow-hidden bg-black border border-green-500/60 backdrop-blur-sm
            transition-all duration-300 hover:border-green-500 hover:bg-green-500/5 group">
            <div className="p-6 flex flex-col gap-6 h-full">
              <div className="flex justify-between items-start">
                <ServerBadge type="sepolia" name="TESTNET" />
                <Shield className="w-8 h-8 text-green-500/70" />
              </div>
              <p className="text-green-500/80 text-lg font-mono">
                Testing network with free tokens. Safe environment for learning without financial risk.
              </p>
              <button
                onClick={() => handleServerSelect("sepolia")}
                className="mt-auto w-full py-4 bg-transparent text-green-500 font-medium tracking-wider font-mono
                  border border-green-500/60 rounded-lg 
                  transition-all duration-300 hover:bg-green-500/10 hover:border-green-500
                  active:scale-95"
              >
                CONNECT
              </button>
            </div>
          </div>

          {/* Testnet Card */}
          {import.meta.env.VITE_SEPOLIA === 'false' && (
          <div className="flex flex-col rounded-xl overflow-hidden bg-black border border-green-500/60 backdrop-blur-sm
          transition-all duration-300 hover:border-green-500 hover:bg-green-500/5 group">
            <div className="p-6 flex flex-col gap-6 h-full">
              <div className="flex justify-between items-start">
                <ServerBadge type="testnet" name="DEVNET" />
                <Zap className="w-8 h-8 text-green-500/70" />
              </div>
              <p className="text-green-500/80 text-lg font-mono">
                Development network for testing. Fastest transactions and unlimited resources for development.
              </p>
              <button
                onClick={() => handleServerSelect("katana")}
                className="mt-auto w-full py-4 bg-transparent text-green-500 font-medium tracking-wider font-mono
                  border border-green-500/60 rounded-lg 
                  transition-all duration-300 hover:bg-green-500/10 hover:border-green-500
                  active:scale-95"
              >
                CONNECT
              </button>
            </div>
          </div>
          )}
        </div>

        {/* Footer info */}
        <div className="mt-8 text-center">
          <div className="inline-flex items-center space-x-2 text-green-500/60 font-mono text-xs">
            <Satellite className="w-4 h-4" />
            <span>CHARON RESCUE OPERATIONS NETWORK</span>
            <Satellite className="w-4 h-4" />
          </div>
        </div>
      </div>
    </div>
  );
};

export default NetworkSelector;