import React, { useState, useEffect, useRef } from 'react';
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
import { drawCelestialBody, drawLunar, drawShip, initializeImages } from './GameImageManager';
import type { CelestialBody } from '../types';

interface Position {
  x: number;
  y: number;
  z: number;
}

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

interface LunarCoor {
  x: number;
  y: number;
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

const CharonUnifiedGame: React.FC = () => {
  // Grid states
  const [targetPosition, setTargetPosition] = useState<Position | null>(null);
  const [viewOffset, setViewOffset] = useState({ x: 0, y: 0 });
  const [gridScale, setGridScale] = useState(1);
  const [isDragging, setIsDragging] = useState(false);
  const [dragStart, setDragStart] = useState({ x: 0, y: 0 });
  const [showCoordinateInput, setShowCoordinateInput] = useState(false);
  const [inputCoords, setInputCoords] = useState({ x: '', y: '', z: '' });
  
  // Game states
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

    const [lunar, setLunarCoord] = useState<LunarCoor>({
    x: 15,
    y: 15,
    });

   const [celestialBodies] = useState<CelestialBody[]>([
    { id: 'lunar', x: 15, y: 15, imageName: 'lunar', baseSize: 240, color: '#888888' },
    { id: 'mars', x: 800, y: 800, imageName: 'mars', baseSize: 400, color: '#ff4400' },
    { id: 'earth', x: 100, y: 100, imageName: 'earth', baseSize: 480, color: '#0088ff' },
    { id: 'charon', x: 7000, y: 7000, imageName: 'charon', baseSize: 180, color: '#666666' },
    { id: 'ceres', x: 5000, y: 5000, imageName: 'ceres', baseSize: 100, color: '#999999' },
  ]);

  const [currentEvent, setCurrentEvent] = useState<GameEvent | null>(null);
  const [selectedCell, setSelectedCell] = useState<{x: number, y: number} | null>(null);
  const [scanRange] = useState(2);
  const [gameLog, setGameLog] = useState<string[]>(['Starting from Moon Base']);
  
  const canvasRef = useRef<HTMLCanvasElement>(null);

  // Initialize grid cells
  const [gridCells] = useState<GridCell[]>(() => {
    const cells: GridCell[] = [];
    // Add specific game locations
    cells.push({ x: 1, y: 4, type: 'station', name: 'Moon Base', faction: 'earth' });
    cells.push({ x: 5, y: 3, type: 'asteroid', name: 'Ceres Rock', faction: 'pirates', threat: 3 });
    cells.push({ x: 8, y: 5, type: 'debris', name: 'Old Ship', loot: ['fuel', 'weapons'] });
    cells.push({ x: 11, y: 4, type: 'planet', name: 'Charon Base', faction: 'neutral' });
    cells.push({ x: 3, y: 1, type: 'station', name: 'Fuel Stop', faction: 'neutral', fuel: 45 });
    cells.push({ x: 7, y: 2, type: 'pirate', name: 'Danger Zone', faction: 'pirates', threat: 4 });
    cells.push({ x: 4, y: 6, type: 'hazard', name: 'Radiation' });
    
    // Add some random asteroids
    for (let i = 0; i < 20; i++) {
      const x = Math.floor(Math.random() * 15) + 1;
      const y = Math.floor(Math.random() * 10) + 1;
      if (!cells.find(cell => cell.x === x && cell.y === y)) {
        cells.push({ x, y, type: 'asteroid', name: 'Rock' });
      }
    }
    
    return cells;
  });

  useEffect(() => {
    const scanInterval = setInterval(() => {
      setScanLines(prev => (prev + 1) % 100);
    }, 50);
    return () => clearInterval(scanInterval);
  }, []);

  useEffect(() => {
    initializeImages();
  }, []);

  // Draw grid with game objects
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    
    const ctx = canvas.getContext('2d');
    if (!ctx) return;
    
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
    
    ctx.fillStyle = '#000000';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    const cellSize = 60 / gridScale;
    const originX = 100 + viewOffset.x * cellSize;
    const originY = canvas.height - 100 + viewOffset.y * cellSize;
    
    // Draw grid lines
    ctx.strokeStyle = '#00ff0020';
    ctx.lineWidth = 0.5;
    
    // Vertical lines
    const startX = Math.max(0, Math.ceil(-originX / cellSize));
    for (let i = startX; i * cellSize + originX < canvas.width; i++) {
      const x = originX + i * cellSize;
      if (x >= 0 && x <= canvas.width) {
        ctx.beginPath();
        ctx.moveTo(x, 0);
        ctx.lineTo(x, Math.min(canvas.height, originY));
        ctx.stroke();
      }
    }
    
    // Horizontal lines
    const startY = Math.max(0, Math.ceil((originY - canvas.height) / cellSize));
    for (let i = startY; originY - i * cellSize >= 0; i++) {
      const y = originY - i * cellSize;
      if (y >= 0 && y <= canvas.height) {
        ctx.beginPath();
        ctx.moveTo(Math.max(0, originX), y);
        ctx.lineTo(canvas.width, y);
        ctx.stroke();
      }
    }
    
    // Draw axes
    ctx.strokeStyle = '#00ff0080';
    ctx.lineWidth = 2;

    ctx.fillStyle = '#00ff0080';
    ctx.font = '10px monospace';

    // X-axis labels - only for visible positive values
    const startLabelX = Math.max(0, Math.ceil(-originX / (cellSize * 5)));
    for (let i = startLabelX; i * cellSize * 5 + originX < canvas.width; i++) {
    const x = originX + i * cellSize * 5;
    const worldX = Math.round(i * 5 * gridScale);
    if (x >= 0 && worldX >= 0 && originY >= 0 && originY <= canvas.height) {
        ctx.fillText(worldX.toString(), x + 2, Math.min(originY + 15, canvas.height - 5));
    }
    }

    // Y-axis labels - only for visible positive values
    const startLabelY = Math.max(0, Math.ceil((originY - canvas.height) / (cellSize * 5)));
    for (let i = startLabelY; originY - i * cellSize * 5 >= 0; i++) {
    const y = originY - i * cellSize * 5;
    const worldY = Math.round(i * 5 * gridScale);
    if (y >= 0 && y <= canvas.height && worldY >= 0 && originX >= 0) {
        ctx.fillText(worldY.toString(), Math.max(originX - 25, 5), y + 3);
    }
    }

    // Draw "X" and "Y" axis labels - only if axes are visible
    ctx.font = 'bold 14px monospace';
    ctx.fillStyle = '#00ff00';
    if (originY >= 0 && originY <= canvas.height) {
    ctx.fillText('X', canvas.width - 30, Math.min(originY - 10, canvas.height - 20));
    }
    if (originX >= 0 && originX <= canvas.width) {
    ctx.fillText('Y', Math.max(originX + 10, 10), 20);
}
    
    if (originY >= 0 && originY <= canvas.height) {
      ctx.beginPath();
      ctx.moveTo(Math.max(0, originX), originY);
      ctx.lineTo(canvas.width, originY);
      ctx.stroke();
    }
    
    if (originX >= 0 && originX <= canvas.width) {
      ctx.beginPath();
      ctx.moveTo(originX, Math.min(canvas.height, originY));
      ctx.lineTo(originX, 0);
      ctx.stroke();
    }
    

    // Draw player ship
    const shipX = originX + playerShip.x * cellSize / gridScale;
    const shipY = originY - playerShip.y * cellSize / gridScale;

    const lunarX = originX + lunar.x * cellSize / gridScale;
    const lunarY = originY - lunar.y * cellSize / gridScale;

    if (shipX >= -15 && shipY >= -15 && shipX <= canvas.width + 15 && shipY <= canvas.height + 15) {
    drawShip(ctx, shipX, shipY);
    }

      // Calculate scaled lunar size
    const scaledLunarSize = 240 / gridScale; // This makes it zoom with the grid
    const lunarHalfSize = scaledLunarSize / 2;

    // if (lunarX >= -lunarHalfSize && lunarY >= -lunarHalfSize && 
    //     lunarX <= canvas.width + lunarHalfSize && lunarY <= canvas.height + lunarHalfSize) {
    //   drawLunar(ctx, lunarX, lunarY, scaledLunarSize); // Pass the scaled size
    // }

        celestialBodies.forEach(body => {
          const bodyX = originX + body.x * cellSize / gridScale;
          const bodyY = originY - body.y * cellSize / gridScale;
          const scaledSize = body.baseSize / gridScale;
          const halfSize = scaledSize / 2;
          
          // Visibility check with buffer
          if (bodyX >= -halfSize && bodyY >= -halfSize && 
              bodyX <= canvas.width + halfSize && bodyY <= canvas.height + halfSize) {
            drawCelestialBody(ctx, bodyX, bodyY, body.imageName, scaledSize, body.color);
          }
        });
        
    // Draw target
    if (targetPosition) {
      const targetX = originX + targetPosition.x * cellSize / gridScale;
      const targetY = originY - targetPosition.y * cellSize / gridScale;
      
      if (targetX >= -10 && targetY >= -10 && targetX <= canvas.width + 10 && targetY <= canvas.height + 10) {
        ctx.strokeStyle = '#ffff00';
        ctx.lineWidth = 2;
        ctx.beginPath();
        ctx.arc(targetX, targetY, 6, 0, Math.PI * 2);
        ctx.stroke();
        
        ctx.strokeStyle = '#ffff0040';
        ctx.lineWidth = 1;
        ctx.setLineDash([5, 5]);
        ctx.beginPath();
        ctx.moveTo(shipX, shipY);
        ctx.lineTo(targetX, targetY);
        ctx.stroke();
        ctx.setLineDash([]);
      }
    }
    
  }, [playerShip, viewOffset, gridScale, targetPosition, gridCells,celestialBodies]);

  // Game helper functions
  const getCell = (x: number, y: number): GridCell | undefined => {
    return gridCells.find(cell => cell.x === x && cell.y === y);
  };

  const getDistance = (x1: number, y1: number, x2: number, y2: number): number => {
    return Math.abs(x1 - x2) + Math.abs(y1 - y2);
  };



  const canMoveTo = (x: number, y: number): boolean => {
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
    }
  };

  const addToLog = (message: string) => {
    setGameLog(prev => [...prev.slice(-4), message]);
  };

  const isInScanRange = (x: number, y: number): boolean => {
    return getDistance(playerShip.x, playerShip.y, x, y) <= scanRange;
  };

  // Canvas interaction handlers
  const handleCanvasClick = (e: React.MouseEvent<HTMLCanvasElement>) => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    
    const rect = canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    
    const cellSize = 60 / gridScale;
    const originX = 100 + viewOffset.x * cellSize;
    const originY = canvas.height - 100 + viewOffset.y * cellSize;
    
    const worldX = Math.max(0, Math.round((x - originX) * gridScale / cellSize));
    const worldY = Math.max(0, Math.round((originY - y) * gridScale / cellSize));
    
    setSelectedCell({ x: worldX, y: worldY });
    
    // If adjacent to player, move there
    if (canMoveTo(worldX, worldY)) {
      moveShip(worldX, worldY);
    } else {
      setTargetPosition({ x: worldX, y: worldY, z: 0 });
    }
  };

  const handleMouseDown = (e: React.MouseEvent) => {
    if (e.button === 0) {
      setIsDragging(true);
      setDragStart({ x: e.clientX, y: e.clientY });
    }
  };

  const handleMouseMove = (e: React.MouseEvent) => {
    if (!isDragging) return;
    
    const dx = (e.clientX - dragStart.x) / 60;
    const dy = (e.clientY - dragStart.y) / 60;
    
    setViewOffset(prev => ({
      x: prev.x + dx,
      y: prev.y + dy
    }));
    
    setDragStart({ x: e.clientX, y: e.clientY });
  };

  const handleMouseUp = () => {
    setIsDragging(false);
  };

  const handleWheel = (e: React.WheelEvent) => {
    e.preventDefault();
    const delta = e.deltaY > 0 ? 1.1 : 0.9;
    setGridScale(prev => Math.max(0.1, Math.min(10, prev * delta)));
  };

  const toggleMenu = (menu: MenuPanel) => {
    setActiveMenu(activeMenu === menu ? null : menu);
  };

  let isHoveringShip = false;

