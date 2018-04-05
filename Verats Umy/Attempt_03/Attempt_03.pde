import processing.sound.*;
final int PATROL = 0;
final int CHASE = 1;
final int DIE = 2;
boolean win=false;
final int LEVEL_WIDTH = 31;
final int LEVEL_HEIGHT = 21;

final int MAX_DURABILITY = 200;      ////MAKE IT 200 AFTER TESTING IS DONE

final int zoom = 32;

int paused = -1;
int kills = 0;
int thiefKills = 0;
float time;  
float lastTime = 0;
float deltaTime;
int counter  = -1;  //DEBUG STUFF, TO CHECK IF IT'S RUNNING PROPERLY

float mspf = 1000/90;  //HOW FAST THE GAME CAN RUN
float timeOfNextFrame = mspf;
 
PImage tileSpriteSheet;    //SPRITE SHEETS
PImage characterSpriteSheet;
PImage helmetSpriteSheet;
PImage armourSpriteSheet;
PImage meleeSpriteSheet;
PImage shieldSpriteSheet;
PImage rangedSpriteSheet;

PImage defaultBackground;   //Basic background Texture
SoundFile bowShot,walk,swordSwing,bowHit;
Player p;  //PLAYER
PlayerGui pg;

Thief t;

int numLevels = 5;
Level[] levels;
int currentLevel;
int levelId = 00;

int clearCounter;
int maxClearCounter = 32;

boolean boss = false;
boolean[] switches = new boolean[5];  
float attackTimer = 40000f;
float maxAttack = 40000f;
float callTimer = 0f;

DeathAnimation deathAnim;
StartAnimation startAnim;
LoopAnimation loopAnim;

int frame = 0;

