
/* Menu Class */

class Menu {
  PImage piOp0;
  PImage piOp0_sel;
  PImage piOp1;
  PImage piOp1_sel;
  PImage piOp2;
  PImage piOp2_sel;
  PImage piLogo;
  
  Menu() {
    piLogo = loadImage("imatges/arkanoid-invaders.jpg");
    piOp0 = loadImage("imatges/menu/img0.jpg");
    piOp1 = loadImage("imatges/menu/img1.jpg");
    piOp2 = loadImage("imatges/menu/img2.jpg");
    piOp0_sel = loadImage("imatges/menu/img0_sel.jpg");
    piOp1_sel = loadImage("imatges/menu/img1_sel.jpg");
    piOp2_sel = loadImage("imatges/menu/img2_sel.jpg");
  }
  void showMenu(){
    fill(25, 44, 125);
    stroke(25, 44, 125);
    rect(0, 25, iWidth, 135);
    image(piLogo, (iWidth/2)-170.5, 30);
    
    image(piOp0, 100, 275);
    image(piOp1, 400, 275);
    image(piOp2, 700, 275); 
  }
  
  void drawOp0Sel(){
    image(piOp0_sel, 100, 275);
  }
  void drawOp1Sel(){
    image(piOp1_sel, 400, 275);
  }
  void drawOp2Sel(){
    image(piOp2_sel, 700, 275);
  }
}
