import React, { useEffect, useState } from 'react';
import { Loader2, Rocket, Satellite, Shield, User, Users, Zap } from 'lucide-react';

const LoadingScreen = ({ message = "Loading Charon Deep Space Rescue..." }) => {
  const [dots, setDots] = useState('');
  const [statusMessage, setStatusMessage] = useState('Connecting to deep space relay');
  const [progress, setProgress] = useState(0);
  const [showTip, setShowTip] = useState(0);

  const tips = [
    "Crew specialists have unique abilities that can save missions!",
    "Balance fuel consumption with mission objectives for optimal outcomes.",
    "Emergency repairs can extend your operational window in critical situations.",
    "Environmental hazards increase with distance from established routes.",
    "Experienced crew members unlock advanced rescue protocols!"
  ];

  useEffect(() => {
    const dotInterval = setInterval(() => {
      setDots(prev => prev.length >= 3 ? '' : prev + '.');
    }, 500);

    const messageInterval = setInterval(() => {
      setStatusMessage(prev => {
        const messages = [
          'Connecting to deep space relay',
          'Calibrating navigation systems',
          'Loading rescue protocols',
          'Synchronizing crew roster',
          'Preparing vessel diagnostics'
        ];
        const currentIndex = messages.indexOf(prev);
        return messages[(currentIndex + 1) % messages.length];
      });
    }, 2000);

    const progressInterval = setInterval(() => {
      setProgress(prev => {
        const newProgress = prev + 1;
        return newProgress > 99 ? 99 : newProgress;
      });
    }, 50);

    const tipInterval = setInterval(() => {
      setShowTip(prev => (prev + 1) % tips.length);
    }, 4000);

    return () => {
      clearInterval(dotInterval);
      clearInterval(messageInterval);
      clearInterval(progressInterval);
      clearInterval(tipInterval);
    };
  }, []);

  return (
    <div className="min-h-screen bg-black flex flex-col items-center justify-center p-4 relative overflow-hidden">
      {/* Background elements */}
      <div className="absolute inset-0">
        <div className="absolute top-10 left-10 w-1 h-1 bg-green-500/20 rounded-full animate-pulse"></div>
        <div className="absolute top-20 right-20 w-1 h-1 bg-green-500/30 rounded-full animate-ping"></div>
        <div className="absolute bottom-20 left-20 w-1 h-1 bg-green-500/20 rounded-full animate-pulse delay-500"></div>
        <div className="absolute bottom-10 right-10 w-1 h-1 bg-green-500/30 rounded-full animate-ping delay-700"></div>
        <div className="absolute top-1/2 left-5 w-1 h-1 bg-green-500/20 rounded-full animate-pulse delay-1000"></div>
        <div className="absolute top-1/3 right-5 w-1 h-1 bg-green-500/30 rounded-full animate-ping delay-300"></div>
      </div>
      
      <div className="absolute top-10 left-10 text-green-500/20 animate-pulse">
        <Shield size={60} />
      </div>
      <div className="absolute bottom-10 right-10 text-green-500/10 animate-pulse" style={{animationDelay: "1s"}}>
        <Rocket size={50} />
      </div>
      <div className="absolute top-20 right-20 text-green-500/10 animate-pulse" style={{animationDelay: "0.5s"}}>
        <Satellite size={40} />
      </div>
      <div className="absolute bottom-20 left-20 text-green-500/15 animate-pulse" style={{animationDelay: "1.5s"}}>
        <Zap size={30} />
      </div>

      {/* Main container */}
      <div className="w-full max-w-2xl bg-black backdrop-blur-md rounded-xl border border-green-500/60 p-8 space-y-8 relative z-10">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <Rocket className="w-8 h-8 text-green-500" />
            <div>
              <h1 className="text-3xl font-bold text-green-500 font-mono">CHARON</h1>
              <p className="text-green-500/80 text-sm font-mono">DEEP SPACE RESCUE</p>
            </div>
          </div>
          <div className="flex space-x-2">
            <div className="w-2 h-2 rounded-full border border-green-500/60"></div>
            <div className="w-2 h-2 rounded-full border border-green-500/60"></div>
            <div className="w-2 h-2 rounded-full bg-green-500/60"></div>
          </div>
        </div>

        {/* Loading animation */}
        <div className="flex flex-col items-center space-y-6 py-4">
          <div className="relative">
            <div className="absolute inset-0 border border-green-500/30 rounded-full animate-ping"></div>
            <div className="relative bg-transparent border-2 border-green-500/60 w-20 h-20 rounded-full flex items-center justify-center">
              <Loader2 className="w-10 h-10 text-green-500 animate-spin" />
            </div>
          </div>
          <div className="text-green-500 font-mono text-lg text-center">
            {statusMessage}{dots}
          </div>
        </div>

        {/* Progress bar */}
        <div className="space-y-3">
          <div className="h-2 bg-transparent border border-green-500/60 rounded-full overflow-hidden">
            <div 
              className="h-full bg-green-500/60 rounded-full transition-all duration-200 ease-out"
              style={{ width: `${progress}%` }}
            />
          </div>
          <div className="flex justify-between text-sm font-mono text-green-500">
            <span>SYSTEM INITIALIZATION</span>
            <span>{progress}%</span>
          </div>
        </div>

        {/* Tip box */}
        <div className="bg-transparent rounded-lg p-5 border border-green-500/60">
          <div className="flex items-start space-x-3">
            <div className="bg-transparent border border-green-500/60 p-2 rounded-lg">
              <User className="w-5 h-5 text-green-500" />
            </div>
            <div>
              <h3 className="text-green-500 font-mono font-medium mb-1">OPERATOR TIP</h3>
              <p className="text-green-500/80 text-sm font-mono">
                {tips[showTip]}
              </p>
            </div>
          </div>
        </div>

        {/* System messages */}
        <div className="px-4 py-2 font-mono text-xs space-y-1.5 border-t border-green-500/60 pt-4">
          <p className="text-green-500/90 flex items-center">
            <span className="inline-block w-3 text-green-500 mr-1">$</span> 
            <span>Initializing rescue database...</span>
          </p>
          <p className="text-green-500/70 flex items-center">
            <span className="inline-block w-3 text-green-500 mr-1">$</span> 
            <span>Configuring vessel systems...</span>
          </p>
          <p className="text-green-500/50 flex items-center">
            <span className="inline-block w-3 text-green-500 mr-1">$</span> 
            <span>Standing by for mission briefing...</span>
          </p>
        </div>
      </div>

      {/* Footer status */}
      <div className="mt-6 text-green-500/60 text-sm font-mono flex items-center">
        <Satellite className="w-4 h-4 mr-2" />
        {message}
      </div>
    </div>
  );
};

export default LoadingScreen;