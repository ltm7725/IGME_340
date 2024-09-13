import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Week3AApp(),
    );
  }
}

class Week3AApp extends StatefulWidget {
  const Week3AApp({super.key});

  @override
  State<Week3AApp> createState() => _Week3AAppState();
}

class _Week3AAppState extends State<Week3AApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello CLASS!'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        color: Colors.grey,
        width: double.infinity,
        height: double.infinity,
        //
        // My main scroll
        //
        child: SingleChildScrollView(
          child: myColumn(),
        ),
      ),
    );
  }

  //
  // my awesome column!
  //
  Widget myColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        redContainer(),
        SizedBox(
          height: 20,
        ),
        blueContainer(),
        SizedBox(height: 20),
        Container(
          color: Colors.purple,
          width: 200,
          height: 200,
          alignment: Alignment.center,
          child: Container(
            color: Colors.pink,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Hello World"),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          color: Colors.orange,
          width: 200,
          height: 200,
          alignment: Alignment.center,
          child: Container(
            color: Colors.brown,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Hello World"),
            ),
          ),
        ),
      ],
    );
  }

  Container blueContainer() {
    return Container(
      color: Colors.blue,
      width: 200,
      height: 200,
      alignment: Alignment.center,
      child: Container(
        color: Colors.yellow,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Hello World"),
        ),
      ),
    );
  }

  Container redContainer() {
    return Container(
      color: Colors.red,
      width: 200,
      height: 200,
      alignment: Alignment.center,
      child: Container(
        color: Colors.green,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Hello World"),
        ),
      ),
    );
  }
}