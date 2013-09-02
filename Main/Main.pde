
import SimpleOpenNI.*;

//Background Image
PImage backg, backg2, piSpaceCraft, piLife, piCalibrate, piGameLogo;
PFont pfFontCalibrate, pfFontCountDown, pfFontGameOver, pfBig, pfSmall;


// Timer variables
Timer tTimer;
int startingTime, seconds = 3;
boolean countdowncontroller = false;

// Counting lifes
int iLifes = 5;

//Wall 1: Bottom
//Wall 2: Right
//Wall 3: Top
//Wall 4: Left
Wall w_Wall, w_Wall2, w_Wall3, w_Wall4;
PVector pNormal, pNormal2, pNormal3, pNormal4, pVect, pVect2, pVect3, pVect4, pPoint, pPoint2, pPoint3, pPoint4;

// Number of monsters in the game
int iNumEnemies = 5;

Particle[] sParticles = new Particle[iNumEnemies];
boolean bParticlesExist = false;

int iNumBullet = 0;
int iMaxBullets = 1;
Bullet[] b_Bullets = new Bullet[5];

//Counting lifes going down
int iHearts = 0;
Heart h_heart;
boolean bHeartExist=false;

//Screen Size
int iWidth = 1024, iHeight = 768;

// Our position
PVector jointPos = new PVector();

//SimpleOpenNI
SimpleOpenNI  context;

// NITE
XnVSessionManager sessionManager;
XnVFlowRouter flowRouter;
PointDrawer pDrawer;
XnVPushDetector pushDetector;
PVector pvPushPos;  //Push position

/*Screen variable:

0 - Menu
1 - Calibrate
2 - Game
3 - How to play
4 - Game over
5 - CountDown
6 - Credits

*/

int iScreen = 0, nextStage = 0;
boolean bTrackingSkel = false, bTrackingHand = true, bInitPart = false, bInitWall = false;
boolean bCapture = false;  // boolean to know if the RGB photo has been taken
Menu menu;
PImage piCapture;
int iStageAct;
boolean bPlayed = false;

void setup()  {    
  
  // Loading fonts
  pfFontCalibrate = loadFont("data/Consolas-30.vlw");
  pfFontCountDown = loadFont("data/Consolas-200.vlw");
  pfFontGameOver = loadFont("data/Consolas-48.vlw");
  pfBig = loadFont("data/Consolas20.vlw");  
  pfSmall = loadFont("data/Consolas14.vlw");

  pvPushPos = new PVector();
  
  // setup NITE 
  context = new SimpleOpenNI(this);
  context.setMirror(true);
  pushDetector = new XnVPushDetector();
  
  context.enableDepth();
  context.enableRGB();
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  context.enableGesture();
  context.enableHands();
  sessionManager = context.createSessionManager("Click,Wave", "RaiseHand");

  pDrawer = new PointDrawer();
  flowRouter = new XnVFlowRouter();
  flowRouter.SetActive(pDrawer);
  
  pushDetector.RegisterPush(this);
  pushDetector.RegisterPrimaryPointCreate(this);
  pushDetector.RegisterPrimaryPointDestroy(this);
  pushDetector.RegisterPointUpdate(this);
  
  sessionManager.AddListener(flowRouter);
  sessionManager.AddListener(pushDetector);

  // Loading images
  backg = loadImage("imatges/fons-1024.jpg");
  backg2 = loadImage("imatges/fonsInvertit-1024.jpg");
  piSpaceCraft = loadImage("imatges/prota.png");
  piLife = loadImage("imatges/vida.png");
  piCalibrate = loadImage("imatges/calibrar.png");
  piGameLogo = loadImage("imatges/arkanoid-invaders.jpg");

  menu = new Menu();
    
  stroke(0,0,255);
  strokeWeight(3);
  size(iWidth, iHeight);

  frameRate(30);
}    

