
class Particle {

  public PVector vPosition;
  public PVector vAux;
  public PVector vSpeed;
  public float fGravity;
  public float fh;
  public int iParticleType;
  Wall w_Wall;
  PImage monster1, monster2, monster3, monster4;
  int iCount = 0;
  Bullet b_Bullet;
  boolean bExists = true;
  
  Particle(float fPositionX, float fPositionY, float fSpeedX, float fSpeedY, int iParticleType) {
    this.iParticleType = iParticleType;
    this.vSpeed = new PVector(fSpeedX, fSpeedY, 0.0);
    this.vAux = new PVector(0.0, 0.0, 0.0);
    this.vPosition = new PVector(fPositionX, fPositionY, 0.0);
    this.fGravity = 9.8;
    this.fh = 0.1;
    w_Wall = new Wall();
    b_Bullet = new Bullet();
    
    //Load monster images
    monster1 = loadImage("imatges/bitxo1.png");
    monster2 = loadImage("imatges/bitxo2.png");
    monster3 = loadImage("imatges/bitxo3.png");
    monster4 = loadImage("imatges/bitxo4.png");
  }
  
  
  void goAhead(){
    
    // Using Euler's method, we calculate the new speed and position
    
    //Position
    this.vAux.x = this.vSpeed.x;
    this.vAux.y = this.vSpeed.y;
    this.vAux.z = this.vSpeed.z;
    
    this.vAux.mult(this.fh);
    this.vPosition.add(this.vAux);
    
    //Speed
    this.vSpeed.y = this.vSpeed.y + (this.fh * this.fGravity);
    this.vSpeed.x = this.vSpeed.x;
    
    if (vPosition.y < -10) this.bExists = false;
    
  }
  
  void drawParticle(){

    if (this.bExists){
      switch (this.iParticleType) {
        case 0:
          image(monster1, vPosition.x, vPosition.y);
          break;
        case 1:
          image(monster2, vPosition.x, vPosition.y);
          break;
        case 2:
          image(monster4, vPosition.x, vPosition.y);
          break;
      }
    }
  }
  
  void collision(Wall wall, PVector norma, int iWallType, PVector pvPoint){
    
    w_Wall = wall;
    
    //1.Calculate vector from the particle to the wall
    
    //1.1.Get point from the wall
    PVector pvWallPoint = new PVector();
    pvWallPoint.x = pvPoint.x;
    pvWallPoint.y = pvPoint.y;
    
    //1.2.Calculate vector
    PVector p = new PVector(((this.vPosition.x)-pvWallPoint.x), ((this.vPosition.y)-pvWallPoint.y), 0.0);
    PVector n = new PVector();
    
    //Calculate normal to the wall
    n.x = norma.x;
    n.y = norma.y;
    
    float a = PVector.angleBetween(n, p); //angle between normal and vector wall-particle
    
    //if cos(angle) between normal and vector <= 0

    if (cos(a) <= 0) {
      //Change particle speed
      
      //Cas paret horitzontal:
      switch(iWallType){
        case 1: this.vSpeed.y= -this.vSpeed.y;
          break;
        case 2: this.vSpeed.x= -this.vSpeed.x;
          break;  
        case 3: this.vSpeed.y= -this.vSpeed.y;
          break;  
        case 4: this.vSpeed.x= -this.vSpeed.x;
          break;  
      }  
    }
  }  
  
  boolean craftCollision(float posX) {
    
    // We calculate particle-craft collision using bounding boxes
    
    boolean bCol = false;
    boolean bColX = false;
    boolean bColY = false;
    boolean bFinalCol = false;
    
    if (((posX+100)>(vPosition.x+35))&&((posX)<(vPosition.x+35))){
      bColX = true;
    } 
    if (((posX+100)>(vPosition.x))&&((posX)<(vPosition.x))){
      bColX = true;
    }
 
    if ((703)<(vPosition.y+17)){
      bColY = true;
    }
    
    if ((bColX) && (bColY) && this.bExists) {
      bCol = true;
      iCount++;
    }
    if (!bCol) {
      iCount = 0;
    }
    if (iCount == 1){
      bFinalCol = true;
    } else {
      bFinalCol = false;
    }
    return bFinalCol;
  }
  
  void bulletCollision(Bullet b) {
    b_Bullet = b;
    float fBulletX = b_Bullet.getX();
    float fBulletY = b_Bullet.getY();
    if ((fBulletX<(this.vPosition.x+35))&&(fBulletX>this.vPosition.x)){
      if (((fBulletY-10)<this.vPosition.y+35)&&((fBulletY+10)>this.vPosition.y)){
        
        // Bullet collision: we kill the monster
        this.bExists = false;

      }
    }
  }
  
  boolean particleExists(){
   return this.bExists; 
  }
}
