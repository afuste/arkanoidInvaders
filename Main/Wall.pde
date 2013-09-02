
/*

Wall Class
Defines the characteristics of a Wall object on the game

*/

class Wall {
      
  float fPositionIniX, fPositionIniY, fPositionEndX, fPositionEndY;
  PVector vNorm; //normal vector of the wall
  int iColor;  
  PVector pvPoint;
  PVector v; //Wall vector
  int iDirection;
  
  Wall() {
    
  }
  
  Wall(float fPositionIniX, float fPositionIniY, float fPositionEndX, float fPositionEndY, int iColor, int iDirection) {
    this.iColor = iColor;
    this.fPositionIniX = fPositionIniX;
    this.fPositionIniY = fPositionIniY;
    this.fPositionEndX = fPositionEndX;
    this.fPositionEndY = fPositionEndY;
    pvPoint = new PVector(fPositionIniX, fPositionIniY, 0.0);
    v = new PVector(fPositionEndX-fPositionIniX, fPositionEndY-fPositionIniY, 0.0);
    v.normalize();
    vNorm = new PVector(1.0, 0.0, 0.0);
    this.iDirection = iDirection; 
  }
  
  void drawWall() {
    stroke(this.iColor);
    strokeWeight(3);
    fill(255);
    line(fPositionIniX, fPositionIniY, fPositionEndX, fPositionEndY);
  }
  
  void calculateNormal(){    
    if (v.y == 0) {
      vNorm.y = -1.0*iDirection;
      vNorm.x = 0.0;
    }else{
      vNorm.y = iDirection*(-v.x*vNorm.x/v.y);
      vNorm.x = iDirection*vNorm.x;
      vNorm.normalize();
    }
  }
  
  PVector getPoint(){
    return pvPoint;
  }
  
  PVector getVector(){
    return v;
  }
  
  PVector getNormal(){
    return vNorm;
  }
}


