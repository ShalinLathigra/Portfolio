//--------------------------------------------------------------------------
//                                                                    PLAYER
//--------------------------------------------------------------------------
class Player extends GameObject {
  float health;    //Healtuh
  float maxHealth = 100;
  float baseDamage = 2.5;    //BASE DAMAGE (no items)
  float baseCritChance = 1;
  float totalCritChance;
  float totalDamage;    //TOTAL DAMAGE (all items)
  float totalDamageReduction;    //TOTAL AMOUNT OF DAMAGE REDUCTION (all items)
  float activeRange;  //RANGE OF CURRENT EQUIPPED ITEMS
  Item[] inv;
  int numItems;

  float stealthValue;  //Value the enemy must beat to spot the player
  float baseStealthValue = 25;
  int sneaking;
  float sneakModifier = 10;
  boolean inBrush;
  int brushModifier;

  float attackRotation;    //ANGLE TO DISPLAY THE ATTACK ANIMATION AT (0, 90, 180, 270)
  float attackAreaX;    //WHAT BLOCKS ARE AFFECTED X
  float attackAreaY;    //WHAT BLOCKS ARE AFFECTED Y

  float animationTimer;
  float maxAnimationTimer = 200f;    //how long the attackAnimation will take
  boolean animationOver = true;    //Has the animation ended?

  float attackTimer;    //How long remains before attack completes
  float maxAttackTimer = 350f;    //Max amount of time before attack completes

  float moveTimer;    //Remaining time before they can move
  float maxMoveTimer = 100f;    //Can't spam move to sprint away
  boolean moving;    //Is the player currently moving

  int attackType;
  boolean attacked;    //Has attacked

  PImage arrowImage;
  int numArrows;

  Animation attackAnim;    //Attack Animation

  int gold;

  public Player(int xin, int yin, PImage iin) {
    super(xin, yin, iin);
    attackAnim = new Animation("anim_l_", 8, maxAnimationTimer);    //The Needed Animation
    gold = 9999;

    arrowImage = loadImage("Arrow.png");
    arrowImage.resize(32, 32);

    attackType = 1;
    activeRange = 1;
    health = maxHealth;
    inv = new Item[5];    //five item inventory
    numArrows = 0;

    sneaking = -1;
    inBrush = false;
    brushModifier = 10;
    setStats();
  }

  void advanceTimers() {
    float deltaTime = time - lastTime;

    attackTimer -= deltaTime;
    if (attackTimer <= 0) {
      attacked = false;
      attackTimer = 0;
    }

    moveTimer -= deltaTime;
    if (moveTimer <= 0) {
      moving = false;
      moveTimer = 0;
    }

    animationTimer -= deltaTime;
    if (animationTimer <= 0) {
      animationOver = true;
      animationTimer = 0;
    }
  }

  void display() {
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
    //self
    //armour
    //items
  }
  void update() {
    if (attacked) {
      advanceAttack();
    }
    advanceTimers();
  }
  
  int getTotalValue(){
    int total = 0;
    for (Item i:inv){
      if (i instanceof Item){
        total += i.value;
      }
    }
    return total;
  }

  void checkItems() {
    for (int i = 0; i < 5; i++) {
      if (inv[i] instanceof Item) {
        numItems ++;
        if (inv[i].durability <= inv[i].initialDurability / 2 && !inv[i].broken) {
          inv[i].breakItem();
          p.setStats();
        }
        if (inv[i].durability <= 0) {
          switch(inv[i].type) {
            case ("HELMET"): 
            inv[i] = new PlaceHolder();
            case ("ARMOUR"): 
            inv[i] = new PlaceHolder();
            case ("MELEE"): 
            takeDamage(random(1, 5));   
            inv[i] = new PlaceHolder(); 
            inv[i].isActive *= -1; 
            setStats();    //Take Damage if you break a weapon -> Replace with a placeholder item(stops it being drawn in gui)
            case ("SHIELD"):                           
            inv[i] = new PlaceHolder(); 
            inv[i].isActive *= -1; 
            setStats();      //-> Set the slot to inactive, just to be safe -> set stats again, damage and damageReduc. of placeholders is always 0
            case ("RANGED"): 
            takeDamage(random(1, 5));  
            inv[i] = new PlaceHolder(); 
            inv[i].isActive *= -1; 
            setStats(); 
            attackType = 1;
          }
        }
      }
    }
  }

