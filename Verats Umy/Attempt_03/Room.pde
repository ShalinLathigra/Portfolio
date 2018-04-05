

class Level{
  Room[][] rooms;
  int currentRoomX;
  int currentRoomY;
  String[] levelData;
  int id;
  
  boolean cleared;
  
  Room currentRoom;
  
  //Map naming: Map_*what level it is on*_*RoomNumber*
  
  Level(String[] data){
    levelData = data;
    rooms = new Room[levelData.length][levelData[0].length()];
    
    id = levelId + 1;
    levelId ++;
    
    cleared = false;
    for (int y = 0; y < data.length; y++){
    for (int x = 0; x < data[0].length(); x++){
      if (Character.toString(levelData[y].charAt(x)).matches("[0-9]")){
        rooms[x][y] = new Room(loadStrings("Map_"+ nf(id, 2) + "_" + nf(Integer.parseInt(Character.toString(levelData[y].charAt(x))), 2) + ".txt"));
        if (Character.toString(levelData[y].charAt(x)).matches("0")){
          currentRoomX = x;
          currentRoomY = y;          
        }
      }
    }
    }
    currentRoom = rooms[currentRoomX][currentRoomY];
  }
  
  
  void changeRoom(int direction){
     switch(direction){
     case LEFT:   currentRoomX --; p.x = LEVEL_WIDTH; break;
     case UP:     currentRoomY --; p.y = LEVEL_HEIGHT; break;
     case RIGHT:  currentRoomX ++; p.x = 0;  break;
     case DOWN:   currentRoomY ++; p.y = 0;  break;
    }
    
    System.out.println(currentRoomX + " " + currentRoomY);
    currentRoom = rooms[currentRoomX][currentRoomY];
    
    t.checkPresent(currentRoom);
  }
  
  void displayCurrent(){
    rooms[currentRoomX][currentRoomY].display();
  }
}

class Room{    //All only for the current room, nothing carries over between rooms
  int[][] exits;
  
  int[][] levers;
  
  int numLevers;
  int checkedLevers;
  
  String[] data;
  PImage[][] background;  
  
  int statues;  
  boolean thief;
  
  ArrayList<Entity> creatures = new ArrayList<Entity>();  //ALL MOVING CREATURES
  
  ArrayList<PickUp> pickUps = new ArrayList<PickUp>();  //ALL PICKUPS
  ArrayList<Chest> chests = new ArrayList<Chest>();  //ALL CHESTS
  
  ArrayList<FloatText> text = new ArrayList<FloatText>();  //ALL FLOATING TEXT OBJECTS
  
  ArrayList<RangedAttack> other = new ArrayList<RangedAttack>();  //Active ranged attacks
  
