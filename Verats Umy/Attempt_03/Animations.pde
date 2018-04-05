
//--------------------------------------------------------------------------
//                                                                 ANIMATION
//--------------------------------------------------------------------------
class Animation{
  int frame;
  int numFrames;
  float mspf = 1000/72;
  PImage[] images;
  float timeOfLastFrame;
  
  public Animation(String imagePrefix, int count, float duration){
    numFrames = count;
    images = new PImage[numFrames + 1];
    
    mspf = duration/numFrames;
    
    for (int i = 0; i < numFrames; i++){
      String filename = imagePrefix + nf(i, 4) + ".png";
      images[i] = loadImage(filename);
      images[i].resize(zoom, zoom);
    }      
    String filename = imagePrefix + nf(numFrames, 4) + ".png";
    PImage tempimage = loadImage(filename);
    tempimage.resize(zoom, zoom);
    images[numFrames] = tempimage;
  }
  
  void advance(float x, float y, float angle){
    if (millis() - timeOfLastFrame >= mspf ){
      frame = (frame + 1) % numFrames;
      timeOfLastFrame = millis();
    } 
    pushMatrix();
    translate(x, y);
    rotate(radians(angle));
    image(images[frame], 0, 0);
    popMatrix();
  }
}
//--------------------------------------------------------------------------
//                                                                FLOAT TEXT
//--------------------------------------------------------------------------
class FloatText{
  float x;
  float y;
  String text;
  int maxTextSize = 30;
  int minTextSize = 15;
  int textSize;
  
  String type;
  
  float frameTimer;
  float maxFrameTimer = 1000/20;
  
  int frame;
  int maxFrames = 15;  //How many frames it should stick around for
  
  int r, g, b;
  
  public FloatText(float xin, float yin, String tin, String type){
    x = xin;
    y = yin;
    text = tin;
    this.type = type;
    if (type == "DAMAGE"){
    textSize = minTextSize + (int)Float.parseFloat(tin);
      if (textSize > maxTextSize){
        textSize = maxTextSize;
      }
        r = 255;
        g = 0;
        b = 0;
    } else if (type == "GOLD"){
      textSize = minTextSize + Integer.parseInt(tin);
      if (textSize > maxTextSize){
        textSize = maxTextSize;
      }
        r = 255;
        g = 255;
        b = 0;
    } else if (type == "MISC"){
      textSize = 20;
      r = 255;
      g = 255;
      b = 255;
      
      x = width / 2;
      y = width / 2;
    }
  }
  
  void display(){
    fill (r,g,b);
    textSize(textSize);
    
    if (type == "DAMAGE" || type == "GOLD" || type == "HEAL"){
      text(text, x * zoom - textWidth(text) / 2, y * zoom - frame);
    } else if (type == "REPAIR"){
      
    } else {
      text(text, x - textWidth(text) / 2, y - frame);
    }
  }
  void update(){
    if (frameTimer <= 0){
      frame ++;
      frameTimer = maxFrameTimer;
    } else {
      frameTimer -= (time - lastTime);
    }
  }
}



//--------------------------------------------------------------------------
//                                                           DEATH ANIMATION
//--------------------------------------------------------------------------
class DeathAnimation{
  int numFrames = 30;
  int currentFrame = 0;
  boolean temp = false;
  String name = "";
  
  public DeathAnimation(){
   int probability = 0;
   String[] first_segments = {"Al", "An", "Br", "Ba", "Co", "Ca", "Dr", "Da", "Di", "Ev", "El", "Er", "Ga", "Ge", 
                              "Gr", "Ha", "He", "Ho", "Hu", "Is", "Ja", "Jo", "Ke", "Ky", "Le", "Li", "Lu", "Ly",
                              "Ma", "Me", "Mi", "Mo", "My", "Ne", "No", "Po", "Pe", "Pa", "Qu", "Ra", "Re", "Ro",
                              "Sc", "Sha", "St", "Th", "To", "Tr", "Va", "Wa", "We", "Wi", "Za"};
   String[] other_segments = {"ex", "ax", "al", "mu", "ri", "ry", "ro", "ast", "gre", "in", "dre", "ol", "on", "yr",
                              "to", "ti", "ui", "uc", "ard", "an", "wa", "yt", "ich", "ont", "ar", "kyn", "kent", "arme",
                              "eni", "larr", "noon", "ode", "in", "use", "end", "de", "ico", "tefo", "ass", "der", "enw",
                              "ot", "ae", "as"};
                              
   name += first_segments[(int)random(first_segments.length)];
   while (true){
     name += other_segments[(int)random(other_segments.length)];
     
      if (random(100) < 10 + 10*probability){
       break;
      }
      probability ++;
    }
  }
  void advance(){
    currentFrame ++;
  }
  
  void display(){
    
    fill(0, 255/numFrames*currentFrame);
    rect(0,0,width,height);
    fill(255, 0,0);
      
    if (boss && BOSS.health < 0 || p.health <= 0){
      textSize(42);
      text("You Died", width/2 - textWidth("You Died")/2, height / 4);
      text("None shall know your name", width/2 - textWidth("None shall know your name")/2, height / 4 + 42);
    } else {
      textSize(42);
      text("You are " + name, width/2 - textWidth("Go Forth" + name)/2, height / 4);    
      text("Go, bring glory to Baile an Láidre", width/2 - textWidth("Go, bring glory to Baile an Láidre")/2, height / 4 + 42);      
    }
    
    textSize(24);
    
    pushMatrix();
    translate(0, 106);
    text("Total Gold = " + p.gold, width/2 - textWidth(String.valueOf("Total Gold = " + p.gold))/2, height / 4 + 42);  //Draw it at the same spot
    
    text("Total Monster Kills * 10 = " + (kills * 10), width/2 - textWidth(String.valueOf("Total Monster Kills * 10 = " + kills * 10))/2, height / 4 + 84);
    
    text("Total Thief Kills * 100 = " + (thiefKills * 100), width/2 - textWidth(String.valueOf("Total Thief Kills * 100 = " + thiefKills * 100))/2, height / 4 + 126);
    
    text("TOTAL = " + (p.gold + kills * 10 + thiefKills * 100), width/2 - textWidth(String.valueOf("TOTAL: " + p.gold + kills * 10 + thiefKills * 100))/2, height / 4 + 168);
    popMatrix();
    
    
    pushMatrix();
    translate(p.x * zoom, p.y * zoom);
    if (currentFrame < numFrames){
      rotate(radians(90/numFrames * currentFrame));
    } else {
      rotate(radians(90));
    }
    image(p.getImage(), 0, 0);
    popMatrix();
  }
}


