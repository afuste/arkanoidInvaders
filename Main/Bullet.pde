
class Bullet {
  private float fPositionX;
  private float fPositionY;
  private int iDirection;  //-1 --> your bullets / 1--> monster bullets
  private boolean bExists;
  
  Bullet(){}
  
  Bullet(float posX, float posY, int direct) {
    this.fPositionX = posX;
    this.fPositionY = posY;
    this.iDirection = direct;
    this.bExists = true;
    
    if (this.iDirection == -1) {
      //asShoot = minim.loadSample("sounds/shoot.wav");
      //asShoot.trigger();
    }
  }
  
  void goAhead() {
    this.fPositionY += 15*iDirection;
    stroke(255);
    strokeWeight(5);
    line(this.fPositionX, this.fPositionY - 10, this.fPositionX, this.fPositionY + 10);
  }
  
  boolean existeix() {
    return this.bExists;
  }
  
  void destroy() {
    this.bExists = false;
  }
  float getY(){
    return this.fPositionY;
  }
  float getX(){
    return this.fPositionX;
  }
  
  void setX(float x) {
    this.fPositionX = x;
  }
  
}
