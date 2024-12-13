import 'package:flutter/material.dart';
import 'package:validators/validators.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LabPage(),
    );
  }
}

class LabPage extends StatefulWidget {
  const LabPage({super.key});

  @override
  State<LabPage> createState() => _LabPageState();
}

class _LabPageState extends State<LabPage> {
  final _myFormId = GlobalKey<FormState>();
  String infoText = "Your Awesome Personal Data will show here!";
  String infoTextOrig = "Your Awesome Personal Data will show here!";

  var contactMethodsList = [
    const DropdownMenuItem(
      value: "In-Person",
      child: Text("In-Person")
    ),
    const DropdownMenuItem(
      value: "Email",
      child: Text("Email")
    ),
    const DropdownMenuItem(
      value: "Voice Call",
      child: Text("Voice Call")
    ),
    const DropdownMenuItem(
      value: "Text Message",
      child: Text("Text Message")
    ),
  ];

  final text01 = TextEditingController();
  final text02 = TextEditingController();
  final text03 = TextEditingController();
  final text04 = TextEditingController();
  final text05 = TextEditingController();
  bool onePassed = false;
  bool twoPassed = false;
  bool threePassed = false;
  bool fourPassed = false;
  String textOut = "";
  String? selectedContactMethod = "Email";

  @override
  void dispose() {
    text01.dispose();
    text02.dispose();
    text03.dispose();
    text04.dispose();
    text05.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "My Cool Game Beta Signup Form",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blue[900],
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _myFormId,
            child: Column(
              children: [
                Container(
                  height: 20,
                ),
                const Center(
                  child: Text(
                    "Welcome to your Doom!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Container(
                  height: 20,
                ),
                Container(
                  height: 175,
                  width: 375,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      style: BorderStyle.solid,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        infoText,
                        style: const TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      "Enter your information to get the latest news on our awesome game!",
                      style: TextStyle(
                        fontSize: 20.5,
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 18),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Color.fromARGB(255, 109, 100, 100),
                        ),
                      ),
                      Container(
                        width: 300,
                        height: 75,
                        child: Center(
                          child: TextFormField(
                            controller: text01,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: "Name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {text01.clear();}, 
                                icon: Icon(
                                  Icons.close,
                                )
                              )
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                onePassed = false;
                                return "Please Enter Your Name";
                              }
                              else onePassed = true;
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 7.5,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 18),
                        child: Icon(
                          Icons.email,
                          size: 60,
                          color: Color.fromARGB(255, 109, 100, 100),
                        ),
                      ),
                      Container(
                        width: 300,
                        height: 75,
                        child: Center(
                          child: TextFormField(
                            controller: text02,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Email",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {text02.clear();}, 
                                icon: Icon(
                                  Icons.close,
                                )
                              )
                            ),
                            validator: (value) {
                              if (value != null && !isEmail(value)) {
                                twoPassed = false;
                                return "Please Enter Your Email Address";
                              }
                              else twoPassed = true;
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 7.5,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 18),
                        child: Icon(
                          Icons.date_range,
                          size: 60,
                          color: Color.fromARGB(255, 109, 100, 100),
                        ),
                      ),
                      Container(
                        width: 300,
                        height: 75,
                        child: Center(
                          child: TextFormField(
                            controller: text03,
                            keyboardType: TextInputType.datetime,
                            decoration: InputDecoration(
                              labelText: "Date of Birth",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {text03.clear();}, 
                                icon: Icon(
                                  Icons.close,
                                )
                              )
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                threePassed = false;
                                return "Please Enter A Valid Date";
                              }
                              else threePassed = true;
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 7.5,
                ),
                Container(
                  width: double.infinity,
                  height: 75,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 18),
                        child: Icon(
                          Icons.phone,
                          size: 60,
                          color: Color.fromARGB(255, 109, 100, 100),
                        ),
                      ),
                      Container(
                        width: 300,
                        height: 75,
                        child: Center(
                          child: TextFormField(
                            controller: text04,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: "Phone",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {text04.clear();}, 
                                icon: Icon(
                                  Icons.close,
                                )
                              )
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                fourPassed = false;
                                return "Please Enter Your Phone Number";
                              }
                              else {
                                fourPassed = true;
                                if(onePassed && twoPassed && threePassed) setState(() {
                                  infoText = "Name: ${text01.text}\nEmail: ${text02.text}\nDOB: ${text03.text}\nPhone: ${text04.text}\nContact Pref $selectedContactMethod";
                                }); 
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 75,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 18),
                        child: Icon(
                          Icons.contact_support,
                          size: 60,
                          color: Color.fromARGB(255, 109, 100, 100),
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        height: 56,
                        child: Center(
                          child: InputDecorator(
                            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                isExpanded: true,
                                value: "$selectedContactMethod",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16
                                ),
                                menuWidth: 412,
                                items: contactMethodsList, 
                                onChanged: (selected) {
                                  setState(() {
                                    selectedContactMethod = selected;
                                  });
                                }
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 28),
                        child: ElevatedButton(
                          onPressed: () {
                            text01.clear();
                            text02.clear();
                            text03.clear();
                            text04.clear();
                            text05.clear();
                            setState(() {
                              infoText = infoTextOrig;
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(Colors.red),
                            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)))
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 8,
                                  top: 12,
                                  bottom: 12
                                ),
                                child: Text(
                                  "Reset Form",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            _myFormId.currentState!.validate();
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(Colors.blue[900]),
                            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)))
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 8,
                                  top: 12,
                                  bottom: 12
                                ),
                                child: Text(
                                  "Submit Form",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
