import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int bannerNum = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Week5A Demo"),
        backgroundColor: Colors.amberAccent,
        leading: Padding(
          padding: const EdgeInsets.only(
            left: 10,
            right: 10
          ),
          child: SvgPicture.asset(
            "assets/images/circle_heat.svg",
            colorFilter: const ColorFilter.mode(
              Colors.white, 
              BlendMode.srcIn),
            ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            SvgPicture.network(
              "https://people.rit.edu/dxcigm/340/assets/images/alien.svg",
              width: 100,
              height: 100,
              ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    action: SnackBarAction(
                      label: "Go Away", 
                      textColor: Colors.black,
                      onPressed: () {
                        print("I Go away!");
                        ScaffoldMessenger.of(context)
                        .hideCurrentSnackBar();
                      }
                    ),
                    duration: Duration(seconds: 10),
                    backgroundColor: Colors.amber,
                    content: Row(
                    children: [
                      Icon(Icons.adobe),
                      SizedBox(
                        width: 50,
                      ),
                      Text("I'm a Snack!",style: TextStyle(color: Colors.black,),),
                    ],
                  ))
                );
              }, 
              child: const Text("Give me a Snack!"),
            ),
            ElevatedButton(
              onPressed: () {
                bannerNum++;
                ScaffoldMessenger.of(context)
                ..removeCurrentMaterialBanner()
                ..showMaterialBanner(
                  MaterialBanner(
                    backgroundColor: Color.fromARGB(255, 233, 194, 239),
                    leading: SvgPicture.asset(
                      "assets/images/circle_heat.svg",
                      width: 60,
                      height: 60,
                      ),
                    padding: EdgeInsets.all(10),
                    content: Text("Welcome Bruce Banner! ${bannerNum}"), 
                    actions: [TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                      }, 
                      child: Text("Thanks!")
                    )]
                ));
              }, 
              child: Text("Show me da Banner!"),
            ),
            SvgPicture.asset(
              "assets/images/circle_heat.svg",
              width: 200,
              height: 200,
              colorFilter: const ColorFilter.mode(
                Color.fromARGB(92, 5, 75, 52),
                BlendMode.srcIn
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  color: Colors.red,
                  height: 300,
                  width: 300,
                ),
                Positioned(
                  right: -100,
                  bottom: -100,
                  child: Container(
                    color: Colors.green,
                    height: 200,
                    width: 200,
                  ),
                ),
                Container(
                  color: Colors.yellow,
                  height: 100,
                  width: 100,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
