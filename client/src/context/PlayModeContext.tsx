import React, { createContext, useContext, useState, useEffect } from "react";
import type { PlayMode} from "../utils/charon";


export type PlayModeContextType = {
  playMode: PlayMode| null;
  setPlayMode: (playMode: PlayMode) => void;
};

// Create the context with a default value
export const PlayModeContext = createContext<PlayModeContextType>({
  playMode: null,
  setPlayMode: () => {},
});

// Custom hook for accessing network context
export const usePlayMode= () => {
  const context = useContext(PlayModeContext);
  return context;
};

// The provider component
export const PlayModeProvider: React.FC<{ 
  children: React.ReactNode;
  initialPlayMode?: PlayMode| null; 
}> = ({ children, initialPlayMode= null }) => {
  const [playMode, setPlayModeState] = useState<PlayMode| null>(initialPlayMode);


  // When network changes, update dojoConfig
  const setPlayMode= (selectedPlayMode: PlayMode) => {
    setPlayModeState(selectedPlayMode);
  };

  const value = {
    playMode,
    setPlayMode,
  };

  return (
    <PlayModeContext.Provider value={value}>
      {children}
    </PlayModeContext.Provider>
  );
};