// Check if mouse is over the ship
const isMouseOverShip = (mouseX, mouseY, shipCanvasX, shipCanvasY, shipSize = 24) => {
  const distance = Math.sqrt(
    Math.pow(mouseX - shipCanvasX, 2) + 
    Math.pow(mouseY - shipCanvasY, 2)
  );
  return distance <= shipSize / 2;
};

// Mouse move handler for cursor change
const handleShipMouseMove = (e) => {
  const canvas = canvasRef.current;
  if (!canvas) return;
  
  const rect = canvas.getBoundingClientRect();
  const mouseX = e.clientX - rect.left;
  const mouseY = e.clientY - rect.top;
  
  // Calculate ship position (same as your drawing code)
  const cellSize = 60 / gridScale;
  const originX = 100 + viewOffset.x * cellSize;
  const originY = canvas.height - 100 + viewOffset.y * cellSize;
  const shipX = originX + playerShip.x * cellSize / gridScale;
  const shipY = originY - playerShip.y * cellSize / gridScale;
  
  const wasHovering = isHoveringShip;
  isHoveringShip = isMouseOverShip(mouseX, mouseY, shipX, shipY);
  console.log(isHoveringShip)
  
  // Change cursor
  if (isHoveringShip !== wasHovering) {
    canvas.style.cursor = isHoveringShip ? 'pointer' : (isDragging ? 'move' : 'crosshair');
  }
};

