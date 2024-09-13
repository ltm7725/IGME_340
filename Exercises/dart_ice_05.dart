/// our list of monsters
List<dynamic> monsters = [];

///
/// Our Base Monster class
///
class Monster {
  String name;
  int hp;
  int speed;
  int score;

  /// constructor
  Monster({this.name = "", this.hp = 0, this.speed = 0, this.score = 0});

  /// class method
  void status() {
    print("name: $name, hp: $hp, speed: $speed, score: $score");
  }
}

class Player {
  String name;
  int lives;
  double score;
  int xp;
  double speed;

  Player(
      {this.name = "",
      this.lives = 1,
      this.score = 50,
      this.xp = 20,
      this.speed = 5});

  void status() {
    print("name: $name, lives: $lives, score: $score, xp: $xp, speed: $speed");
  }

  void levelUp() {
    xp += 100;
    speed += 10;
    score += 500;
    status();
  }
}

class Treasure {
  String name = "";
  double value = 0;
  String rarity = "";
  String type = "";

  Treasure(String name, double value, String rarity, String type) {
    this.name = name;
    this.value = value;
    this.rarity = rarity;
    this.type = type;
  }

  Treasure.template(
      [this.name = "", this.value = 0, this.rarity = "", this.type = ""]);

  void status() {
    print("name: $name, value: $value, rarity: $rarity, type: $type");
  }
}

void main() {
  Monster myGoomba = Monster(hp: 50, name: 'John', score: 200, speed: 20);
  myGoomba.status();

  var j = Player(name: "John 2", lives: 3, score: 90, xp: 35, speed: 7);
  j.status();
  j.levelUp();

  var vario = Player(name: "Mario", lives: 4, score: 0, speed: 10);
  for (int i = 0; i < 10; i++) vario.levelUp();

  List treasures = [];
  treasures.add(Treasure("Gold", 100, "Uncommon", "Coin"));
  treasures.add(Treasure("Sword", 50, "Rare", "Weapon"));
  treasures.add(Treasure("Crown", 500, "Epic", "Garment"));
  treasures.add(Treasure("Ruby", 250, "Slightly Common", "Gemstone"));
  treasures.add(Treasure("Amulet", 2225, "Legendary", "Magic Equippable"));
  for (Treasure t in treasures) t.status();

  Player hero = Player();
  hero
    ..name = "Hero"
    ..lives = 2
    ..score = 25
    ..xp = 125
    ..speed = 10
    ..status();

  Treasure newTreasure = Treasure.template();
  newTreasure
    ..name = "Wand"
    ..value = 10675
    ..rarity = "Ancient-Mythic"
    ..type = "Magic Weapon"
    ..status();
}
