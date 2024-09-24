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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            verticalDirection: VerticalDirection.down,
            children: [
              Container(
                height: 200,
                color: Colors.red,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Item 01",
                    ),
                )
              ),
              Container(
                height: 200,
                color: Colors.orange,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Item 02",
                    ),
                )
              ),
              Container(
                height: 200,
                color: Colors.yellow,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Item 03",
                    ),
                )
              ),
              Container(
                height: 200,
                color: Colors.green,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Item 04",
                    ),
                )
              ),
              Container(
                height: 200,
                color: Colors.blue,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Item 05",
                    ),
                )
              ),
              Container(
                height: 200,
                color: Colors.purple,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Item 06",
                    ),
                )
              ),
              Container(
                height: 200,
                color: Colors.pink,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Item 07",
                    ),
                )
              ),
              Container(
                height: 200,
                color: Colors.white,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Item 08",
                    ),
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}