void draw()  {
  
  switch(iScreen){
    
    case 0: //Menu
          
          background(backg);
          menu.showMenu();
          iLifes = 5;

          context.update();
          context.update(sessionManager);
          
          image(context.depthImage(),iWidth-100,iHeight-100, 100, 100);
          pDrawer.draw();
          break;
          
    case 1: //Calibrate
          
          background(backg2);
          
          preDraw();
          fill(0);
          textFont(pfFontGameOver);
          text("Stay like this for a while!", 170, 80 );
          context.update();
          image(piCalibrate, (iWidth/2)-114, 250);
          image(context.depthImage(),iWidth-100,iHeight-100, 100, 100);
        break;
        
    case 2:  //Game
    
          bPlayed = true;
          iHearts++;
      
          if (!bInitPart){
            InitParticules();
            bInitPart = true;
          }
          if (!bInitWall){
            InitWalls();
            bInitWall = true;
          }
    
          background(backg);
      
      
          //Kinect
          context.update();
          image(context.depthImage(),iWidth-100,iHeight-100, 100, 100);
          
          //The user moves out of the camera and back in, if it's a
          //different user we detect it like ID 1.
          int userCount = context.getNumberOfUsers();

          if(userCount>0) {
            IntVector userList = new IntVector();
            context.getUsers(userList);
            int trackingListIndex = userCount-1;          
            int trackingId = (int)userList.get(trackingListIndex);
            
            // draw the skeleton if it's available 
            if(context.isTrackingSkeleton(trackingId)) {
              drawSkeleton(trackingId);
            }
          } 
      
          //Drawing particles and moving them forward 
          for (int iAux = 0; iAux < iNumEnemies; iAux++) {
            sParticles[iAux].goAhead();
            sParticles[iAux].drawParticle();
            
            //Detecting collisions with walls
            sParticles[iAux].collision(w_Wall, pNormal, 1, pPoint);
            sParticles[iAux].collision(w_Wall2, pNormal2, 2, pPoint2);
            sParticles[iAux].collision(w_Wall3, pNormal3, 3, pPoint3);
            sParticles[iAux].collision(w_Wall4, pNormal4, 4, pPoint4);
            
            //Detecting collision with craft
            if (sParticles[iAux].craftCollision(jointPos.x*iWidth/640)){
              lifeDown();
            }
            
            //Detecting Collision with bullet
            for (int i = 0; i < iNumBullet ; i++){
              sParticles[iAux].bulletCollision(b_Bullets[i]);
            } 
            //Killing particle
            if (sParticles[iAux].particleExists()) {
              bParticlesExist = true;
            }
          }
      
          if(iHearts%500 == 0){
            // Heart going down
            h_heart = new Heart(random(100, 400));
            bHeartExist = true;
          }
          if (bHeartExist){
            h_heart.goAhead();
            if (h_heart.craftCollision(jointPos.x*iWidth/640)){
              bHeartExist = false;
              h_heart.destroy();
              iLifes++;
            }
          }
    
          if ((iLifes == 0)||(!bParticlesExist)) {
            iScreen = 4;
        } else {
            bParticlesExist = false;
          }
          // Print lifes
          drawLifes();
          if (!countdowncontroller) iScreen = 5;
          
          if (!bCapture) {
            piCapture = context.rgbImage();
            bCapture = true;
          }
      
      
      break;
    
    case 3: // Instructions
      preDraw();
      context.update();
      context.update(sessionManager);
      
      howToPlay();
      image(context.depthImage(),iWidth-100,iHeight-100, 100, 100);
      
      break;
      
    case 4: //Game over
      preDraw();
      
      context.update();
      context.update(sessionManager);
      image(context.depthImage(),iWidth-100,iHeight-100, 100, 100);
      fill(255);
      textFont(pfFontCountDown);
      if(iLifes == 0) {
        text("GAME OVER!", 10, 250 );
      } else {
        text("YOU WIN!", 100, 250 );
      }
      
      //Init vars
      bInitPart = false;
      bInitWall = false;
      
      countdowncontroller = false;
      
      image(context.depthImage(),iWidth-100,iHeight-100, 100, 100);
      image(piCapture, 300, 300, 320, 240);
      
      break;
      
    case 5:
      if (!countdowncontroller) {        
        tTimer = new Timer(3000);
        tTimer.start();
        countdowncontroller = true;
      }
      countDown(3, iWidth, iHeight, nextStage);
      break;
      
    case 6:
      preDraw();
      context.update();
      context.update(sessionManager);
      
      credits();
      image(context.depthImage(),iWidth-100,iHeight-100, 100, 100);
      break;
      
  }
}


