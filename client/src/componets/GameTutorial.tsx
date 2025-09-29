import React, { useState } from 'react';
import { ChevronLeft, ChevronRight, X, Rocket, Satellite, Monitor } from 'lucide-react';

const GameTutorial = ({ content, onClose }) => {
  const [currentStep, setCurrentStep] = useState(0);

  const nextStep = () => {
    if (currentStep < content.length - 1) {
      setCurrentStep(currentStep + 1);
    }
  };

  const prevStep = () => {
    if (currentStep > 0) {
      setCurrentStep(currentStep - 1);
    }
  };

  const goToStep = (stepIndex) => {
    setCurrentStep(stepIndex);
  };

  const renderContent = (item) => {
    if (item.gType === 'section') {
      return (
        <div className="space-y-4">
          <h3 className="text-xl font-bold text-green-500 font-mono flex items-center">
            <Monitor className="w-5 h-5 mr-2" />
            {item.data.title}
          </h3>
          <div className="text-green-500/80 font-mono text-sm leading-relaxed whitespace-pre-line">
            {item.data.content}
          </div>
        </div>
      );
    }
    
    if (item.gType === 'image') {
      return (
        <div className="flex justify-center my-6">
          <div className="bg-transparent border border-green-500/60 rounded-lg p-4">
            <img 
              src={item.data.url} 
              alt="Tutorial Screenshot"
              style={{ 
                width: item.data.width, 
                height: item.data.height 
              }}
              className="rounded border border-green-500/30"
              onError={(e) => {
                //e.target.style.display = 'none';
                //e.target.nextSibling.style.display = 'block';
              }}
            />
            <div 
              className="text-green-500/60 font-mono text-xs text-center mt-2 hidden"
              style={{ display: 'none' }}
            >
              [Screenshot: {item.data.url}]
            </div>
          </div>
        </div>
      );
    }
    
    return null;
  };

  return (
    <div className="bg-black border border-green-500/60 rounded-lg max-w-4xl mx-auto">
      {/* Header */}
      <div className="flex items-center justify-between p-4 border-b border-green-500/60">
        <div className="flex items-center space-x-3">
          <Rocket className="w-6 h-6 text-green-500" />
          <h2 className="text-lg font-bold text-green-500 font-mono">CHARON OPERATIONS MANUAL</h2>
        </div>
        <button
          onClick={onClose}
          className="text-green-500 hover:text-green-400 p-1 rounded border border-green-500/60 hover:border-green-500"
        >
          <X className="w-5 h-5" />
        </button>
      </div>

      {/* Progress indicator */}
      <div className="p-4 border-b border-green-500/60">
        <div className="flex items-center justify-between mb-2">
          <span className="text-green-500 font-mono text-sm">
            SECTION {currentStep + 1} OF {content.length}
          </span>
          <div className="flex items-center space-x-1">
            <Satellite className="w-4 h-4 text-green-500" />
            <span className="text-green-500/60 font-mono text-xs">
              {Math.round(((currentStep + 1) / content.length) * 100)}% COMPLETE
            </span>
          </div>
        </div>
        
        <div className="w-full bg-transparent border border-green-500/60 rounded-full h-2">
          <div 
            className="bg-green-500/60 h-full rounded-full transition-all duration-300"
            style={{ width: `${((currentStep + 1) / content.length) * 100}%` }}
          />
        </div>
      </div>

      {/* Content */}
      <div className="p-6 min-h-[400px] max-h-[500px] overflow-y-auto">
        {content[currentStep] && renderContent(content[currentStep])}
      </div>

      {/* Navigation */}
      <div className="flex items-center justify-between p-4 border-t border-green-500/60">
        <button
          onClick={prevStep}
          disabled={currentStep === 0}
          className={`flex items-center space-x-2 px-4 py-2 rounded border font-mono text-sm transition-colors ${
            currentStep === 0
              ? 'border-green-500/30 text-green-500/30 cursor-not-allowed'
              : 'border-green-500/60 text-green-500 hover:bg-green-500/10 hover:border-green-500'
          }`}
        >
          <ChevronLeft className="w-4 h-4" />
          <span>PREVIOUS</span>
        </button>

        {/* Step indicators */}
        <div className="flex space-x-1 max-w-md overflow-x-auto">
          {content.map((_, index) => (
            <button
              key={index}
              onClick={() => goToStep(index)}
              className={`w-2 h-2 rounded-full transition-colors ${
                index === currentStep
                  ? 'bg-green-500'
                  : index < currentStep
                  ? 'bg-green-500/60'
                  : 'bg-green-500/20 border border-green-500/40'
              }`}
              title={`Section ${index + 1}`}
            />
          ))}
        </div>

        <button
          onClick={nextStep}
          disabled={currentStep === content.length - 1}
          className={`flex items-center space-x-2 px-4 py-2 rounded border font-mono text-sm transition-colors ${
            currentStep === content.length - 1
              ? 'border-green-500/30 text-green-500/30 cursor-not-allowed'
              : 'border-green-500/60 text-green-500 hover:bg-green-500/10 hover:border-green-500'
          }`}
        >
          <span>NEXT</span>
          <ChevronRight className="w-4 h-4" />
        </button>
      </div>

      {/* Footer */}
      <div className="px-4 py-2 border-t border-green-500/60 text-center">
        <div className="text-green-500/60 font-mono text-xs">
          Use keyboard arrows or click navigation buttons to move between sections
        </div>
      </div>
    </div>
  );
};

export default GameTutorial;