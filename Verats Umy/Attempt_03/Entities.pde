//--------------------------------------------------------------------------
//                                                                GAMEOBJECT
//--------------------------------------------------------------------------
abstract class GameObject{
  protected float x, y;
  private PImage image;
  
  public GameObject(float xin, float yin, PImage iin){
    x = xin;
    y = yin;
    image = iin;
    
    image.resize(32, 32);
  }

  protected void display(){
    pushMatrix();
    translate(32, 32);
    image(getImage(), x * zoom, y * zoom);
    popMatrix();
  }
  protected void update(){}
  void setPos(float newx, float newy){
    x = newx;
    y = newy;
  }
  
  void setImage(PImage iin){
    image = iin;
  }
  public PImage getImage(){return image;}
}

//--------------------------------------------------------------------------
//                                                                    ENTITY
//--------------------------------------------------------------------------
abstract class Entity extends GameObject{
  //move
  //attack
  //takeDamage
  boolean alive;
  float health;
  float damageReduction;
  float damage;
  
  float startHealth;
  int startX, startY;
  boolean normal;
  //float dropChance;
  // dropChest;
  public Entity(int xin, int yin, PImage iin, float hin, float din){
    super(xin, yin, iin);
    alive = true;
    normal = true;
    health = hin;
    damage = din;
    damageReduction = random(100);
    
    startHealth = hin;
    startX = xin;
    startY = yin;
  }
  
  protected void display(){
    image(getImage(), x * zoom + 32, y * zoom + 32);
  }
  protected void takeDamage(float din){
    float damageTaken = din;
    health -= damageTaken;
    
    levels[currentLevel].currentRoom.text.add(new FloatText(x, y, String.format("%1.2f", damageTaken), "DAMAGE"));
    if (health<=0){
      alive = false;
      kills +=1;
    //  dropChance = random(100);
      //if (dropChance>85){
       //dropChest = new Chest(1,(int)x,(int)y); 
       int goldGain = (int)random(50);
       p.gold += goldGain;    
     levels[currentLevel].currentRoom.text.add(new FloatText(20, 23, String.format("%d", goldGain), "GOLD"));
       pg.update(); 
      }
    }
  
  
  protected void perceive(){}
  
  protected void act(){}
}
//--------------------------------------------------------------------------
//                                                                    STATUE
//--------------------------------------------------------------------------
class Statue extends Entity{
  int gold;
  
  public Statue(int xin, int yin, int gin){
    super(xin, yin, characterSpriteSheet.get((int)random(0,1) * 16, 5*16, 16, 16), 75, 0);
    gold = gin;
  }
  
  protected void takeDamage(float din){
    float damageTaken = din;
    health -= damageTaken;
    
    levels[currentLevel].currentRoom.text.add(new FloatText(x, y, String.format("%1.2f", damageTaken), "DAMAGE"));
    if (health<=0){
      p.gold += gold;
     levels[currentLevel].currentRoom.text.add(new FloatText(20, 23, String.format("%d", gold), "GOLD"));      pg.update();
      alive = false;
    }
  }
  
  
}
//--------------------------------------------------------------------------
//                                                                     ENEMY
//--------------------------------------------------------------------------
class Enemy extends Entity{
  
  Animation attackAnim;    //Attack Animation
  
  float attackTimer;    //How long player still must pause
  float maxAttackTimer = 750f;    //how long the player will pause per attack
  
  float moveTimer;    //Remaining time before they can move
  float maxMoveTimer = 450f;    //Can't spam move to sprint away
  boolean moving;    //Is the player currently moving
  
  float animationTimer;
  float maxAnimationTimer = 200f;    //how long the attackAnimation will take
  boolean animationOver = true;    //Has the animation ended?
  
  int state;
  int maxChaseCounter = 3;    //If you don't move this many times, then go back to wandering
  int chaseCounter;    //Current number of non-moves
  
  int attackType;
  boolean attacking;
  boolean attacked;    //Has fired a ranged shot
  
  float attackRotation;    //ANGLE TO DISPLAY THE ATTACK ANIMATION AT (0, 90, 180, 270)
  float attackAreaX;    //WHAT BLOCKS ARE AFFECTED X
  float attackAreaY;    //WHAT BLOCKS ARE AFFECTED Y
  int detection;
  String direction;
  