/***************************************/
/*********** Start Functions ***********/
/***************************************/

void preDraw() {
  if ((!bTrackingSkel) && (iScreen == 1)) {
    sessionManager.EndSession();
    context.stopTrackingHands(1);
    context.stopTrackingAllHands(); 
    
    //The user moves out of the camera and back in, if it's a
    //different user we detect it like ID 1.
    int userCount = context.getNumberOfUsers();

    if(userCount>0) {
      IntVector userList = new IntVector();
      context.getUsers(userList);
      
      int trackingListIndex = userCount-1;          
      int trackingId = (int)userList.get(trackingListIndex);
        
      // draw the skeleton if it's available 
      if(context.isTrackingSkeleton(trackingId)) {
          
        //drawSkeleton(trackingId);
        iScreen = 5;
      }
    } 
    
    bTrackingHand = false;
    bTrackingSkel = true;
  }
  
  if ((!bTrackingHand) && ((iScreen == 4)||(iScreen == 6)) ){
    context.enableGesture();
    context.enableHands();

    bTrackingHand = true;
    bTrackingSkel = false;
  }
}

void InitParticules(){
  //initialize all particles
  for (int iAux = 0; iAux < iNumEnemies; iAux++) {
    sParticles[iAux] = new Particle(random(300, 500), random(150, 250), random(-100, 100), random(-100, 100),int(random(3)));
  }
}

void InitWalls() {
  //Init wall 1 - Bottom Wall
  w_Wall = new Wall(0.0, iHeight-35.0, iWidth, iHeight-35.0, 100, 1);
  pNormal = new PVector();
  pVect = new PVector();
  pPoint = new PVector();
  w_Wall.calculateNormal();
  pNormal = w_Wall.getNormal();
  pVect = w_Wall.getVector();
  pPoint = w_Wall.getPoint();
  
  //Init wall 2 - Right Wall
  w_Wall2 = new Wall(iWidth-25.0, iHeight, iWidth-25.0, 0.0, 100, -1);
  pNormal2 = new PVector();
  pVect2 = new PVector();
  pPoint2 = new PVector();
  w_Wall2.calculateNormal();
  pNormal2 = w_Wall2.getNormal();
  pVect2 = w_Wall2.getVector();
  pPoint2 = w_Wall2.getPoint();
  
  //Init wall 3 - Top Wall
  w_Wall3 = new Wall(0.0, 0.0, iWidth, 0.0, 100, -1);
  pNormal3 = new PVector();
  pVect3 = new PVector();
  pPoint3 = new PVector();
  w_Wall3.calculateNormal();
  pNormal3 = w_Wall3.getNormal();
  pVect3 = w_Wall3.getVector();
  pPoint3 = w_Wall3.getPoint();
  
  //Init wall 4 - Left Wall
  w_Wall4 = new Wall(0.0, 0.0, 0.0, iHeight, 100, 1);
  pNormal4 = new PVector();
  pVect4 = new PVector();
  pPoint4 = new PVector();
  w_Wall4.calculateNormal();
  pNormal4 = w_Wall4.getNormal();
  pVect4 = w_Wall4.getVector();
  pPoint4 = w_Wall4.getPoint();
  
}


