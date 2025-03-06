PImage characterImg; // Character image
PImage characterImg2; // Alternative character image when toggled
PImage startImg; // Start screen image
int charX = 50; // Character's starting position on X-axis
int charY; // Character's starting position on Y-axis
int speed = 10; // Character's movement speed
int maxSpeed = 20; // Maximum speed when running (hold Shift)
int slideSpeed = 15; // Speed when sliding
float charScale = 0.5; // Scaling factor
float scaleX = 1.0; // Horizontal scale factor

boolean moveLeft = false;
boolean moveRight = false;
boolean toggleImage = false; // Toggle image state
boolean isJumping = false; // Is the character in the air
boolean isFalling = false; // Is the character falling
boolean isSliding = false; // Is the character in slide state
float jumpHeight = 300; // Height the character can jump
float jumpSpeed = 0; // Speed of the jump
float maxJumpSpeed = 15; // Maximum jump speed
float gravity = 1.5; // Gravity effect

// Background settings
int bgY = 0; // Background's vertical position
int bgSpeed = 5; // Speed of background movement
int groundHeight = 100; // Height of the ground

// Track settings
int trackWidth;
int trackHeight;
int currentTrack = 1;
int targetTrack = 1;
float trackXPos;
float trackSwitchSpeed = 0.1;

// Image toggle settings
int currentToggleInterval = 0;
int toggleImageInterval = 10;

int startTime;
int currentTime;
boolean gameStarted = false;

// Forhindringer
ArrayList<Obstacle> obstacles = new ArrayList<>();
int obstacleSpawnRate = 120; // Spawn rate for obstacles

void setup() {
  size(1200, 800);
  characterImg = loadImage("Charekter 1.png");
  characterImg2 = loadImage("Charekter 1.1.png");
  startImg = loadImage("Charekter start.png");
  trackWidth = width / 3;
  charY = height - groundHeight - (int)(characterImg.height * charScale) / 2;
  trackXPos = trackWidth * currentTrack + trackWidth / 2;
  imageMode(CENTER);
}

void draw() {
  if (!gameStarted) {
    showStartScreen();
    return;
  }

  currentTime = millis() - startTime;
  moveBackground();
  trackXPos = lerp(trackXPos, trackWidth * targetTrack + trackWidth / 2, trackSwitchSpeed);

  drawCharacter();
  handleMovement();
  handleJump();
  updateImageToggle();
  handleSlide();
  drawTimer();

  // Spawn obstacles
  if (frameCount % obstacleSpawnRate == 0) {
    obstacles.add(new Obstacle(int(random(3))));
  }

  // Move and display obstacles
  for (int i = obstacles.size() - 1; i >= 0; i--) {
    Obstacle obs = obstacles.get(i);
    obs.move();
    obs.display();

    // Check for collision only if the character is not jumping
    if (obs.hitsCharacter() && !isJumping) {
      println("Game Over!");
      noLoop(); // Stop game
    }

    if (obs.y > height) {
      obstacles.remove(i);
    }
  }
}

void showStartScreen() {
  background(0);
  image(startImg, width / 2, height / 2);
  textAlign(CENTER, CENTER);
  textSize(32);
  fill(255);
  text("Click to Start", width / 2, height - 50);
}

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

void moveBackground() {
  bgY += bgSpeed;
  if (bgY >= height) bgY = 0;
  background(200, 200, 255);
  fill(0, 255, 0);
  rect(0, height - groundHeight, width, groundHeight);
  fill(135, 206, 235);
  rect(0, bgY - height, width, height);
  rect(0, bgY, width, height);
}

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

void handleMovement() {}

void handleJump() {
  if (isJumping) {
    if (!isFalling) {
      charY -= jumpSpeed;
      if (charY <= height - groundHeight - jumpHeight) isFalling = true;
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

void updateImageToggle() {
  if (currentToggleInterval >= toggleImageInterval && !isJumping && !isSliding) {
    toggleImage = !toggleImage;
    currentToggleInterval = 0;
  } else {
    currentToggleInterval++;
  }
}

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

void mousePressed() {
  if (!gameStarted) {
    gameStarted = true;
    startTime = millis();
  }
}

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
    if (!isJumping && !isSliding) isSliding = true;
  }
}

void keyReleased() {
  if (key == 's' || key == 'S') isSliding = false;
}

// Forhindringsklasse
class Obstacle {
  int x, y, width, height;
  int speed = bgSpeed;

  Obstacle(int track) {
    this.width = 50;
    this.height = 50;
    this.x = track * trackWidth + trackWidth / 2;
    this.y = -height;
  }

  void move() {
    y += speed;
  }

  void display() {
    fill(255, 0, 0);
    rect(x - width / 2, y, width, height);
  }

  boolean hitsCharacter() {
    return (y + height > charY && y < charY + (characterImg.height * charScale) && abs(x - trackXPos) < width / 2);
  }
}