  void takeDamage(float din){
  
     super.takeDamage(din);
   
  }
  public Enemy(int xin, int yin, PImage iin, float hin, float din){
    super(xin, yin, iin, hin, din);
    direction = "up";
    state = 0;
    detection = (int)random(5,20);
    attackAnim = new Animation("anim_l_", 8, maxAttackTimer);
  }
  void advanceTimers(){
    float deltaTime = time - lastTime;
    
    attackTimer -= deltaTime;
    if (attackTimer <= 0){
      attacked = false;
      attackTimer = 0;
    }
    
    moveTimer -= deltaTime;
    if (moveTimer <= 0){
      moving = false;
      moveTimer = 0;
    }
    
    animationTimer -= deltaTime;
    if (animationTimer <= 0){
      animationOver = true;
      animationTimer = 0;
    }
  }
  
  void perceive(){
    //Check player distance, if too far, pass
    //else check if they are in view (line of sight)
    //set curret state
   //Math.sqrt(Math.pow(targetX-x,2)+Math.pow(targetY-y,2))
    float playerDist = (float)Math.sqrt(Math.pow(p.x - x,2) + Math.pow(p.y - y,2));
    if (p.stealthValue > detection){
      if ((p.stealthValue-detection)*random(3)>5){
        if (playerDist < 9){
         state = 1; 
        }
      }
    } else if(playerDist < 3){
      state = 1;
    } else {state=0;}
  }
  void randChange(){
    int Num;
   Num = (int)random(1,4);
   //System.out.println(Num);
   if (direction=="up"){
     if (Num == 1){
       direction = "down";
     } else if (Num == 2){
      direction = "right"; 
     } else if (Num == 3){
       direction = "left";
     }
   } else if (direction == "down"){
     if (Num == 1){
       direction = "up";
     } else if (Num == 2){
      direction = "right"; 
     } else if (Num == 3){
       direction = "left";
     }
   } else if (direction == "right"){
     if (Num == 1){
       direction = "down";
     } else if (Num == 2){
      direction = "up"; 
     } else if (Num == 3){
       direction = "left";
     }
   } else if (direction == "left"){
     if (Num == 1){
       direction = "down";
     } else if (Num == 2){
      direction = "right"; 
     } else if (Num == 3){
       direction = "up";
     }
   }
  }
  void wander(){
    if (boss&&!normal){state = 1;}
    perceive();
    float nextx, nexty;
    nextx = x;
    nexty = y;
    if (direction == "up"){
    nextx = x ;
    nexty = y - 1;
    } else if (direction == "down"){
     nexty = y+1;
     nextx = x;
    } else if (direction == "left"){
     nextx = x-1;
     nexty = y;
    } else if (direction == "right"){
     nextx = x+1;
     nexty = y;
    }
    
    for (Entity e : levels[currentLevel].currentRoom.creatures){
      if (nextx == e.x && nexty == e.y){  //CANT GO INSIDE ANOTHER ENTITY
        randChange();
        nextx = x;
        nexty = y;
      }
    }
        
    if (nextx < 0){ nextx = 0; randChange();}
    else if (nextx >= levels[currentLevel].currentRoom.data[0].length()){ nextx = x;randChange();}  //CANT GO OUTSIDE OF SCREEN
    
    if (nexty < 0){ nexty = 0;randChange();}
    else if (nexty >= levels[currentLevel].currentRoom.data.length){ nexty = y;randChange();}
    
    String atNextPos = Character.toString(levels[currentLevel].currentRoom.data[(int)nexty].charAt((int)nextx));    //Check if the next position is an immovable object (Wall or something on map) *also prevents movement on black areas, inaccessible
    if (atNextPos.matches("[#X<^>v]")){  //If colliding, stop movement
      randChange();
      nextx = x;
      nexty = y;
    }
    setPos(nextx, nexty);
    
    moving = true;
    moveTimer = maxMoveTimer;
    //if (atNextPos.matches("[<^>v]")){
      //nextRoom(atNextPos);
    //}
  
  }
  
