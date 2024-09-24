import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.light,
      theme: ThemeData(
        fontFamily: "Courier",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[300],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(ColorScheme.fromSeed(seedColor: Colors.deepPurple).secondary),
            foregroundColor: WidgetStatePropertyAll(ColorScheme.fromSeed(seedColor: Colors.deepPurple).inversePrimary),
            textStyle: const WidgetStatePropertyAll(TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            )
            )
          )
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Colors.black,
            fontSize: 48,
            fontWeight: FontWeight.bold
          ),
          displayMedium: TextStyle(
            color: Colors.black,
            fontSize: 36,
            fontWeight: FontWeight.w300
          ),
          displaySmall: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.normal
          ),
          bodyLarge: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold
          ),
          bodyMedium: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.normal
          ),
          bodySmall: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.normal
          )
        )
      ),
      darkTheme: ThemeData(
        fontFamily: "Courier",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        scaffoldBackgroundColor: Colors.blueGrey[500],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(ColorScheme.fromSeed(seedColor: Colors.red).secondary),
            foregroundColor: WidgetStatePropertyAll(ColorScheme.fromSeed(seedColor: Colors.red).inversePrimary),
            textStyle: const WidgetStatePropertyAll(TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            )
            )
          )
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold
          ),
          displayMedium: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w300
          ),
          displaySmall: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.normal
          ),
          bodyLarge: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold
          ),
          bodyMedium: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.normal
          ),
          bodySmall: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.normal
          )
        )

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

  int number = 0;

  void add() {
    setState(() {
      number++;
    });
    print("button press total = $number");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("IGME-340: Themes; \nbutton press total = $number", style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: add, 
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.onTertiaryFixedVariant),
                foregroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.tertiaryContainer),
                side: const WidgetStatePropertyAll(BorderSide(color: Colors.white))
              ),
              child: const Icon(Icons.add)
            ),
            TextButton(
              onPressed: add,
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.primary),
                foregroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.onInverseSurface),
              ),
              child: const Text(
                "Text Button",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal
                ),
              ),
            ),
            OutlinedButton(
              onPressed: add, 
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.tertiary),
                foregroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.tertiaryContainer),
              ),
              child: const Text(
                "Outlined Button"
              )
            ),
            Container(
              width: 300,
              height: 200,
              color: Theme.of(context).colorScheme.primary,
              child: Text("I am Green", style: Theme.of(context).textTheme.displayLarge),
            ),
            Container(
              width: 200,
              height: 200,
              color: Theme.of(context).colorScheme.secondary,
              child: Text("I am Yellow", style: Theme.of(context).textTheme.displayMedium),
            ),
            Container(
              width: 350,
              height: 100,
              color: Theme.of(context).colorScheme.error,
              child: Text("I am Pink", style: Theme.of(context).textTheme.displaySmall),
            ),
            ElevatedButton(
              onPressed: add,
              child: const Text('Elevated Button', style: TextStyle(fontFamily: "Courier")), //Added font to self-styled button
            ),
            ElevatedButton(
              onPressed: add,
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.outline),
                foregroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.surface),
              ),
              child: const Text(
                'Elevated Button',
                style: TextStyle(
                  fontFamily: "Courier", //Added font to self-styled button
                  fontSize: 28,
                  fontWeight: FontWeight.normal
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
