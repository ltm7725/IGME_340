import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // fontFamily: "GoogleFonts.pacifico().fontFamily",

        textTheme: TextTheme(
          // bodyMedium: GoogleFonts.pacifico(
          //   fontSize: 20,
          //   // fontWeight: FontWeight.bold,
          //   // letterSpacing: -1.5,
          bodyMedium: TextStyle(
            fontFamily: "Juggernaut",
            fontSize: 20,
          ),
        ),
      ),
      home: DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                print("You clicked me!");
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("ALERT!"),
                      content: Column(
                        children: [
                          Container(
                            height: 200,
                            color: Colors.amber,
                          ),
                          Text("Whoa! You clicked me!"),
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("OK"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                width: 200,
                height: 200,
                color: Colors.pink,
                child: Center(
                  child: Text("Click me for fun!"),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                print("You clicked me too!");
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return CupertinoAlertDialog(
                      title: Text("ALERT!"),
                      content: Text("Whoa! You clicked me!"),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("OK"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                width: 200,
                height: 200,
                color: Colors.yellow,
                child: Center(
                  child: Text("Click me Too!"),
                ),
              ),
            ),
            Text(
              "I am Juggernaut!",
              style: TextStyle(
                fontFamily: "Juggernaut",
                fontSize: 30,
              ),
            ),
            Text(
              'Hello World!',
              style: GoogleFonts.arsenal(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Text(
              "This is another line here!",
              style: GoogleFonts.getFont('Bitter'),
            ),
            Text("This is yet another block of stuff to look at!"),
            Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."),
          ],
        ),
      ),
    );
  }
}