  void hunt(){
    perceive();
    int distX;
    int distY;
    float nextx=x;
    float nexty=y;
    if (p.x >x){distX = (int)(p.x-x);}
    else {distX = (int)(x-p.x);}
    if (p.y>y){distY = (int)(p.y-y);}
    else {distY = (int)(y-p.y);}
    if (distX > distY){
       if (p.x>x){direction = "right";}
       else{direction = "left";}
    } else{
       if (p.y>y){direction = "down";}
       else{direction = "up";}
    }
    
    if (direction == "up"){
    nextx = x ;
    nexty = y - 1;
    } else if (direction == "down"){
     nexty = y+1;
     nextx = x;
    } else if (direction == "left"){
     nextx = x-1;
     nexty = y;
    } else if (direction == "right"){
     nextx = x+1;
     nexty = y;
    }
    if (nextx == p.x&& nexty == p.y){nextx = x;nexty = y;}
    //System.out.println(p.x + " " + x + " " + p.y + " " + y);
    for (Entity e : levels[currentLevel].currentRoom.creatures){
      if (nextx == e.x && nexty == e.y){  //CANT GO INSIDE ANOTHER ENTITY
        nextx = x;
        nexty = y;
      }
    }
        
    if (nextx < 0){ nextx = 0; direction = "right";}
    else if (nextx >= levels[currentLevel].currentRoom.data[0].length()){ nextx = x;direction = "left";}  //CANT GO OUTSIDE OF SCREEN
    
    if (nexty < 0){ nexty = 0;direction = "down";}
    else if (nexty >= levels[currentLevel].currentRoom.data.length){ nexty = y;direction = "up";}
    
    String atNextPos = Character.toString(levels[currentLevel].currentRoom.data[(int)nexty].charAt((int)nextx));    //Check if the next position is an immovable object (Wall or something on map) *also prevents movement on black areas, inaccessible
    if (atNextPos.matches("[#X]")){  //If colliding, stop movement
    
      nextx = x;
      nexty = y;
    }
    setPos(nextx, nexty);
    if ((distY==0 &&distX==1)||(distX==0&&distY==1)){
      state = 2;
    }
    moving = true;
    moveTimer = maxMoveTimer;
    
    if (state == 1 && nextx == x && nexty == y){
      chaseCounter ++;
      
      if (chaseCounter >= maxChaseCounter){
        state = 0;
        chaseCounter = 0;
      }
    } else {
      chaseCounter = 0;
    }
    //System.out.println(chaseCounter);
  }
  
  void attack(){
    
    int distY,distX;
    if (!attacked){
    if (p.x >x){distX = (int)(p.x-x);}
    else {distX = (int)(x-p.x);}
    if (p.y>y){distY = (int)(p.y-y);}
    else {distY = (int)(y-p.y);}
    if (!((distY==0 &&distX==1)||(distX==0&&distY==1))){
      state = 1;
    }else{
    if (p.x+1 == x &&p.y == y){
      //LEFT
      attackRotation = 0;
    } else if (p.x-1==x &&p.y==y){
     //RIGHT 
     attackRotation = 180;
    } else if (p.y-1 == y &&p.x==x){
     //DOWN 
     attackRotation = 270;
    } else if (p.y+1==y&&p.x==x){
     //UP 
     attackRotation = 90;
    } else{state = 1;}
    animationTimer = maxAnimationTimer;
      attackTimer = maxAttackTimer;
      animationOver = false;
      
    p.takeDamage(damage);
    attacked = true;
  }
    }
  }
  void advanceAttack(){
   if (attackRotation == 0){
        attackAnim.advance((x - 1) * zoom + 32, y * zoom + 32, attackRotation);
      }
      else if (attackRotation == 90){
        attackAnim.advance(x * zoom + 32, (y - 1) * zoom + 32, attackRotation);
      }
      else if (attackRotation == 180){
        attackAnim.advance((x + 1) * zoom + 32, y * zoom + 32, attackRotation);
      }
      else if (attackRotation == 270){
        attackAnim.advance(x * zoom + 32, (y + 1) * zoom + 32, attackRotation);
      } 
  }
  void act(){
    advanceTimers();
    if (attacked){
      advanceAttack();
    }
    if (state == 0&& !moving){
      wander();
    } else if (state == 1&&!moving){
     hunt(); 
    } else if (state == 2){
     attack(); 
    }
    
    //depending on current state
    
    //if dead, play death animation, then delete self
    //if patroling, go to best place to go about route
    //if chasing player, go to best place, if in range, attack
  }
}
  
//--------------------------------------------------------------------------
//                                                                     DUMMY
//--------------------------------------------------------------------------
class Dummy extends Entity{
    public Dummy(int xin, int yin, PImage iin, float hin, float din){
    super(xin, yin, iin, hin, din);
  }
}
//--------------------------------------------------------------------------
//                                                                     THIEF
//--------------------------------------------------------------------------
class Thief extends Entity{ 
  
  //MAKE SURE IT DISAPPEARS IF IT IS HIT
  
  
  PImage baseImage = characterSpriteSheet.get(1*16, 5*16, 16, 16);
  PImage altImage = characterSpriteSheet.get(0, 5*16, 16, 16);
  
  
  float actTimer;    //Remaining time before they can move
  float maxActTimer = 150f;    //Can't spam move to sprint away
  boolean acting;    //Is the player currently moving
  
  boolean isPresent = true;
  
  Item[] inv = new Item[5];  //Stolen Items
  int heldIndex;
  