void drawSkeleton(int userId)
{
  // to get the 3d joint data
  PVector pvLeftHand = new PVector();
  PVector pvRightHand = new PVector();
  PVector pvNeck = new PVector();
  
  // Get the torso position of the player body
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_TORSO,jointPos);
  
  //convert 3d world coord to 2d coord
  context.convertRealWorldToProjective(jointPos, jointPos);
  
  // Drawing the craft at the player body x-position (we scale the position to our screen size)
  image(piSpaceCraft, (jointPos.x)*iWidth/640 , 703);
  
  //detect the three points needed to shoot. The user shoots 
  //when the Left and Right hands are above the neck
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,pvLeftHand);
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,pvRightHand);
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,pvNeck);
  
  //function to convert 3d world coord to 2d coord
  context.convertRealWorldToProjective(pvLeftHand, pvLeftHand);
  context.convertRealWorldToProjective(pvRightHand, pvRightHand);
  context.convertRealWorldToProjective(pvNeck, pvNeck);
  
  // Shooting
  if ((pvLeftHand.y < pvNeck.y) && (pvRightHand.y < pvNeck.y)&& (iNumBullet<iMaxBullets)){  
      b_Bullets[iNumBullet] = new Bullet((jointPos.x*iWidth/640)+50, 703, -1);
      iNumBullet++;
  }
  
  // Move bullets on the screen forward 
  for (int i=0; i < iNumBullet; i++) {
    b_Bullets[i].goAhead();
    if(b_Bullets[i].getY() < 0){
      iNumBullet--;
    }
  }
}

// Function to take away one life
void lifeDown(){
  if (iLifes>0) {
    iLifes--;
  }
  println(iLifes);
}

// Function to draw the actual lifes of the player
void drawLifes(){
  for (int i =0; i<iLifes; i++){
    image(piLife, 59.0*i, 10.0);
  }
}

// Timer countdown
void countDown(int seconds, int iWidth, int iHeight, int iActScreen) {
  if (tTimer.isFinished()) {
    
    //when the countdown is finished, start the game
    iScreen  = iActScreen;    
  }else{
    
    // Draw time left
    fill(255);
    textFont(pfFontCalibrate);
    text("Stage "+(iActScreen-1), (iWidth/2)-20, 100);
    fill(80);
    rect((iWidth/2)-90,(iHeight/2)-150, 200, 200);
    stroke(0);
    //roundRect((iWidth/2)-100,(iHeight/2)-100, 200, 200);
    fill(255);
    textFont(pfFontCountDown);
    text((seconds - tTimer.getSeconds()), (iWidth/2)-15, (iHeight/2)+20);
  }
}

// Function for the credits
void credits() {
  
  background(backg2);

  fill(25, 44, 125);
  stroke(25, 44, 125);
  rect(0, 25, iWidth, 135);
  image(piGameLogo, (iWidth/2)-170.5, 30);
  
  fill(25, 44, 125);
  stroke(25, 44, 125);
  textFont(pfBig);
  text("Developers....................................Anna Fusté / Jordi Llobet", 150, 260 );
  text("Avatars.......................................Space Invaders", 150, 290 );
  
  fill(25, 44, 125);
  stroke(25, 44, 125);
  textFont(pfSmall);
  text("La Salle Bonanova, URL 2011", 520, 580);
}

void howToPlay() {

  background(backg2);  
  
  fill(25, 44, 125);
  stroke(25, 44, 125);
  rect(0, 25, iWidth, 135);
  image(piGameLogo, (iWidth/2)-170.5, 30);
  
  fill(25, 44, 125);
  stroke(25, 44, 125);
  textFont(pfBig);
  text("HOW TO PLAY", 60, 220 );
  text("Get started!", 60, 290 );
  textFont(pfSmall);
  fill(250, 0, 0);
  text("** This is a single player game **", 60, 320 );
  text("** When you select the option GAME, be sure that you're the only one in front of the Kinect! **", 60, 340 );
  textFont(pfBig);
  fill(25, 44, 125);
  text("First of all, you have to calibrate.", 60, 400 );
  text("Follow the instructions in order to calibrate your skeleton.", 60, 430 );
  text("When your body is calibrated, the game will start autamically.", 60, 460 );
  
  text("Ready to play!", 60, 540 );
  text("You are the space craft. Move left and right to avoid the little monsters", 60, 570 );
  text("Get your hands up and you'll shoot!", 60, 600 );
  text("Try to catch the hearts falling down in order to get more lifes", 60, 630 );
  
  fill(250, 0, 0);
  text("Push to go back to menu", 400, 680 );

}


