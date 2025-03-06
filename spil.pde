PImage characterImg;    // Character image
PImage characterImg2;   // Alternative character image when toggled
PImage startImg;        // Start screen image

int charX = 50;         // Character's starting X position
int charY;              // Character's starting Y position

int speed = 10;         // Character's movement speed
int maxSpeed = 20;      // Maximum speed (unused here, but available)
int slideSpeed = 15;    // Speed when sliding

float charScale = 0.5;  // Scaling factor for character
float scaleX = 1.0;     // Horizontal scale modifier

boolean moveLeft = false;
boolean moveRight = false;
boolean toggleImage = false; // For image animation/toggling
boolean isJumping = false;   // Is the character jumping?
boolean isFalling = false;   // Is the character falling?
boolean isSliding = false;   // Is the character sliding?

float jumpHeight = 300;      // Maximum jump height
float jumpSpeed = 0;         // Current jump speed
float maxJumpSpeed = 15;     // Maximum initial jump speed
float gravity = 1.5;         // Gravity effect

// Background settings
int bgY = 0;               // Vertical position of scrolling background
int bgSpeed = 5;           // Background scroll speed
int groundHeight = 100;      // Height of the ground (green area)

// Track settings (for lane control)
int trackWidth;
int trackHeight;
int currentTrack = 1;
int targetTrack = 1;
float trackXPos;
float trackSwitchSpeed = 0.1;

// Image toggle settings (to animate character)
int currentToggleInterval = 0;
int toggleImageInterval = 10;

int startTime;
int currentTime;
boolean gameStarted = false;

void setup() {
  size(1200, 800);
  
  // Load images (ensure they are in your sketch’s "data" folder)
  characterImg = loadImage("Charekter 1.png");
  characterImg2 = loadImage("Charekter 1.1.png");
  startImg = loadImage("Charekter start.png");
  
  // Calculate track width based on screen width (3 lanes)
  trackWidth = width / 3;
  
  // Set the character's starting Y so it stands on the ground.
  charY = height - groundHeight - (int)(characterImg.height * charScale) / 2;
  
  // Initially position the character in lane 1 (center lane)
  trackXPos = trackWidth * currentTrack + trackWidth / 2;
  
  // Use centered image mode
  imageMode(CENTER);
}

void draw() {
  if (!gameStarted) {
    showStartScreen();
    return;
  }
  
  // Update elapsed time and score (if you want to use it later)
  currentTime = millis() - startTime;
  
  // Draw the background (futuristic layered look using rectangles)
  moveBackground();
  
  // Smoothly transition the character's lane position if needed
  trackXPos = lerp(trackXPos, trackWidth * targetTrack + trackWidth / 2, trackSwitchSpeed);
  
  // Draw the character (toggling images for animation)
  drawCharacter();
  
  // Future movement functions (expand handleMovement() if desired)
  handleMovement();
  handleJump();
  updateImageToggle();
  handleSlide();
  
  // Draw a timer in the top-right (optional)
  drawTimer();
}

void showStartScreen() {
  background(0);
  image(startImg, width/2, height/2);
  textAlign(CENTER, CENTER);
  textSize(32);
  fill(255);
  text("Click to Start", width/2, height - 50);
}

// Draw a timer (hours/minutes/seconds/millis)
void drawTimer() {
  fill(255);
  textSize(32);
  textAlign(RIGHT, TOP);
  int minutes = (currentTime / 60000) % 60;
  int seconds = (currentTime / 1000) % 60;
  int milliseconds = currentTime % 1000;
  String timerString = nf(minutes, 2) + ":" + nf(seconds, 2) + ":" + nf(milliseconds, 3);
  text(timerString, width - 20, 20);
}

// Draw the background using layered rectangles
void moveBackground() {
  bgY += bgSpeed;
  if (bgY >= height) bgY = 0;
  
  // Sky
  background(200, 200, 255);
  
  // Ground
  fill(0, 255, 0);
  rect(0, height - groundHeight, width, groundHeight);
  
  // Two layers of moving background to create a scrolling effect
  fill(135, 206, 235);
  rect(0, bgY - height, width, height);
  rect(0, bgY, width, height);
}

// Draw the character using toggled images and proper scaling
void drawCharacter() {
  pushMatrix();
  int trackX = (int)trackXPos;
  if (isSliding) {
    translate(trackX, charY);
    scale(scaleX, -1);
    image(characterImg, 0, 0, characterImg.width * charScale, characterImg.height * charScale);
  } else {
    if (!isJumping) {
      if (toggleImage) {
        image(characterImg, trackX, charY, characterImg.width * charScale, characterImg.height * charScale);
      } else {
        image(characterImg2, trackX, charY, characterImg2.width * charScale, characterImg2.height * charScale);
      }
    } else {
      image(characterImg, trackX, charY, characterImg.width * charScale, characterImg.height * charScale);
    }
  }
  popMatrix();
}

// (Placeholder) Function to handle other movement (if needed)
void handleMovement() {
  // You can add additional movement logic here.
}

// Handle jumping, including upward motion and applying gravity
void handleJump() {
  if (isJumping) {
    if (!isFalling) {
      charY -= jumpSpeed;
      if (charY <= height - groundHeight - jumpHeight)
        isFalling = true;
    } else {
      jumpSpeed += gravity;
      charY += jumpSpeed;
      if (charY >= height - groundHeight - (int)(characterImg.height * charScale) / 2) {
        charY = height - groundHeight - (int)(characterImg.height * charScale) / 2;
        isJumping = false;
        isFalling = false;
        jumpSpeed = 0;
      }
    }
  }
}

// Toggle the character's image for a simple animation effect
void updateImageToggle() {
  if (currentToggleInterval >= toggleImageInterval && !isJumping && !isSliding) {
    toggleImage = !toggleImage;
    currentToggleInterval = 0;
  } else {
    currentToggleInterval++;
  }
}

// Adjust scaling when sliding
void handleSlide() {
  if (isSliding) {
    speed = slideSpeed;
    charScale = 0.4;
    scaleX = 0.8;
  } else {
    speed = 10;
    charScale = 0.5;
    scaleX = 1.0;
  }
}

// Start the game on a mouse click
void mousePressed() {
  if (!gameStarted) {
    gameStarted = true;
    startTime = millis();
  }
}

// Keyboard controls for lane switching, jumping, and sliding
void keyPressed() {
  if (key == 'a' || key == 'A') {
    if (targetTrack > 0) targetTrack--;
  }
  if (key == 'd' || key == 'D') {
    if (targetTrack < 2) targetTrack++;
  }
  if (key == 'w' || key == 'W') {
    if (!isFalling) {
      isJumping = true;
      jumpSpeed = maxJumpSpeed;
    }
  }
  if (key == 's' || key == 'S') {
    if (!isJumping && !isSliding)
      isSliding = true;
  }
}

// Key release to stop sliding
void keyReleased() {
  if (key == 's' || key == 'S') {
    isSliding = false;
  }
}