  int numActions;
  int maxActions = 7;
  
  boolean isActive;
  public Thief(int xin, int yin){
    super(xin, yin, characterSpriteSheet.get(0, 5*16, 16, 16), 50, 0);
    isActive = false;
    baseImage.resize(32, 32);
    altImage.resize(32, 32);
    numActions = maxActions;
    
  }
  public Thief(Thief tin, int xin, int yin){
    super(xin, yin, characterSpriteSheet.get(0, 5*16, 16, 16), 50, 0);
    inv = tin.inv;
    isActive = false;
    baseImage.resize(32, 32);
    altImage.resize(32, 32);
  }
  
  void takeDamage(float din){
    float damageTaken = din;
    health -= damageTaken;
    levels[currentLevel].currentRoom.text.add(new FloatText(x, y, String.format("%1.2f", damageTaken), "DAMAGE"));
    
    if (health <= 0){
      
     int goldGain = (int)random(50, 500);
     p.gold += goldGain;    
     levels[currentLevel].currentRoom.text.add(new FloatText(20, 23, String.format("%d", goldGain), "GOLD"));
     
     pg.update(); 
      die();
      kills +=1;
    }
  }

  void update(){
    if (isPresent){
      if (!acting){
        if (!isActive){
          if (Math.abs(p.x - x) <= 1.0 && Math.abs(p.y - y) <= 1.0){
            steal();
            acting = true;
            actTimer = maxActTimer;
          }
        } else {
          move();
        }
      } else {
      
        actTimer -= deltaTime;
        if (actTimer <= 0){
          actTimer -= deltaTime;
          acting = false;
        }
      
        if (numActions <= 0){
          isActive = false;
          isPresent = false;
          t.leaveRoom();
        }
      }
    }
  }
    
  void steal(){  //If you are inactive, and contact the player, then become active and steal a random item
  if (p.numItems > 0){
    int stealIndex = (int) random(5);
      if (p.numItems < 5){    //If player inventory isn't full
        while (p.inv[stealIndex] == null){    //Keep picking a random index until you find an item
          stealIndex = (int) random(5);  
          heldIndex = stealIndex;
        }
      } 
      //Bypassing if statement or finishing the loop means that the chosen index is valid]
      inv[stealIndex] = p.inv[stealIndex];
      p.inv[stealIndex] = null;
      isActive = true;
      setImage(baseImage);
      
      p.setStats();
      pg.update();
    }
  }
  
  void move(){
    if (this.isActive){
          if (!acting) {
            int dx = 0;
            int dy = 0;
            
            float deltaX = p.x - x;
            float deltaY = p.y - y;
            
            if (deltaX > 0){
              dx = -1;
            } else if (deltaX < 0){
              dx = 1;
            } else {
              dx = 0;
            }
            
            if (deltaY > 0){
              dy = -1;
            } else if (deltaY < 0){
              dy = 1;
            } else {
              dy = 0;
            }
            
            if (Math.abs(deltaX) >= Math.abs(deltaY)){
              dy = 0;
            } else {
              dx = 0;
            }
            
            
      float nextx = x + dx;
      float nexty = y + dy;

      for (Entity e : levels[currentLevel].currentRoom.creatures) {
        if (nextx == e.x && nexty == e.y) {  //CANT GO INSIDE ANOTHER ENTITY
          nextx = x;
          nexty = y;
        }
      }

      if (nextx < 0) { 
        nextx = 0;
      } else if (nextx >= levels[currentLevel].currentRoom.data[0].length()) { 
        nextx = x;
      }  //CANT GO OUTSIDE OF SCREEN

      if (nexty < 0) { 
        nexty = 0;
      } else if (nexty >= levels[currentLevel].currentRoom.data.length) { 
        nexty = y;
      }

      String atNextPos = Character.toString(levels[currentLevel].currentRoom.data[(int)nexty].charAt((int)nextx));    //Check if the next position is an immovable object (Wall or something on map) *also prevents movement on black areas, inaccessible
      if (atNextPos.matches("[#X]")) {  //If colliding, stop movement
        nextx = x;
        nexty = y;
      }

      setPos(nextx, nexty);
      acting = true;
      actTimer = maxActTimer;
      
      numActions --;
    }
  }
}
  
  void checkPresent(Room r){
    if (r.thief){
      int newX = (int)random(LEVEL_WIDTH);
      int newY = (int)random(LEVEL_HEIGHT);
      while (Character.toString(levels[currentLevel].currentRoom.data[newY].charAt(newY)).matches("[X#DL]")){
        newX = (int)random(LEVEL_WIDTH);
        newY = (int)random(LEVEL_HEIGHT);
      }
      
      isActive = false;
      isPresent = true;
      setImage(altImage);
      
      x = newX;
      y = newY;
      
      numActions = maxActions;
    }
  }
  
