import React, { useState, useEffect } from 'react';
import { ChevronRight, X, Rocket, Users, Clock, Satellite, Shield, Zap, User } from 'lucide-react';
import About from './About';  // Import your About component
import GameTutorial from './GameTutorial';
import { tutorialContent } from '../utils/charon';

const LandingPage = ({ onStartGame }) => {
  const [showTutorial, setShowTutorial] = useState(false);
  const [showAbout, setShowAbout] = useState(false);
  const [cardIndex, setCardIndex] = useState(0);
  
  const featuredVessels = [
    {
      name: "CERBERUS",
      class: "Corvette",
      rating: 94,
      systems: "Advanced",
      rarity: "Military",
      color: "border-green-400"
    },
    {
      name: "HERMES",
      class: "Interceptor", 
      rating: 92,
      systems: "Enhanced",
      rarity: "Civilian",
      color: "border-green-500"
    },
    {
      name: "ATLAS",
      class: "Heavy Rescue",
      rating: 91,
      systems: "Industrial",
      rarity: "Commercial",
      color: "border-green-600"
    }
  ];
  
  useEffect(() => {
    const interval = setInterval(() => {
      setCardIndex((prevIndex) => (prevIndex + 1) % featuredVessels.length);
    }, 3000);
    
    return () => clearInterval(interval);
  }, []);

  const TutorialModal = () => (
    <div className="fixed inset-0 bg-black/80 backdrop-blur-sm flex items-center justify-center z-50">
      <div className="bg-black border border-green-500/60 p-6 rounded-lg max-w-2xl w-full mx-4">
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-green-500 text-xl font-mono">Rescue Operations Guide</h3>
          <button 
            onClick={() => setShowTutorial(false)}
            className="text-green-500 hover:text-green-400"
          >
            <X className="w-6 h-6" />
          </button>
        </div>
        <div className="space-y-4 text-green-500/80 font-mono">
        <GameTutorial 
          content={tutorialContent} 
          onClose={() => setShowTutorial(false)}
        />
        </div>
      </div>
    </div>
  );

  const AboutModal = () => (
    <div className="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 flex items-start justify-center overflow-y-auto">
      <div className="relative w-full max-w-6xl mx-4 bg-black border border-green-500/60 rounded-lg">
        {/* Close button */}
        <button 
          onClick={() => setShowAbout(false)}
          className="absolute right-4 top-4 text-green-500 hover:text-green-400 z-10 bg-transparent border border-green-500/60 p-1 rounded-lg"
        >
          <X className="w-6 h-6" />
        </button>
        
        {/* Scrollable container */}
        <div className="h-full overflow-y-auto">
          <div className="bg-black border border-green-500/60 rounded-lg">
            <About />
          </div>
        </div>
      </div>
    </div>
  );

  // Vessel card component
  const AnimatedVessel = ({ vessel, isActive }) => (
    <div className={`transform transition-all duration-700 ease-out ${
      isActive ? 'scale-100 opacity-100' : 'scale-90 opacity-40'
    }`}>
      <div className={`w-64 h-96 rounded-xl overflow-hidden relative bg-black border-2 ${vessel.color}`}>
        {/* Card header */}
        <div className="absolute top-0 left-0 w-full p-3 flex justify-between items-center">
          <span className="bg-transparent border border-green-500/60 text-green-500 font-bold rounded-full px-2 py-1 text-sm font-mono">
            {vessel.rating}
          </span>
          <span className="bg-transparent border border-green-500/60 text-green-500 font-bold rounded-full px-2 py-1 text-xs font-mono">
            {vessel.rarity}
          </span>
        </div>
        
        {/* Card body with vessel silhouette */}
        <div className="h-64 flex justify-center items-center">
          <div className="w-48 h-48 bg-transparent border border-green-500/30 rounded-full flex items-center justify-center">
            <Rocket className="w-16 h-16 text-green-500/80" />
          </div>
        </div>
        
        {/* Card footer */}
        <div className="absolute bottom-0 left-0 w-full p-4 bg-black border-t border-green-500/30">
          <div className="text-green-500 font-bold text-xl mb-1 font-mono">{vessel.name}</div>
          <div className="flex justify-between items-center">
            <div className="text-green-500/80 text-sm font-mono">{vessel.class}</div>
            <div className="text-green-500/80 text-sm font-mono">{vessel.systems}</div>
          </div>
        </div>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-black flex flex-col relative">
      {/* Background effects */}
      <div className="absolute inset-0">
        <div className="absolute top-10 left-10 w-1 h-1 bg-green-500/20 rounded-full animate-pulse"></div>
        <div className="absolute top-20 right-20 w-1 h-1 bg-green-500/30 rounded-full animate-ping"></div>
        <div className="absolute bottom-20 left-20 w-1 h-1 bg-green-500/20 rounded-full animate-pulse delay-500"></div>
        <div className="absolute bottom-10 right-10 w-1 h-1 bg-green-500/30 rounded-full animate-ping delay-700"></div>
        <div className="absolute top-1/2 left-5 w-1 h-1 bg-green-500/20 rounded-full animate-pulse delay-1000"></div>
        <div className="absolute top-1/3 right-5 w-1 h-1 bg-green-500/30 rounded-full animate-ping delay-300"></div>
      </div>
      
      {/* Floating elements for visual interest */}
      <div className="absolute top-20 left-20 text-green-500/10 animate-pulse">
        <Rocket size={60} />
      </div>
      <div className="absolute bottom-20 right-20 text-green-500/10 animate-pulse" style={{animationDelay: "1.5s"}}>
        <Shield size={50} />
      </div>
      <div className="absolute top-40 right-40 text-green-500/10 animate-pulse" style={{animationDelay: "0.8s"}}>
        <Satellite size={40} />
      </div>
      
      {/* Main content */}
      <div className="relative flex-1 flex flex-col md:flex-row items-center justify-center px-4 py-8 md:py-0 gap-8">
        {/* Left side content */}
        <div className="md:w-1/2 max-w-2xl w-full space-y-8 text-center md:text-left">
          <div className="inline-flex items-center px-4 py-2 rounded-full bg-transparent border border-green-500/60">
            <Satellite className="w-5 h-5 text-green-500 mr-2" />
            <span className="text-green-500 text-sm font-medium font-mono">Sol System 2387</span>
          </div>
          
          <h1 className="text-4xl md:text-6xl font-bold font-mono text-green-500">
            CHARON
            <span className="block text-green-500 text-3xl md:text-4xl mt-2">
              DEEP SPACE 
            </span>
            <span className="block text-green-500 text-2xl md:text-3xl mt-1">
              RESCUE
            </span>
          </h1>
          
          <p className="text-lg text-green-500/80 max-w-xl font-mono">
            Command specialized rescue vessels in the outer solar system. 
            Extract stranded personnel and salvage critical equipment from failing deep space stations.
          </p>
          
          <div className="flex flex-col sm:flex-row gap-4 justify-center md:justify-start mt-8">
            <button 
              onClick={onStartGame}
              className="bg-transparent border border-green-500/60 hover:bg-green-500/10 text-green-500 px-8 py-4 rounded-lg font-semibold flex items-center justify-center group transition-all duration-300 font-mono"
            >
              LAUNCH MISSION
              <ChevronRight className="ml-2 transition-transform group-hover:translate-x-1" />
            </button>
            
            <div className="flex gap-3">
              <button 
                onClick={() => setShowAbout(true)}
                className="border border-green-500/60 bg-transparent hover:bg-green-500/5 text-green-500 px-6 py-4 rounded-lg font-medium transition-colors font-mono"
              >
                OPERATIONS MANUAL
              </button>
              <button 
                onClick={() => setShowTutorial(true)}
                className="border border-green-500/60 bg-transparent hover:bg-green-500/5 text-green-500 px-6 py-4 rounded-lg font-medium transition-colors font-mono"
              >
                TRAINING
              </button>
            </div>
          </div>
        </div>
        
        {/* Right side - Vessel Showcase */}
        <div className="md:w-1/2 flex justify-center items-center mt-8 md:mt-0">
          <div className="relative h-96 w-64">
            {featuredVessels.map((vessel, index) => (
              <div key={index} className="absolute inset-0 transition-all duration-700" 
                   style={{
                     opacity: cardIndex === index ? 1 : 0,
                     transform: cardIndex === index ? 'rotateY(0)' : 'rotateY(-90deg)',
                     transformStyle: 'preserve-3d',
                     perspective: '1000px'
                   }}>
                <AnimatedVessel vessel={vessel} isActive={true} />
              </div>
            ))}
            
            {/* Vessel glow effect */}
            <div className="absolute inset-0 bg-green-500/5 pointer-events-none rounded-xl"></div>
          </div>
        </div>
      </div>
      
      {/* Footer */}
      <div className="relative w-full p-4 mt-auto border-t border-green-500/60">
        <div className="flex justify-between items-center text-green-500/60 text-sm font-mono">
          <div className="flex items-center">
            <Rocket className="w-4 h-4 mr-2" />
            <span>Charon Deep Space Rescue © 2387</span>
          </div>
          <div className="flex items-center space-x-4">
            <span className="flex items-center">
              <Clock className="w-3 h-3 mr-1" />
              <span>System Online</span>
            </span>
            <button className="hover:text-green-500 transition-colors">Support</button>
            <button className="hover:text-green-500 transition-colors">Terms</button>
          </div>
        </div>
      </div>
      
      {showTutorial && <TutorialModal />}
      {showAbout && <AboutModal />}
    </div>
  );
};

export default LandingPage;