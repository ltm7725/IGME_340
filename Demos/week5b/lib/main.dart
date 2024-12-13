import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Week5bPage(),
    );
  }
}

class Week5bPage extends StatefulWidget {
  const Week5bPage({super.key});

  @override
  State<Week5bPage> createState() => _Week5bPageState();
}

class _Week5bPageState extends State<Week5bPage> {
  var weaponsList = [
    const DropdownMenuItem(
      value: "Axe",
      child: Text("Axe"),
    ),
    const DropdownMenuItem(
      value: "Spear",
      child: Text("Spear"),
    ),
    const DropdownMenuItem(
      value: "Dagger",
      child: Text("Dagger"),
    ),
    const DropdownMenuItem(
      value: "Sword",
      child: Text("Sword"),
    ),
    const DropdownMenuItem(
      value: "Mace",
      child: Text("Mace"),
    ),
  ];
  var armorList = [
    "Plate",
    "Scale",
    "Chain",
    "Leather",
    "Cloth",
  ];
  String? selectedArmor = "Leather";
  String? selectedWeapn = "Dagger";
  final textField01 = TextEditingController();
  final phoneField = TextEditingController();
  String textOut = "";

  @override
  void initState() {
    super.initState();

    textField01.addListener(dumpText);
    textField01.text = "Hi Class!";
    phoneField.text = "123-123-1234";
  }

  void dumpText() {
    setState(() {
      textOut = textField01.text;
    });
  }

  @override
  void dispose() {
    textField01.dispose();
    phoneField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Text('Select Weapon'),
              myDropdownRow(),

              // Text Fields
              Text("$textOut"),
              TextField(
                controller: textField01,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Enter Some Text"),
                  contentPadding: EdgeInsets.all(20),
                  filled: true,
                  fillColor: Colors.amberAccent,
                  // prefix: Text("Mr. "),
                  prefixIcon: Icon(Icons.access_alarm),
                  suffixIcon: IconButton(
                    onPressed: () {
                      textField01.clear();
                    },
                    icon: Icon(Icons.delete),
                  ),
                ),
                onSubmitted: (String value) {
                  setState(() {
                    textField01.text = value;
                    print("TextField: ${textField01.text}");
                  });
                },
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                keyboardType: TextInputType.phone,
                controller: phoneField,
                textInputAction: TextInputAction.previous,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Phone Number"),
                  contentPadding: EdgeInsets.all(20),
                  filled: true,
                  fillColor: Colors.blueAccent,
                  // prefix: Text("Mr. "),
                  prefixIcon: Icon(Icons.access_alarm),
                  suffixIcon: IconButton(
                    onPressed: () {
                      phoneField.clear();
                    },
                    icon: Icon(Icons.delete),
                  ),
                ),
                onSubmitted: (String value) {
                  setState(() {
                    phoneField.text = value;
                    print("Phone: ${phoneField.text}");
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  //
  // My Row of Dropdowns
  //
  Row myDropdownRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Weapon Dropdown
        DropdownButton(
          items: weaponsList,
          value: selectedWeapn,
          onChanged: (selected) {
            setState(() {
              selectedWeapn = selected;
            });
          },
        ),
        SizedBox(
          width: 50,
        ),
        // Armor Dropdown
        DropdownButton(
            items: armorList.map((String item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            value: selectedArmor,
            onChanged: (selected) {
              setState(() {
                selectedArmor = selected;
              });
            }),
      ],
    );
  }
}
