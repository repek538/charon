export const imageCache = new Map();

// Function to load and cache images
export const loadImage = (src) => {
  if (imageCache.has(src)) {
    return Promise.resolve(imageCache.get(src));
  }
  
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.onload = () => {
      imageCache.set(src, img);
      resolve(img);
    };
    img.onerror = reject;
    img.src = src;
  });
};


// Function to draw image at world coordinates

// Function to preload all game images
export const preloadGameImages = async (imageList) => {
  const promises = imageList.map(src => loadImage(src));
  try {
    await Promise.all(promises);
    console.log('All game images loaded successfully');
    return true;
  } catch (error) {
    console.error('Failed to load some images:', error);
    return false;
  }
};

// Updated ship drawing function using PNG
export const drawPlayerShip = (ctx) => {
  const shipImageSrc = '/images/ship.png'; // Your ship image path
  
  drawImageAtPosition(ctx, shipImageSrc, playerShip.x, playerShip.y, {
    width: 24,
    height: 24,
    rotation: 0, // You could add ship rotation based on movement direction
    alpha: 1,
    scale: 1
  });
};
