// Simple ship image loading and drawing for useEffect
let shipImage = null;
let shipImageLoaded = false;

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

// Call this once when your component mounts
loadShipImage();