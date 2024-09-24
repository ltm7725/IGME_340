import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IGME-340 Basic App"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
      ),
      body: Align(
        alignment: Alignment.topRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          verticalDirection: VerticalDirection.down,
          children: [
            Container(
              height: 350,
              width: 95,
              color: Colors.amber,
              child: const Align(
                alignment: Alignment.center,
                child: Text(
                  "Item 01"
                ),
              )
            ),
            Container(
              height: 300,
              width: 95,
              color: Colors.red[400],
              child: const Align(
                alignment: Alignment.center,
                child: Text(
                  "Item 02"
                ),
              )
            ),
            Container(
              height: 200,
              width: 95,
              color: Colors.blue,
              child: const Align(
                alignment: Alignment.center,
                child: Text(
                  "Item 03"
                ),
              ),
            ),
            Container(
              height: 100,
              width: 95,
              color: Colors.lightGreen,
              child: const Align(
                alignment: Alignment.center,
                child: Text(
                  "Item 04"
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}

