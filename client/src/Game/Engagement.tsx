import React, { useState, useEffect, useRef } from 'react';
import { 
  Radio, 
  Zap, 
  Shield, 
  Flame, 
  Target, 
  DollarSign, 
  Users, 
  AlertTriangle,
  Skull,
  HandMetal,
  MessageSquare,
  ArrowRight,
  X
} from 'lucide-react';

// Action definitions with icons and descriptions
const playerActions = {
  Hail: { 
    icon: Radio, 
    color: 'text-blue-400', 
    desc: 'Send a friendly greeting',
    outcomes: ['Open communication', 'Show peaceful intent', 'Gather information']
  },
  Comply: { 
    icon: HandMetal, 
    color: 'text-yellow-400', 
    desc: 'Submit to their demands',
    outcomes: ['Avoid conflict', 'Lose cargo/credits', 'Safe passage likely']
  },
  Negotiate: { 
    icon: MessageSquare, 
    color: 'text-green-400', 
    desc: 'Try to bargain',
    outcomes: ['Reduce losses', 'Find compromise', 'Buy time']
  },
  PayBribe: { 
    icon: DollarSign, 
    color: 'text-yellow-400', 
    desc: 'Offer money to leave',
    outcomes: ['Lose credits', 'Peaceful resolution', 'Quick exit']
  },
  Threaten: { 
    icon: AlertTriangle, 
    color: 'text-orange-400', 
    desc: 'Show force and intimidate',
    outcomes: ['Scare them off', 'Escalate to combat', 'Show strength']
  },
  OpenFire: { 
    icon: Target, 
    color: 'text-red-400', 
    desc: 'Attack immediately',
    outcomes: ['First strike advantage', 'Enter combat', 'No turning back']
  },
  ActivateShields: { 
    icon: Shield, 
    color: 'text-cyan-400', 
    desc: 'Raise defensive systems',
    outcomes: ['Increase survival', 'Show readiness', 'Defensive posture']
  },
  Burn: { 
    icon: Flame, 
    color: 'text-orange-400', 
    desc: 'Full throttle escape',
    outcomes: ['Use fuel', 'Might escape', 'Risk being shot']
  },
  ActivatePDCs: { 
    icon: Zap, 
    color: 'text-purple-400', 
    desc: 'Point defense systems online',
    outcomes: ['Counter missiles', 'Show armed status', 'Defensive measure']
  },
  LaunchTorpedoes: { 
    icon: Target, 
    color: 'text-red-600', 
    desc: 'Fire heavy weapons',
    outcomes: ['Major damage', 'Enter full combat', 'High fuel cost']
  },
  SurrenderCargo: { 
    icon: Users, 
    color: 'text-gray-400', 
    desc: 'Give up your goods',
    outcomes: ['Lose cargo', 'Preserve ship', 'Avoid casualties']
  },
  SurrenderShip: { 
    icon: Skull, 
    color: 'text-gray-600', 
    desc: 'Total capitulation',
    outcomes: ['Game over?', 'Become prisoner', 'Last resort']
  }
};

const npcActionDescriptions = {
  Hail: { text: 'is attempting to make contact', color: 'text-blue-400', threat: 'low' },
  Demand: { text: 'is making demands', color: 'text-yellow-400', threat: 'medium' },
  Threaten: { text: 'is showing weapons systems', color: 'text-orange-400', threat: 'high' },
  OpenFire: { text: 'has opened fire!', color: 'text-red-600', threat: 'critical' },
  BoardingAction: { text: 'is attempting to board!', color: 'text-red-400', threat: 'critical' },
  Negotiate: { text: 'is willing to negotiate', color: 'text-green-400', threat: 'low' },
  Rob: { text: 'is demanding cargo', color: 'text-yellow-600', threat: 'medium' }
};