  ArrayList<HealStation> healStations = new ArrayList<HealStation>();    //All heal stations
  ArrayList<RepairStation> repairStations = new ArrayList<RepairStation>();    //All repair stations
  ArrayList<StealthArea> stealthAreas = new ArrayList<StealthArea>();   //All Stealth Areas
  ArrayList<Rocks> rocks = new ArrayList<Rocks>();//all falling rocks
  
  
   Room(String[] mapData){    //GENERATING A ROOM
    exits = new int[0][2];
    data = mapData;
    background = new PImage[data.length][data[0].length()];
    thief = random(100) > 80;  
    if (random(10) >= 6)
      statues = (int)random(5);
      
    int grass = (int)random(1, 3);
    float grassProb = 15.75 * grass;
      
//    PImage itemPickUpBase = backgroundSpriteSheet.get(17 * 18, 17 * 13, 16, 16);
    for (int y = 0; y < data.length; y++){
      for (int x = 0; x < data[y].length(); x++){
        //Add an image to PImage at the given point (x,y)
        //Image displayed depends on the data at that point. Player is not displayed. MapData used later for collisions and shite
        
        if (data[y].charAt(x) == '#'){  //WALLS
          background[y][x] = tileSpriteSheet.get(0, 0, 16, 16);
        } else {
          background[y][x] = defaultBackground;
          
        }
        
        if (data[y].charAt(x) == 'M'){  //MONSTERS
          PImage temp = characterSpriteSheet.get(16 * 1, 16 * 3, 16, 16);
          temp.resize(zoom, zoom);
          Enemy monster = new Enemy(x, y, temp, random(25 + 25 * currentLevel, 50 + 50 * currentLevel), random(5, 25));
          creatures.add(monster);
          
          
        } else if (data[y].charAt(x) == 'D'){  //MONSTERS
          PImage temp = characterSpriteSheet.get(0, 10 * 16, 16, 16);
          temp.resize(zoom, zoom);
          Dummy dummy = new Dummy(x, y, temp, 2500, 0);
          creatures.add(dummy);
          
        } else if (data[y].charAt(x) == 'H'){  //HELMET STAND
          PImage image = helmetSpriteSheet.get(16 * (int)random(3), 16 * (int)random(8), 16, 16);
          image.resize(32, 32);
          PickUp helmPickUp = new PickUp(x, y, new Helmet(image, random(10, 30), 0));
          if (currentLevel != 0){
            helmPickUp.heldItem.cost = 0;
          }  
          pickUps.add(helmPickUp);
          
        } else if (data[y].charAt(x) == 'A'){  //ARMOUR STAND
          PImage image = armourSpriteSheet.get(16 * (int)random(11), 16 * (int)random(9), 16, 16);
          image.resize(32, 32);
          PickUp armourPickUp = new PickUp(x, y, new Armour(image, random(15,45), 0));
          if (currentLevel != 0){
            armourPickUp.heldItem.cost = 0;
          }  
          pickUps.add(armourPickUp);
          
        } else if (data[y].charAt(x) == 'W'){  //WEAPONS STAND
          PImage image = meleeSpriteSheet.get(16 * (int)random(9), 16 * (int)random(9), 16, 16);
          image.resize(32, 32);
          PickUp weaponPickUp = new PickUp(x, y,  new Melee(image, random(10, 20), random(10,30), 1));
          if (currentLevel != 0){
            weaponPickUp.heldItem.cost = 0;
          }  
          pickUps.add(weaponPickUp);
          
        } else if (data[y].charAt(x) == 'S'){  //SHIELD STAND
          PImage image = shieldSpriteSheet.get(16 * (int)random(8), 16 * (int)random(6), 16, 16);
          image.resize(32, 32);
          PickUp shieldPickUp = new PickUp(x, y,  new Shield(image, random(15, 25), random(5, 15), 1));
          if (currentLevel != 0){
            shieldPickUp.heldItem.cost = 0;
          }
          pickUps.add(shieldPickUp);
          
        } else if (data[y].charAt(x) == 'B'){  //BOW STAND
          PImage image = rangedSpriteSheet.get(16 * (int)random(1), 16 * (int)random(4), 16, 16);
          image.resize(32, 32);
          PickUp bowPickUp = new PickUp(x, y,  new Ranged(image, random(5), random(5, 15), 4 * (int)random(4,8)));
          if (currentLevel != 0){
            bowPickUp.heldItem.cost = 0;
          }
          pickUps.add(bowPickUp);
          
        } else if (data[y].charAt(x) == 'C'){  //CHEST
          chests.add(new Chest(10, x, y));
          
        } else if (data[y].charAt(x) == 'L'){  //LEVERS
          background[y][x] = tileSpriteSheet.get(16 * 1, 16 * 2, 16, 16);
          numLevers++;
          
        } else if (data[y].charAt(x) == '>'){  //RIGHT SIDE EXIT INDICATOR
          background[y][x] = tileSpriteSheet.get(16 * 1, 16 * 1, 16, 16);
          addExit(x, y);
          
        }  else if (data[y].charAt(x) == '<'){  //LEFT SIDE EXIT INDICATOR
          background[y][x] = tileSpriteSheet.get(16 * 0, 16 * 1, 16, 16);
          addExit(x, y);
          
        }  else if (data[y].charAt(x) == '^'){  //UP SIDE EXIT INDICATOR
          background[y][x] = tileSpriteSheet.get(16 * 2, 16 * 0, 16, 16);
          addExit(x, y);
          
        }  else if (data[y].charAt(x) == 'v'){  //DOWN SIDE EXIT INDICATOR
          background[y][x] = tileSpriteSheet.get(16 * 3, 16 * 0, 16, 16);
          addExit(x, y);
          
        } else if (data[y].charAt(x) == 'R'){  //REPAIR STATIONS
          PImage tempImage = tileSpriteSheet.get(16 * 3, 16 * 1, 16, 16);
          tempImage.resize(32, 32);
          repairStations.add(new RepairStation(tempImage, x, y));
          
        } else if (data[y].charAt(x) == 'h'){  //HEAL STATIONS
          PImage tempImage = tileSpriteSheet.get(16 * 2, 16 * 1, 16, 16);
          tempImage.resize(32, 32);
          healStations.add(new HealStation(tempImage, x, y));
          
        } else if (data[y].charAt(x) == 's'){  //STEALTH AREAS
            PImage tempImage = tileSpriteSheet.get(16 * 0, 16 * 2, 16, 16);
            tempImage.resize(32, 32);
            stealthAreas.add(new StealthArea(tempImage, x, y));
        } else if (data[y].charAt(x) == '/' && currentLevel > 0){  //STEALTH AREAS PART 2
         if (random(0, 100) < grassProb){
            PImage tempImage = tileSpriteSheet.get(16 * 0, 16 * 2, 16, 16);
            tempImage.resize(32, 32);
            stealthAreas.add(new StealthArea(tempImage, x, y));
          }
        } else if (data[y].charAt(x) == '+'){  //ASCEND
          PImage tempImage = tileSpriteSheet.get(16 * 0, 16 * 3, 16, 16);
          tempImage.resize(32, 32);
          background[y][x] = tempImage;
          
          
        } else if (data[y].charAt(x) == '-'){  //DESCEND
          PImage tempImage = tileSpriteSheet.get(16 * 1, 16 * 3, 16, 16);
          tempImage.resize(32, 32);
          background[y][x] = tempImage;
          
        } else if (data[y].charAt(x) == 'X'){  //BLANK SPACES
          background[y][x] = createImage(1,1,RGB);
          
        }
        
        
        if (background[y][x] instanceof PImage){
          background[y][x].resize(zoom, zoom);
        }
      }
    }
    
    for (int i = 0; i < statues; i++){
      int y = (int)random(LEVEL_HEIGHT);
      int x = (int)random(LEVEL_WIDTH);
      while (data[y].charAt(x) != '/'){
        y = (int)random(LEVEL_HEIGHT);
        x = (int)random(LEVEL_WIDTH);
      }
      creatures.add(new Statue(x, y, (int)random(300)));
    }
  }
  