  void move(float dx, float dy) {

    if (!moving) {
      float nextx = x + dx;
      float nexty = y + dy;

      for (Entity e : levels[currentLevel].currentRoom.creatures) {
        if (nextx == e.x && nexty == e.y) {  //CANT GO INSIDE ANOTHER ENTITY
          nextx = x;
          nexty = y;
        }
      }
        if (nextx == t.x && nexty == t.y && t.isPresent) {  //CANT GO INSIDE THE THIEF, UNLESS IT'S INACTIVE
          nextx = x;
          nexty = y;
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

      if (atNextPos.matches("[s]")) {
        inBrush = true;
        setStats();
      } else if (inBrush && !atNextPos.matches("[#Xs]")) {
        inBrush = false;
        setStats();
      } 

      if (atNextPos.matches("[+]")) {
        changeLevel(-1);
      } else if (atNextPos.matches("[-]") && !levels[currentLevel].cleared) {
        levels[currentLevel].currentRoom.text.add(new FloatText(width/2, height/2, "MUST ACTIVATE ALL LEVERS", "MISC"));
      } else if (atNextPos.matches("[-]") && levels[currentLevel].cleared) {
        changeLevel(+1);
      } else if (atNextPos.matches("[L]")) {
        levels[currentLevel].currentRoom.checkedLevers++;
        levels[currentLevel].currentRoom.background[(int)nexty][(int)nextx] = tileSpriteSheet.get(16*3, 16*3, 16, 16);
        levels[currentLevel].currentRoom.background[(int)nexty][(int)nextx].resize(32, 32);

        for (int i = 0; i < levels[currentLevel].rooms[0].length; i++) {
          for (int j = 0; j < levels[currentLevel].rooms.length; j++) {
            System.out.println(j + " " + i);
            if (levels[currentLevel].rooms[j][i] instanceof Room){
              if (levels[currentLevel].rooms[j][i].checkedLevers == levels[currentLevel].rooms[j][i].numLevers){
                levels[currentLevel].cleared = true;
              }
            }
          }
        }
      }

      setPos(nextx, nexty);
      moving = true;
      walk.play(); 
      moveTimer = maxMoveTimer;
      
      if (sneaking > 0) {
        moveTimer *= sneakModifier;
      }

      if (atNextPos.matches("[<^>v]")) {
        levels[currentLevel].currentRoom.resetArrays();
        nextRoom(atNextPos);
      }
    }
  }

  void nextRoom(String exitChar) {
    switch(exitChar) {
      case ("<"): 
      levels[currentLevel].changeRoom(LEFT);  
      break;
      case ("^"): 
      levels[currentLevel].changeRoom(UP);    
      break;
      case (">"): 
      levels[currentLevel].changeRoom(RIGHT); 
      break;
      case ("v"): 
      levels[currentLevel].changeRoom(DOWN);  
      break;
    }
  }

  void reduceDurability(int[] indices) {    //Takes in an array of indices (0 = helm, 1 = armour, 2 = sword, 3 = shield, 4 = bow) and reduces their durabilities
    for (int i = 0; i < indices.length; i++) {
      if (inv[indices[i]] instanceof Item) {
        if (inv[indices[i]].isActive > 0) {
          inv[indices[i]].changeDurability(-1);
        }
      }
    }
    checkItems();
  }

  void attack(int direction) {    //SET THE AOE FOR ATTACK, SET THE ANGLE TO ROTATE THE ANIMATION BY (0, 90, 180, 270)
    attacked = true;

    if (attackType == 1) {

      if (direction == LEFT) {
        attackAreaX = x - activeRange;
        attackAreaY = y;

        attackRotation = 0;
      }
      if (direction == UP) {
        attackAreaX = x;
        attackAreaY = y - (int)activeRange;

        attackRotation = 90;
      }
      if (direction == RIGHT) {
        attackAreaX = x + (int)activeRange;
        attackAreaY = y;

        attackRotation = 180;
      }
      if (direction == DOWN) {
        attackAreaX = x;
        attackAreaY = y + (int)activeRange;

        attackRotation = 270;
      }

      animationTimer = maxAnimationTimer;
      attackTimer = maxAttackTimer;
      animationOver = false;

      float crit = random(100);
      float damageTaken = totalDamage + random(-2, 2);
            
      for (Entity e : levels[currentLevel].currentRoom.creatures) {    //For every creature, 
        if (e.x == (int)attackAreaX) {    //check x first,  
          if (e.y == (int)attackAreaY) {    //then y, if in right area,


            if (crit < totalCritChance) {
              damageTaken *= 2;
            }
            if (damageTaken <= 0) {
              damageTaken = 0;
            }
            e.takeDamage(damageTaken);        //it takes damage (slightly randomized) 
            reduceDurability(new int[]{2, 3});      //Then reduce durabilities
          }
        }
      }
      if (t.isPresent){
        if ((int)t.x == (int)attackAreaX) {    //check x first,  
          if ((int)t.y == (int)attackAreaY) {    //then y, if in right area,
            t.takeDamage(damageTaken);
          }
        }
      }
      attacked = true;
    } else if (attackType == 2 && numArrows>0) {

      RangedAttack attack;

      if (direction == LEFT) {
        if (x - 1 > 0) {
          attack = new RangedAttack(x, y, arrowImage, -1, 0, totalDamage, 0, totalCritChance);    //All essentially identical, make a new ranged attack object in proper position, with proper stats
          levels[currentLevel].currentRoom.other.add(attack);                                                            //Add it to array of Ranged Objects
        }
      }
      if (direction == UP) {
        if (y - 1 > 0) {
          attack = new RangedAttack(x, y, arrowImage, 0, -1, totalDamage, 90, totalCritChance);
          levels[currentLevel].currentRoom.other.add(attack);
        }
      }
      if (direction == RIGHT) {
        if (x + 1 < LEVEL_WIDTH) {
          attack = new RangedAttack(x, y, arrowImage, 1, 0, totalDamage, 180, totalCritChance);  
          levels[currentLevel].currentRoom.other.add(attack);
        }
      }
      if (direction == DOWN) {
        if (y + 1 < LEVEL_HEIGHT) {
          attack = new RangedAttack(x, y, arrowImage, 0, 1, totalDamage, 270, totalCritChance);
          levels[currentLevel].currentRoom.other.add(attack);
        }
      }
      reduceDurability(new int[]{4});    //Reduce durability of 4th inv slot (ranged slot)
      attackTimer = 1.25 * maxAttackTimer;    //Increased delay for ranged, can't spam
      numArrows--;    //Reduce # of arrows
    }
  }

  void advanceAttack() {    //advance attack cooldown, advance attack animation
    if (attackType == 1 && !animationOver) {
      if (attackRotation == 0) {
        attackAnim.advance((x - 1) * zoom + 32, y * zoom + 32, attackRotation);
      } else if (attackRotation == 90) {
        attackAnim.advance(x * zoom + 32, (y - 1) * zoom + 32, attackRotation);
      } else if (attackRotation == 180) {
        attackAnim.advance((x + 1) * zoom + 32, y * zoom + 32, attackRotation);
      } else if (attackRotation == 270) {
        attackAnim.advance(x * zoom + 32, (y + 1) * zoom + 32, attackRotation);
      }
    }
  }

  boolean pickUp() {              //PICKING UP ITEMS
    for (PickUp u : levels[currentLevel].currentRoom.pickUps) {    //Check all pickups
      if (u.isActive) {    //if active
        if (u.getPos()[0] == getPos()[0] && u.getPos()[1] == getPos()[1]) {    //Get the position X & Y, check against own position X & Y
          if (p.gold > u.heldItem.cost) {
            gold -= u.heldItem.cost;
            p.addItem(u.heldItem);    //Add the item to current inv
            u.isActive = false;    //Disable pickup, prevent it from being rendered

            if (u.heldItem instanceof Ranged) {
              numArrows += (int) random(5, 25);
            }
            return true;
          }
        }
      }
    }
    return false;
  }

  void addItem(Item item) {    //Get the item's valid inv slot
    inv[item.invSlot] = item;    
    if (item.invSlot == 4) {    //If you pick up a bow, auto unequip other weapons, equip bow
      if (inv[3] instanceof Item) {    
        inv[3].isActive = -1;
      }
      if (inv[2] instanceof Item) {
        inv[2].isActive = -1;
      }
    } else if (item.invSlot == 3 || item.invSlot == 2) {    //& vice versa for melee weapons
      if (inv[4] instanceof Item) {
        inv[4].isActive = -1;
      }
    }
    setStats();    //Set stats
    pg.update();
  }

  float[] getPos() {
    float[] pos = {x, y};    
    return pos;
  }

  void setStats() {
    totalDamage = baseDamage;
    totalDamageReduction = 0;
    totalCritChance = baseCritChance;
    stealthValue = baseStealthValue;
    numItems = 0;
    for (Item e : inv) {
      if (e instanceof Item) {
        numItems++;
        if (e.isActive > 0) {
          totalDamage += e.damage;
          totalDamageReduction += e.damageReduction;

          switch (e.type) {
            case ("ARMOUR"):
            stealthValue += (30 - e.damageReduction);
            case ("HELMET"):
            stealthValue += (20 - e.damageReduction);
            case ("MELEE"):
            stealthValue += (e.damage - 15);
            case ("SHIELD"):
            stealthValue += 2 * (e.damageReduction - 25);
            case ("RANGED"):
            stealthValue += e.damage - 5;
          }

          totalCritChance += e.critChance;
          if (e.type == "RANGED") {
            activeRange = ((Weapon)e).range;
            attackType = 2;
          } else {
            activeRange = 1;
            attackType = 1;
          }
        }
      }
    }
    if (sneaking > 0) {
      stealthValue += sneakModifier;
    }
    if  (inBrush) {
      stealthValue += brushModifier;
    }
  }

  void takeDamage(float din) {
    float damageTaken = din;
    health -= damageTaken;
    reduceDurability(new int[]{0, 1, 3});
    levels[currentLevel].currentRoom.text.add(new FloatText(x, y, String.format("%1.2f", damageTaken), "DAMAGE"));
  }

  void healDamage(float din) {
    health += din;
    if (health > maxHealth) {
      health = maxHealth;
    }
  }
  void repairItems(int rin) {
    for (Item i : inv) {
      if (i instanceof Item) {
        i.changeDurability(rin);
      }
    }
  }

  void activate() {
    for (HealStation h : levels[currentLevel].currentRoom.healStations) {
      if (x == h.x && y == h.y && h.uses > 0) {
        if (gold >= h.cost) {
          h.activate();
          gold -= h.cost; 
          break;
        }
      }
    }
    for (RepairStation r : levels[currentLevel].currentRoom.repairStations) {
      if (x == r.x && y == r.y && r.uses > 0) {
        if (gold >= r.cost) {
          r.activate();
          gold -= r.cost;
          break;
        }
      }
    }
    for (Chest c : levels[currentLevel].currentRoom.chests) {
      if (x == c.x && y == c.y && c.isActive) {
        c.activate();
        break;
      }
    }
    
    pg.update();
  }
}
//add/remove item
// for add, if an available slot present, fill it
// if no available and one slot toggled on, replace that slot
//if no available and both on, replace main hand
//move
//attack
//advance attack animation
//setStats
//reduced benefits from offhand
//inventory
//Toggle selected item
//q for main hand
//e for off hand
//takeDamage