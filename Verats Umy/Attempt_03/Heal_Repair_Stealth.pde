class StealthArea extends GameObject{
  
  public StealthArea(PImage iin, float xin, float yin){
    super(xin, yin, iin);
  }
}

class HealStation extends GameObject{
  float healAmount;
  int uses;
  
  int cost;
  public HealStation(PImage iin, float xin, float yin){
    super(xin, yin, iin);
    
    healAmount = random(10, 20);
    uses = (int)random(2) + 1;
    
    cost = (int)(100 * uses * healAmount);
  }
  
  void activate(){
    p.healDamage(healAmount);
    uses -= 1;
    System.out.println(uses);
    if (uses <= 0){
      PImage tempImage = tileSpriteSheet.get(16 * 2, 16 * 2, 16, 16);
      tempImage.resize(32, 32);
      setImage(tempImage);
    }
  }
  
  void display(){
    super.display();
    if (uses > 0){
      fill(255, 255, 0);
      text(cost + "G", x * zoom, y * zoom + 32);
    }
  }
}

class RepairStation extends GameObject{
  int repairAmount;
  int uses;
  
  int cost;
  public RepairStation(PImage iin, float xin, float yin){
    super(xin, yin, iin);
    
    repairAmount = (int)random(10, 20);
    uses = (int)random(2) + 1;
    
    cost = (int)(100 * uses * repairAmount);
  }
  
  void activate(){
    p.repairItems(repairAmount);
    uses -= 1;
    if (uses <= 0){  
      PImage tempImage = tileSpriteSheet.get(16 * 3, 16 * 2, 16, 16);
      tempImage.resize(32, 32);
      setImage(tempImage);
    }
  }
  
    void display(){
    super.display();
    if (uses > 0){
      fill(255, 255, 0);
      text(cost + "G", x * zoom, y * zoom + 32);
    }
  }
}