void setup(){
  switches[0] = false;
  switches[1] = false;
  switches[2] = false;
  switches[3] = false;
  switches[4] = false;
  imageMode(CENTER);
  bowShot = new SoundFile(this, "ArrowShot.mp3");
  walk = new SoundFile(this,"walk.mp3");
  swordSwing = new SoundFile(this,"SwordSwing.mp3");
  bowHit = new SoundFile(this,"wallHit.mp3");
  
  tileSpriteSheet = loadImage("tileSpriteSheet.png");
  characterSpriteSheet = loadImage("characterSpriteSheet.png");
  helmetSpriteSheet = loadImage("helmetSpriteSheet.png");
  armourSpriteSheet = loadImage("armourSpriteSheet.png");
  meleeSpriteSheet = loadImage("meleeSpriteSheet.png");
  shieldSpriteSheet = loadImage("shieldSpriteSheet.png");
  rangedSpriteSheet = loadImage("rangedSpriteSheet.png");
  
  defaultBackground = tileSpriteSheet.get(16 * 1, 16 * 0, 16, 16);
  
  
  levels = new Level[5];
  for (int i = 0; i < numLevels; i++){
    currentLevel = i;
    levels[i] = new Level(loadStrings("Level_" + nf(i + 1, 2) + ".txt"));
  }
  
  currentLevel = 0;//change back to 0
if (currentLevel!=4){
  levels[currentLevel].currentRoom.thief = true;
}
  
  PImage player = characterSpriteSheet.get(0,0,16,16);      //MAKE PLAYER IMAGE WITH PANTS
  
  player.resize(zoom, zoom);
  p = new Player(3, 2, player);
  t = new Thief(17, 10);
  pg = new PlayerGui(p);
  
  deathAnim = new DeathAnimation();
  startAnim = new StartAnimation();
  loopAnim = new LoopAnimation();
  
  size(1056, 800);
  frameRate(60);
}
void draw(){
  if (currentLevel == 4){
   boss = true; 
  }
  
  if (startAnim.started){
    if (paused < 0 && p.health > 0 && startAnim.done){
      time = millis();
      deltaTime = time - lastTime;//Used several times for cooldowns
    
    
      if (time > timeOfNextFrame){    //If enough time has elapsed
  
  
        clear();
      
        levels[currentLevel].displayCurrent();
        levels[currentLevel].currentRoom.updateEntities();
        levels[currentLevel].currentRoom.displayEntities();
        int s =levels[currentLevel].currentRoom.creatures.size();
      
        for (int i = 0; i<s;i++){
          if (!levels[currentLevel].currentRoom.creatures.get(i).alive){
            s--;
            levels[currentLevel].currentRoom.creatures.remove(i);
          }
        }
      
        t.update();
        t.display();
      
        p.update();    //UPDATE AND DISPLAY PLAYER
        p.display();
      
        pg.update();
        pg.display();
      
        levels[currentLevel].currentRoom.displayText();
      
        levels[currentLevel].currentRoom.displayStealth();    //Ensures that the player is behind the stealth areas, for the visual effect
        timeOfNextFrame = time + mspf;
      }
      lastTime = time;
      clearCounter++;
      if (clearCounter == maxClearCounter){
        levels[currentLevel].currentRoom.clearUsed();
        clearCounter = 0;
      }
  
    } else {
    
      time = millis();
      clear();
      levels[currentLevel].displayCurrent();
      levels[currentLevel].currentRoom.displayEntities();
      
      t.display();
     
      
      levels[currentLevel].currentRoom.displayStealth();
      
      if (p.health <= 0){
        deathAnim.display();
        deathAnim.advance();
      } else {
        p.display();
        
        pg.update();
        pg.display();
      }
        
        if (startAnim.started && !startAnim.done){
          startAnim.advance();
          startAnim.display();
        }
        timeOfNextFrame += deltaTime;
      }
      
  if (boss){
   bossBattleUpdate(); 
  }
  
      timeOfNextFrame = time + mspf;
      
      
    } else {    //Still looping animation
      
      time = millis();
      
      if (time >= timeOfNextFrame){
      clear();
      
      levels[currentLevel].displayCurrent();
        levels[currentLevel].currentRoom.updateEntities();
      levels[currentLevel].currentRoom.displayEntities();
      
      loopAnim.progressAnimation();
      
      p.update();
      p.display();
      }
    }
  } 
  boolean horde = false;
  boolean arrows = false;
  boolean rocks = false;
  boolean bossHPlow = false;
  PImage arrow;
  //boolean electricitry = false; will add this in after other two
  
  void arrows(){
    arrow = loadImage("Arrow.png");
    if (arrows){
    RangedAttack attack1, attack2,attack3,attack4,attack5,attack6,attack7,attack8;
    attack1 = new RangedAttack(10, 1, arrow, 0, 1, random(5,15), 270, 0);
    attack2 = new RangedAttack(20,1,arrow,0,1,random(5,15),270,0);
    attack3 = new RangedAttack(15,19,arrow,0,-1,random(5,15),90,0);
    attack4 = new RangedAttack(1,7,arrow,1,0,random(5,15),180,0);
    attack5 = new RangedAttack(1,13,arrow,1,0,random(5,15),180,0);
    attack6 = new RangedAttack(30,4,arrow,-1,0,random(5,15),0,0);
    attack7 = new RangedAttack(30,10,arrow,-1,0,random(5,15),0,0);
    attack8 = new RangedAttack(30,16,arrow,-1,0,random(5,15),0,0);
    attack1.boss1 = true;
    attack2.boss1 = true;
    attack3.boss1 = true;
    attack4.boss1 = true;
    attack5.boss1 = true;
    attack6.boss1 = true;
    attack7.boss1 = true;
    attack8.boss1 = true;
    levels[currentLevel].currentRoom.other.add(attack1);
    levels[currentLevel].currentRoom.other.add(attack2);
    levels[currentLevel].currentRoom.other.add(attack3);
    levels[currentLevel].currentRoom.other.add(attack4);
    levels[currentLevel].currentRoom.other.add(attack5);
    levels[currentLevel].currentRoom.other.add(attack6);
    levels[currentLevel].currentRoom.other.add(attack7);
    levels[currentLevel].currentRoom.other.add(attack8);
    }
  }
