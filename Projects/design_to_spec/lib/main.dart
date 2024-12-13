import 'package:flutter/material.dart';

/// 
/// Project 1: Design to Spec
/// 
/// Interactive, informational app template themed on 
/// Minecraft trees and their uses; developed to be 
/// as 1:1 as possible to reference material for assignment
/// 
/// @author: L Mavroudakis
/// @version: 1.0.0
/// @since: 2024-09-26
/// 

///
/// Main function that starts the program. 
/// We use runApp to start the program with our StatelessWidget MainApp.
///
void main() {
  runApp(const MyApp());
}
// END main

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  //
  // primary build function that builds the UI for the program.
  //
  // @return MaterialApp
  //
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trees & Wood',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: "RetroComputerPersonalUse",
            fontSize: 21.5
          ),
          headlineMedium: TextStyle(
            color: Colors.white, 
            fontFamily: "RetroComputerPersonalUse",
            fontSize: 22,
          ),
          headlineSmall: TextStyle(
            color: Colors.white, 
            fontFamily: "RetroComputerPersonalUse",
            fontSize: 20.9,
            height: 1.3
          ),
          bodyLarge:  TextStyle(
            color: Colors.white,
            fontSize: 20.1,
            height: 1.17,
          ),
          titleMedium: TextStyle(
            fontFamily: "VT323Regular",
            color: Colors.white,
            fontSize: 24
          ),
          titleLarge: TextStyle(
            fontFamily: "VT323Regular",
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600
          ),
          bodyMedium: TextStyle(
            fontFamily: "VT323Regular",
            color: Colors.white,
            fontSize: 22.5,
            letterSpacing: -0.1,
            height: 1
          ),
          displayLarge: TextStyle(
            fontFamily: "RetroComputerPersonalUse",
            color: Colors.white,
            fontSize: 16,
            height: 1.215,
          ),
          displayMedium: TextStyle(
            fontFamily: "VT323Regular",
            color: Colors.white,
            fontSize: 21
          ),
          displaySmall: TextStyle(
            fontFamily: "VT323Regular",
            color: Colors.black,
            fontSize: 17.3,
            height: 1
          ),
          titleSmall: TextStyle(
            fontFamily: "VT323Regular",
            color: Colors.black,
            fontSize: 20,
            height: 1
          ),
          labelSmall: TextStyle(
            fontFamily: "VT323Regular",
            color: Colors.black,
            fontSize: 16,
            height: 1
          )
        )
      ),
      home: const MyHomePage(title: 'Trees & Wood'),
    );
  }
   // END build
}
// END MainApp

///
/// state update class handling dynamic changes within the app
///
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
// END state update class

///
/// state class handling the compilation of content and
/// functions defined within the widget in said class
///
class _MyHomePageState extends State<MyHomePage> {

