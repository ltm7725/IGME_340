void main() {
  int myNumber = 1234;
  double myFloat = 1234.6234;
  String myString = "Hello World";
  bool myBoolean = false;
  const myConst = "I don't change";
  final iAmFinal;
  dynamic iAmDynamic = 1;
  var iAmVar;
  // myConst = "changed const"; ERROR
  iAmFinal = "My Final Offer";
  // iAmFinal = "I changed my Mind!"; ERROR
  iAmVar = 12345;
  print(iAmVar);
  iAmVar = "I am String now";
  print(iAmVar);
  // You can do:
  // print ("some text " + dbl.toString());
  // print ("some text $variable");
  // print ("some text ${variable.function()}");
  // Note: in the above example, if you print a number without interpolation, such as a int or double, you need to use the toString function.
  print("$myString $myFloat");
  print("${myString.toUpperCase()}");
  print("${myFloat.ceil()} ${myFloat.floor()}");
  dynamic time = DateTime.timestamp();
  print("${time.millisecondsSinceEpoch / 1000}");
  dynamic num = -999;
  print(num.abs());
  dynamic test = 1234;
  print(test);
  test = "Hello there!";
  print(test);
  for (int i = 0; i < 21; i++) {
    print(i);
    if (i == 10) break;
  }
  int i = 0;
  while (i < 21) {
    print(i);
    if (i == 10) break;
    i++;
  }
}