/*************************************************/
/*********** Start SimpleOpenNI events ***********/
/*************************************************/

void onNewUser(int userId)
{
  if (userId == 1) {
    
    context.startPoseDetection("Psi",userId);
    println("New user Id: " + userId);
    println("Start pose detection");
    
  } else {
    
    // don't calibrate if userId > 1
    println("User "+userId+", We are not interested in.");
  }
}

void onLostUser(int userId)
{
  if (userId == 1) {
    println("Lost User - userId: " + userId);
  }
}

void onStartCalibration(int userId)
{
  println("onStartCalibration - userId: " + userId);
}

void onEndCalibration(int userId, boolean successfull)
{
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);
  
  if (successfull) 
  { 
    println("  UserId = "+userId+" calibrated !");
    context.startTrackingSkeleton(userId);
    // When the user is calibrated we go to the next stage
    iScreen  = nextStage;
  } 
  else 
  {
    // If the calibration is not successfull we try to re-calibrate the user  
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    context.startPoseDetection("Psi",userId);
  }
}

void onStartPose(String pose,int userId)
{
  /*
  function that detects the user calibration pose. When de user
  is calibrated the function start to attemting to calibrate the Skeleton  
  */
  
  println(" onStartPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection ");
  
  context.stopPoseDetection(userId); 
  context.requestCalibrationSkeleton(userId, true);
 
}

void onEndPose(String pose,int userId) {
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}

void onStartSession(PVector pos)
{
  println("onStartSession: " + pos);
}

void onEndSession()
{
  println("onEndSession: ");
}

void onFocusSession(String strFocus,PVector pos,float progress)
{
  println("onFocusSession: focus=" + strFocus + ",pos=" + pos + ",progress=" + progress);
}

void onPush(float velocity, float fangle)
{
  /*
  
  */
  println("PUSH");
  println(pvPushPos.x+","+pvPushPos.y);
  
  // If we are in the game or in the instructions screen 
  // or in the credits screen and there's a push, return to menu
  if ((iScreen == 4) || (iScreen == 6) || (iScreen == 3)) {
    
    bTrackingSkel=false;
    iScreen = 0;
    
  } else{
    
    // If we are in the menu
    
    if ((pvPushPos.x > -550)&&(pvPushPos.x < -150)&&(iScreen == 0)) {
      
      if (!bPlayed){
        // If we haven't played already, we have to calibrate
        iScreen = 1;
      
    } else{
        // If we have played before, we are calibrated so we go directly to the game
        iScreen = 2;
      }
      nextStage = 2;
    }  
    
    if ((pvPushPos.x > -150)&&(pvPushPos.x < 150)&&(iScreen == 0)) {
      // We go to the game instructions
      iScreen = 3;
    } 
    if ((pvPushPos.x > 150)&&(pvPushPos.x < 550)&&(iScreen == 0)) {
      // We go to the credits
      iScreen = 6;
    } 

  }
}

void onPointUpdate(XnVHandPointContext cxt){
  
  //we keep the player position in a PVector
  pvPushPos.x = cxt.getPtPosition().getX();
  pvPushPos.y = cxt.getPtPosition().getY();
  
  // If our hand is over an option, the option is highligthed
  if (((pvPushPos.x > -550)&&(pvPushPos.x < -150))&&(iScreen == 0)) {
    menu.drawOp0Sel();
  }  
  if (((pvPushPos.x > -150)&&(pvPushPos.x < 150))&&(iScreen == 0)) {
    menu.drawOp1Sel();
  }  
  if (((pvPushPos.x > 150)&&(pvPushPos.x < 550))&&(iScreen == 0)) {
    menu.drawOp2Sel();
  }  
}

void onPrimaryPointCreate(XnVHandPointContext pContext, XnPoint3D ptFocus){  
  //println("PUSH onPrimaryPointCreate "+ pContext.getPtPosition().getX() + "/ " + pContext.getPtPosition().getY());
}

void onPrimaryPointDestroy(int nID){
  //println("On point destroy");
}