// Click handler for ship modals
const handleShipClick = (e) => {

  const canvas = canvasRef.current;

  const rect = canvas.getBoundingClientRect();
  const mouseX = e.clientX - rect.left;
  const mouseY = e.clientY - rect.top;
  const cellSize = 60 / gridScale;
  const originX = 100 + viewOffset.x * cellSize;
  const originY = canvas.height - 100 + viewOffset.y * cellSize;
  const shipX = originX + playerShip.x * cellSize / gridScale;
  const shipY = originY - playerShip.y * cellSize / gridScale;
  
  const wasHovering = isHoveringShip;
  isHoveringShip = isMouseOverShip(mouseX, mouseY, shipX, shipY);
    

 
  if (!isHoveringShip) return false; // Not clicking ship
  
  // Ship Status Modal
  setCurrentEvent({
    type: 'communication',
    title: 'Ship Computer',
    description: `Ship systems operational. Hull integrity at ${playerShip.hull}%.`,
    options: [
      {
        text: 'View Status',
        action: () => {
          setCurrentEvent(null);
          setActiveMenu('ship');
        }
      },
      {
        text: 'Ship Log',
        action: () => {
          setCurrentEvent(null);
          setActiveMenu('log');
        }
      },
      {
        text: 'Close',
        action: () => setCurrentEvent(null)
      }
    ]
  });
  
  // Or directly open a menu:
  // setActiveMenu('ship');
  
  // Or create a custom ship modal:
  // setCurrentEvent({
  //   type: 'encounter',
  //   title: 'Ship Actions',
  //   description: 'What would you like to do?',
  //   options: [
  //     {
  //       text: 'Repair Hull',
  //       action: () => {
  //         if (playerShip.supplies >= 3) {
  //           setPlayerShip(prev => ({
  //             ...prev,
  //             hull: Math.min(prev.hull + 20, 100),
  //             supplies: prev.supplies - 3
  //           }));
  //           addToLog('Hull repaired +20%');
  //         } else {
  //           addToLog('Not enough supplies for repairs');
  //         }
  //         setCurrentEvent(null);
  //       },
  //       cost: { supplies: 3 }
  //     },
  //     {
  //       text: 'Rest (Restore 10 fuel)',
  //       action: () => {
  //         setPlayerShip(prev => ({
  //           ...prev,
  //           fuel: Math.min(prev.fuel + 10, prev.maxFuel)
  //         }));
  //         addToLog('Rested - fuel restored');
  //         setCurrentEvent(null);
  //       }
  //     },
  //     {
  //       text: 'Cancel',
  //       action: () => setCurrentEvent(null)
  //     }
  //   ]
  // });
  
  e.stopPropagation(); // Prevent canvas click
  return true; // Ship was clicked
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
    <div className="fixed top-20 left-32 w-80 bg-black/95 border-2 border-green-500 p-4 rounded-lg shadow-lg shadow-green-500/20 z-40">
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
  <div className="h-screen space-background bg-black text-green-400 font-mono relative overflow-hidden">
    {/* Scan lines effect */}
    <div className="absolute inset-0 pointer-events-none opacity-10">
      <div className="absolute inset-0 bg-gradient-to-b from-transparent via-green-500 to-transparent h-4"
        style={{ transform: `translateY(${scanLines * 10}px)` }}/>
    </div>

    {/* Main grid canvas - full screen */}
    <canvas
      ref={canvasRef}
      className="absolute inset-0 cursor-crosshair"
      onClick={(e) => {
        if (!handleShipClick(e)) {
            handleCanvasClick(e); // Only run if ship wasn't clicked
        }
        }}
      onMouseDown={handleMouseDown}
      onMouseMove={(e) => {
        handleShipMouseMove(e);
        handleMouseMove(e); 
        }}
      onMouseUp={handleMouseUp}
      onMouseLeave={handleMouseUp}
      onWheel={handleWheel}
      style={{ cursor: isDragging ? 'move' : 'crosshair' }}
    />

    {/* Top HUD - Game title and basic info */}
    <div className="fixed top-0 left-0 right-0 z-30 p-3 bg-black/90 border-b border-green-500">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-xl font-bold text-green-400 tracking-widest">CHARON EXPEDITION</h1>
          <div className="text-xs text-green-600">Grid Navigation System</div>
        </div>
        <div className="text-right text-xs text-green-600">
          <div>Position: [{playerShip.x}, {playerShip.y}] | Scale: {gridScale.toFixed(1)}x</div>
          <div>Time: {String(new Date().getHours()).padStart(2, '0')}:{String(new Date().getMinutes()).padStart(2, '0')}</div>
        </div>
      </div>
    </div>

    {/* Left Side Menu - Game controls */}
    <div className="fixed top-1/2 left-4 -translate-y-1/2 w-20 rounded-3xl bg-black/90 border-2 border-green-400 shadow-[0_0_25px_rgba(74,222,128,0.6)] flex flex-col items-center py-6 space-y-6 z-50">
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

    {/* Top Right - Quick Status */}
    <div className="fixed top-16 right-4 z-40 flex gap-4 bg-black/90 border border-green-500 rounded-lg p-3">
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

    {/* Bottom Right - Grid Controls */}
    <div className="fixed bottom-4 right-4 z-40 space-y-2">
      <button
        onClick={() => setShowCoordinateInput(true)}
        className="block w-full px-4 py-2 border border-green-500 text-green-400 hover:bg-green-900/30 rounded text-sm bg-black/90"
      >
        Jump to Coords
      </button>
      {targetPosition && (
        <button
          onClick={() => {
            setPlayerShip(prev => ({ ...prev, x: targetPosition.x, y: targetPosition.y }));
            setTargetPosition(null);
            addToLog(`Jumped to [${targetPosition.x},${targetPosition.y}]`);
          }}
          className="block w-full px-4 py-2 border border-yellow-500 text-yellow-400 hover:bg-yellow-900/30 rounded text-sm animate-pulse bg-black/90"
        >
          Move to Target
        </button>
      )}
      <button
        onClick={() => {
          setViewOffset({ x: 0, y: 0 });
          setTargetPosition(null);
        }}
        className="block w-full px-4 py-2 border border-green-500 text-green-400 hover:bg-green-900/30 rounded text-sm bg-black/90"
      >
        Reset View
      </button>
    </div>

    {/* Bottom Left - Grid Info */}
    <div className="fixed bottom-4 left-4 z-40 p-3 bg-black/90 border border-green-500 rounded-lg max-w-xs">
      <h3 className="text-green-400 font-bold mb-2 text-sm">Navigation</h3>
      <div className="text-xs text-green-600 space-y-1">
        <div>• Click adjacent cell to move (costs 5 fuel)</div>
        <div>• Click distant cell to set target</div>
        <div>• Drag to pan view</div>
        <div>• Scroll to zoom</div>
        <div>• Green circle = Your ship</div>
        <div>• Yellow circle = Target</div>
      </div>
      <div className="mt-3">
        <div className="text-xs text-green-600 mb-1">Zoom: {gridScale.toFixed(1)}x</div>
        <input
          type="range"
          min="0.1"
          max="5"
          step="0.1"
          value={gridScale}
          onChange={(e) => setGridScale(parseFloat(e.target.value))}
          className="w-full h-2 bg-gray-900 rounded-lg appearance-none cursor-pointer"
        />
      </div>
      {targetPosition && (
        <div className="mt-2 text-xs text-yellow-400">
          Target: [{targetPosition.x},{targetPosition.y}]
        </div>
      )}
    </div>

    {/* Menu Panel */}
    {renderMenuPanel()}

    {/* Event Modal */}
    {currentEvent && (
      <div className="fixed inset-0 bg-black/75 flex items-center justify-center z-50">
        <div className="bg-black border-2 border-green-400 p-6 max-w-md mx-4 shadow-lg shadow-green-400/20 rounded-3xl">
          <h3 className="text-xl font-bold text-green-400 mb-4">{currentEvent.title}</h3>
          <p className="text-green-300 mb-6">{currentEvent.description}</p>
          <div className="space-y-3">
            {currentEvent.options.map((option, index) => (
              <button
                key={index}
                onClick={option.action}
                className="w-full p-3 border border-green-600 text-left hover:border-green-400 hover:bg-green-900/30 transition-all rounded-2xl"
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

    {/* Coordinate Input Modal */}
    {showCoordinateInput && (
      <div className="fixed inset-0 bg-black/75 flex items-center justify-center z-50">
        <div className="bg-black border-2 border-green-400 p-6 rounded-lg">
          <h3 className="text-xl font-bold text-green-400 mb-4">Jump to Coordinates</h3>
          <div className="text-xs text-green-600 mb-3">Enter positive coordinates (≥ 0)</div>
          <div className="space-y-3">
            <input
              type="number"
              placeholder="X coordinate"
              min="0"
              value={inputCoords.x}
              onChange={(e) => setInputCoords(prev => ({ ...prev, x: e.target.value }))}
              className="w-full px-3 py-2 bg-black border border-green-500 text-green-400 rounded focus:outline-none focus:border-green-400"
            />
            <input
              type="number"
              placeholder="Y coordinate"
              min="0"
              value={inputCoords.y}
              onChange={(e) => setInputCoords(prev => ({ ...prev, y: e.target.value }))}
              className="w-full px-3 py-2 bg-black border border-green-500 text-green-400 rounded focus:outline-none focus:border-green-400"
            />
          </div>
          <div className="mt-4 flex space-x-3">
            <button
              onClick={() => {
                const x = Math.max(0, parseFloat(inputCoords.x) || 0);
                const y = Math.max(0, parseFloat(inputCoords.y) || 0);
                setPlayerShip(prev => ({ ...prev, x, y }));
                setShowCoordinateInput(false);
                setInputCoords({ x: '', y: '', z: '' });
                addToLog(`Jumped to [${x},${y}]`);
              }}
              className="flex-1 px-4 py-2 border border-green-400 text-black bg-green-400 hover:bg-green-500 rounded"
            >
              Jump
            </button>
            <button
              onClick={() => setShowCoordinateInput(false)}
              className="flex-1 px-4 py-2 border border-green-600 text-green-400 hover:bg-green-900/30 rounded"
            >
              Cancel
            </button>
          </div>
        </div>
      </div>
    )}
  </div>
);
}
export default CharonUnifiedGame; 