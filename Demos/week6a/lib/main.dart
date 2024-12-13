import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Week6APage(),
    );
  }
}

class Week6APage extends StatefulWidget {
  const Week6APage({super.key});

  @override
  State<Week6APage> createState() => _Week6APageState();
}

class _Week6APageState extends State<Week6APage> {
  final _myFormId = GlobalKey<FormState>();
  bool? chk01 = false;
  bool? cblt01 = false;
  List<Map> inventory = [
    {'name': 'Apple', 'price': 10},
    {'name': 'Banana', 'price': 20},
    {'name': 'Coconut', 'price': 30},
    {'name': 'Fig', 'price': 50},
    {'name': 'Jackfruit', 'price': 23},
    {'name': 'Grape', 'price': 44},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Form Demo"),
          backgroundColor: Colors.amberAccent,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Form(
            key: _myFormId,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Enter Your Name",
                      border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please Enter Some Text";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: "Enter Your EMail",
                      border: OutlineInputBorder()),
                  validator: (value) {
                    if (value != null && !EmailValidator.validate(value)) {
                      return "Please Enter a valid Email";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_myFormId.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Processing Data"),
                        ),
                      );
                    }
                  },
                  child: Text("Submit"),
                ),
                SizedBox(
                  height: 20,
                ),
                Checkbox(
                  tristate: true,
                  activeColor: Colors.yellow,
                  checkColor: Colors.purple,
                  value: chk01,
                  onChanged: (value) {
                    setState(() {
                      chk01 = value;
                    });
                  },
                ),
                CheckboxListTile(
                  // controlAffinity: ListTileControlAffinity.leading,
                  checkboxShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  secondary: Icon(Icons.access_alarm),
                  title: Text("My Cool Checkbox List Tile"),
                  subtitle: Text("this is my sub"),
                  value: cblt01,
                  onChanged: (value) {
                    setState(() {
                      cblt01 = value;
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  color: Colors.blue,
                  height: 100,
                  child: ListView(
                    padding: EdgeInsets.all(10),
                    reverse: true,
                    scrollDirection: Axis.horizontal,
                    children: [
                      Container(
                        width: 150,
                        color: Colors.amber[600],
                        child: Center(
                          child: Text("List Item 1"),
                        ),
                      ),
                      Container(
                        width: 150,
                        color: Colors.amber[500],
                        child: Center(
                          child: Text("List Item 2"),
                        ),
                      ),
                      Container(
                        width: 150,
                        color: Colors.amber[400],
                        child: Center(
                          child: Text("List Item 3"),
                        ),
                      ),
                      Container(
                        width: 150,
                        color: Colors.amber[300],
                        child: Center(
                          child: Text("List Item 4"),
                        ),
                      ),
                      // Text("List Item 1"),
                      // Text("List Item 2"),
                      // Text("List Item 3"),
                      // Text("List Item 4"),
                      // Text("List Item 5"),
                      // Text("List Item 6"),
                      // Text("List Item 7"),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                //
                // ListViewBuilder
                //
                Container(
                  color: Colors.yellow,
                  height: 200,
                  child: ListView.builder(
                      itemCount: inventory.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          tileColor: Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          minVerticalPadding: 10,
                          title: Text("${inventory[index]['name']}"),
                          trailing: Text("\$ ${inventory[index]['price']}"),
                          onTap: () {
                            print(
                                "You Tapped $index which is ${inventory[index]['name']}");
                          },
                        );

                        // return Container(
                        //   height: 50,
                        //   color: Colors.pinkAccent,
                        //   child: Center(
                        //     child: Text("Entry: $index"),
                        //   ),
                        // );
                      }),
                )
              ],
            ),
          ),
        ));
  }
}
