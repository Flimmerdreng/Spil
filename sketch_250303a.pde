PImage backgroundImg; // Background image
PImage characterImg; // Character image
PImage characterImg2; // Alternative character image when toggled
int charX = 50; // Character's starting position on X-axis
int charY; // Character's starting position on Y-axis
int speed = 5; // Character's movement speed
int slideSpeed = 10; // Speed when sliding
float charScale = 0.5; // Scaling factor to make the character smaller (50% of original size)

boolean moveLeft = false;
boolean moveRight = false;
boolean toggleImage = false; // Toggle image state
boolean isJumping = false; // Is the character in the air
boolean jumpUp = false; // Is the jump phase active
boolean jumpCooldown = false; // Jump cooldown between jumps
boolean isSliding = false; // Is the character in slide state
int jumpHeight = 200; // Height the character can jump
float jumpSpeed = 0; // Speed of the jump (changes over time)
float maxJumpSpeed = 15; // Maximum speed while jumping
float gravity = 1; // Gravity (pulls the character down)
int jumpCooldownTime = 30; // Cooldown time between jumps in frames
int currentCooldown = 0; // Tracks the cooldown time
int toggleImageInterval = 10; // Time between each image toggle (in frames)
int currentToggleInterval = 0; // Timer to count down for next image toggle

void setup() {
  size(1200, 800); // World size (larger canvas)
  backgroundImg = loadImage("background.png"); // Load background image only once
  characterImg = loadImage("Charekter 1.png"); // Load character image 1
  characterImg2 = loadImage("Charekter 1.1.png"); // Load character image 2
  charY = height - 100 - (int)(characterImg.height * charScale) / 2; // Position character at the bottom of the screen, adjusted for scale
  imageMode(CENTER); // Draw images from the center
}

void draw() {
  // Resize the background to fit the canvas size
  background(200, 200, 255); // Fallback background color to avoid empty frames
  image(backgroundImg, width / 2, height / 2, width, height); // Center and resize the background image to fill the canvas
  
  drawWorld(); // Draw world elements (like ground, etc.)
  drawCharacter(); // Draw the character on top of the background
  handleMovement(); // Handle character movement
  handleJump(); // Handle jump and gravity
  handleCooldown(); // Handle jump cooldown
  updateImageToggle(); // Handle image toggling
  handleSlide(); // Handle sliding
}

// Draws world elements (like ground)
void drawWorld() {
  fill(0, 255, 0); // Green color for grass
  rect(0, height - 100, width, 100); // Ground
}

// Draws the character (as an image)
void drawCharacter() {
  pushMatrix(); // Save the current transformation matrix
  
  if (isSliding) {
    // If the character is sliding, flip the image vertically and make it smaller
    translate(charX, charY); // Move to the character's position
    scale(1, -1); // Flip the image upside down
    image(characterImg, 0, 0, characterImg.width * charScale, characterImg.height / 2 / charScale); // Stretch the image height (flattened)
  } else {
    // Change image only when not jumping or sliding
    if (!isJumping) {
      if (toggleImage) {
        image(characterImg, charX, charY, (int)(characterImg.width * charScale), (int)(characterImg.height * charScale)); // Draw image 1
      } else {
        image(characterImg2, charX, charY, (int)(characterImg2.width * charScale), (int)(characterImg2.height * charScale)); // Draw image 2
      }
    } else {
      // If the character is jumping, show the normal image
      image(characterImg, charX, charY, (int)(characterImg.width * charScale), (int)(characterImg.height * charScale)); // Draw image 1
    }
  }
  
  popMatrix(); // Restore the original transformation matrix
}

// Handles character movement
void handleMovement() {
  if (moveLeft && !isSliding) {
    charX -= speed; // Move character left
  }
  if (moveRight && !isSliding) {
    charX += speed; // Move character right
  }
}

// Handles jumping and gravity
void handleJump() {
  if (isJumping) {
    if (jumpUp) {
      jumpSpeed -= gravity;
      charY -= jumpSpeed;
      if (jumpSpeed <= 0) {
        jumpUp = false;
      }
    } else {
      jumpSpeed += gravity;
      charY += jumpSpeed;
      if (charY >= height - 100 - (int)(characterImg.height * charScale) / 2) {
        charY = height - 100 - (int)(characterImg.height * charScale) / 2;
        isJumping = false;
      }
    }
  }
}

// Handles jump cooldown
void handleCooldown() {
  if (jumpCooldown) {
    if (currentCooldown < jumpCooldownTime) {
      currentCooldown++;
    } else {
      jumpCooldown = false;
    }
  }
}

// Handles image toggling
void updateImageToggle() {
  if (currentToggleInterval >= toggleImageInterval && !isJumping && !isSliding) {
    toggleImage = !toggleImage;
    currentToggleInterval = 0;
  } else {
    currentToggleInterval++;
  }
}

// Handles sliding
void handleSlide() {
  if (isSliding) {
    // When sliding, increase speed and make the character smaller
    speed = slideSpeed;
    charScale = 0.4; // Make the character smaller while sliding
  } else {
    // If not sliding, normal speed and size
    speed = 5;
    charScale = 0.5;
  }
}

// Handles key press
void keyPressed() {
  if (key == 'a' || key == 'A') {
    moveLeft = true;
  }
  if (key == 'd' || key == 'D') {
    moveRight = true;
  }
  if (key == 'w' || key == 'W') {
    if (!isJumping && !jumpCooldown) {
      isJumping = true;
      jumpUp = true;
      jumpSpeed = maxJumpSpeed;
      jumpCooldown = true;
      currentCooldown = 0;
    }
  }
  if (key == 's' || key == 'S') {
    if (!isJumping && !isSliding) {
      isSliding = true; // Start sliding when S is pressed
    }
  }
}

// Handles key release
void keyReleased() {
  if (key == 'a' || key == 'A') {
    moveLeft = false;
  }
  if (key == 'd' || key == 'D') {
    moveRight = false;
  }
  if (key == 'w' || key == 'W') {
    // Stop jumping when W is released
    jumpUp = false;
  }
  if (key == 's' || key == 'S') {
    isSliding = false; // Stop sliding when S is released
  }
}