  void die(){
    if (inv[heldIndex] != null){
      levels[currentLevel].currentRoom.pickUps.add(new PickUp((int)x, (int)y, inv[heldIndex], 0));
      inv[heldIndex] = null;
    }
    
    isPresent = false;
    isActive = false;
    x = 0;
    y = 0;
    
    thiefKills ++;
    t.leaveRoom();
  }
  
  void leaveRoom(){
    levels[currentLevel].currentRoom.thief = false;
    isPresent = false;
    isActive = false;
  }
  
  void display() {
    if (isPresent && levels[currentLevel].currentRoom.thief){
    pushMatrix();
    translate((x + 1) * zoom, (y   + 1) * zoom);
    image(getImage(), 0, 0);    //Display at the proper position
    for (Item i : inv) {
      if (i instanceof Item) {
        if (i.isActive > 0) {
          image(i.image, 0, 0);    //Display items at the proper position
        }
      }
    }
    popMatrix();
  }
  }
}

//--------------------------------------------------------------------------
//                                                                       NPC
//--------------------------------------------------------------------------
class NPC extends Entity{
  String name;
  
  public NPC(String nin, int xin, int yin, PImage iin, float hin, float din){
    super(xin, yin, iin, hin, din);
    name = nin;
  }
}
//--------------------------------------------------------------------------
//                                                              RangedAttack
//--------------------------------------------------------------------------
  class RangedAttack extends GameObject{
    int dx;
    int dy;
    float damage;
    boolean active = true;
    int speed = 3;
    int counter = 0;
    float angle;
    float distanceTraveled = 0;
    float crit;
    boolean boss1 = false;
    RangedAttack(float xin, float yin, PImage imagein, int dxin, int dyin, float din, float ain, float cin){
      super(xin, yin, imagein);
      damage = din;
      dx = dxin;
      dy = dyin;
      angle = ain;
      crit = cin;
      
      if (xin < 0 || xin > LEVEL_WIDTH){
        active = false;
      }
      if (yin < 0 || yin > LEVEL_HEIGHT){
        active = false;
      }
      if (active){
        
        String atNextPos = Character.toString(levels[currentLevel].currentRoom.data[(int)yin].charAt((int)xin));
        if (atNextPos.matches("#")){  //If colliding, stop movement
            active = false;
          
        } else {
          for (Entity e : levels[currentLevel].currentRoom.creatures){
            if ((int)e.x == (int)xin && (int)e.y == (int)yin){
              e.takeDamage(damage + random(-4, 4));
              active = false;
            
            }
          }
        }
      }
    }
    void update(){
      
      float nextX = x + (float)dx / 3;
      float nextY = y + (float)dy / 3;
        
      
      if (nextX < 0 || nextX > LEVEL_WIDTH){
        active = false;
      } else if (nextY < 0 || nextY > LEVEL_HEIGHT){
        active = false;
      }
      if (active){
        String atNextPos = Character.toString(levels[currentLevel].currentRoom.data[(int)nextY].charAt((int)nextX));
        if (atNextPos.matches("#")){  //If colliding, stop movement
            active = false;
          bowHit.play();
        } else {
          for (Entity e : levels[currentLevel].currentRoom.creatures){
            if ((int)e.x == (int)nextX && (int)e.y == (int)nextY){
              if (random(100) < crit){
                e.takeDamage(2 * damage + random(-4, 4));
              } else {
                e.takeDamage(damage + random(-2, 2));
              }
              bowHit.play();
              active = false;
            }
          }
          
          if ((int)t.x == (int)nextX && (int)t.y == (int)nextY && t.isPresent){
            bowHit.play();
            active = false;
            t.takeDamage(2 * damage + random(-4, 4));
          }
          if ((int)p.x == (int)nextX&&(int)p.y==(int)nextY&& boss1){
           p.takeDamage(damage + random(-2, 2)-p.totalDamageReduction);
           active = false;
           bowHit.play();
         }
        setPos(nextX, nextY);
        if (boss1 == false){
        distanceTraveled += Math.abs(dx) + Math.abs(dy);
        if(distanceTraveled > p.activeRange && active){
          active = false;
        }
        }
        }
      }
    }
    
    void display(){
      
      pushMatrix();
      translate((x + 1) * zoom, (y + 1) * zoom);
      rotate(radians(angle));
      image(getImage(), 0, 0);
      popMatrix();
    }
}