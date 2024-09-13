void helloFunction(String? a, int b) {
  print("$a, $b");
}

void helloFunction3({String a = "hi", int b = 10}) {
  print("$a, $b");
}

void printThree({String? first, required String second, String? third}) {
  print("$first, $second, $third");
}

void addThree({required int numOne, required int numTwo, required int numThree}) {
  print(numOne + numTwo + numThree);
}

String joinStrings({String? first, String? second, String third = "three", String fourth = "four"}) {
  String theString = "";
  if (first != null) theString += first;
  if (second != null) theString += second;
  theString += third;
  theString += fourth;
  return theString;
}

Map hiLow(double a, double b, double c) {
  var product = Map();
  product['sum'] = a + b + c;
  product['high'] = product['sum'].ceil();
  product['low'] = product['sum'].floor();
  return product;
}

Map makeCharacter({String? name, String? playerClass, double? mp, double? hp}) {
  var product = Map();
  product['name'] = name;
  product['class'] = playerClass;
  
  // Below just makes it so if you specifically put in null it also sets the default values
  
  if (mp == null) product['mp'] = 125;
  else product['mp'] = mp;
  
  if (hp == null) product['hp'] = 35;
  else product['hp'] = hp;
  
  product['xp'] = 54;
  product['level'] = 2;
  return product;
}

void main() {
  helloFunction("hi", 10);
  helloFunction(null, 10);
  helloFunction3();
  printThree(first: "Hello", second: "Fall", third: "Season");
  printThree(
    third: "Season",
    first: "Hello",
    second: "Fall",
  );
  printThree(second: "Hello");

  addThree(numOne: 2, numTwo: 5, numThree: 6);

  print(joinStrings(first: "one"));

  print(hiLow(3.2, 5.7, 9.6));

  print(makeCharacter(name: "Ted", playerClass: "Rogue"));
  print(makeCharacter(name: "Ted", playerClass: "Rogue", mp: null, hp: null));
}