const EngagementScreen = () => {
  const [npcAction, setNpcAction] = useState('Threaten');
  const [selectedAction, setSelectedAction] = useState(null);
  const [engagementLog, setEngagementLog] = useState([
    'Pirate vessel detected at 5000km',
    'They are changing course to intercept',
    'Incoming transmission...'
  ]);
  const canvasRef = useRef(null);

  const npcInfo = npcActionDescriptions[npcAction];
  const threatColors = {
    low: 'border-green-500',
    medium: 'border-yellow-500',
    high: 'border-orange-500',
    critical: 'border-red-500'
  };

  // Canvas drawing
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    
    const ctx = canvas.getContext('2d');
    if (!ctx) return;
    
    canvas.width = canvas.offsetWidth;
    canvas.height = canvas.offsetHeight;
    
    // Clear canvas
    ctx.fillStyle = '#000000';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    // Draw starfield
    ctx.fillStyle = '#ffffff';
    for (let i = 0; i < 100; i++) {
      const x = Math.random() * canvas.width;
      const y = Math.random() * canvas.height;
      const size = Math.random() * 2;
      ctx.fillRect(x, y, size, size);
    }
    
    // Draw player ship (left side)
    const playerX = canvas.width * 0.3;
    const playerY = canvas.height * 0.5;
    
    // Simple ship representation
    ctx.strokeStyle = '#00ff00';
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.arc(playerX, playerY, 20, 0, Math.PI * 2);
    ctx.stroke();
    
    ctx.strokeStyle = '#00ff00';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(playerX - 15, playerY);
    ctx.lineTo(playerX + 15, playerY);
    ctx.moveTo(playerX, playerY - 15);
    ctx.lineTo(playerX, playerY + 15);
    ctx.stroke();
    
    ctx.fillStyle = '#00ff00';
    ctx.font = '12px monospace';
    ctx.fillText('YOUR SHIP', playerX - 30, playerY + 40);
    
    // Draw enemy ship (right side)
    const enemyX = canvas.width * 0.7;
    const enemyY = canvas.height * 0.5;
    
    ctx.strokeStyle = '#ff0000';
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.arc(enemyX, enemyY, 20, 0, Math.PI * 2);
    ctx.stroke();
    
    ctx.strokeStyle = '#ff0000';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(enemyX - 15, enemyY);
    ctx.lineTo(enemyX + 15, enemyY);
    ctx.moveTo(enemyX, enemyY - 15);
    ctx.lineTo(enemyX, enemyY + 15);
    ctx.stroke();
    
    ctx.fillStyle = '#ff0000';
    ctx.fillText('ENEMY', enemyX - 20, enemyY + 40);
    
    // Draw distance line
    ctx.strokeStyle = '#ffffff40';
    ctx.lineWidth = 1;
    ctx.setLineDash([5, 5]);
    ctx.beginPath();
    ctx.moveTo(playerX, playerY);
    ctx.lineTo(enemyX, enemyY);
    ctx.stroke();
    ctx.setLineDash([]);
    
    // Distance label
    ctx.fillStyle = '#ffffff80';
    ctx.font = '14px monospace';
    const midX = (playerX + enemyX) / 2;
    const midY = (playerY + enemyY) / 2;
    ctx.fillText('2.3 km', midX - 20, midY - 10);
    
  }, [npcAction, selectedAction]);

  const handleActionClick = (actionName) => {
    setSelectedAction(actionName);
  };

  const confirmAction = () => {
    setEngagementLog(prev => [
      ...prev, 
      `You chose: ${selectedAction}`,
      `Outcome: ${playerActions[selectedAction].outcomes[0]}`
    ]);
    setSelectedAction(null);
  };

  // Group actions by position
  const topActions = ['Hail', 'Negotiate', 'Threaten'];
  const rightActions = ['OpenFire', 'ActivatePDCs', 'LaunchTorpedoes'];
  const bottomActions = ['ActivateShields', 'Burn'];
  const leftActions = ['Comply', 'PayBribe', 'SurrenderCargo'];

  const ActionButton = ({ actionName, compact = false }) => {
    const action = playerActions[actionName];
    const Icon = action.icon;
    const isSelected = selectedAction === actionName;

    return (
      <button
        onClick={() => handleActionClick(actionName)}
        className={`
          relative p-3 rounded-lg border-2 transition-all
          ${isSelected 
            ? 'border-green-400 bg-green-900/60 shadow-[0_0_20px_rgba(74,222,128,0.5)]' 
            : 'border-green-600/40 hover:border-green-400 hover:bg-green-900/20'
          }
          text-left group
        `}
      >
        <div className={`flex ${compact ? 'flex-col' : 'flex-row'} items-center gap-2`}>
          <Icon className={`w-5 h-5 ${action.color} flex-shrink-0`} />
          <div className="flex-1 min-w-0">
            <div className={`font-bold ${action.color} text-xs`}>{actionName}</div>
            {!compact && <div className="text-xs text-green-600 mt-1">{action.desc}</div>}
          </div>
        </div>
      </button>
    );
  };

  return (
    <div className="min-h-screen bg-black text-green-400 font-mono p-4">
      {/* Top Bar - NPC Action & Threat */}
      <div className={`border-2 ${threatColors[npcInfo.threat]} bg-black/95 rounded-lg p-4 mb-4 shadow-lg`}>
        <div className="flex items-center justify-between">
          <div className="flex-1">
            <div className="text-sm text-gray-400">ENEMY ACTION:</div>
            <div className="text-lg">
              <span className="text-red-400 font-bold">Pirate Skiff "Dark Runner"</span>
              <span className="text-gray-400"> {npcInfo.text}</span>
            </div>
            <div className="mt-2 text-sm text-yellow-400 italic">
              "Hand over your cargo or we'll take it from your wreckage!"
            </div>
          </div>
          <div className="text-right ml-4">
            <div className={`text-xl font-bold ${npcInfo.color}`}>
              {npcInfo.threat.toUpperCase()}
            </div>
            <div className="text-xs text-gray-400">Distance: 2.3km</div>
          </div>
        </div>
        
        {/* Test Buttons */}
        <div className="mt-3 flex gap-2 flex-wrap">
          <span className="text-xs text-gray-600">Test NPC Actions:</span>
          <button onClick={() => setNpcAction('Hail')} className="px-2 py-1 text-xs border border-blue-500 rounded hover:bg-blue-900/20">Hail</button>
          <button onClick={() => setNpcAction('Demand')} className="px-2 py-1 text-xs border border-yellow-500 rounded hover:bg-yellow-900/20">Demand</button>
          <button onClick={() => setNpcAction('Threaten')} className="px-2 py-1 text-xs border border-orange-500 rounded hover:bg-orange-900/20">Threaten</button>
          <button onClick={() => setNpcAction('OpenFire')} className="px-2 py-1 text-xs border border-red-500 rounded hover:bg-red-900/20">OpenFire</button>
        </div>
      </div>

      {/* Main Layout - Actions Around Canvas */}
      <div className="grid grid-cols-12 gap-4">
        {/* Left Actions */}
        <div className="col-span-2 space-y-3">
          <div className="text-xs text-yellow-400 font-bold mb-2">SUBMIT</div>
          {leftActions.map(action => (
            <ActionButton key={action} actionName={action} compact />
          ))}
        </div>

        {/* Center Column */}
        <div className="col-span-8 space-y-4">
          {/* Top Actions */}
          <div className="grid grid-cols-3 gap-3">
            <div className="col-span-3 text-xs text-blue-400 font-bold mb-1">COMMUNICATE</div>
            {topActions.map(action => (
              <ActionButton key={action} actionName={action} />
            ))}
          </div>

          {/* Canvas */}
          <div className="relative">
            <canvas
              ref={canvasRef}
              className="w-full h-96 border-4 border-green-600/40 rounded-lg bg-black"
            />
            
            {/* Canvas Overlay Info */}
            <div className="absolute top-4 left-4 bg-black/80 border border-green-600 rounded p-2 text-xs">
              <div className="text-green-400 font-bold mb-1">TACTICAL VIEW</div>
              <div className="text-gray-400">Range: 2.3km</div>
              <div className="text-gray-400">Angle: 045°</div>
            </div>

            {/* Ship Status Overlay */}
            <div className="absolute top-4 right-4 bg-black/80 border border-green-600 rounded p-2 text-xs">
              <div className="text-green-400 font-bold mb-1">STATUS</div>
              <div className="flex justify-between gap-3">
                <span className="text-gray-400">Hull:</span>
                <span className="text-red-400">82%</span>
              </div>
              <div className="flex justify-between gap-3">
                <span className="text-gray-400">Shields:</span>
                <span className="text-cyan-400">OFF</span>
              </div>
            </div>
          </div>

          {/* Bottom Actions */}
          <div className="grid grid-cols-2 gap-3">
            <div className="col-span-2 text-xs text-cyan-400 font-bold mb-1">DEFENSIVE</div>
            {bottomActions.map(action => (
              <ActionButton key={action} actionName={action} />
            ))}
          </div>
        </div>

        {/* Right Actions & Info */}
        <div className="col-span-2 space-y-3">
          <div className="text-xs text-red-400 font-bold mb-2">ATTACK</div>
          {rightActions.map(action => (
            <ActionButton key={action} actionName={action} compact />
          ))}

          {/* Engagement Log */}
          <div className="mt-6 bg-black/95 border-2 border-green-600/40 rounded-lg p-3">
            <div className="text-xs font-bold text-green-400 mb-2">LOG</div>
            <div className="space-y-1 max-h-48 overflow-y-auto">
              {engagementLog.slice(-8).map((log, idx) => (
                <div key={idx} className="text-xs text-green-600">
                  <span className="text-gray-600">[{String(idx).padStart(2, '0')}]</span> {log}
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Action Confirmation Modal */}
      {selectedAction && (
        <div className="fixed inset-0 bg-black/75 flex items-center justify-center z-50">
          <div className="bg-black border-4 border-green-400 rounded-lg p-6 max-w-md mx-4 shadow-[0_0_30px_rgba(74,222,128,0.5)]">
            <button
              onClick={() => setSelectedAction(null)}
              className="absolute top-2 right-2 text-gray-400 hover:text-red-400"
            >
              <X className="w-5 h-5" />
            </button>
            
            <h3 className="text-xl font-bold text-green-400 mb-4">CONFIRM ACTION</h3>
            
            <div className="space-y-4">
              <div className="text-2xl font-bold text-yellow-400">{selectedAction}</div>
              <div className="text-sm text-gray-400">{playerActions[selectedAction].desc}</div>
              
              <div className="border-t border-green-900 pt-4">
                <div className="text-xs text-gray-500 mb-2">POSSIBLE OUTCOMES:</div>
                {playerActions[selectedAction].outcomes.map((outcome, idx) => (
                  <div key={idx} className="flex items-start gap-2 text-sm text-green-400 mb-2">
                    <ArrowRight className="w-4 h-4 mt-0.5 flex-shrink-0" />
                    <span>{outcome}</span>
                  </div>
                ))}
              </div>

              <div className="flex gap-3 mt-6">
                <button
                  onClick={confirmAction}
                  className="flex-1 py-3 bg-green-600 hover:bg-green-500 text-black font-bold rounded-lg transition-all shadow-[0_0_20px_rgba(74,222,128,0.5)]"
                >
                  EXECUTE
                </button>
                <button
                  onClick={() => setSelectedAction(null)}
                  className="flex-1 py-3 border-2 border-red-600 text-red-400 hover:bg-red-900/30 font-bold rounded-lg transition-all"
                >
                  CANCEL
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default EngagementScreen;