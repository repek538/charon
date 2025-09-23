import React, { useState, useEffect } from 'react';
import { 
  Fuel, 
  Heart, 
  Package, 
  Coins, 
  MapPin, 
  Target, 
  Radar, 
  ScrollText, 
  X,
  Clock,
  Zap
} from 'lucide-react';
import CharonGrid from './CharonGrid';

interface GridCell {
  x: number;
  y: number;
  type: 'empty' | 'asteroid' | 'debris' | 'station' | 'pirate' | 'planet' | 'hazard';
  faction?: 'pirates' | 'mars' | 'earth' | 'neutral' | 'unknown';
  name?: string;
  fuel?: number;
  threat?: number;
  loot?: string[];
}

interface PlayerShip {
  x: number;
  y: number;
  fuel: number;
  maxFuel: number;
  supplies: number;
  hull: number;
  credits: number;
}

interface GameEvent {
  type: 'encounter' | 'discovery' | 'hazard' | 'communication';
  title: string;
  description: string;
  options: Array<{
    text: string;
    action: () => void;
    cost?: { fuel?: number; credits?: number; hull?: number };
  }>;
}

type MenuPanel = 'ship' | 'mission' | 'scanner' | 'log' | null;

const CharonGame: React.FC = () => {
  const [gridSize] = useState({ width: 12, height: 8 });
  const [scanLines, setScanLines] = useState(0);
  const [activeMenu, setActiveMenu] = useState<MenuPanel>(null);
  const [playerShip, setPlayerShip] = useState<PlayerShip>({
    x: 1,
    y: 4,
    fuel: 85,
    maxFuel: 100,
    supplies: 12,
    hull: 100,
    credits: 150
  });
  const [currentEvent, setCurrentEvent] = useState<GameEvent | null>(null);
  const [selectedCell, setSelectedCell] = useState<{x: number, y: number} | null>(null);
  const [scanRange] = useState(2);
  const [gameLog, setGameLog] = useState<string[]>(['Starting from Moon Base']);

  useEffect(() => {
    const scanInterval = setInterval(() => {
      setScanLines(prev => (prev + 1) % 100);
    }, 50);
    return () => clearInterval(scanInterval);
  }, []);

  // Initialize grid with various objects
  const [gridCells] = useState<GridCell[]>(() => {
    const cells: GridCell[] = [];
    for (let x = 0; x < gridSize.width; x++) {
      for (let y = 0; y < gridSize.height; y++) {
        let cell: GridCell = { x, y, type: 'empty' };
        
        // Add specific locations
        if (x === 1 && y === 4) {
          cell = { x, y, type: 'station', name: 'Moon Base', faction: 'earth' };
        } else if (x === 5 && y === 3) {
          cell = { x, y, type: 'asteroid', name: 'Ceres Rock', faction: 'pirates', threat: 3 };
        } else if (x === 8 && y === 5) {
          cell = { x, y, type: 'debris', name: 'Old Ship', loot: ['fuel', 'weapons'] };
        } else if (x === 11 && y === 4) {
          cell = { x, y, type: 'planet', name: 'Charon Base', faction: 'neutral' };
        } else if (x === 3 && y === 1) {
          cell = { x, y, type: 'station', name: 'Fuel Stop', faction: 'neutral', fuel: 45 };
        } else if (x === 7 && y === 2) {
          cell = { x, y, type: 'pirate', name: 'Danger Zone', faction: 'pirates', threat: 4 };
        } else if (x === 4 && y === 6) {
          cell = { x, y, type: 'hazard', name: 'Radiation' };
        } else if (Math.random() < 0.1 && x > 2) {
          cell = { x, y, type: 'asteroid', name: 'Rock' };
        }
        
        cells.push(cell);
      }
    }
    return cells;
  });

  const getCell = (x: number, y: number): GridCell | undefined => {
    return gridCells.find(cell => cell.x === x && cell.y === y);
  };

  const getDistance = (x1: number, y1: number, x2: number, y2: number): number => {
    return Math.abs(x1 - x2) + Math.abs(y1 - y2);
  };

  const canMoveTo = (x: number, y: number): boolean => {
    if (x < 0 || x >= gridSize.width || y < 0 || y >= gridSize.height) return false;
    const distance = getDistance(playerShip.x, playerShip.y, x, y);
    return distance === 1 && playerShip.fuel >= 5;
  };

  const moveShip = (x: number, y: number) => {
    if (!canMoveTo(x, y)) return;

    setPlayerShip(prev => ({
      ...prev,
      x,
      y,
      fuel: prev.fuel - 5
    }));

    addToLog(`Moved to [${x},${y}] - Used 5 fuel`);
    checkProximityEvents(x, y);
  };

  const checkProximityEvents = (x: number, y: number) => {
    const cell = getCell(x, y);
    if (cell && cell.type !== 'empty') {
      triggerCellEvent(cell);
    }

    for (let dx = -1; dx <= 1; dx++) {
      for (let dy = -1; dy <= 1; dy++) {
        if (dx === 0 && dy === 0) continue;
        const nearbyCell = getCell(x + dx, y + dy);
        if (nearbyCell && nearbyCell.faction === 'pirates' && Math.random() < 0.3) {
          triggerPirateEncounter(nearbyCell);
          break;
        }
      }
    }
  };

  const triggerCellEvent = (cell: GridCell) => {
    switch (cell.type) {
      case 'station':
        setCurrentEvent({
          type: 'encounter',
          title: `${cell.name} Station`,
          description: `"Hello pilot, need anything?"`,
          options: [
            {
              text: 'Buy fuel (30 units)',
              action: () => {
                if (playerShip.credits >= 50) {
                  setPlayerShip(prev => ({
                    ...prev,
                    fuel: Math.min(prev.fuel + 30, prev.maxFuel),
                    credits: prev.credits - 50
                  }));
                  addToLog('Bought fuel - 30 units');
                } else {
                  addToLog('Not enough money');
                }
                setCurrentEvent(null);
              },
              cost: { credits: 50 }
            },
            {
              text: 'Keep flying',
              action: () => {
                addToLog('Left station');
                setCurrentEvent(null);
              }
            }
          ]
        });
        break;

      case 'debris':
        setCurrentEvent({
          type: 'discovery',
          title: 'Found Wreckage',
          description: 'Old ship parts floating here. Might be useful.',
          options: [
            {
              text: 'Take supplies',
              action: () => {
                const salvage = Math.floor(Math.random() * 3) + 1;
                setPlayerShip(prev => ({
                  ...prev,
                  supplies: prev.supplies + salvage,
                  fuel: prev.fuel - 2
                }));
                addToLog(`Found ${salvage} supplies`);
                setCurrentEvent(null);
              },
              cost: { fuel: 2 }
            },
            {
              text: 'Leave it',
              action: () => {
                addToLog('Left wreckage alone');
                setCurrentEvent(null);
              }
            }
          ]
        });
        break;

      case 'hazard':
        setCurrentEvent({
          type: 'hazard',
          title: 'Danger! Radiation',
          description: 'Strong radiation here. Your ship might get damaged.',
          options: [
            {
              text: 'Go through it',
              action: () => {
                setPlayerShip(prev => ({
                  ...prev,
                  hull: Math.max(prev.hull - 15, 0)
                }));
                addToLog('Ship damaged - lost 15% hull');
                setCurrentEvent(null);
              },
              cost: { hull: 15 }
            },
            {
              text: 'Go around',
              action: () => {
                setPlayerShip(prev => ({
                  ...prev,
                  fuel: prev.fuel - 3
                }));
                addToLog('Went around danger zone');
                setCurrentEvent(null);
              },
              cost: { fuel: 3 }
            }
          ]
        });
        break;
    }
  };

  const triggerPirateEncounter = (cell: GridCell) => {
    setCurrentEvent({
      type: 'encounter',
      title: 'Pirates!',
      description: '"Give us your money or else!"',
      options: [
        {
          text: 'Pay them',
          action: () => {
            if (playerShip.credits >= 25) {
              setPlayerShip(prev => ({
                ...prev,
                credits: prev.credits - 25
              }));
              addToLog('Paid pirates - they let you go');
            } else {
              addToLog('No money - Pirates angry!');
            }
            setCurrentEvent(null);
          },
          cost: { credits: 25 }
        },
        {
          text: 'Run away',
          action: () => {
            const escape = Math.random() < 0.6;
            if (escape) {
              setPlayerShip(prev => ({
                ...prev,
                fuel: prev.fuel - 8
              }));
              addToLog('Escaped! Used extra fuel');
            } else {
              setPlayerShip(prev => ({
                ...prev,
                hull: prev.hull - 20,
                supplies: Math.max(prev.supplies - 2, 0)
              }));
              addToLog('Caught! Ship damaged');
            }
            setCurrentEvent(null);
          }
        }
      ]
    });
  };

  const addToLog = (message: string) => {
    setGameLog(prev => [...prev.slice(-4), message]);
  };

  const isInScanRange = (x: number, y: number): boolean => {
    return getDistance(playerShip.x, playerShip.y, x, y) <= scanRange;
  };

  const toggleMenu = (menu: MenuPanel) => {
    setActiveMenu(activeMenu === menu ? null : menu);
  };

  const renderMenuPanel = () => {
    if (!activeMenu) return null;

    const panelContent = () => {
      switch (activeMenu) {
        case 'ship':
          return (
            <div className="space-y-4">
              <h3 className="text-green-400 font-bold mb-4 flex items-center gap-2">
                <Zap className="w-5 h-5" />
                SHIP STATUS
              </h3>
              
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Fuel className="w-4 h-4 text-blue-400" />
                    <span>Fuel:</span>
                  </div>
                  <span className={playerShip.fuel < 20 ? 'text-red-400' : 'text-green-400'}>
                    {playerShip.fuel}/{playerShip.maxFuel}
                  </span>
                </div>
                <div className="w-full bg-gray-900 h-2 rounded-full overflow-hidden">
                  <div 
                    className={`h-2 transition-all rounded-full ${playerShip.fuel < 20 ? 'bg-red-500' : 'bg-blue-500'}`}
                    style={{ width: `${(playerShip.fuel / playerShip.maxFuel) * 100}%`, boxShadow: '0 0 10px currentColor' }}
                  />
                </div>
                
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Heart className="w-4 h-4 text-red-400" />
                    <span>Hull:</span>
                  </div>
                  <span className={playerShip.hull < 30 ? 'text-red-400' : 'text-green-400'}>
                    {playerShip.hull}%
                  </span>
                </div>
                <div className="w-full bg-gray-900 h-2 rounded-full overflow-hidden">
                  <div 
                    className={`h-2 transition-all rounded-full ${playerShip.hull < 30 ? 'bg-red-500' : 'bg-red-400'}`}
                    style={{ width: `${playerShip.hull}%`, boxShadow: '0 0 10px currentColor' }}
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Package className="w-4 h-4 text-yellow-400" />
                    <span>Supplies:</span>
                  </div>
                  <span className="text-green-400">{playerShip.supplies}</span>
                </div>
                
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Coins className="w-4 h-4 text-yellow-400" />
                    <span>Credits:</span>
                  </div>
                  <span className="text-yellow-400">{playerShip.credits}</span>
                </div>
                
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <MapPin className="w-4 h-4 text-blue-400" />
                    <span>Position:</span>
                  </div>
                  <span className="text-blue-400">[{playerShip.x},{playerShip.y}]</span>
                </div>
              </div>
            </div>
          );

        case 'mission':
          return (
            <div>
              <h3 className="text-yellow-400 font-bold mb-4 flex items-center gap-2">
                <Target className="w-5 h-5" />
                MISSION
              </h3>
              <div className="space-y-2">
                <div className="flex items-center gap-2">
                  <span>Destination:</span>
                  <span className="text-green-400">CHARON [11,4]</span>
                </div>
                <div className="flex items-center gap-2">
                  <span>Distance:</span>
                  <span className="text-blue-400">{getDistance(playerShip.x, playerShip.y, 11, 4)} spaces</span>
                </div>
                <div className="flex items-center gap-2">
                  <Clock className="w-4 h-4 text-red-400" />
                  <span className="text-red-400 animate-pulse">Time: 92 hours</span>
                </div>
              </div>
            </div>
          );

        case 'scanner':
          return (
            <div>
              <h3 className="text-blue-400 font-bold mb-4 flex items-center gap-2">
                <Radar className="w-5 h-5" />
                SCANNER
              </h3>
              {selectedCell ? (
                <div className="space-y-2">
                  <div>Scanning: [{selectedCell.x},{selectedCell.y}]</div>
                  {(() => {
                    const cell = getCell(selectedCell.x, selectedCell.y);
                    if (cell && isInScanRange(selectedCell.x, selectedCell.y)) {
                      return (
                        <div className="space-y-1">
                          <div>Type: <span className="text-green-400">{cell.type}</span></div>
                          {cell.name && <div>Name: <span className="text-yellow-400">{cell.name}</span></div>}
                          {cell.faction && <div>Owner: <span className="text-blue-400">{cell.faction}</span></div>}
                          {cell.threat && <div>Threat: <span className="text-red-400">{cell.threat}/5</span></div>}
                        </div>
                      );
                    } else {
                      return <div className="text-gray-500">Out of scan range</div>;
                    }
                  })()}
                </div>
              ) : (
                <div className="text-gray-500">Click on grid to scan</div>
              )}
            </div>
          );

        case 'log':
          return (
            <div>
              <h3 className="text-gray-400 font-bold mb-4 flex items-center gap-2">
                <ScrollText className="w-5 h-5" />
                SHIP LOG
              </h3>
              <div className="space-y-1 h-48 overflow-y-auto">
                {gameLog.map((entry, index) => (
                  <div key={index} className="text-green-300 text-sm">
                    &gt; {entry}
                  </div>
                ))}
              </div>
            </div>
          );

        default:
          return null;
      }
    };

    return (
    <div className="absolute top-35 left-28 w-80 bg-black/95 border-2 border-green-500 p-4 rounded-lg shadow-lg shadow-green-500/20 z-40">
      <button
        onClick={() => setActiveMenu(null)}
        className="absolute top-2 right-2 text-gray-400 hover:text-red-400 transition-colors"
      >
        <X className="w-5 h-5" />
      </button>
      {panelContent()}
    </div>
    );
  };

  return (
    <div className="min-h-screen bg-black text-green-400 font-mono relative overflow-hidden">
      {/* Scan lines effect */}
      <div className="absolute inset-0 pointer-events-none opacity-10">
        <div className="absolute inset-0 bg-gradient-to-b from-transparent via-green-500 to-transparent h-4"
          style={{ transform: `translateY(${scanLines * 10}px)` }}/>
      </div>

      {/* Header */}
      <div className="border-b-2 border-green-500 p-4 bg-black bg-opacity-80 relative z-30">
        <div className="flex justify-between items-center">
          <div className="text-sm text-green-600">
            Time: {String(new Date().getHours()).padStart(2, '0')}:{String(new Date().getMinutes()).padStart(2, '0')}
          </div>
        </div>
      </div>

      <div className="fixed top-1/3 left-6 -translate-y-1/2 w-20 rounded-3xl bg-black/80 border-2 border-green-400 shadow-[0_0_25px_rgba(74,222,128,0.6)] flex flex-col items-center py-6 space-y-6 z-50">
        <button
          onClick={() => toggleMenu('ship')}
          className={`p-3 rounded-xl transition-all ${
            activeMenu === 'ship'
              ? 'bg-green-900/40 text-green-400 border border-green-400 shadow-[0_0_15px_rgba(74,222,128,0.7)]'
              : 'text-green-600 hover:text-green-400 hover:border hover:border-green-400 hover:shadow-[0_0_10px_rgba(74,222,128,0.5)]'
          }`}
          title="Ship Status"
        >
          <Zap className="w-7 h-7" />
        </button>

        <button
          onClick={() => toggleMenu('mission')}
          className={`p-3 rounded-xl transition-all ${
            activeMenu === 'mission'
              ? 'bg-green-900/40 text-green-400 border border-green-400 shadow-[0_0_15px_rgba(74,222,128,0.7)]'
              : 'text-green-600 hover:text-green-400 hover:border hover:border-green-400 hover:shadow-[0_0_10px_rgba(74,222,128,0.5)]'
          }`}
          title="Mission"
        >
          <Target className="w-7 h-7" />
        </button>

        <button
          onClick={() => toggleMenu('scanner')}
          className={`p-3 rounded-xl transition-all ${
            activeMenu === 'scanner'
              ? 'bg-green-900/40 text-green-400 border border-green-400 shadow-[0_0_15px_rgba(74,222,128,0.7)]'
              : 'text-green-600 hover:text-green-400 hover:border hover:border-green-400 hover:shadow-[0_0_10px_rgba(74,222,128,0.5)]'
          }`}
          title="Scanner"
        >
          <Radar className="w-7 h-7" />
        </button>

        <button
          onClick={() => toggleMenu('log')}
          className={`p-3 rounded-xl transition-all ${
            activeMenu === 'log'
              ? 'bg-green-900/40 text-green-400 border border-green-400 shadow-[0_0_15px_rgba(74,222,128,0.7)]'
              : 'text-green-600 hover:text-green-400 hover:border hover:border-green-400 hover:shadow-[0_0_10px_rgba(74,222,128,0.5)]'
          }`}
          title="Ship Log"
        >
          <ScrollText className="w-7 h-7" />
        </button>
      </div>

      {/* Menu Panel */}
      {renderMenuPanel()}

      {/* Quick Status Bar */}
      <div className="fixed top-20 right-4 z-40 flex gap-4 bg-black bg-opacity-80 border border-green-500 rounded-lg p-3">
        <div className="flex items-center gap-1 text-sm">
          <Fuel className={`w-4 h-4 ${playerShip.fuel < 20 ? 'text-red-400' : 'text-blue-400'}`} />
          <span className={playerShip.fuel < 20 ? 'text-red-400' : 'text-blue-400'}>
            {playerShip.fuel}
          </span>
        </div>
        <div className="flex items-center gap-1 text-sm">
          <Heart className={`w-4 h-4 ${playerShip.hull < 30 ? 'text-red-400' : 'text-red-400'}`} />
          <span className={playerShip.hull < 30 ? 'text-red-400' : 'text-red-400'}>
            {playerShip.hull}%
          </span>
        </div>
        <div className="flex items-center gap-1 text-sm">
          <Coins className="w-4 h-4 text-yellow-400" />
          <span className="text-yellow-400">{playerShip.credits}</span>
        </div>
      </div>

      {/* Main Grid Area */}
      <div className="p-4 pt-8">
        <CharonGrid />
      </div>

      {/* Event Modal */}
      {currentEvent && (
        <div className="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50">
          <div className="bg-black border-2 border-green-400 p-6 max-w-md mx-4 shadow-lg shadow-green-400/20 rounded-3xl">
            <h3 className="text-xl font-bold text-green-400 mb-4">{currentEvent.title}</h3>
            <p className="text-green-300 mb-6">{currentEvent.description}</p>
            <div className="space-y-3">
              {currentEvent.options.map((option, index) => (
                <button
                  key={index}
                  onClick={option.action}
                  className="w-full p-3 border border-green-600 text-left hover:border-green-400 hover:bg-green-900 hover:bg-opacity-30 transition-all rounded-2xl"
                >
                  <div className="text-green-400">{option.text}</div>
                  {option.cost && (
                    <div className="text-xs text-green-600 mt-1">
                      Cost: {Object.entries(option.cost).map(([key, value]) => `${value} ${key}`).join(', ')}
                    </div>
                  )}
                </button>
              ))}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default CharonGame;