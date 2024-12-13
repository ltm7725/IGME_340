import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Week7bDemo(),
    );
  }
}

class Week7bDemo extends StatefulWidget {
  const Week7bDemo({super.key});

  @override
  State<Week7bDemo> createState() => _Week7bDemoState();
}

class _Week7bDemoState extends State<Week7bDemo> {
  String randomUrl =
      "https://api.giphy.com/v1/gifs/random?api_key=RofgiRjHSYdpdRnyWOzJRhfNFda7BIUf&tag=&rating=g";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Week 7b Demo'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Container(
            color: const Color.fromARGB(255, 247, 209, 221),
            height: 300,
            child: RefreshIndicator(
              onRefresh: doRefresh,
              child: GridView.builder(
                // physics: NeverScrollableScrollPhysics(),
                itemCount: 30,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return GridTile(
                    header: Center(child: Text("Header: $index")),
                    footer: Center(child: Text("Footer $index")),
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.green,
                      child: Text("Grid: $index"),
                    ),
                  );

                  // return Container(
                  //     alignment: Alignment.center,
                  //     height: 50,
                  //     width: 50,
                  //     color: Colors.green,
                  //     child: Text("Grid: $index"));
                },
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              doRandom();
            },
            child: Text("Random"),
          ),
        ],
      ),
      // body: GridView.count(
      //   crossAxisSpacing: 10,
      //   mainAxisSpacing: 20,
      //   crossAxisCount: 3,
      //   children: [
      //     Container(
      //       color: Colors.amber,
      //       child: Text("Grid 01"),
      //     ),
      //     Container(
      //       color: Colors.amber[200],
      //       child: Text("Grid 02"),
      //     ),
      //     Container(
      //       color: Colors.amber[400],
      //       child: Text("Grid 03"),
      //     ),
      //     Container(
      //       color: Colors.amber[100],
      //       child: Text("Grid 04"),
      //     ),
      //     Container(
      //       color: Colors.amber[300],
      //       child: Text("Grid 05"),
      //     ),
      //     Container(
      //       color: Colors.amber[500],
      //       child: Text("Grid 06"),
      //     ),
      //   ],
      // ),
    );
  }

  Future<void> doRefresh() async {
    await Future.delayed(
      Duration(seconds: 2),
    );
    print("Done Refreshing");
  }

  Future doRandom() async {
    var response = await http.get(Uri.parse(randomUrl));

    if (response.statusCode == 200) {
      var jsonResp = jsonDecode(response.body);
      print(jsonResp);
    } else {
      print("ERROR: $response.statusCode");
    }
  }
}