void rocks(){
    int x1,x2,y1,y2,x,y;
    if (!bossHPlow){
      for (int i = 0; i <8;i++){
        x = (int)random(2,29); 
     y = (int)random(2,20);
        while(Character.toString(levels[currentLevel].currentRoom.data[(int)y].charAt((int)x)).matches(("[#X]"))){
          
     x = (int)random(2,29); 
     y = (int)random(2,20);
        }
     Rocks rock = new Rocks(x,y);
    
      }
    }else{
    x1 = (int)random(2,29);
    x2 = (int)random(2,29);
    y1 = (int)random(2,20);
    y2 = (int)random(2,20);
    while(Character.toString(levels[currentLevel].currentRoom.data[(int)y1].charAt((int)x1)).matches(("[#X]"))){
     x1 = (int)random(2,29); 
     y1 = (int)random(2,20);
    }
    while(Character.toString(levels[currentLevel].currentRoom.data[(int)y2].charAt((int)x2)).matches(("[#X]"))){
     x2 = (int)random(2,29); 
     y2 = (int)random(2,20);
    }
    Rocks rock1 = new Rocks(x1,y1);
    Rocks rock2 = new Rocks(x2,y2);
    }
  }

  void advanceTimers(){
    attackTimer -= deltaTime;
    callTimer += deltaTime;
    if (bossHPlow == false){//changes the booleans at each time if the bosses health is low
    if (attackTimer <40000 && attackTimer >25000){
      rocks = false;
      arrows = true;
      horde = false;
     System.out.println(attackTimer);
    } else if (attackTimer <=20000 && attackTimer >= 15000){
      arrows = false;
      rocks = true;
      horde = false;
    } else if (attackTimer<=10000 && attackTimer >= 5000){
      rocks = false;
      arrows = false;
      horde = true;
     
    }else if (attackTimer<=0){
      attackTimer = maxAttack; 
    }
    else{
     arrows = false;
     rocks = false;
     //electricity = true;
    }
    
    }
    if (callTimer >=750){
      //System.out.println(callTimer);
     if (arrows){arrows();}
     if (rocks){rocks();}
     if (horde){horde();}
     callTimer = 0;
    } else{
      //callTimer += deltaTime;
     //attackTimer = maxAttack;  
    }
}

void horde(){
 Enemy horde;
  for (int i = 0; i <3;i++){
     horde = new Enemy(10,16,characterSpriteSheet.get(16, 16 * 3, 16, 16),25,5);
     levels[currentLevel].currentRoom.creatures.add(horde);
 }
}
boolean spwn = false;
Enemy BOSS;
void bossBattleUpdate(){
  advanceTimers();
  if (!spwn){
   BOSS = new Enemy(10,16,characterSpriteSheet.get(16, 5*16, 16, 16),500,30);
   BOSS.normal = false;
  spwn = true;
  levels[currentLevel].currentRoom.creatures.add(BOSS);
  
}
if (BOSS.health< 100){
 bossHPlow = true; 
 arrows = true;
 horde = true;
}
if (BOSS.health <=0){
 win = true;
}
//levels[currentLevel].currentRoom.creatures.add(BOSS);
}
void keyPressed(){
  if (!startAnim.started && !startAnim.done){
    p = new Player(3, 2, characterSpriteSheet.get(0,0,16,16));
    pg = new PlayerGui(p);
    startAnim.started = true;
  }else if (!startAnim.done){
    startAnim.done = true;
  }
  
  
  if (p.health > 0){
    if (!p.attacked && paused < 0){
      if (key == 'w' || key == 'W'){p.move(0, -1);}
      if (key == 'a' || key == 'A'){p.move(-1, 0);}
      if (key == 's' || key == 'S'){p.move(0, 1);}
      if (key == 'd' || key == 'D'){p.move(1, 0);} 
      if (keyCode == UP){p.attack(UP); p.attackAnim.frame = 0;}
      if (keyCode == LEFT){p.attack(LEFT); p.attackAnim.frame = 0;}
      if (keyCode == DOWN){p.attack(DOWN); p.attackAnim.frame = 0;}
      if (keyCode == RIGHT){p.attack(RIGHT); p.attackAnim.frame = 0;}
      if (keyCode == SHIFT){p.sneaking *= -1; p.setStats();}
      if (key == ' '){
        if (p.pickUp()){
          if (currentLevel == 0 && p.x == 13){    //Keep generating new items if in the first room
            levels[currentLevel].currentRoom.pickUps.add( new PickUp((int)p.x, (int)p.y, generateItem()));
          }
        } else {
          p.activate();
        }
      }
    }  else {
      if (key == '1' || key == '2'){      //EQUIP/UNEQUIP MAIN/OFFHAND WEAPONS
        int index = Integer.parseInt(Character.toString(key)) + 1;
        if (p.inv[index] instanceof Item){
          if (p.inv[4] instanceof Item){
            p.inv[4].isActive = -1;
          }
          p.inv[index].isActive *= -1;
        }
        p.attackType = 1;
      }
    
      if (key == '3' && p.inv[4] instanceof Item){      //EQUIP/UNEQUIP BOW
        p.inv[4].isActive *= -1;
      
        if (p.inv[2] instanceof Item){
        p.inv[2].isActive = -1;
        }
        if (p.inv[3] instanceof Item){
        p.inv[3].isActive = -1;
        }
      
        p.attackType = 2;
      }
    
      p.setStats();
    }
    if (key == 'e' || key == 'E'){paused *= -1;}
  }
}

