
class Heart {
  private float fPositionX;
  private float fPositionY;
  private PImage piHeartImg;
  private int iCount;
  private boolean bExists;
  
  Heart(){}
  
  Heart(float posX) {
    this.fPositionX = posX;
    this.fPositionY = -50;
    piHeartImg = loadImage("imatges/vida2.png");
    this.bExists = true;
  }
  
  void goAhead() {
    if (this.bExists){
      this.fPositionY += 5;
      image(piHeartImg, fPositionX, fPositionY);
    }
  }
  
  void destroy(){
    bExists = false;
  }

  boolean craftCollision(float posX) {
    boolean bCollision = false;
    boolean bCollisionX = false;
    boolean bCollisionY = false;
    boolean bCollisionfinal = false;
    
    if (((posX+100)>(fPositionX+40))&&((posX)<(fPositionX+40))){
      bCollisionX = true;
    } 
    if (((posX+100)>(fPositionX))&&((posX)<(fPositionX))){
      bCollisionX = true;
    }
 
    if ((703)<(fPositionY+17)){
      bCollisionY = true;
    }
    
    if ((bCollisionX) && (bCollisionY)) {
      bCollision = true;
      iCount++;
    }
    if (!bCollision) {
      iCount = 0;
    }
    if (iCount == 1){
      bExists = false;
      bCollisionfinal = true;
    
  } else {
      bCollisionfinal = false;
    }
    return bCollisionfinal;
  }
  
}
