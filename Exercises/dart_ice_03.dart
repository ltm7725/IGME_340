var player01 = {
  'name': 'Leeroy Jenkins',
  'sex': 'M',
  'class': 'Knight',
  'hp': 1000
};

Map player02 = {
  'name': 'Jarod Lee Nandin',
  'sex': 'M',
  'class': 'Overlord',
  'hp': 9000
};

Map<String, dynamic> player03 = {
  'name': 'Samantha Evelyn Cook',
  'sex': 'F',
  'class': 'Gunter',
  'hp': 5000
};

void main() {
  print(player01);
  print("${player01.runtimeType}");
  print(player02);
  print("${player02.runtimeType}");
  print(player03);
  print("${player03.runtimeType}");

  var player04 = Map();
  player04['name'] = 'Gordon Freeman';
  player04['sex'] = 'M';
  player04['class'] = 'Scientist';
  player04['hp'] = 6000;

  print("player04: $player04");
  print("player04: ${player04.runtimeType}");

  var player05 = Map();
  player05['name'] = 'Test Dummy';
  player05['sex'] = 'N/A';
  player05['class'] = 'Target Practice';
  player05['hp'] = 1000000;
  player05['armor'] = "None";
  player05.remove('hp');
  print(player05);

  var moreStuff = Map<String, Object>();
  moreStuff['mp'] = '15';
  moreStuff['money'] = '10 dollars';
  moreStuff['xp'] = '90';
  moreStuff['level'] = 10;
  player01.addEntries(moreStuff.entries);
  player02.addEntries(moreStuff.entries);
  player03.addEntries(moreStuff.entries);
  player04.addEntries(moreStuff.entries);
  player05.addEntries(moreStuff.entries);

  print(player05.keys);

  print(player05.values);

  List<Map> playerList = [];
  playerList.add(player01);
  playerList.add(player02);
  playerList.add(player03);
  playerList.add(player04);
  playerList.add(player05);
  print(playerList);

  print(playerList[1]['name']);

  for (Map player in playerList) {
    print("${player['name']}, ${player['class']}");
  }

  player01.clear();
  print(player01);
}