//--------------------------------------------------------------------------
//                                                           START ANIMATION
//--------------------------------------------------------------------------
class StartAnimation{
  int numFrames = 270;
  int currentIndex = 0;
  
  int numColourFrames = 9;
  int colourFrame = numFrames;
  
  int numTextFrames = 9;
  int textFrame;
  
  float frameTime;
  float animmspf = 1000/10;
  boolean textStarted = false;
  boolean done = false;
  boolean textDone = false;
  
  boolean started = false;
  String[] text = {"",
  "So you wish to leave our village of Baile na Láidre",
  "I trust you know what that entails", 
  "You must take the trial", 
  "You must face the Verats Umy",
                   "You and one other will be given gold for equipment", 
                   "The first to escape the tower will be granted a name and can leave", 
                   "The other shall die",
                   "Remember, once you enter the tower, there is no coming back"};
  public StartAnimation(){
    frameTime = millis() + animmspf;
  }

  void advance(){
    if (!done){
    //text not started
    //text started
    //text done
    if (time >= frameTime){
      if (!textStarted){
        colourFrame -= numFrames / numColourFrames;
        if (colourFrame == 0){
          textStarted = true;
        }
      frameTime += animmspf;
      } else if (textStarted && !textDone){
        if (textFrame % (numFrames / numTextFrames) == 0){
          currentIndex ++;
          if (currentIndex >= text.length - 1){
            textDone = true;
          }
        }
      frameTime += 20 * animmspf;
      } else if (textStarted && textDone){
        
        colourFrame += numFrames / numColourFrames;
        if (colourFrame == numFrames){
          done = true;
        }
      frameTime += animmspf;
      }
      
      
      }
    }
  }
  
  void display(){
    if (!done){
    fill(255, 255 - 255 * colourFrame / numFrames);
    rect(0,0,width, height);
    textSize(24);
    fill(255, 0, 0);
    text(text[currentIndex], width/2 - textWidth(text[currentIndex]) / 2, height/3);
    }
  }
}



//--------------------------------------------------------------------------
//                                                            LOOP ANIMATION
//--------------------------------------------------------------------------
class LoopAnimation{
  //ORDER
  int MRIGHT = 0;
  int MUP = 1;
  int MLEFT = 2;
  int MDOWN = 3;
  
  int ARIGHT = 4;
  int AUP = 5;
  int ALEFT = 6;
  int ADOWN = 7;
  
  int PICKUP = 8;
  
  int[] actions = {0,0,0,0,0,0,0,0,0,0,
                   3,3,
                   8,
                   3,3,3,
                   8,
                   3,3,3,
                   8,
                   3,3,3,
                   8,
                   2,2,2,2,2,2,2,2,
                   6,6,
                   1,
                   2,
                   7,
                   1,
                   5,
                   0,0,0,
                   3,3,3,
                   0,0,0,
                   3,3,  
                   0,0,0,
                   8,
                   2,2,2,2,2,
                   6,6,6,
                   1,1,1,
                   6,6,
                   1,1,
                   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
                   
  int currentFrame = 0;
  
  
  void progressAnimation(){
    if (time >= timeOfNextFrame){
      switch (actions[currentFrame]){
        case(0): p.move(1,0); timeOfNextFrame = time + p.maxMoveTimer; break;
        case(1): p.move(0,-1); timeOfNextFrame = time + p.maxMoveTimer; break;
        case(2): p.move(-1,0); timeOfNextFrame = time + p.maxMoveTimer; break;
        case(3): p.move(0,1); timeOfNextFrame = time + p.maxMoveTimer; break;
        
        case (4): p.attack(RIGHT); if (p.attackType == 1){timeOfNextFrame = time + p.maxAttackTimer;} else {timeOfNextFrame = time + 1.25 * p.maxAttackTimer;} break;
        case (5): p.attack(UP); if (p.attackType == 1){timeOfNextFrame = time + p.maxAttackTimer;} else {timeOfNextFrame = time + 1.25 * p.maxAttackTimer;} break;
        case (6): p.attack(LEFT); if (p.attackType == 1){timeOfNextFrame = time + p.maxAttackTimer;} else {timeOfNextFrame = time + 1.25 * p.maxAttackTimer;} break;
        case (7): p.attack(DOWN); if (p.attackType == 1){timeOfNextFrame = time + p.maxAttackTimer;} else {timeOfNextFrame = time + 1.25 * p.maxAttackTimer;} break;
        
        case(8):if (p.pickUp()){if (currentLevel == 0 && p.x == 13){levels[currentLevel].currentRoom.pickUps.add( new PickUp((int)p.x, (int)p.y, generateItem()));}
        }
      }
    }
    
    currentFrame ++;
    if (currentFrame >= actions.length - 1){
    currentFrame = 0;
    p = new Player(3, 2, characterSpriteSheet.get(0,0,16,16));
    pg = new PlayerGui(p);
    }
  }
}