void changeLevel(int direction){
  currentLevel += direction;
}



public Item generateItem(){    //To generate a random ietm, specifically for first room
  if (p.y == 4){
    PImage image = helmetSpriteSheet.get(16 * (int)random(3), 16 * (int)random(8), 16, 16);
    image.resize(32, 32);
    Helmet helmet = new Helmet(image, random(10), 0);
    return helmet;
    
  } else if (p.y == 7){
    PImage image = armourSpriteSheet.get(16 * (int)random(11), 16 * (int)random(9), 16, 16);
    image.resize(32, 32);
    Armour armour = new Armour(image, random(15, 35), 0);
    return armour;
  } else if (p.y == 10){
    PImage image = meleeSpriteSheet.get(16 * (int)random(9), 16 * (int)random(9), 16, 16);
    image.resize(32, 32);
    Melee melee = new Melee(image, random(5, 15), random(15, 35), 1);
    return melee;
  } else if (p.y == 13){
    PImage image = shieldSpriteSheet.get(16 * (int)random(8), 16 * (int)random(6), 16, 16);
    image.resize(32, 32);
    Shield shield = new Shield(image, random(5, 15), random(1, 9), 1);
    return shield;
  } else {
    PImage image = rangedSpriteSheet.get(16 * (int)random(1), 16 * (int)random(4), 16, 16);
    image.resize(32, 32);
    Ranged ranged = new Ranged(image, random(0, 5), random(10, 30), 16);
    return ranged;
  }
}

public Item generate(String type, int value){
  Item item = null;
  if (type == "HELMET"){
    PImage image = helmetSpriteSheet.get(16 * (int)random(3), 16 * (int)random(8), 16, 16); 
    image.resize(32, 32); 
    Helmet helmet = new Helmet(image, random(value / 10), 0); 
    item = helmet;
    
  } else if (type == "ARMOUR"){
    PImage image = armourSpriteSheet.get(16 * (int)random(11), 16 * (int)random(9), 16, 16); 
    image.resize(32, 32); 
    Armour armour = new Armour(image, random(value / 10, value / 5), 0); 
    item = armour;
    
  } else if (type == "MELEE"){
    PImage image = meleeSpriteSheet.get(16 * (int)random(9), 16 * (int)random(9), 16, 16);
    image.resize(32, 32);
    Melee melee = new Melee(image, random(value / 30, value / 10), random(value / 10, value / 5), 1);
    item = melee;
    
  } else if (type == "SHIELD"){
    PImage image = shieldSpriteSheet.get(16 * (int)random(8), 16 * (int)random(6), 16, 16);
    image.resize(32, 32);
    Shield shield = new Shield(image, random(value / 30, value / 10), random(value / 30, value / 15), 1);
    item = shield;
    
  } else if (type == "RANGED"){
    PImage image = rangedSpriteSheet.get(16 * (int)random(1), 16 * (int)random(4), 16, 16);
    image.resize(32, 32);
    Ranged ranged = new Ranged(image, random(0, value / 30), random(value / 15, value / 5), random(12, 20));
    item = ranged;
  }
  item.value = value;
  return item;
}