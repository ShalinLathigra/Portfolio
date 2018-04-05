
//--------------------------------------------------------------------------
//                                                                 BASE ITEM
//--------------------------------------------------------------------------
//Non Interactable stuff(no collisions) 
abstract class Item{
  PImage image;           //Image displayed 
  
  String type;            //Type of item (weapon, bow, shield, helm, armour), used to determine primary inventory position
  
  int isActive;          //Whether or not it affects the player and is rendered
  
  float damageReduction;  //amount of damage reduction
  float damage;           //Damage it deals
  
  float critChance;
  
  boolean broken;
  int initialDurability = (int)random(1, MAX_DURABILITY);
  int durability;       //Durability
  
  int cost;
  int value;
  
  int invSlot;   //Ideal Position in inventory array
  
  
  
  
  //NOTE REDO THE COLOUR GUI STUFF
  
  
  
  
  
  
  public Item(PImage iin, String tin, float drin, float din){
    image = iin;
    type = tin;
    damageReduction = drin;
    damage = din;
    isActive = 1;
    critChance = random(5);
    
    durability = initialDurability;
    
    cost = (int) random((damageReduction + damage + critChance + durability + 10) / 2, (damageReduction + damage + critChance + durability + 10));
    value = (int)(damageReduction + damage + critChance + durability);
    
    if (type == "HELMET"){
        invSlot = 0;    //Primary positions for each item type set here
    } else if (type == "ARMOUR"){
        invSlot = 1;
    } else if (type == "MELEE"){
        invSlot = 2;
    } else if (type == "SHIELD"){
        invSlot = 3;
    } else if (type == "RANGED"){
        invSlot = 4;
    }
  }
  
  void breakItem(){
    damageReduction *= 1/2;
    damage *= 1/2;
    broken = true;
  }
  
  void changeDurability(int din){
    durability += din;
    if (durability > initialDurability){
      durability = initialDurability;
    }
  }
}

//--------------------------------------------------------------------------
//                                                                    WEAPON
//--------------------------------------------------------------------------
abstract class Weapon extends Item{
  float range;              //How far it reaches
  
  public Weapon(PImage iin, String tin, float drin, float din, float rin){
    super(iin, tin, drin, din);
    range = rin;
  }
}

//--------------------------------------------------------------------------
//                                                       MELEE/RANGED/SHIELD
//--------------------------------------------------------------------------


//EACH HAS A UNIQUE CONSTRUCTOR TO MAKE LIFE EASIER
class Melee extends Weapon{
    public Melee(PImage iin, float drin, float din, float rin){
      super(iin, "MELEE", drin, din, rin);
    }
}

class Shield extends Weapon{
    public Shield(PImage iin, float drin, float din, float rin){
      super(iin, "SHIELD", drin, din, rin);
    }
}
class Ranged extends Weapon{
  public Ranged(PImage iin, float drin, float din, float rin){
    super(iin, "RANGED", drin, din, rin);
  }
}

class Helmet extends Item{
  public Helmet(PImage iin, float drin, float din){
    super(iin, "HELMET", drin, din);
  }
}
class Armour extends Item{
  public Armour(PImage iin, float drin, float din){
    super(iin, "ARMOUR", drin, din);
  }
}

//--------------------------------------------------------------------------
//                                                               PLACEHOLDER
//--------------------------------------------------------------------------
class PlaceHolder extends Item{
  public PlaceHolder(){
    super(new PImage(), "PLACEHOLDER", 0, 0);
  }
}

//--------------------------------------------------------------------------
//                                                                    PICKUP
//--------------------------------------------------------------------------
class PickUp{
  Item heldItem;
  int x, y;
  boolean isActive;
  
  public PickUp (int xin, int yin, Item iin){
    x = xin;
    y = yin;
    heldItem = iin;
    isActive = true;
  }
  
  public PickUp (int xin, int yin, Item iin, int cost){
    x = xin;
    y = yin;
    heldItem = iin;
    isActive = true;
    
    heldItem.cost = cost;
  }
  
  void display(){
    pushMatrix();
    translate(32,32);
    image(heldItem.image, x * zoom, y * zoom);
    textSize(18 + 12 * heldItem.cost/250);
    
    if (p.inv[heldItem.invSlot] instanceof Item){
      if (p.inv[heldItem.invSlot].value > heldItem.value){
        fill(255,0,0);
      } else if (p.inv[heldItem.invSlot].value < heldItem.value){
        fill(0,175,50);
      } else {
        fill(255, 255, 0);
      }
    } else {
        fill(255, 255, 255);
    }
    
    if (heldItem.cost > 0){
      text(heldItem.cost, x * zoom - textWidth(String.valueOf(heldItem.cost)) / 2, y * zoom + 32);
    } else {
      rect(x * zoom, y * zoom + 8, 16, 10);
    }
    popMatrix();
  }
  int[] getPos(){
    int[] pos = {x, y};
    return pos;
  }
}

//--------------------------------------------------------------------------
//                                                                     CHEST
//--------------------------------------------------------------------------
class Chest{
  int x, y;
  int helmChance = 20;
  int armourChance = 20;
  int meleeChance = 20;
  int shieldChance = 20;
  int bowChance = 20;
  
  int healChance;    //Maximum value it can be to heal
  int repairChance;    //Minumum value it can be to repair
  //Makes it possible to heal and repair, just unlikely
  
  float healAmount;
  int repairAmount;
  
  int goldAmount;
  
  Item pickUpItem;
  PickUp drop;
  
  boolean isActive;
  boolean hasItem = false;
  
  PImage image;
  
  public Chest(int items, int xin, int yin){
    image = tileSpriteSheet.get(16 * 2, 16 * 3, 16, 16);
    image.resize(32, 32);
    
    x = xin;
    y = yin;
    
    if (items > 0){
      int selected = (int)random(100);
      int value = (int)random(150);
      
      if (selected < helmChance){
        pickUpItem = generate("HELMET", value);
      } else if (selected < 20 + armourChance){
        pickUpItem = generate("ARMOUR", value);
      } else if (selected < 40 + meleeChance){
        pickUpItem = generate("MELEE", value);
      } else if (selected < 60 + shieldChance){
        pickUpItem = generate("SHIELD", value);
      } else if (selected < 80 + bowChance){
        pickUpItem = generate("RANGED", value);
      }  
      
      drop = new PickUp(x, y, pickUpItem, 0);
      hasItem = true;
      goldAmount = (150 - value) / 10;
      healAmount = 0;
      repairAmount = 0;
      
    } else {
      goldAmount = (int)random(1000);
      healChance = (int)random(100);
      repairChance = (int)random(100);
      
      int selected = (int)random(100);
      
      if (selected < healChance){
        healAmount = random(100);
      }
      if (selected > repairChance){
        repairAmount = (int)random(20);
      }
    }
    
    isActive = true;
  }
  
  void display(){
    if (isActive){
    pushMatrix();
    translate(32,32);
    image(image, x * zoom, y * zoom);
    popMatrix();
    }
  }
  
  void activate(){
    p.healDamage(healAmount);
    p.repairItems(repairAmount);
    
    if (drop instanceof PickUp){
      levels[currentLevel].currentRoom.pickUps.add(drop);
    }
    
    levels[currentLevel].currentRoom.chests.remove(this);
  }
}