
class Rocks{
int x,y;
int radi;
boolean land;
int opacity;
boolean active;
public Rocks(int xin, int yin){
  x = xin+1;
  y = yin+1;
  radi = 1;
  opacity = 100;
  active = true;
  levels[currentLevel].currentRoom.rocks.add(this);
}
float time = 1600;
float maxTime = 1600;
public void update(){
 time -= deltaTime;
 if (time%4 ==0&&radi<20){
   radi += 1;
 }
 if (radi == 16){
   opacity = 255;
   if ((int)p.x+1 == x&&(int)p.y+1==y&&active){
    p.takeDamage(random(15,20)-p.totalDamageReduction); 
   active = false;
   }
   
}
  if (radi == 20){
    active = false;

   }
time -= deltaTime;
//if (time <=-10){
  //  active = false;
    //levels[currentLevel].currentRoom.numDeadRocks++;
  //}
drawRock();
}
public void drawRock(){
  noStroke();
  ellipseMode(RADIUS);
  fill(#504B4B,opacity);
  ellipse(x*zoom,y*zoom,radi,radi);
}
}