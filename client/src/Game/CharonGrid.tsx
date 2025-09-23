import React, { useState, useEffect, useRef } from 'react';

interface Position {
  x: number;
  y: number;
  z: number;
}

const CharonGrid: React.FC = () => {
  const [position, setPosition] = useState<Position>({ x: 0, y: 0, z: 0 });
  const [targetPosition, setTargetPosition] = useState<Position | null>(null);
  const [viewOffset, setViewOffset] = useState({ x: 0, y: 0 });
  const [gridScale, setGridScale] = useState(1); // Units per grid cell
  const [scanLines, setScanLines] = useState(0);
  const [isDragging, setIsDragging] = useState(false);
  const [dragStart, setDragStart] = useState({ x: 0, y: 0 });
  const [showCoordinateInput, setShowCoordinateInput] = useState(false);
  const [inputCoords, setInputCoords] = useState({ x: '', y: '', z: '' });
  
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const scanInterval = setInterval(() => {
      setScanLines(prev => (prev + 1) % 100);
    }, 50);
    return () => clearInterval(scanInterval);
  }, []);

  // Draw grid
useEffect(() => {
  const canvas = canvasRef.current;
  if (!canvas) return;
  
  const ctx = canvas.getContext('2d');
  if (!ctx) return;
  
  // Set canvas size
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
  
  // Clear canvas
  ctx.fillStyle = '#000000';
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  
  // Calculate grid parameters
  const cellSize = 60 / gridScale;
  
  // Origin is at bottom-left for positive quadrant
  // We need to transform coordinates: canvas Y increases downward, but we want Y to increase upward
  const originX = 100 + viewOffset.x * cellSize; // Offset from left edge
  const originY = canvas.height - 100 + viewOffset.y * cellSize; // Offset from bottom edge
  
  // ALWAYS draw grid - remove the restrictive condition
  // We'll handle bounds checking within each drawing loop instead
  
  // Grid styling
  ctx.strokeStyle = '#00ff0020';
  ctx.lineWidth = 0.5;
  
  // Draw vertical lines (positive X only)
  // Start from the first positive grid line that's visible
  const startX = Math.max(0, Math.ceil(-originX / cellSize));
  for (let i = startX; i * cellSize + originX < canvas.width; i++) {
    const x = originX + i * cellSize;
    if (x >= 0 && x <= canvas.width) { // Only draw if line is within canvas
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x, Math.min(canvas.height, originY)); // Don't draw below origin
      ctx.stroke();
    }
  }
  
  // Draw horizontal lines (positive Y only)
  // Start from the first positive grid line that's visible
  const startY = Math.max(0, Math.ceil((originY - canvas.height) / cellSize));
  for (let i = startY; originY - i * cellSize >= 0; i++) {
    const y = originY - i * cellSize;
    if (y >= 0 && y <= canvas.height) { // Only draw if line is within canvas
      ctx.beginPath();
      ctx.moveTo(Math.max(0, originX), y); // Don't draw left of origin
      ctx.lineTo(canvas.width, y);
      ctx.stroke();
    }
  }
  
  // Draw major grid lines (every 10 units)
  ctx.strokeStyle = '#00ff0040';
  ctx.lineWidth = 1;
  
  // Major vertical lines
  const startMajorX = Math.max(0, Math.ceil(-originX / (cellSize * 10)));
  for (let i = startMajorX; i * cellSize * 10 + originX < canvas.width; i++) {
    const x = originX + i * cellSize * 10;
    if (x >= 0 && x <= canvas.width) {
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x, Math.min(canvas.height, originY));
      ctx.stroke();
    }
  }
  
  // Major horizontal lines
  const startMajorY = Math.max(0, Math.ceil((originY - canvas.height) / (cellSize * 10)));
  for (let i = startMajorY; originY - i * cellSize * 10 >= 0; i++) {
    const y = originY - i * cellSize * 10;
    if (y >= 0 && y <= canvas.height) {
      ctx.beginPath();
      ctx.moveTo(Math.max(0, originX), y);
      ctx.lineTo(canvas.width, y);
      ctx.stroke();
    }
  }
  
  // Draw X and Y axes
  ctx.strokeStyle = '#00ff0080';
  ctx.lineWidth = 2;
  
  // X-axis (horizontal, at Y=0) - only draw the positive portion
  if (originY >= 0 && originY <= canvas.height) {
    ctx.beginPath();
    ctx.moveTo(Math.max(0, originX), originY);
    ctx.lineTo(canvas.width, originY);
    ctx.stroke();
  }
  
  // Y-axis (vertical, at X=0) - only draw the positive portion
  if (originX >= 0 && originX <= canvas.width) {
    ctx.beginPath();
    ctx.moveTo(originX, Math.min(canvas.height, originY));
    ctx.lineTo(originX, 0);
    ctx.stroke();
  }
  
  // Draw coordinate labels
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
  
  // Draw current position marker
  const posX = originX + position.x * cellSize / gridScale;
  const posY = originY - position.y * cellSize / gridScale;
  
  if (posX >= -10 && posY >= -10 && posX <= canvas.width + 10 && posY <= canvas.height + 10) {
    ctx.strokeStyle = '#00ff00';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.arc(posX, posY, 10, 0, Math.PI * 2);
    ctx.stroke();
    
    // Draw crosshair at position
    ctx.strokeStyle = '#00ff00';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(posX - 15, posY);
    ctx.lineTo(posX + 15, posY);
    ctx.moveTo(posX, posY - 15);
    ctx.lineTo(posX, posY + 15);
    ctx.stroke();
  }
  
  // Draw target if exists
  if (targetPosition) {
    const targetX = originX + targetPosition.x * cellSize / gridScale;
    const targetY = originY - targetPosition.y * cellSize / gridScale;
    
    if (targetX >= -10 && targetY >= -10 && targetX <= canvas.width + 10 && targetY <= canvas.height + 10) {
      ctx.strokeStyle = '#ffff00';
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.arc(targetX, targetY, 8, 0, Math.PI * 2);
      ctx.stroke();
      
      // Draw line from position to target
      if (posX >= -15 && posY >= -15 && posX <= canvas.width + 15 && posY <= canvas.height + 15) {
        ctx.strokeStyle = '#ffff0040';
        ctx.lineWidth = 1;
        ctx.setLineDash([5, 5]);
        ctx.beginPath();
        ctx.moveTo(posX, posY);
        ctx.lineTo(targetX, targetY);
        ctx.stroke();
        ctx.setLineDash([]);
      }
    }
  }
  
}, [position, viewOffset, gridScale, targetPosition]);

  // Handle canvas click
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
    
    setTargetPosition({ x: worldX, y: worldY, z: position.z });
  };

  // Handle mouse drag for panning
  const handleMouseDown = (e: React.MouseEvent) => {
    if (e.button === 0) { // Left click
      setIsDragging(true);
      setDragStart({ x: e.clientX, y: e.clientY });
    }
  };

  const handleMouseMove = (e: React.MouseEvent) => {
    if (!isDragging) return;
    
    const dx = (e.clientX - dragStart.x) / 60;
    const dy = (e.clientY - dragStart.y) / 60; // Invert Y for proper panning
    
    setViewOffset(prev => ({
      x: prev.x + dx,
      y: prev.y + dy
    }));
    
    setDragStart({ x: e.clientX, y: e.clientY });
  };

  const handleMouseUp = () => {
    setIsDragging(false);
  };

  // Handle zoom
  const handleWheel = (e: React.WheelEvent) => {
    e.preventDefault();
    const delta = e.deltaY > 0 ? 1.1 : 0.9;
    setGridScale(prev => Math.max(0.1, Math.min(10, prev * delta)));
  };

  // Move to target
  const moveToTarget = () => {
    if (!targetPosition) return;
    setPosition(targetPosition);
    setTargetPosition(null);
  };

  // Jump to coordinates
  const jumpToCoordinates = () => {
    const x = Math.max(0, parseFloat(inputCoords.x) || 0);
    const y = Math.max(0, parseFloat(inputCoords.y) || 0);
    const z = Math.max(0, parseFloat(inputCoords.z) || 0);
    
    setPosition({ x, y, z });
    setShowCoordinateInput(false);
    setInputCoords({ x: '', y: '', z: '' });
  };

  const calculateDistance = (from: Position, to: Position): number => {
    const dx = to.x - from.x;
    const dy = to.y - from.y;
    const dz = to.z - from.z;
    return Math.sqrt(dx * dx + dy * dy + dz * dz);
  };

  return (
    <div className="min-h-screen bg-black text-green-400 font-mono relative overflow-hidden">
      {/* Scan lines effect */}
      <div className="absolute inset-0 pointer-events-none opacity-10">
        <div className="absolute inset-0 bg-gradient-to-b from-transparent via-green-500 to-transparent h-4"
          style={{ transform: `translateY(${scanLines * 10}px)` }}/>
      </div>

      {/* Canvas for grid */}
      <canvas
        ref={canvasRef}
        className="absolute inset-0 cursor-crosshair"
        onClick={handleCanvasClick}
        onMouseDown={handleMouseDown}
        onMouseMove={handleMouseMove}
        onMouseUp={handleMouseUp}
        onMouseLeave={handleMouseUp}
        onWheel={handleWheel}
        style={{ cursor: isDragging ? 'move' : 'crosshair' }}
      />

      {/* Top HUD */}
      <div className="absolute top-0 left-0 right-0 z-20 p-4 bg-black bg-opacity-80 border-b border-green-500">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-green-400 tracking-widest">CHARON GRID</h1>
            <div className="text-xs text-green-600 mt-1">Positive Quadrant Navigation</div>
          </div>
          <div className="text-right text-xs text-green-600">
            <div>Position: [{position.x.toFixed(1)}, {position.y.toFixed(1)}, {position.z.toFixed(1)}]</div>
            <div>Scale: {gridScale.toFixed(2)} units/grid</div>
            <div>View Offset: [{viewOffset.x.toFixed(1)}, {viewOffset.y.toFixed(1)}]</div>
          </div>
        </div>
      </div>

      {/* Bottom HUD */}
      <div className="absolute bottom-0 left-0 right-0 z-20 p-4 bg-black bg-opacity-80 border-t border-green-500">
        <div className="flex justify-between items-center">
          <div className="text-sm">
            {targetPosition && (
              <div className="text-yellow-400">
                Target: [{targetPosition.x}, {targetPosition.y}, {targetPosition.z}] 
                • Distance: {calculateDistance(position, targetPosition).toFixed(2)} units
              </div>
            )}
          </div>
          <div className="space-x-4">
            <button
              onClick={() => setShowCoordinateInput(true)}
              className="px-4 py-2 border border-green-500 text-green-400 hover:bg-green-900 hover:bg-opacity-30 rounded text-sm"
            >
              Jump to Coordinates
            </button>
            {targetPosition && (
              <button
                onClick={moveToTarget}
                className="px-4 py-2 border border-yellow-500 text-yellow-400 hover:bg-yellow-900 hover:bg-opacity-30 rounded text-sm animate-pulse"
              >
                Move to Target
              </button>
            )}
            <button
              onClick={() => {
                setViewOffset({ x: 0, y: 0 });
                setTargetPosition(null);
              }}
              className="px-4 py-2 border border-green-500 text-green-400 hover:bg-green-900 hover:bg-opacity-30 rounded text-sm"
            >
              Reset View
            </button>
            <button
              onClick={() => {
                setPosition({ x: 0, y: 0, z: 0 });
                setViewOffset({ x: 0, y: 0 });
                setTargetPosition(null);
              }}
              className="px-4 py-2 border border-green-500 text-green-400 hover:bg-green-900 hover:bg-opacity-30 rounded text-sm"
            >
              Origin
            </button>
          </div>
        </div>
      </div>

      {/* Left Panel - Controls */}
      <div className="absolute left-0 top-24 z-10 p-4 bg-black bg-opacity-80 border border-green-500 rounded-r-lg max-w-xs">
        <h3 className="text-green-400 font-bold mb-2">Controls</h3>
        <div className="text-xs text-green-600 space-y-1">
          <div>• Click to set target</div>
          <div>• Drag to pan</div>
          <div>• Scroll to zoom</div>
          <div>• Position: ○ (green)</div>
          <div>• Target: ○ (yellow)</div>
        </div>
        <div className="mt-4 space-y-2">
          <div>
            <label className="text-xs text-green-600">Grid Scale</label>
            <input
              type="range"
              min="0.1"
              max="10"
              step="0.1"
              value={gridScale}
              onChange={(e) => setGridScale(parseFloat(e.target.value))}
              className="w-full"
            />
          </div>
        </div>
        <div className="mt-4 text-xs text-green-600">
          <div>Quadrant: Positive Only</div>
          <div>X: 0 → ∞</div>
          <div>Y: 0 → ∞</div>
        </div>
      </div>

      {/* Coordinate Input Modal */}
      {showCoordinateInput && (
        <div className="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50">
          <div className="bg-black border-2 border-green-400 p-6 rounded-lg">
            <h3 className="text-xl font-bold text-green-400 mb-4">Jump to Coordinates</h3>
            <div className="text-xs text-green-600 mb-3">Positive values only (0 → ∞)</div>
            <div className="space-y-3">
              <input
                type="number"
                placeholder="X coordinate (≥ 0)"
                min="0"
                value={inputCoords.x}
                onChange={(e) => setInputCoords(prev => ({ ...prev, x: e.target.value }))}
                className="w-full px-3 py-2 bg-black border border-green-500 text-green-400 rounded focus:outline-none focus:border-green-400"
              />
              <input
                type="number"
                placeholder="Y coordinate (≥ 0)"
                min="0"
                value={inputCoords.y}
                onChange={(e) => setInputCoords(prev => ({ ...prev, y: e.target.value }))}
                className="w-full px-3 py-2 bg-black border border-green-500 text-green-400 rounded focus:outline-none focus:border-green-400"
              />
              <input
                type="number"
                placeholder="Z coordinate (≥ 0)"
                min="0"
                value={inputCoords.z}
                onChange={(e) => setInputCoords(prev => ({ ...prev, z: e.target.value }))}
                className="w-full px-3 py-2 bg-black border border-green-500 text-green-400 rounded focus:outline-none focus:border-green-400"
              />
            </div>
            <div className="mt-4 flex space-x-3">
              <button
                onClick={jumpToCoordinates}
                className="flex-1 px-4 py-2 border border-green-400 text-black bg-green-400 hover:bg-green-500 rounded"
              >
                Jump
              </button>
              <button
                onClick={() => setShowCoordinateInput(false)}
                className="flex-1 px-4 py-2 border border-green-600 text-green-400 hover:bg-green-900 hover:bg-opacity-30 rounded"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default CharonGrid;