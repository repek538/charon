import React, { useState } from 'react';
import { 
  Rocket, 
  Users, 
  Zap, 
  Shield, 
  Target, 
  Clock, 
  Satellite, 
  Settings, 
  Trophy,
  ChevronDown,
  ChevronRight
} from 'lucide-react';

const About = () => {
  const [expandedSection, setExpandedSection] = useState('overview');

  const sections = [
    {
      id: 'overview',
      title: 'GAME OVERVIEW',
      icon: Rocket,
      content: (
        <div className="space-y-4">
          <p className="text-green-500/80 font-mono text-sm leading-relaxed">
            Charon is a strategic space rescue simulation set in the distant reaches of our solar system. 
            Players command customizable vessels and crew to undertake high-stakes extraction missions 
            in the hostile environment around Pluto's moon, Charon.
          </p>
          <p className="text-green-500/80 font-mono text-sm leading-relaxed">
            You are a freelance rescue operator tasked with extracting scientists, recovering valuable 
            research data, and salvaging equipment from failing deep space stations. Time is your enemy 
            as life support systems fail and unknown dangers lurk in the darkness of the outer solar system.
          </p>
        </div>
      )
    },
    {
      id: 'ships',
      title: 'SHIP MANAGEMENT',
      icon: Shield,
      content: (
        <div className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="bg-transparent border border-green-500/30 rounded-lg p-4">
              <h4 className="text-green-500 font-mono font-bold mb-2 flex items-center">
                <Settings className="w-4 h-4 mr-2" />
                VESSEL CUSTOMIZATION
              </h4>
              <ul className="text-green-500/70 font-mono text-sm space-y-1">
                <li>• Command corvette-class ships</li>
                <li>• Modular system upgrades</li>
                <li>• Specialized configurations</li>
              </ul>
            </div>
            <div className="bg-transparent border border-green-500/30 rounded-lg p-4">
              <h4 className="text-green-500 font-mono font-bold mb-2 flex items-center">
                <Zap className="w-4 h-4 mr-2" />
                WEAPONS SYSTEMS
              </h4>
              <ul className="text-green-500/70 font-mono text-sm space-y-1">
                <li>• Point defense cannons (PDCs)</li>
                <li>• Torpedo bays</li>
                <li>• Optional railgun mounting</li>
              </ul>
            </div>
          </div>
          <div className="bg-transparent border border-green-500/30 rounded-lg p-4">
            <h4 className="text-green-500 font-mono font-bold mb-2 flex items-center">
              <Target className="w-4 h-4 mr-2" />
              RESOURCE MANAGEMENT
            </h4>
            <p className="text-green-500/70 font-mono text-sm">
              Balance fuel consumption, cargo capacity, and shield/hull integrity while navigating 
              through coordinate-based space sectors.
            </p>
          </div>
        </div>
      )
    },
    {
      id: 'crew',
      title: 'CREW SYSTEM',
      icon: Users,
      content: (
        <div className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
            {[
              { role: 'CAPTAIN', desc: 'Leadership and morale bonuses' },
              { role: 'PILOT', desc: 'Navigation and maneuvering expertise' },
              { role: 'ENGINEER', desc: 'Repairs and system optimization' },
              { role: 'GUNNER', desc: 'Weapons efficiency and accuracy' },
              { role: 'MEDIC', desc: 'Crew health and recovery' },
              { role: 'SCIENTIST', desc: 'Scanning and research capabilities' }
            ].map((crew, index) => (
              <div key={index} className="bg-transparent border border-green-500/30 rounded-lg p-3">
                <h5 className="text-green-500 font-mono font-bold text-sm mb-1">{crew.role}</h5>
                <p className="text-green-500/70 font-mono text-xs">{crew.desc}</p>
              </div>
            ))}
          </div>
          <div className="bg-transparent border border-green-500/30 rounded-lg p-4">
            <h4 className="text-green-500 font-mono font-bold mb-2">CREW ATTRIBUTES</h4>
            <div className="grid grid-cols-2 md:grid-cols-3 gap-4 text-green-500/70 font-mono text-sm">
              <div>
                <span className="text-green-500">Physical:</span>
                <div className="ml-2">Health, Stamina, Strength</div>
              </div>
              <div>
                <span className="text-green-500">Mental:</span>
                <div className="ml-2">Intelligence, Morale, Dexterity</div>
              </div>
              <div>
                <span className="text-green-500">Progression:</span>
                <div className="ml-2">Experience, Special Abilities</div>
              </div>
            </div>
          </div>
        </div>
      )
    },
    {
      id: 'missions',
      title: 'MISSION STRUCTURE',
      icon: Target,
      content: (
        <div className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="bg-transparent border border-green-500/30 rounded-lg p-4">
              <h4 className="text-green-500 font-mono font-bold mb-2">PRIMARY OBJECTIVES</h4>
              <ul className="text-green-500/70 font-mono text-sm space-y-1">
                <li>• Time-critical rescue operations</li>
                <li>• Personnel extraction</li>
                <li>• Emergency evacuations</li>
              </ul>
            </div>
            <div className="bg-transparent border border-green-500/30 rounded-lg p-4">
              <h4 className="text-green-500 font-mono font-bold mb-2">SECONDARY GOALS</h4>
              <ul className="text-green-500/70 font-mono text-sm space-y-1">
                <li>• Data recovery</li>
                <li>• Equipment salvage</li>
                <li>• Station investigation</li>
              </ul>
            </div>
          </div>
          <div className="bg-transparent border border-green-500/30 rounded-lg p-4">
            <h4 className="text-green-500 font-mono font-bold mb-2 flex items-center">
              <Clock className="w-4 h-4 mr-2" />
              ENVIRONMENTAL HAZARDS
            </h4>
            <div className="grid grid-cols-2 gap-4 text-green-500/70 font-mono text-sm">
              <ul className="space-y-1">
                <li>• Asteroid field navigation</li>
                <li>• Hostile encounters</li>
              </ul>
              <ul className="space-y-1">
                <li>• Structural instabilities</li>
                <li>• Limited fuel for return</li>
              </ul>
            </div>
          </div>
        </div>
      )
    },
    {
      id: 'gameplay',
      title: 'GAMEPLAY LOOP',
      icon: Clock,
      content: (
        <div className="space-y-4">
          <div className="space-y-3">
            {[
              { step: '01', title: 'PREPARATION PHASE', desc: 'Register/configure your ship, recruit specialized crew' },
              { step: '02', title: 'MISSION BRIEFING', desc: 'Review objectives, hazards, and rewards' },
              { step: '03', title: 'EXECUTION', desc: 'Navigate to target location, manage resources, complete objectives' },
              { step: '04', title: 'EXTRACTION', desc: 'Safely return with rescued personnel and salvage' }
            ].map((phase, index) => (
              <div key={index} className="bg-transparent border border-green-500/30 rounded-lg p-4 flex items-start space-x-4">
                <div className="bg-transparent border border-green-500/60 rounded-full w-12 h-12 flex items-center justify-center flex-shrink-0">
                  <span className="text-green-500 font-mono font-bold text-sm">{phase.step}</span>
                </div>
                <div>
                  <h4 className="text-green-500 font-mono font-bold mb-1">{phase.title}</h4>
                  <p className="text-green-500/70 font-mono text-sm">{phase.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      )
    },
    {
      id: 'progression',
      title: 'PROGRESSION SYSTEMS',
      icon: Trophy,
      content: (
        <div className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {[
              {
                title: 'ECONOMIC',
                desc: 'Earn credits for successful missions to upgrade ships and hire better crew',
                icon: Target
              },
              {
                title: 'REPUTATION',
                desc: 'Build faction standing for access to better contracts',
                icon: Trophy
              },
              {
                title: 'TECHNOLOGY',
                desc: 'Unlock advanced blueprints and ship modifications',
                icon: Settings
              },
              {
                title: 'EXPERIENCE',
                desc: 'Level up crew members to unlock new abilities',
                icon: Users
              }
            ].map((system, index) => (
              <div key={index} className="bg-transparent border border-green-500/30 rounded-lg p-4">
                <h4 className="text-green-500 font-mono font-bold mb-2 flex items-center">
                  <system.icon className="w-4 h-4 mr-2" />
                  {system.title}
                </h4>
                <p className="text-green-500/70 font-mono text-sm">{system.desc}</p>
              </div>
            ))}
          </div>
        </div>
      )
    },
    {
      id: 'technical',
      title: 'TECHNICAL IMPLEMENTATION',
      icon: Satellite,
      content: (
        <div className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="bg-transparent border border-green-500/30 rounded-lg p-4">
              <h4 className="text-green-500 font-mono font-bold mb-2">FRONTEND</h4>
              <ul className="text-green-500/70 font-mono text-sm space-y-1">
                <li>• React/TypeScript interface</li>
                <li>• Real-time game updates</li>
                <li>• Responsive design</li>
              </ul>
            </div>
            <div className="bg-transparent border border-green-500/30 rounded-lg p-4">
              <h4 className="text-green-500 font-mono font-bold mb-2">BLOCKCHAIN</h4>
              <ul className="text-green-500/70 font-mono text-sm space-y-1">
                <li>• Dojo engine for game logic</li>
                <li>• Starknet state management</li>
                <li>• On-chain asset ownership</li>
              </ul>
            </div>
          </div>
          <div className="bg-transparent border border-green-500/30 rounded-lg p-4">
            <h4 className="text-green-500 font-mono font-bold mb-2">FEATURES</h4>
            <ul className="text-green-500/70 font-mono text-sm space-y-1">
              <li>• Procedural mission generation for unlimited replayability</li>
              <li>• Persistent ship and crew progression</li>
              <li>• Decentralized ownership of vessels and equipment</li>
            </ul>
          </div>
        </div>
      )
    }
  ];

  const toggleSection = (sectionId) => {
    setExpandedSection(expandedSection === sectionId ? null : sectionId);
  };

  return (
    <div className="bg-black p-6 font-mono">
      {/* Header */}
      <div className="text-center mb-8 pb-6 border-b border-green-500/60">
        <div className="flex items-center justify-center mb-4">
          <Rocket className="w-12 h-12 text-green-500 mr-4" />
          <div>
            <h1 className="text-4xl font-bold text-green-500">CHARON</h1>
            <p className="text-green-500/80">DEEP SPACE RESCUE</p>
          </div>
          <Satellite className="w-12 h-12 text-green-500 ml-4" />
        </div>
        <p className="text-green-500/70 text-sm max-w-2xl mx-auto">
          Strategic space rescue simulation combining tactical planning, atmospheric storytelling, 
          and high-stakes decision-making in humanity's furthest frontier.
        </p>
      </div>

      {/* Sections */}
      <div className="space-y-4 max-w-6xl mx-auto">
        {sections.map((section) => (
          <div key={section.id} className="bg-transparent border border-green-500/60 rounded-lg overflow-hidden">
            <button
              onClick={() => toggleSection(section.id)}
              className="w-full p-4 flex items-center justify-between hover:bg-green-500/5 transition-colors"
            >
              <div className="flex items-center space-x-3">
                <section.icon className="w-6 h-6 text-green-500" />
                <h2 className="text-lg font-bold text-green-500">{section.title}</h2>
              </div>
              {expandedSection === section.id ? (
                <ChevronDown className="w-5 h-5 text-green-500" />
              ) : (
                <ChevronRight className="w-5 h-5 text-green-500" />
              )}
            </button>
            
            {expandedSection === section.id && (
              <div className="p-4 border-t border-green-500/30">
                {section.content}
              </div>
            )}
          </div>
        ))}
      </div>

      {/* Footer */}
      <div className="mt-8 pt-6 border-t border-green-500/60 text-center">
        <div className="flex items-center justify-center space-x-4 text-green-500/60 text-sm">
          <Satellite className="w-4 h-4" />
          <span>Target Experience: Tactical planning meets atmospheric isolation</span>
          <Satellite className="w-4 h-4" />
        </div>
        <p className="text-green-500/50 text-xs mt-2">
          The edge of human exploration awaits your command.
        </p>
      </div>
    </div>
  );
};

export default About;