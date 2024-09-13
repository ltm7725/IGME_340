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
  String type;

  /// constructor
  Monster(
      {this.name = "",
      this.hp = 0,
      this.speed = 0,
      this.score = 0,
      this.type = ""});

  /// class method
  void status() {
    print("name: $name, hp: $hp, speed: $speed, score: $score");
  }
}

class Goomba extends Monster {
  String color;
  int dmg;

  Goomba(
      {super.name,
      super.hp,
      super.speed,
      super.score,
      super.type,
      this.color = "brown",
      this.dmg = 20}) {
    super.type = super.type + "!";
  }

  @override
  void status() {
    print(
        "name: $name, hp: $hp, speed: $speed, score: $score, type: $type, color: $color, dmg: $dmg");
  }
}

class Boo extends Monster {
  int mp;

  Boo(
      {super.name,
      super.hp,
      this.mp = 20,
      super.speed,
      super.score,
      super.type});

  @override
  void status() {
    print(
        "name: $name, hp: $hp, mp: $mp, speed: $speed, score: $score, type: $type");
  }

  void castSpell(int amt) {
    this.mp -= amt;
    print("$name cast a spell, using $amt mp!");
  }
}

List makeSomeMonsters() {
  List list = [];
  list.add(Goomba(name: "Bluey", hp: 82, speed: 3, score: 90, type: "Blueish"));
  list.add(
      Goomba(name: "Greeny", hp: 31, speed: 7, score: 80, type: "Greenish"));
  list.add(Boo(
      name: "Booington",
      hp: 400,
      mp: 70,
      speed: 6,
      score: 300,
      type: "Medium Guy"));
  list.add(Boo(
      name: "Ms. Boo",
      hp: 700,
      mp: 90,
      speed: 5,
      score: 900,
      type: "Smallish Guy"));
  return list;
}

void showMonsters<type>(List mList) {
  for (Monster m in mList) if (m is type) m.status();
}

void main() {
  Goomba myGoomba =
      Goomba(name: "Pinky", hp: 50, speed: 5, score: 100, type: "Pinkish");
  myGoomba.status();

  Boo myBoo = Boo(
      name: "Boosley", hp: 500, mp: 50, speed: 5, score: 100, type: "Big Guy");
  myBoo.status();

  myBoo.castSpell(20);
  myBoo.status();

  print("  ");

  List monsterList = makeSomeMonsters();
  showMonsters<Boo>(monsterList);

  print("  ");

  showMonsters<Goomba>(monsterList);
}
