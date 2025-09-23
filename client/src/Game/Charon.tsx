import React, { useState, useEffect } from 'react';
import MusicControls from './MusicControls';

interface ShipOberon {
  ship: string;
  owner: string;
  name: string;
  hull: number;
  shield: number;
  point_defense: number;
  torpedoes: number;
  railgun: boolean;
  crew_capacity: number;
  fuel: number;
  cargo: number;
  location: { x: number; y: number };
}

interface Crew {
  ship: string;
  captain: string;
  members: number;
  engineers: number;
  gunners: number;
  medics: number;
}

interface CrewMember {
  id: number;
  ship: string;
  owner: string;
  role: 'Captain' | 'Pilot' | 'Engineer' | 'Gunner' | 'Medic' | 'Scientist';
  health: number;
  morale: number;
  stamina: number;
  intelligence: number;
  strength: number;
  dexterity: number;
  experience: number;
  active: boolean;
}

type Screen = 'loading' | 'ship-check' | 'create-ship' | 'ship-info' | 'crew-check' | 'add-crew' | 'crew-info' | 'objectives';

const Charon: React.FC = () => {
  const [currentScreen, setCurrentScreen] = useState<Screen>('loading');
  const [ship, setShip] = useState<ShipOberon | null>(null);
  const [crew, setCrew] = useState<Crew | null>(null);
  const [crewMembers, setCrewMembers] = useState<CrewMember[]>([]);
  // Removed scanLines state - using CSS animation instead

  const musicTracks = [
    { name: "Space Ambient", url: "/music/space-ambient-351305.mp3" },
    { name: "Andromeda - Space Adventure", url: "andromeda-space-adventure-403080.mp3" },
    { name: "Ambient Space Arpeggio", url: "URL_TO_PIXEL_VALOR" },
    { name: "Exploration | Chiptune RPG Adventure (Themenickpanek)", url: "URL_TO_CHIPTUNE_RPG" },
    { name: "Pixel Adventure Background Music Master", url: "URL_TO_ADVENTURE_BG" },
  ];


  // Initial check flow - only run once on mount
  useEffect(() => {
    const timer = setTimeout(() => {
      // For demo: check if ship exists (simulated)
      const hasShip = false; // Set to false to always start with ship creation for testing
      
      if (hasShip) {
        // Mock ship data
        const mockShip: ShipOberon = {
          ship: '0x123...',
          owner: '0xABC...',
          name: 'LUNA_WANDERER',
          hull: 100,
          shield: 75,
          point_defense: 2,
          torpedoes: 6,
          railgun: true,
          crew_capacity: 12,
          fuel: 850,
          cargo: 500,
          location: { x: 42, y: 128 }
        };
        setShip(mockShip);
        setCurrentScreen('ship-info');
      } else {
        setCurrentScreen('create-ship');
      }
    }, 2000);

    return () => clearTimeout(timer);
  }, []);

  const handleShipCreated = (newShip: ShipOberon) => {
    setShip(newShip);
    setCurrentScreen('add-crew');
  };

  const handleCrewAdded = (newCrew: Crew, members: CrewMember[]) => {
    setCrew(newCrew);
    setCrewMembers(members);
    setCurrentScreen('crew-info');
  };

  const proceedToObjectives = () => {
    setCurrentScreen('objectives');
  };

  const skipToObjectives = () => {
    setCurrentScreen('objectives');
  };

  // Loading Screen
  const LoadingScreen = () => (
    <div className="min-h-screen bg-black flex items-center justify-center">
      <div className="text-center">
        <div className="text-green-400 font-mono text-xl mb-4 animate-pulse">
          [INITIALIZING SYSTEMS...]
        </div>
        <div className="flex justify-center gap-2">
          {[...Array(5)].map((_, i) => (
            <div key={i} className="w-3 h-3 bg-green-400 animate-pulse"
              style={{ animationDelay: `${i * 0.1}s` }} />
          ))}
        </div>
      </div>
    </div>
  );

  // Ship Info Screen
  const ShipInfoScreen = () => (
    <div className="min-h-screen bg-black text-green-400 p-8">
      <div className="max-w-4xl mx-auto">
        <div className="border border-green-500 p-6 mb-6">
          <h2 className="text-2xl font-mono mb-4">[VESSEL_CONFIGURATION]</h2>
          
          <div className="grid grid-cols-2 gap-6">
            <div>
              <h3 className="text-green-600 font-mono text-sm mb-3">IDENTIFICATION</h3>
              <div className="space-y-2 font-mono text-xs">
                <div>NAME: {ship?.name}</div>
                <div>OWNER: {ship?.owner?.substring(0, 10)}...</div>
                <div>CONTRACT: {ship?.ship?.substring(0, 10)}...</div>
              </div>
            </div>
            
            <div>
              <h3 className="text-green-600 font-mono text-sm mb-3">SPECIFICATIONS</h3>
              <div className="space-y-2 font-mono text-xs">
                <div>HULL: {ship?.hull}%</div>
                <div>SHIELD: {ship?.shield}%</div>
                <div>CREW_CAPACITY: {ship?.crew_capacity}</div>
              </div>
            </div>
            
            <div>
              <h3 className="text-green-600 font-mono text-sm mb-3">WEAPONS</h3>
              <div className="space-y-2 font-mono text-xs">
                <div>PDC: {ship?.point_defense} UNITS</div>
                <div>TORPEDOES: {ship?.torpedoes}/8</div>
                <div>RAILGUN: {ship?.railgun ? 'MOUNTED' : 'NONE'}</div>
              </div>
            </div>
            
            <div>
              <h3 className="text-green-600 font-mono text-sm mb-3">RESOURCES</h3>
              <div className="space-y-2 font-mono text-xs">
                <div>FUEL: {ship?.fuel} UNITS</div>
                <div>CARGO: {ship?.cargo} T</div>
                <div>LOCATION: [{ship?.location.x}, {ship?.location.y}]</div>
              </div>
            </div>
          </div>
        </div>
        
        <div className="flex justify-between items-center">
          {!crew ? (
            <>
              <div className="text-yellow-400 font-mono text-sm animate-pulse">
                ⚠ NO_CREW_DETECTED
              </div>
              <div className="space-x-4">
                <button
                  onClick={() => setCurrentScreen('add-crew')}
                  className="px-6 py-2 border border-green-400 bg-green-400 text-black font-mono hover:bg-green-500"
                >
                  ADD_CREW
                </button>
                <button
                  onClick={skipToObjectives}
                  className="px-6 py-2 border border-green-600 text-green-400 font-mono hover:bg-green-900 hover:bg-opacity-30"
                >
                  SKIP →
                </button>
              </div>
            </>
          ) : (
            <button
              onClick={() => setCurrentScreen('crew-info')}
              className="px-6 py-2 border border-green-400 bg-green-400 text-black font-mono hover:bg-green-500 ml-auto"
            >
              VIEW_CREW →
            </button>
          )}
        </div>
      </div>
    </div>
  );

  // Create Ship Screen - FIXED
  const CreateShipScreen = () => {
    const [shipName, setShipName] = useState('');
    const [isSubmitting, setIsSubmitting] = useState(false);
    
    const handleCreateShip = () => {
      if (shipName.trim() && !isSubmitting) {
        setIsSubmitting(true);
        
        // Sanitize ship name
        const sanitizedName = shipName.trim().toUpperCase().replace(/[^A-Z0-9_\- ]/g, '').replace(/ /g, '_');
        
        const newShip: ShipOberon = {
          ship: '0x' + Math.random().toString(36).substring(7),
          owner: '0xUSER',
          name: sanitizedName || 'UNNAMED_VESSEL',
          hull: 100,
          shield: 100,
          point_defense: 2,
          torpedoes: 8,
          railgun: false,
          crew_capacity: 10,
          fuel: 1000,
          cargo: 500,
          location: { x: 0, y: 0 }
        };
        
        // Simulate async operation
        setTimeout(() => {
          handleShipCreated(newShip);
          setIsSubmitting(false);
        }, 500);
      }
    };
    
    return (
      <div className="min-h-screen bg-black text-green-400 flex items-center justify-center p-8">
        <div className="max-w-2xl w-full">
          <div className="border border-green-500 p-8">
            <h2 className="text-2xl font-mono mb-6">[VESSEL_REGISTRATION]</h2>
            
            <div className="text-yellow-400 font-mono text-sm mb-6 animate-pulse">
              ⚠ NO_VESSEL_DETECTED - REGISTRATION_REQUIRED
            </div>
            
            <div className="space-y-6">
              <div>
                <label htmlFor="shipName" className="block text-green-600 font-mono text-xs mb-2">
                  VESSEL_NAME ({shipName.length}/20)
                </label>
                <input
                  id="shipName"
                  type="text"
                  value={shipName}
                  onChange={(e) => {
                    if (e.target.value.length <= 20) {
                      setShipName(e.target.value);
                    }
                  }}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter') {
                      e.preventDefault();
                      handleCreateShip();
                    }
                  }}
                  className="w-full bg-black border border-green-600 text-green-400 font-mono px-3 py-2 focus:border-green-400 focus:outline-none"
                  placeholder="ENTER_NAME..."
                  autoFocus
                  disabled={isSubmitting}
                  maxLength={20}
                />
                {shipName.length > 0 && (
                  <div className="text-xs font-mono text-green-600 mt-1">
                    FORMATTED: {shipName.trim().toUpperCase().replace(/[^A-Z0-9_\- ]/g, '').replace(/ /g, '_')}
                  </div>
                )}
              </div>
              
              <div className="text-xs font-mono text-green-600 space-y-1">
                <div>DEFAULT_CONFIGURATION:</div>
                <div className="ml-4">- CORVETTE_CLASS</div>
                <div className="ml-4">- 2x POINT_DEFENSE</div>
                <div className="ml-4">- 8x TORPEDOES</div>
                <div className="ml-4">- 10 CREW_CAPACITY</div>
              </div>
              
              <button
                type="button"
                onClick={handleCreateShip}
                disabled={!shipName.trim() || isSubmitting}
                className={`w-full px-6 py-3 font-mono font-bold border transition-all ${
                  shipName.trim() && !isSubmitting
                    ? 'border-green-400 bg-green-400 text-black hover:bg-green-500' 
                    : 'border-green-800 text-green-800 cursor-not-allowed'
                }`}
              >
                {isSubmitting ? 'REGISTERING...' : 'REGISTER_VESSEL'}
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  };

  // Add Crew Screen - FIXED
  const AddCrewScreen = () => {
    const [selectedRoles, setSelectedRoles] = useState<string[]>(['Captain']);
    const [isSubmitting, setIsSubmitting] = useState(false);
    const roles = ['Captain', 'Pilot', 'Engineer', 'Gunner', 'Medic', 'Scientist'];
    
    const handleAddCrew = () => {
      if (selectedRoles.length > 0 && !isSubmitting) {
        setIsSubmitting(true);
        
        const members: CrewMember[] = selectedRoles.map((role, index) => ({
          id: index + 1,
          ship: ship?.ship || '0x',
          owner: ship?.owner || '0x',
          role: role as CrewMember['role'],
          health: 90 + Math.floor(Math.random() * 10),
          morale: 70 + Math.floor(Math.random() * 30),
          stamina: 80 + Math.floor(Math.random() * 20),
          intelligence: 60 + Math.floor(Math.random() * 40),
          strength: 60 + Math.floor(Math.random() * 40),
          dexterity: 60 + Math.floor(Math.random() * 40),
          experience: Math.floor(Math.random() * 300),
          active: true
        }));
        
        const newCrew: Crew = {
          ship: ship?.ship || '0x',
          captain: '0xCAPT',
          members: selectedRoles.length,
          engineers: selectedRoles.filter(r => r === 'Engineer').length,
          gunners: selectedRoles.filter(r => r === 'Gunner').length,
          medics: selectedRoles.filter(r => r === 'Medic').length,
        };
        
        setTimeout(() => {
          handleCrewAdded(newCrew, members);
          setIsSubmitting(false);
        }, 500);
      }
    };
    
    const toggleRole = (role: string) => {
      if (role === 'Captain' || isSubmitting) return;
      
      if (selectedRoles.includes(role)) {
        setSelectedRoles(selectedRoles.filter(r => r !== role));
      } else if (selectedRoles.length < (ship?.crew_capacity || 10)) {
        setSelectedRoles([...selectedRoles, role]);
      }
    };
    
    return (
      <div className="min-h-screen bg-black text-green-400 p-8">
        <div className="max-w-4xl mx-auto">
          <div className="border border-green-500 p-6 mb-6">
            <h2 className="text-2xl font-mono mb-6">[CREW_RECRUITMENT]</h2>
            
            <div className="mb-6">
              <div className="text-green-600 font-mono text-sm mb-3">
                SELECT_CREW_ROLES ({selectedRoles.length}/{ship?.crew_capacity || 10})
              </div>
              
              <div className="grid grid-cols-3 gap-4">
                {roles.map((role) => (
                  <button
                    key={role}
                    type="button"
                    onClick={() => toggleRole(role)}
                    disabled={role === 'Captain' || isSubmitting}
                    className={`p-4 border font-mono text-xs transition-all ${
                      selectedRoles.includes(role)
                        ? 'border-green-400 bg-green-400 bg-opacity-20 text-green-400'
                        : 'border-green-800 text-green-800 hover:border-green-600 hover:bg-green-900 hover:bg-opacity-20'
                    } ${(role === 'Captain' || isSubmitting) ? 'cursor-not-allowed opacity-75' : 'cursor-pointer'}`}
                  >
                    <div className="font-bold mb-1">{role.toUpperCase()}</div>
                    <div className="text-xs opacity-70">
                      {role === 'Captain' && 'REQUIRED'}
                      {role === 'Engineer' && 'REPAIRS'}
                      {role === 'Gunner' && 'WEAPONS'}
                      {role === 'Medic' && 'HEALING'}
                      {role === 'Pilot' && 'NAVIGATION'}
                      {role === 'Scientist' && 'SCANNING'}
                    </div>
                  </button>
                ))}
              </div>
            </div>
            
            <div className="flex justify-between items-center">
              <div className="text-xs font-mono text-green-600">
                CREW_COST: {selectedRoles.length * 100} CREDITS
              </div>
              <div className="space-x-4">
                <button
                  type="button"
                  onClick={handleAddCrew}
                  disabled={selectedRoles.length === 0 || isSubmitting}
                  className={`px-6 py-2 font-mono font-bold border transition-all ${
                    selectedRoles.length > 0 && !isSubmitting
                      ? 'border-green-400 bg-green-400 text-black hover:bg-green-500'
                      : 'border-green-800 text-green-800 cursor-not-allowed'
                  }`}
                >
                  {isSubmitting ? 'RECRUITING...' : 'RECRUIT_CREW'}
                </button>
                <button
                  type="button"
                  onClick={skipToObjectives}
                  disabled={isSubmitting}
                  className="px-6 py-2 border border-green-600 text-green-400 font-mono hover:bg-green-900 hover:bg-opacity-30 transition-all disabled:opacity-50"
                >
                  SKIP →
                </button>
              </div>
            </div>
          </div>
          
          <div className="text-xs font-mono text-green-600 opacity-70 text-center">
            Press ENTER to recruit • Press ESC to skip
          </div>
        </div>
      </div>
    );
  };

  // Crew Info Screen
  const CrewInfoScreen = () => (
    <div className="min-h-screen bg-black text-green-400 p-8">
      <div className="max-w-5xl mx-auto">
        <div className="border border-green-500 p-6 mb-6">
          <h2 className="text-2xl font-mono mb-6">[CREW_MANIFEST]</h2>
          
          <div className="mb-6">
            <div className="grid grid-cols-4 gap-2 text-xs font-mono text-green-600 mb-2">
              <div>TOTAL: {crew?.members}</div>
              <div>ENGINEERS: {crew?.engineers}</div>
              <div>GUNNERS: {crew?.gunners}</div>
              <div>MEDICS: {crew?.medics}</div>
            </div>
          </div>
          
          <div className="space-y-4">
            {crewMembers.map(member => (
              <div key={member.id} className="border border-green-800 p-4">
                <div className="flex justify-between items-start mb-3">
                  <div>
                    <div className="font-mono text-sm text-green-400 font-bold">
                      {member.role.toUpperCase()}
                    </div>
                    <div className="text-xs font-mono text-green-600">
                      ID: #{member.id} | EXP: {member.experience}
                    </div>
                  </div>
                  <div className={`text-xs font-mono ${member.active ? 'text-green-400' : 'text-red-400'}`}>
                    {member.active ? '● ACTIVE' : '○ INACTIVE'}
                  </div>
                </div>
                
                <div className="grid grid-cols-6 gap-2 text-xs font-mono">
                  <div>
                    <div className="text-green-600">HEALTH</div>
                    <div className="text-green-400">{member.health}%</div>
                  </div>
                  <div>
                    <div className="text-green-600">MORALE</div>
                    <div className="text-green-400">{member.morale}%</div>
                  </div>
                  <div>
                    <div className="text-green-600">STAMINA</div>
                    <div className="text-green-400">{member.stamina}%</div>
                  </div>
                  <div>
                    <div className="text-green-600">INT</div>
                    <div className="text-green-400">{member.intelligence}</div>
                  </div>
                  <div>
                    <div className="text-green-600">STR</div>
                    <div className="text-green-400">{member.strength}</div>
                  </div>
                  <div>
                    <div className="text-green-600">DEX</div>
                    <div className="text-green-400">{member.dexterity}</div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
        
        <button
          onClick={proceedToObjectives}
          className="px-8 py-3 border border-green-400 bg-green-400 text-black font-mono font-bold hover:bg-green-500 w-full"
        >
          PROCEED_TO_MISSION_BRIEFING →
        </button>
      </div>
    </div>
  );

  // Objectives Screen - FIXED
  const ObjectivesScreen = () => {
    const [selectedAction, setSelectedAction] = useState<'accept' | 'review' | null>(null);
    
    const handleAcceptMission = () => {
      setSelectedAction('accept');
      setTimeout(() => {
        console.log('Mission launched!');
        // Here you would navigate to the actual game
      }, 1000);
    };
    
    const handleReviewLoadout = () => {
      setSelectedAction('review');
      setTimeout(() => {
        setCurrentScreen('ship-info');
        setSelectedAction(null);
      }, 300);
    };
    
    return (
      <div className="min-h-screen bg-black text-green-400 p-8">
        <div className="max-w-4xl mx-auto">
          <div className="border-2 border-green-500 p-8 mb-6">
            <h2 className="text-3xl font-mono mb-6 text-center">[MISSION_BRIEFING]</h2>
            
            <div className="space-y-6">
              <div className="border border-green-800 p-4">
                <div className="font-mono text-xs text-green-600 mb-2">PRIMARY_OBJECTIVE</div>
                <div className="text-green-400 font-mono">
                  <div className="text-lg font-bold mb-2">EXTRACTION_PROTOCOL_ALPHA</div>
                  <div className="text-sm space-y-1">
                    <div>TARGET: DR_SARAH_CHEN</div>
                    <div>LOCATION: CHARON_STATION_VII</div>
                    <div>STATUS: NO_CONTACT_72H</div>
                    <div className="text-red-400 animate-pulse mt-2">
                      ⚠ TIME_CRITICAL - LIFE_SUPPORT_FAILING
                    </div>
                  </div>
                </div>
              </div>
              
              <div className="border border-green-800 p-4">
                <div className="font-mono text-xs text-green-600 mb-2">SECONDARY_OBJECTIVES</div>
                <div className="text-green-400 font-mono text-sm space-y-2">
                  <div>▸ RECOVER_RESEARCH_DATA</div>
                  <div>▸ INVESTIGATE_STATION_MALFUNCTION</div>
                  <div>▸ SALVAGE_VALUABLE_EQUIPMENT</div>
                </div>
              </div>
              
              <div className="border border-green-800 p-4">
                <div className="font-mono text-xs text-green-600 mb-2">HAZARDS</div>
                <div className="text-yellow-400 font-mono text-sm space-y-2">
                  <div>⚠ ASTEROID_FIELD_NAVIGATION</div>
                  <div>⚠ POTENTIAL_HOSTILE_PRESENCE</div>
                  <div>⚠ STATION_STRUCTURAL_INSTABILITY</div>
                  <div>⚠ LIMITED_FUEL_FOR_RETURN</div>
                </div>
              </div>
              
              <div className="border border-green-800 p-4">
                <div className="font-mono text-xs text-green-600 mb-2">REWARDS</div>
                <div className="text-green-400 font-mono text-sm space-y-2">
                  <div>◆ 10,000 CREDITS</div>
                  <div>◆ SALVAGE_RIGHTS</div>
                  <div>◆ FACTION_REPUTATION_+100</div>
                  <div>◆ ADVANCED_TECH_BLUEPRINTS</div>
                </div>
              </div>
            </div>
          </div>
          
          <div className="flex gap-4">
            <button
              onClick={handleAcceptMission}
              disabled={selectedAction !== null}
              className={`flex-1 px-8 py-4 border-2 font-mono font-bold text-lg transition-all ${
                selectedAction === 'accept'
                  ? 'border-green-400 bg-green-400 text-black animate-pulse'
                  : selectedAction !== null
                  ? 'border-green-800 text-green-800 cursor-not-allowed'
                  : 'border-green-400 bg-green-400 text-black hover:bg-green-500'
              }`}
            >
              {selectedAction === 'accept' ? 'LAUNCHING...' : 'ACCEPT_MISSION'}
            </button>
            <button
              onClick={handleReviewLoadout}
              disabled={selectedAction !== null}
              className={`px-6 py-4 border font-mono transition-all ${
                selectedAction === 'review'
                  ? 'border-green-600 bg-green-900 bg-opacity-30 text-green-400'
                  : selectedAction !== null
                  ? 'border-green-800 text-green-800 cursor-not-allowed'
                  : 'border-green-600 text-green-400 hover:bg-green-900 hover:bg-opacity-30'
              }`}
            >
              {selectedAction === 'review' ? 'LOADING...' : 'REVIEW_LOADOUT'}
            </button>
          </div>
          
          <div className="mt-4 text-xs font-mono text-green-600 opacity-70 text-center">
            Press ENTER to accept mission • Press R to review loadout
          </div>
        </div>
      </div>
    );
  };

  // Background effects with CSS animation
  const BackgroundEffects = () => (
    <>
      <style>{`
        @keyframes scan {
          0% { transform: translateY(0px); }
          100% { transform: translateY(1000px); }
        }
        .scan-line {
          animation: scan 5s linear infinite;
        }
      `}</style>
      <div className="fixed inset-0 pointer-events-none opacity-10">
        <div className="scan-line absolute inset-0 bg-gradient-to-b from-transparent via-green-500 to-transparent h-4" />
      </div>
      <div className="fixed inset-0 opacity-5 pointer-events-none">
        {[...Array(50)].map((_, i) => (
          <div key={`h${i}`} className="absolute w-full border-t border-green-500"
            style={{ top: `${i * 2}%` }}/>
        ))}
      </div>
    </>
  );

  // Render current screen
  const renderScreen = () => {
    switch (currentScreen) {
      case 'loading':
        return <LoadingScreen />;
      case 'create-ship':
        return <CreateShipScreen />;
      case 'ship-info':
        return <ShipInfoScreen />;
      case 'add-crew':
        return <AddCrewScreen />;
      case 'crew-info':
        return <CrewInfoScreen />;
      case 'objectives':
        return <ObjectivesScreen />;
      default:
        return <LoadingScreen />;
    }
  };

  return (
    <div className="relative min-h-screen bg-black">
      <MusicControls tracks={musicTracks} />
      <BackgroundEffects />
      <div className="relative z-10">
        {renderScreen()}
      </div>
    </div>
  );
};

export default Charon;