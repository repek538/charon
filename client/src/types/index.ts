export interface CelestialBody {
  id: string;
  x: number;
  y: number;
  imageName: string;
  baseSize: number; // Size at scale 1.0
  color?: string; // Fallback color
}