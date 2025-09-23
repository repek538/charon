
import React, { useState, useEffect } from 'react';

// Music Control Component - Separate Component
interface MusicControlsProps {
  tracks: Array<{ name: string; url: string }>;
}

const MusicControls: React.FC<MusicControlsProps> = ({ tracks }) => {
  const [isMusicPlaying, setIsMusicPlaying] = useState(true);
  const [volume, setVolume] = useState(30);
  const [showVolumeControl, setShowVolumeControl] = useState(false);
  const [currentTrack, setCurrentTrack] = useState(0);
  const [isLooping, setIsLooping] = useState(true);
  const [isMuted, setIsMuted] = useState(false);
  const [previousVolume, setPreviousVolume] = useState(30);
  const audioRef = React.useRef<HTMLAudioElement | null>(null);

  // Initialize/change audio track
  useEffect(() => {
    if (audioRef.current) {
      audioRef.current.pause();
    }
    
    const audio = new Audio(tracks[currentTrack].url);
    audio.loop = isLooping;
    audio.volume = isMuted ? 0 : volume / 100;
    audioRef.current = audio;

    if (isMusicPlaying) {
      audio.play().catch(err => console.log('Audio play failed:', err));
    }

    return () => {
      if (audioRef.current) {
        audioRef.current.pause();
      }
    };
  }, [currentTrack]);

  // Handle volume changes
  useEffect(() => {
    if (audioRef.current) {
      audioRef.current.volume = isMuted ? 0 : volume / 100;
    }
  }, [volume, isMuted]);

  // Handle loop changes
  useEffect(() => {
    if (audioRef.current) {
      audioRef.current.loop = isLooping;
    }
  }, [isLooping]);

  const toggleMusic = () => {
    if (audioRef.current) {
      if (isMusicPlaying) {
        audioRef.current.pause();
      } else {
        audioRef.current.play().catch(err => console.log('Audio play failed:', err));
      }
      setIsMusicPlaying(!isMusicPlaying);
    }
  };

  const toggleMute = () => {
    if (isMuted) {
      setVolume(previousVolume);
      setIsMuted(false);
    } else {
      setPreviousVolume(volume);
      setIsMuted(true);
    }
  };

  const changeTrack = (direction: 'next' | 'prev') => {
    let newTrack = currentTrack;
    if (direction === 'next') {
      newTrack = (currentTrack + 1) % tracks.length;
    } else {
      newTrack = currentTrack === 0 ? tracks.length - 1 : currentTrack - 1;
    }
    setCurrentTrack(newTrack);
  };

  return (
    <div className="fixed top-4 right-4 z-50">
      <div className="bg-black border border-green-500">
        {/* Minimized View */}
        <div className="flex items-center gap-1 p-2">
          <button
            onClick={() => setShowVolumeControl(!showVolumeControl)}
            className="text-green-400 hover:text-green-300 transition-colors p-1"
            title="Expand Controls"
          >
            <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
              {showVolumeControl ? (
                <path d="M7 14l5-5 5 5z"/>
              ) : (
                <path d="M7 10l5 5 5-5z"/>
              )}
            </svg>
          </button>

          <button
            onClick={toggleMusic}
            className="text-green-400 hover:text-green-300 transition-colors p-1"
            title={isMusicPlaying ? 'Pause' : 'Play'}
          >
            {isMusicPlaying ? (
              <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                <path d="M6 4h4v16H6V4zm8 0h4v16h-4V4z"/>
              </svg>
            ) : (
              <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                <path d="M8 5v14l11-7z"/>
              </svg>
            )}
          </button>
          
          <button
            onClick={toggleMute}
            className="text-green-400 hover:text-green-300 transition-colors p-1"
            title={isMuted ? 'Unmute' : 'Mute'}
          >
            <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
              {isMuted || volume === 0 ? (
                <path d="M16.5 12c0-1.77-1.02-3.29-2.5-4.03v2.21l2.45 2.45c.03-.2.05-.41.05-.63zm2.5 0c0 .94-.2 1.82-.54 2.64l1.51 1.51C20.63 14.91 21 13.5 21 12c0-4.28-2.99-7.86-7-8.77v2.06c2.89.86 5 3.54 5 6.71zM4.27 3L3 4.27 7.73 9H3v6h4l5 5v-6.73l4.25 4.25c-.67.52-1.42.93-2.25 1.18v2.06c1.38-.31 2.63-.95 3.69-1.81L19.73 21 21 19.73l-9-9L4.27 3zM12 4L9.91 6.09 12 8.18V4z"/>
              ) : volume < 50 ? (
                <path d="M18.5 12c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02zM5 9v6h4l5 5V4L9 9H5z"/>
              ) : (
                <path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02zM14 3.23v2.06c2.89.86 5 3.54 5 6.71s-2.11 5.85-5 6.71v2.06c4.01-.91 7-4.49 7-8.77s-2.99-7.86-7-8.77z"/>
              )}
            </svg>
          </button>

          <div className="text-green-400 font-mono text-xs px-2">
            {isMusicPlaying ? '♪' : '◼'} {tracks[currentTrack].name}
          </div>
        </div>

        {/* Expanded Controls */}
        {showVolumeControl && (
          <div className="border-t border-green-500 p-3 space-y-3">
            {/* Track Controls */}
            <div className="flex items-center justify-between gap-2">
              <button
                onClick={() => changeTrack('prev')}
                className="text-green-400 hover:text-green-300 transition-colors p-1"
                title="Previous Track"
              >
                <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M6 6h2v12H6zm3.5 6l8.5 6V6z"/>
                </svg>
              </button>

              <div className="flex-1 text-center">
                <div className="text-green-400 font-mono text-xs">TRACK_{currentTrack + 1}/{tracks.length}</div>
                <div className="text-green-600 font-mono text-xs truncate max-w-[120px]">
                  {tracks[currentTrack].name}
                </div>
              </div>

              <button
                onClick={() => changeTrack('next')}
                className="text-green-400 hover:text-green-300 transition-colors p-1"
                title="Next Track"
              >
                <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M6 18l8.5-6L6 6v12zM16 6v12h2V6h-2z"/>
                </svg>
              </button>
            </div>

            {/* Volume Slider */}
            <div className="space-y-1">
              <div className="text-green-600 font-mono text-xs">VOLUME_{Math.round(isMuted ? 0 : volume)}%</div>
              <div className="flex items-center gap-2">
                <input
                  type="range"
                  min="0"
                  max="100"
                  value={isMuted ? 0 : volume}
                  onChange={(e) => {
                    const newVolume = Number(e.target.value);
                    setVolume(newVolume);
                    if (isMuted && newVolume > 0) {
                      setIsMuted(false);
                    }
                  }}
                  className="flex-1 h-1 appearance-none bg-green-900 outline-none"
                  style={{
                    background: `linear-gradient(to right, #4ade80 0%, #4ade80 ${isMuted ? 0 : volume}%, #14532d ${isMuted ? 0 : volume}%, #14532d 100%)`
                  }}
                />
              </div>
            </div>

            {/* Additional Controls */}
            <div className="flex justify-between items-center pt-2 border-t border-green-800">
              <button
                onClick={() => setIsLooping(!isLooping)}
                className={`text-xs font-mono px-2 py-1 border ${
                  isLooping 
                    ? 'border-green-400 text-green-400 bg-green-400 bg-opacity-20' 
                    : 'border-green-800 text-green-800'
                }`}
                title="Toggle Loop"
              >
                LOOP_{isLooping ? 'ON' : 'OFF'}
              </button>

              <div className="text-green-600 font-mono text-xs">
                {isMusicPlaying ? 'PLAYING' : 'PAUSED'}
              </div>
            </div>

            {/* Visualizer */}
            {isMusicPlaying && (
              <div className="flex items-end justify-center gap-1 h-8">
                {[...Array(7)].map((_, i) => (
                  <div
                    key={i}
                    className="w-1 bg-green-400 animate-pulse"
                    style={{
                      height: `${Math.random() * 100}%`,
                      animationDelay: `${i * 0.1}s`,
                      animationDuration: '0.5s'
                    }}
                  />
                ))}
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
};

export default MusicControls;