  void display(){
    for (int y = 0; y < background.length; y++){
      for (int x = 0; x < background[y].length; x++){
        if (background[y][x] instanceof PImage){
          image(background[y][x], zoom * x + 32, zoom * y + 32);
        }
      }
    }
  }
  
  void updateEntities(){
    for (Rocks r: rocks){
     r.update(); 
    }
    for (int i = 0; i < rocks.size(); i++){
      Rocks r = rocks.get(i);
        if (!r.active){
          rocks.remove(r); 
          System.out.println("Cleared");
          break;
        }
      }
    if (creatures.size() > 0){
    for (Entity e : creatures){    //UPDATE ENTITIES
      e.update();
      e.act();
    }
    }
    for (RangedAttack a : other){
      a.update();
    } 
    for (FloatText t : text){
      t.update();
    }
    
    for (FloatText t : text){
      if (t.frame >= t.maxFrames){
        text.remove(t);
        break;
      }
    }
    
  }
  
  void resetArrays(){
    for (Entity e : creatures){
      e.alive = true;
      e.x = e.startX;
      e.y = e.startY;
      e.health = e.startHealth;
    }
  }
  void displayEntities(){
    for (Entity e : creatures){    //DISPLAY ENTITIES
      e.display();
    }
    for (PickUp p : pickUps){    //DISPLAY PICKUPS
      if (p.isActive){
        p.display();
      }
    }
    for (RangedAttack a : other){
      if (a.active){
        a.display();
      }
    } 
    
    for (HealStation h : healStations){
      h.display();
    }
    for (RepairStation r : repairStations){
      r.display();
    }
    for (Chest c : chests){
      c.display();
    }
}
  
  void displayText(){
   for (FloatText t : text){    //UPDATE AND DISPLAY DAMAGE TEXT
        t.display();
      }
  }
  
  void displayStealth(){
    for (StealthArea s : stealthAreas){
      s.display();
    }
  }
  
  void addExit (int xin, int yin){
    int[][]temp = new int[exits.length + 1][2];
    
    for (int i = 0; i < exits.length; i++){
      temp[i] = exits[i];
    }
    temp[exits.length] = new int[]{xin, yin};
  }
  
  void clearUsed(){
      
     for (int i = 0; i < rocks.size(); i++){
      Rocks r = rocks.get(i);
        if (!r.active){
          rocks.remove(r); 
          System.out.println("Cleared");
          break;
        }
      }
      
    for (int i = 0; i < other.size(); i++){
      RangedAttack r = other.get(i);
        if (!r.active){
          other.remove(r); 
        }
      }
  
    for (int i = 0; i < pickUps.size(); i++){
      PickUp p = pickUps.get(i);
        if (!p.isActive){
          other.remove(p); 
        }
      }
    
    for (int i = 0; i < chests.size(); i++){
      Chest c = chests.get(i);
        if (!c.isActive){
          other.remove(c);
       }
     }
  }
}