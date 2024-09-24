import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String text01 = "Button 01";
  String text02 = "Button 02";
  String text03 = "Button 03";
  int count01 = 0;
  int count02 = 0;
  int count03 = 0;
  String netImg =
      "https://i.pinimg.com/736x/4f/79/d5/4f79d5e42a80a3e289a7cf0b235ecd49.jpg";

  pressEB1() {
    setState(() {
      count01++;
      text01 = "I was clicked $count01 times";
    });
  }

  pressEB2() {
    setState(() {
      count02++;
      text02 = "I was clicked $count02 times";
    });
  }

  pressEB3() {
    setState(() {
      count03++;
      text03 = "I was clicked $count03 times";
    });
  }

  clearNums() {
    setState(() {
      count01 = 0;
      text01 = "Button 01";
      count02 = 0;
      text02 = "Button 02";
      count03 = 0;
      text03 = "Button 03";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Week4A Demos"),
        backgroundColor: Color.fromARGB(80, 238, 116, 55),
        elevation: 20,
        leading: Image.network(netImg),
        // leading: const Padding(
        //   padding: EdgeInsets.only(
        //     left: 20,
        //     right: 20,
        //   ),
        //   child: Icon(
        //     Icons.handyman,
        //     size: 40,
        //     color: Colors.green,
        //     shadows: [
        //       Shadow(
        //         color: Colors.black,
        //         blurRadius: 20,
        //         offset: Offset(2, 2),
        //       ),
        //     ],
        //   ),
        // ),
        actions: [
          IconButton(
            onPressed: pressEB1,
            icon: Icon(Icons.add),
          ),
          IconButton(
            onPressed: clearNums,
            icon: Icon(Icons.delete_forever),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(netImg),
                  ),
                  color: Colors.purpleAccent,
                  border: Border.all(
                    color: Colors.red,
                    width: 5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 20,
                      offset: Offset(5, 5),
                    ),
                  ],
                ),
                // color: Colors.green,
              ),
              // Image.network(
              //   netImg,
              //   width: 200,
              //   height: 200,
              //   fit: BoxFit.cover,
              // ),
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/egg.png"),
                  ),
                  color: Colors.pink,
                  border: Border.all(
                    color: Colors.green,
                    width: 5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 20,
                      offset: Offset(5, 5),
                    ),
                  ],
                ),
                // color: Colors.green,
              ),
              const Image(
                width: 200,
                height: 200,
                image: AssetImage("assets/images/egg.png"),
              ),
              ElevatedButton(
                onPressed: pressEB1,
                child: Text("$text01"),
              ),
              ElevatedButton(
                onPressed: pressEB2,
                child: Text("$text02"),
              ),
              ElevatedButton(
                onPressed: pressEB3,
                child: Text("$text03"),
              ),
              Container(
                width: double.infinity,
                height: 5,
                color: Colors.green,
              ),
              Text("Count 01: $count01"),
              Text("Count 02: $count02"),
              Text("Count 03: $count03"),
            ],
          ),
        ),
      ),
    );
  }
}
