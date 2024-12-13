import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Week7aDemo(),
    );
  }
}

class Week7aDemo extends StatefulWidget {
  const Week7aDemo({super.key});

  @override
  State<Week7aDemo> createState() => _Week7aDemoState();
}

class _Week7aDemoState extends State<Week7aDemo> {
  String myText = """
  Nunc vehicula tempor nulla ac convallis. 
  
  Pellentesque sollicitudin ornare tempus. Quisque felis quam, 
  pellentesque eu erat sit amet, mollis viverra urna. 
  
  Aenean congue, elit ac scelerisque venenatis, lectus mi ultricies dolor, 
  vitae bibendum odio lectus eu risus. Vestibulum lacinia blandit massa et finibus. 
  
  Fusce eget felis iaculis, placerat sapien at, mattis augue. 
  
  Vestibulum sit amet dui urna. Curabitur et nisi et nibh vulputate egestas non ut elit. 
  Phasellus quis faucibus turpis. 
  
  Nulla ut ligula quis magna tempus tristique nec vel lorem. 
  Praesent sit amet condimentum eros. Sed a elit eleifend, tristique tortor a, 
  convallis nulla. Donec non purus vitae sapien hendrerit scelerisque. 
  Aenean id ligula purus.
  """;
  late FocusNode _nameFocusNode;
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;

  @override
  void initState() {
    super.initState();
    _nameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Week7A"),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Color(0xFF999999),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                        width: 4,
                        color: Colors.red,
                      )),
                      width: 100,
                      height: 100,
                      child: Image.network("https://placehold.co/300x300/png"),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 4,
                            color: Colors.green,
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Text(myText),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                        width: 4,
                        color: Colors.purple,
                      )),
                      width: 100,
                      height: 100,
                      child: Image.network("https://placehold.co/300x300/png"),
                    ),
                  ],
                ),
                //
                // TextFields
                //
                SizedBox(
                  height: 150,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    style: TextStyle(
                      color: Colors.red,
                    ),
                    focusNode: _nameFocusNode,
                    onEditingComplete: () {
                      _emailFocusNode.requestFocus();
                    },
                    onTapOutside: (event) {
                      _nameFocusNode.unfocus();
                    },
                    decoration: InputDecoration(
                      icon: Icon(Icons.align_horizontal_center_rounded),
                      prefix: Icon(Icons.ac_unit),
                      prefixIcon: Icon(Icons.ads_click_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.yellow,
                          width: 3,
                        ),
                      ),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.pink,
                        width: 4,
                      )),
                      labelText: "Name",
                      suffixIcon: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.clear,
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                TextField(
                  focusNode: _emailFocusNode,
                  onEditingComplete: () {
                    _passwordFocusNode.requestFocus();
                  },
                  decoration: InputDecoration(
                    labelText: "Email",
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.clear,
                      ),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                TextField(
                  focusNode: _passwordFocusNode,
                  onEditingComplete: () {
                    _passwordFocusNode.unfocus();
                  },
                  decoration: InputDecoration(
                    labelText: "Password",
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.clear,
                      ),
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: DropdownButton(
                    isExpanded: false,
                    padding: EdgeInsets.all(10),
                    dropdownColor: Colors.amber,
                    value: "Stuff",
                    items: const [
                      DropdownMenuItem(
                        child: Text("Stuff"),
                        value: "Stuff",
                      ),
                      DropdownMenuItem(
                        child: Text("Stuff2"),
                      ),
                      DropdownMenuItem(
                        child: Text("Stuff3"),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    print("HELLO I GOT YOUR STUFF");
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  child: Text("Submit"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
