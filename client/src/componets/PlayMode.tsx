import React, { useState } from 'react';
import { User, Users, Rocket, Satellite, Globe, Zap, ArrowRight } from 'lucide-react';
import type { PlayMode } from '../utils/charon';



interface PlayModeProps {
  onModeSelect: (playMode: PlayMode) => void;
}

const PlayModeSelector: React.FC<PlayModeProps> = ({ onModeSelect }) => {
  const [selectedMode, setSelectedMode] = useState<PlayMode | null>(null);
  const [isTransitioning, setIsTransitioning] = useState(false);

  const handleModeSelect = (mode: PlayMode) => {
    setSelectedMode(mode);
    setIsTransitioning(true);
    
    // Add a slight delay for smooth transition effect
    setTimeout(() => {
      onModeSelect(mode);
    }, 800);
  };

  return (
    <div className="min-h-screen bg-black relative overflow-hidden flex items-center justify-center p-4">
      {/* Animated background elements */}
      <div className="absolute inset-0">
        <div className="absolute top-10 left-10 w-1 h-1 bg-green-500/30 rounded-full animate-pulse"></div>
        <div className="absolute top-20 right-20 w-1 h-1 bg-green-500/30 rounded-full animate-ping"></div>
        <div className="absolute bottom-20 left-20 w-1 h-1 bg-green-500/30 rounded-full animate-pulse delay-500"></div>
        <div className="absolute bottom-10 right-10 w-1 h-1 bg-green-500/30 rounded-full animate-ping delay-700"></div>
        <div className="absolute top-1/2 left-5 w-1 h-1 bg-green-500/30 rounded-full animate-pulse delay-1000"></div>
        <div className="absolute top-1/3 right-5 w-1 h-1 bg-green-500/30 rounded-full animate-ping delay-300"></div>
      </div>

      {/* Main content */}
      <div className="relative z-10 max-w-4xl w-full">
        {/* Header */}
        <div className="text-center mb-12">
          <div className="flex items-center justify-center mb-6">
            <div className="p-4 bg-transparent rounded-full border border-green-500/60 mr-4">
              <Rocket className="w-12 h-12 text-green-500" />
            </div>
            <div className="text-center">
              <h1 className="text-5xl font-bold text-green-500 font-mono tracking-wider mb-2">
                CHARON
              </h1>
              <div className="w-32 h-px bg-green-500 mx-auto"></div>
            </div>
            <div className="p-4 bg-transparent rounded-full border border-green-500/60 ml-4">
              <Satellite className="w-12 h-12 text-green-500" />
            </div>
          </div>
          
          <h2 className="text-xl text-green-500 font-mono mb-2">SELECT PLAY MODE</h2>
        </div>

        {/* Mode selection cards */}
        <div className="grid md:grid-cols-2 gap-8 mb-8">
          {/* Single Player */}
          <div 
            className={`relative group cursor-pointer transform transition-all duration-500 hover:scale-105 ${
              selectedMode === 'singleplayer' ? 'scale-105' : ''
            } ${isTransitioning && selectedMode === 'singleplayer' ? 'animate-pulse' : ''}`}
            onClick={() => handleModeSelect('singleplayer')}
          >
            <div className="bg-black backdrop-blur-md rounded-2xl border border-green-500/60 p-8 h-full relative overflow-hidden">
              {/* Background pattern */}
              <div className="absolute inset-0 opacity-5">
                <div className="absolute top-4 right-4">
                  <Globe className="w-24 h-24 text-green-500" />
                </div>
              </div>
              
              <div className="relative z-10">
                <div className="flex items-center mb-6">
                  <div className="p-3 bg-transparent rounded-full border border-green-500/60 mr-4">
                    <User className="w-8 h-8 text-green-500" />
                  </div>
                  <h3 className="text-xl font-bold text-green-500 font-mono">SINGLE PLAYER</h3>
                </div>
                
                <div className="space-y-2 mb-6">
                  <div className="flex items-center text-green-500/80">
                    <span className="font-mono text-sm">Solo exploration</span>
                  </div>
                  <div className="flex items-center text-green-500/80">
                    <span className="font-mono text-sm">Story campaign</span>
                  </div>
                  <div className="flex items-center text-green-500/80">
                    <span className="font-mono text-sm">Progressive difficulty</span>
                  </div>
                </div>
                
                <div className="flex items-center justify-between">
                  <span className="text-green-500 font-mono text-sm font-bold">READY</span>
                  <ArrowRight className="w-5 h-5 text-green-500 group-hover:translate-x-2 transition-transform duration-300" />
                </div>
              </div>
              
              {/* Hover glow effect */}
              <div className="absolute inset-0 bg-green-500/5 rounded-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
            </div>
          </div>

          {/* Multiplayer */}
          <div 
            className={`relative group cursor-pointer transform transition-all duration-500 hover:scale-105 ${
              selectedMode === 'multiplayer' ? 'scale-105' : ''
            } ${isTransitioning && selectedMode === 'multiplayer' ? 'animate-pulse' : ''}`}
            onClick={() => handleModeSelect('multiplayer')}
          >
            <div className="bg-black backdrop-blur-md rounded-2xl border border-green-500/60 p-8 h-full relative overflow-hidden">
              {/* Background pattern */}
              <div className="absolute inset-0 opacity-5">
                <div className="absolute top-4 right-4">
                  <Users className="w-24 h-24 text-green-500" />
                </div>
              </div>
              
              <div className="relative z-10">
                <div className="flex items-center mb-6">
                  <div className="p-3 bg-transparent rounded-full border border-green-500/60 mr-4">
                    <Users className="w-8 h-8 text-green-500" />
                  </div>
                  <h3 className="text-xl font-bold text-green-500 font-mono">MULTIPLAYER</h3>
                </div>
                
                <div className="space-y-2 mb-6">
                  <div className="flex items-center text-green-500/80">
                    <span className="font-mono text-sm">Cooperative missions</span>
                  </div>
                  <div className="flex items-center text-green-500/80">
                    <span className="font-mono text-sm">PvP combat arenas</span>
                  </div>
                  <div className="flex items-center text-green-500/80">
                    <span className="font-mono text-sm">Guild systems</span>
                  </div>
                </div>
                
                <div className="flex items-center justify-between">
                  <span className="text-green-500 font-mono text-sm font-bold">ONLINE</span>
                  <ArrowRight className="w-5 h-5 text-green-500 group-hover:translate-x-2 transition-transform duration-300" />
                </div>
              </div>
              
              {/* Hover glow effect */}
              <div className="absolute inset-0 bg-green-500/5 rounded-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="text-center">
          <div className="inline-flex items-center space-x-2 text-green-500/60 font-mono text-xs">
            <Satellite className="w-4 h-4" />
            <span>SOL SYSTEM</span>
            <Satellite className="w-4 h-4" />
          </div>
        </div>
      </div>

      {/* Additional background effects */}
      <div className="absolute inset-0 bg-green-500/1 backdrop-blur-3xl pointer-events-none"></div>
    </div>
  );
};

export default PlayModeSelector;