class PlayerGui{
  int numArrows;
  float health;
  int durability_helm, durability_armour, durability_sword, durability_shield, durability_bow;
  Item helm, armour, sword, shield, bow;
  int gold;
  
  int currentLevel;
  
  Player model;
  
  public PlayerGui (Player p){
    model = p;
    
    numArrows = model.numArrows;
    health = model.health;
    gold = model.gold;
    update();
    
  }
  
  void update(){
    
    if (model.inv[0] instanceof Item){
    helm = model.inv[0];
    durability_helm = helm.durability;
    } else {
      helm = null;
      durability_helm = 0;
    }
    if (model.inv[1] instanceof Item){
    armour = model.inv[1];
    durability_armour = armour.durability;
    } else {
      armour = null;
      durability_armour = 0;
    }
    if (model.inv[2] instanceof Item){
    sword = model.inv[2];
    durability_sword = sword.durability;
    } else {
      sword = null;
      durability_sword = 0;
    }
    if (model.inv[3] instanceof Item){
    shield = model.inv[3];
    durability_shield = shield.durability;
    } else {
      bow = shield;
      durability_shield = 0;
    }
    if (model.inv[4] instanceof Item){
    bow = model.inv[4];
    durability_bow = bow.durability;
    } else {
      bow = null;
      durability_bow = 0;
    }
    
    numArrows = model.numArrows;
    gold = model.gold;
  }
  
  void display(){
    if (paused > 0){
      fill(0, 100);
      rect(0,0,width,height);
    }
    noStroke();
    fill (0, 127);
    rect(0, 448, 64, height - 592);
    rect(64, height - 64, 640, 64);
    
    fill (255, 0, 0);
    textSize(20);
    text("HEALTH: ", width / 8, height - 20);
    rect(width / 6 + textWidth("HEALTH: "), height - 16, 250 * (p.health / p.maxHealth), -20);  //Health bar
    
    fill(255);
    text("ARROWS: " + numArrows, width /8, height - 40);
    
    fill(255, 255, 0);
    text("GOLD: " + gold, width / 6 + textWidth("HEALTH: ") + 275, height - 20  );
    pushMatrix();
    translate(32,480);
    if (helm != null){
    image(helm.image, 0, 0);
    fill(255 / helm.initialDurability * (helm.initialDurability - helm.durability), 255 + 255 * (helm.durability - helm.initialDurability) / helm.initialDurability, 0);
    rect(-24, 0, 50 * helm.durability / helm.initialDurability, 10);
    
    if (paused > 0){
      textSize(12);
    fill(255, 255, 0);
      text("DAMAGE: " + String.format("%1.2f",helm.damage), 32, -8 );
      text("ARMOUR: " + String.format("%1.2f",helm.damageReduction), 32, 8);
    }
    }
    if (armour != null){
    image(armour.image, 0, 32);
    fill(255 / armour.initialDurability * (armour.initialDurability - armour.durability), 255 + 255 * (armour.durability - armour.initialDurability) / armour.initialDurability, 0);
    rect(-24, 48, 50 * armour.durability / armour.initialDurability, 10);
    
    if (paused > 0){
      textSize(12);
    fill(255, 255, 0);
      text("DAMAGE: " + String.format("%1.2f",armour.damage), 32, 32 );
      text("ARMOUR: " + String.format("%1.2f",armour.damageReduction), 32, 48);
    }
    }
    if (sword != null){
    image(sword.image, 16, 90);
    fill(255 / sword.initialDurability * (sword.initialDurability - sword.durability), 255 + 255 * (sword.durability - sword.initialDurability) / sword.initialDurability, 0);
    rect(-24, 112, 50 * sword.durability / sword.initialDurability, 10);
    
    if (paused > 0){
      textSize(10);
    fill(255);
      if (sword.isActive > 0){
        fill(255, 255, 0);
      }
      text("DAMAGE: " + String.format("%1.2f",sword.damage), 32, 82 );
      text("ARMOUR: " + String.format("%1.2f",sword.damageReduction), 32, 98);
      
    }
    }
    if (shield != null){
    image(shield.image, 0, 156);
    fill(255 / shield.initialDurability * (shield.initialDurability - shield.durability), 255 + 255 * (shield.durability - shield.initialDurability) / shield.initialDurability, 0);
    rect(-24, 176, 50 * shield.durability / shield.initialDurability, 10);
    
    if (paused > 0){
      textSize(10);
    fill(255);
      if (shield.isActive > 0){
        fill(255, 255, 0);
      }
      text("DAMAGE: " + String.format("%1.2f",shield.damage), 32, 148 );
      text("ARMOUR: " + String.format("%1.2f",shield.damageReduction), 32, 164);
    }
    }
    if (bow != null){
    image(bow.image, 16, 220);
    fill(255 / bow.initialDurability * (bow.initialDurability - bow.durability), 255 + 255 * (bow.durability - bow.initialDurability) / bow.initialDurability, 0);
    rect(-24, 240, 50 * bow.durability / bow.initialDurability, 10);
    
    if (paused > 0){
      textSize(10);
      fill(255);
      if (bow.isActive > 0){
        fill(255, 255, 0);
      }
      text("DAMAGE: " + String.format("%1.2f",bow.damage), 32, 212 );
      text("ARMOUR: " + String.format("%1.2f",bow.damageReduction), 32, 228);
    }
    }
    
    popMatrix();
    
    stroke(1);
  }
}
    
    