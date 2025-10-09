// Simple ship image loading and drawing for useEffect
let shipImage = null;
let shipImageLoaded = false;

let lunarImage = null;
let lunarImageLoaded = false;

const imageCache = new Map();
const imageLoadedStatus = new Map();

// Load ship image once
const loadShipImage = () => {
  if (!shipImage) {
    shipImage = new Image();
    shipImage.onload = () => {
      shipImageLoaded = true;
    };
    shipImage.src = '/images/ship.png'; // Your ship image path
  }
};

export const loadImage = (imageName: string, imagePath: string) => {
  if (!imageCache.has(imageName)) {
    const img = new Image();
    img.onload = () => {
      imageLoadedStatus.set(imageName, true);
    };
    img.onerror = () => {
      console.error(`Failed to load image: ${imagePath}`);
      imageLoadedStatus.set(imageName, false);
    };
    img.src = imagePath;
    imageCache.set(imageName, img);
    imageLoadedStatus.set(imageName, false);
  }
};


const loadLunarImage = () => {
  if (!lunarImage) {
    lunarImage = new Image();
    lunarImage.onload = () => {
      lunarImageLoaded = true;
    };
    lunarImage.src = '/images/lunar.png'; // Your lunar image path
  }
};

// Initialize - load all images at startup
export const initializeImages = () => {
  loadImage('ship', '/images/ship.png');
  loadImage('lunar', '/images/lunar.png');
  loadImage('mars', '/images/mars.png');
  loadImage('earth', '/images/earth.png');
  loadImage('charon', '/images/charon.png');
  loadImage('ceres', '/images/ceres.png');
  // Add more as needed
};

export const drawCelestialBody = (
  ctx: CanvasRenderingContext2D, 
  x: number, 
  y: number, 
  imageName: string,
  size: number,
  fallbackColor: string = '#00ff00'
) => {
  const image = imageCache.get(imageName);
  const isLoaded = imageLoadedStatus.get(imageName);
  
  if (isLoaded && image) {
    // Draw the PNG image
    ctx.drawImage(image, x - size/2, y - size/2, size, size);
  } else {
    // Fallback drawing
    ctx.strokeStyle = fallbackColor;
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.arc(x, y, 8, 0, Math.PI * 2);
    ctx.stroke();
    
    ctx.strokeStyle = fallbackColor;
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(x - 12, y);
    ctx.lineTo(x + 12, y);
    ctx.moveTo(x, y - 12);
    ctx.lineTo(x, y + 12);
    ctx.stroke();
  }
};

// Draw ship function to use in your canvas useEffect
export const drawShip = (ctx, shipX, shipY) => {
  if (shipImageLoaded && shipImage) {
    // Draw the PNG image
    const shipSize = 24;
    ctx.drawImage(shipImage, shipX - shipSize/2, shipY - shipSize/2, shipSize, shipSize);
  } else {
    // Fallback to your original circle drawing if image not loaded
    ctx.strokeStyle = '#00ff00';
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.arc(shipX, shipY, 8, 0, Math.PI * 2);
    ctx.stroke();
    
    ctx.strokeStyle = '#00ff00';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(shipX - 12, shipY);
    ctx.lineTo(shipX + 12, shipY);
    ctx.moveTo(shipX, shipY - 12);
    ctx.lineTo(shipX, shipY + 12);
    ctx.stroke();
  }
};

  export const drawLunar = (ctx, lunarX, lunarY, lunarSize = 240) => {
    if (lunarImageLoaded && lunarImage) {
      // Draw the PNG image with the provided size
      ctx.drawImage(lunarImage, lunarX - lunarSize/2, lunarY - lunarSize/2, lunarSize, lunarSize);
    } else {
      // Fallback to your original circle drawing if image not loaded
      ctx.strokeStyle = '#00ff00';
      ctx.lineWidth = 3;
      ctx.beginPath();
      ctx.arc(lunarX, lunarY, 8, 0, Math.PI * 2);
      ctx.stroke();
      
      ctx.strokeStyle = '#00ff00';
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(lunarX - 12, lunarY);
      ctx.lineTo(lunarX + 12, lunarY);
      ctx.moveTo(lunarX, lunarY - 12);
      ctx.lineTo(lunarX, lunarY + 12);
      ctx.stroke();
    }
  };

// Call these once when your component mounts
loadShipImage();
loadLunarImage();  // Don't forget to call this too!