  // build function defining defining content and specific
  // functions/interactions contained/done in the app
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 161, 159, 161),
        title: Text(
          widget.title, 
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        // appbar pickaxe graphic
        leading: const Image(
          height: 1, 
          width: 1, 
          image: AssetImage("assets/images/pickaxe.png")),
        // account-image button displaying information about the project/developer
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4))
                    ),
                    title: Text(
                      "About",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    content: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        "Created by L Mavroudakis\n\nBased on the work done in 235's Design to Spec Homework.\n\nSeptember 26-27, 2024",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ButtonStyle(
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                          backgroundColor: const WidgetStatePropertyAll(Color.fromARGB(255, 161, 159, 161))
                        ),
                        child: Text(
                          "OK",
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(
              Icons.account_circle, 
              color: Colors.black,
            )
          )
        ],
      ),
      // valley background
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/valley.jpg"), 
            fit: BoxFit.fitHeight
          )
        ),
        child: Center(
          // main scroll area of app
          child: SingleChildScrollView(
            child: Column(
              children: [
                // top tree graphic & gradient/white frame
                Container(
                  width: 412,
                  height: 412,
                  color: Colors.white,
                  child: Center(
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomRight,
                          end: Alignment.topLeft,
                          colors:[
                            Color.fromARGB(255, 52, 69, 68),
                            Color.fromARGB(255, 139, 141, 143)
                          ],
                        )
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 325,
                          height: 325,
                          child: Image(
                            image: AssetImage("assets/images/oaktree.png"),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // top dialogue about oak trees, with surrounding widget
                Stack(
                  children: [
                    Container(
                      width: 412,
                      height: 554,
                      color: const Color.fromARGB(255, 107, 104, 107),
                    ),
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Text(
                              "The Oak Tree",
                              style: Theme.of(context).textTheme.headlineLarge
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                            top: 2
                          ),
                          child: Text(
                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut porta metus risus, tempus pulvinar est finibus nec.\n\nPhasellus tempus gravida condimentum. Nullam scelerisque tristique pretium. Sed quis feugiat arcu, vel sodales ante. Fusce convallis sapien non ex rutrum volutpat sit amet et arcu. In lectus leo, aliquam vel maximus commodo, maximus id leo.\n\nAenean non faucibus metus, venenatis dictum lacus. Nulla tempor eget ante vitae blandit. In hac habitasse platea dictumst. Done tortor sem, vulputate in iaculis eu, rutrum eget leo. Nunc et laoreet diam. Praesent diam eros, volutpat eu hendrerit quis, scelerisque placerat enim.",
                            style: Theme.of(context).textTheme.bodyLarge
                          ),
                        )
                      ],
                    )
                  ],
                ),
                // empty space between sections, displaying background
                Container(
                  height: 425,
                ),
                // surrounding widget for informational sections
                Stack(
                  children: [
                    Container(
                      height: 715,
                      width: 412,
                      color: const Color.fromARGB(255, 55, 54, 61),
                    ),
                    // column of informational sections for what wood from
                    // trees is able to be turned into
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Stack(
                            children: [
                              Container(
                                width: 388,
                                height: 158,
                                color: const Color.fromARGB(255, 107, 104, 107),
                              ),
                              // planks informational section
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // informational pop-up dialog for planks
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: const Color.fromARGB(255, 107, 104, 107),
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(12))
                                            ),
                                            title: Text(
                                              "Planks",
                                              style: Theme.of(context).textTheme.displayMedium,
                                            ),
                                            content: Stack(
                                              children: [
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    height: 1000, // arbitrary
                                                    width: 284,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        Align(
                                                          alignment: Alignment.center,
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(top: 6),
                                                            child: Container(
                                                              height: 272,
                                                              width: 272,
                                                              color: const Color.fromARGB(255, 49, 78, 69),
                                                            ),
                                                          ),
                                                        ),
                                                        const Align(
                                                          alignment: Alignment.center,
                                                          child: Padding(
                                                            padding: EdgeInsets.only(top: 16),
                                                            child: Image(
                                                              height: 252,
                                                              width: 252,
                                                              image: AssetImage("assets/images/planks.png"),
                                                            )
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 346,
                                                      width: 292,
                                                      child: SingleChildScrollView(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(
                                                            top: 12,
                                                            left: 10,
                                                            right: 10
                                                          ),
                                                          child: Text(
                                                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi sed iaculis ligula. Nunc felis eros, dictum non orci ut, elementun facilisis nulla. Vestibulum at risus tellus. Phasellus interdum nisi faucibus dictun hendrerit. Quisque interdum diam purus, vitae mattis tellus semper at. In hac habitasse platea dictumst. Aenean rutrum maximus lacus, et eleifend urna tempor non. Aenean feugiat efficitur feugiat. Quisque pretiun orci vel arcu imperdiet naximus. Quisque et nunc at enim maximus sagittis ac quis ipsum. Etiam ullancorper sollicitudin velit eget tincidunt. Sed ultrices, leo ac blandit vehicula, lacus metus nollis nibh, id pulvinar ipsun neque non purus. Donec a ipsum nunc. Pellentesque habitant norbi tristique senectus et netus et malesuada fames ac turpis egestas. Nullam mollis pellentesque urna eu ullamcorper. Phasellus id lacus sit amet leo aliquet eleifend.",
                                                            style: Theme.of(context).textTheme.displaySmall,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                style: ButtonStyle(
                                                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                                                  backgroundColor: const WidgetStatePropertyAll(Color.fromARGB(255, 161, 159, 161))
                                                ),
                                                child: Text(
                                                  "Close",
                                                  style: Theme.of(context).textTheme.displaySmall,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 158,
                                          height: 158,
                                          color: Colors.white,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Container(
                                            height: 146,
                                            width: 146,
                                            color: const Color.fromARGB(255, 49, 78, 69),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(3),
                                                  child: Text(
                                                    "Planks",
                                                    style: Theme.of(context).textTheme.titleMedium,
                                                  ),
                                                ),
                                                const Image(
                                                  height: 95,
                                                  width: 95,
                                                  image: AssetImage("assets/images/planks.png"),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 229,
                                    height: 142,
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                          right: 8,
                                        ),
                                        child: Text(
                                          "Planks are common blocks used as building blocks and in crafting recipes. They are one of the first things that a player can craft in Survival and Adventure modes. Two categories of planks can be differentiated: flammable Overworld planks made from tree logs, and nonflammable Nether planks made from huge fungus stems.",
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 12,
                            left: 12,
                            right: 12
                          ),
                          child: Stack(
                            children: [
                              Container(
                                width: 388,
                                height: 158,
                                color: const Color.fromARGB(255, 107, 104, 107),
                              ),
                              // sticks informational section
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // informational pop-up dialog for sticks
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: const Color.fromARGB(255, 107, 104, 107),
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(12))
                                            ),
                                            title: Text(
                                              "Sticks",
                                              style: Theme.of(context).textTheme.displayMedium,
                                            ),
                                            content: Stack(
                                              children: [
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    height: 1000, // arbitrary
                                                    width: 284,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        Align(
                                                          alignment: Alignment.center,
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(top: 6),
                                                            child: Container(
                                                              height: 272,
                                                              width: 272,
                                                              color: const Color.fromARGB(255, 49, 78, 69),
                                                            ),
                                                          ),
                                                        ),
                                                        const Align(
                                                          alignment: Alignment.center,
                                                          child: Padding(
                                                            padding: EdgeInsets.only(top: 16),
                                                            child: Image(
                                                              height: 252,
                                                              width: 252,
                                                              image: AssetImage("assets/images/stick.png"),
                                                            )
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 346,
                                                      width: 292,
                                                      child: SingleChildScrollView(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(
                                                            top: 12,
                                                            left: 10,
                                                            right: 10
                                                          ),
                                                          child: Text(
                                                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi sed iaculis ligula. Nunc felis eros, dictum non orci ut, elementun facilisis nulla. Vestibulum at risus tellus. Phasellus interdum nisi faucibus dictun hendrerit. Quisque interdum diam purus, vitae mattis tellus semper at. In hac habitasse platea dictumst. Aenean rutrum maximus lacus, et eleifend urna tempor non. Aenean feugiat efficitur feugiat. Quisque pretiun orci vel arcu imperdiet naximus. Quisque et nunc at enim maximus sagittis ac quis ipsum. Etiam ullancorper sollicitudin velit eget tincidunt. Sed ultrices, leo ac blandit vehicula, lacus metus nollis nibh, id pulvinar ipsun neque non purus. Donec a ipsum nunc. Pellentesque habitant norbi tristique senectus et netus et malesuada fames ac turpis egestas. Nullam mollis pellentesque urna eu ullamcorper. Phasellus id lacus sit amet leo aliquet eleifend.",
                                                            style: Theme.of(context).textTheme.displaySmall,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                style: ButtonStyle(
                                                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                                                  backgroundColor: const WidgetStatePropertyAll(Color.fromARGB(255, 161, 159, 161))
                                                ),
                                                child: Text(
                                                  "Close",
                                                  style: Theme.of(context).textTheme.displaySmall,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 158,
                                          height: 158,
                                          color: Colors.white,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Container(
                                            height: 146,
                                            width: 146,
                                            color: const Color.fromARGB(255, 49, 78, 69),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                    top: 8,
                                                    bottom: 6
                                                  ),
                                                  child: Text(
                                                    "Sticks",
                                                    style: Theme.of(context).textTheme.titleLarge,
                                                  ),
                                                ),
                                                const Image(
                                                  height: 95,
                                                  width: 95,
                                                  image: AssetImage("assets/images/stick.png"),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 229,
                                    height: 142,
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                          right: 8,
                                        ),
                                        child: Text(
                                          "A stick is an item used for crafting many tools and items.",
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 12,
                            left: 12,
                            right: 12
                          ),
                          child: Stack(
                            children: [
                              Container(
                                width: 388,
                                height: 158,
                                color: const Color.fromARGB(255, 107, 104, 107),
                              ),
                              // chests informational section
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // informational pop-up dialog for chests
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: const Color.fromARGB(255, 107, 104, 107),
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(12))
                                            ),
                                            title: Text(
                                              "Chests",
                                              style: Theme.of(context).textTheme.displayMedium,
                                            ),
                                            content: Stack(
                                              children: [
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    height: 1000, // arbitrary
                                                    width: 284,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        Align(
                                                          alignment: Alignment.center,
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(top: 6),
                                                            child: Container(
                                                              height: 272,
                                                              width: 272,
                                                              color: const Color.fromARGB(255, 49, 78, 69),
                                                            ),
                                                          ),
                                                        ),
                                                        const Align(
                                                          alignment: Alignment.center,
                                                          child: Image(
                                                            height: 282,
                                                            width: 282,
                                                            image: AssetImage("assets/images/chest.png"),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 342,
                                                      width: 292,
                                                      child: SingleChildScrollView(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(
                                                            top: 8,
                                                            left: 10,
                                                            right: 10
                                                          ),
                                                          child: Text(
                                                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi sed iaculis ligula. Nunc felis eros, dictum non orci ut, elementun facilisis nulla. Vestibulum at risus tellus. Phasellus interdum nisi faucibus dictun hendrerit. Quisque interdum diam purus, vitae mattis tellus semper at. In hac habitasse platea dictumst. Aenean rutrum maximus lacus, et eleifend urna tempor non. Aenean feugiat efficitur feugiat. Quisque pretiun orci vel arcu imperdiet naximus. Quisque et nunc at enim maximus sagittis ac quis ipsum. Etiam ullancorper sollicitudin velit eget tincidunt. Sed ultrices, leo ac blandit vehicula, lacus metus nollis nibh, id pulvinar ipsun neque non purus. Donec a ipsum nunc. Pellentesque habitant norbi tristique senectus et netus et malesuada fames ac turpis egestas. Nullam mollis pellentesque urna eu ullamcorper. Phasellus id lacus sit amet leo aliquet eleifend.",
                                                            style: Theme.of(context).textTheme.displaySmall,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                style: ButtonStyle(
                                                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                                                  backgroundColor: const WidgetStatePropertyAll(Color.fromARGB(255, 161, 159, 161))
                                                ),
                                                child: Text(
                                                  "Close",
                                                  style: Theme.of(context).textTheme.displaySmall,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 158,
                                          height: 158,
                                          color: Colors.white,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Container(
                                            height: 146,
                                            width: 146,
                                            color: const Color.fromARGB(255, 49, 78, 69),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                    top: 7,
                                                    bottom: 6
                                                  ),
                                                  child: Text(
                                                    "Chests",
                                                    style: Theme.of(context).textTheme.titleLarge,
                                                  ),
                                                ),
                                                const Image(
                                                  height: 95,
                                                  width: 95,
                                                  image: AssetImage("assets/images/chest.png"),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 229,
                                    height: 142,
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                          right: 8,
                                        ),
                                        child: Text(
                                          "Pellentesque molestie nisl libero, a tincidunt arcu auctor in. Integer sed massa nec enim dictum tempor et sit amet nisl. Sed ad excepteur excepteur aute. Non ad velit labore id id anim pariatur dolore elit reprehenderit. Labore velit esse eiusmod deserunt sit duis laboris fugiat. Ipsum consequat fugiat proident eiusmod. Do sunt culpa enim do pariatur ad aliquip voluptate. Excepteur cupidatat laborum qui proident amet fugiat. Aliquip excepteur do cupidatat amet ut veniam aute elit enim. Ullamco est cillum eiusmod ad. Minim consectetur do reprehenderit amet labore. Adipisicing ut anim sint culpa velit sunt laborum amet consectetur proident occaecat cupidatat. Ipsum eiusmod dolore irure adipisicing fugiat laborum exercitation dolor labore aliqua fugiat qui.",
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 12,
                            left: 12,
                            right: 12
                          ),
                          child: Stack(
                            children: [
                              Container(
                                width: 388,
                                height: 158,
                                color: const Color.fromARGB(255, 107, 104, 107),
                              ),
                              // stairs informational section
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // informational pop-up dialog for stairs
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: const Color.fromARGB(255, 107, 104, 107),
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(12))
                                            ),
                                            title: Text(
                                              "Stairs",
                                              style: Theme.of(context).textTheme.displayMedium,
                                            ),
                                            content: Stack(
                                              children: [
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    height: 1000, // arbitrary
                                                    width: 284,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        Align(
                                                          alignment: Alignment.center,
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(top: 6),
                                                            child: Container(
                                                              height: 272,
                                                              width: 272,
                                                              color: const Color.fromARGB(255, 49, 78, 69),
                                                            ),
                                                          ),
                                                        ),
                                                        const Align(
                                                          alignment: Alignment.center,
                                                          child: Padding(
                                                            padding: EdgeInsets.only(top: 16),
                                                            child: Image(
                                                              height: 252,
                                                              width: 252,
                                                              image: AssetImage("assets/images/stairs.png"),
                                                            )
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 346,
                                                      width: 292,
                                                      child: SingleChildScrollView(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(
                                                            top: 12,
                                                            left: 10,
                                                            right: 10
                                                          ),
                                                          child: Text(
                                                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi sed iaculis ligula. Nunc felis eros, dictum non orci ut, elementun facilisis nulla. Vestibulum at risus tellus. Phasellus interdum nisi faucibus dictun hendrerit. Quisque interdum diam purus, vitae mattis tellus semper at. In hac habitasse platea dictumst. Aenean rutrum maximus lacus, et eleifend urna tempor non. Aenean feugiat efficitur feugiat. Quisque pretiun orci vel arcu imperdiet naximus. Quisque et nunc at enim maximus sagittis ac quis ipsum. Etiam ullancorper sollicitudin velit eget tincidunt. Sed ultrices, leo ac blandit vehicula, lacus metus nollis nibh, id pulvinar ipsun neque non purus. Donec a ipsum nunc. Pellentesque habitant norbi tristique senectus et netus et malesuada fames ac turpis egestas. Nullam mollis pellentesque urna eu ullamcorper. Phasellus id lacus sit amet leo aliquet eleifend.",
                                                            style: Theme.of(context).textTheme.displaySmall,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                style: ButtonStyle(
                                                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                                                  backgroundColor: const WidgetStatePropertyAll(Color.fromARGB(255, 161, 159, 161))
                                                ),
                                                child: Text(
                                                  "Close",
                                                  style: Theme.of(context).textTheme.displaySmall,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 158,
                                          height: 158,
                                          color: Colors.white,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Container(
                                            height: 146,
                                            width: 146,
                                            color: const Color.fromARGB(255, 49, 78, 69),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                    top: 7,
                                                    bottom: 6
                                                  ),
                                                  child: Text(
                                                    "Stairs",
                                                    style: Theme.of(context).textTheme.titleLarge,
                                                  ),
                                                ),
                                                const Image(
                                                  height: 95,
                                                  width: 95,
                                                  image: AssetImage("assets/images/stairs.png"),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 229,
                                    height: 142,
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                          right: 8,
                                        ),
                                        child: Text(
                                          "Sed sodales vel nulla neo sollicitudin. Vestibulum sodales congue gravida. Nam nulla massa, rhoncus id pulvinar in, sagittis reprehenderit magna ex fugiat anim eu ea. Incididunt amet nulla cupidatat enim elit. Ea eiusmod consectetur labore elit sunt nulla ipsum sint aliquip nostrud sint Lorem. Irure exercitation cupidatat quis culpa cupidatat elit excepteur. Qui esse qui non aliqua ullamco cillum. Veniam amet laboris Lorem exercitation amet fugiat ipsum veniam nostrud. Cupidatat esse quis aliqua proident officia adipisicing non consectetur nostrud magna incididunt. Cillum in nostrud ipsum adipisicing mollit enim ut velit dolor excepteur irure.",
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        // thin white section separator
                        Container(
                          height: 10,
                          width: 412,
                          color: Colors.white,
                        ),
                        // bottom tree display with text on top and bottom
                        Stack(
                          children: [
                            const Image(
                              image: AssetImage("assets/images/trees.jpg"),
                              height: 315,
                              width: 412,
                              fit: BoxFit.fill,
                            ),
                            Column(
                              children: [
                                Text(
                                  "Trees are pretty cool, right?",
                                  style: Theme.of(context).textTheme.headlineSmall,
                                  textAlign: TextAlign.center,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 203
                                  ),
                                  child: Text(
                                    "Copyright 2024\nRIT School of Interactive Games and Media",
                                    style: Theme.of(context).textTheme.displayLarge,
                                    textAlign: TextAlign.center,
                                  )
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  // END build
}
// END state class
