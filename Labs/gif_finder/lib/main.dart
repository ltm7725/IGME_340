import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LabPage(),
      theme: ThemeData(
        fontFamily: "Oswald"
      ),
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
  final text01 = TextEditingController();
  String? selectedResultAmt = "10";
  String? selectedRating = "r";
  String apiKey = "z4SiOyuYCYGUS95bkcBxh4D6SVpKwB1k";
  String searchUrl = "";
  int itemCt = 0;
  Map httpData = Map();
  var gifData = [];

  var resultAmtsList = [
    const DropdownMenuItem(value: "10", child: Text("10")),
    const DropdownMenuItem(value: "20", child: Text("20")),
    const DropdownMenuItem(value: "30", child: Text("30")),
    const DropdownMenuItem(value: "40", child: Text("40")),
    const DropdownMenuItem(value: "50", child: Text("50")),
  ];

  var ratingsList = [
    const DropdownMenuItem(value: "r", child: Text("Any (R & Below)")),
    const DropdownMenuItem(value: "g", child: Text("G")),
    const DropdownMenuItem(value: "pg", child: Text("PG")),
    const DropdownMenuItem(value: "pg-13", child: Text("PG-13")),
  ];

  @override
  void dispose() {
    text01.dispose();
  }

  @override
  void initState() {
    doHttpInit();
  }

  Future doHttpInit() async {
    String link = "https://api.giphy.com/v1/gifs/trending?api_key=$apiKey&limit=$selectedResultAmt&rating=$selectedRating";

    var response = await http.get(Uri.parse(link));

    if (response.statusCode == 200) {
      httpData = jsonDecode(response.body);
      print(httpData);

      setState(() {
        searchUrl = "https://giphy.com/search/${text01.text}?rating=";
        if (selectedRating == "r")
          searchUrl == "r";
        else
          searchUrl += "pg-13";
        gifData = [];

        for (int i = 0; i < httpData["pagination"]["count"]; i++) {
          gifData.add(httpData["data"][i]);
          print("${httpData["data"][i]["images"]["original"]["url"]}");
        }

        itemCt = httpData["pagination"]["count"];
      });
    } else {
      print("ERROR: $response.statusCode");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Giphy Finder"),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          leading: Padding(
            padding: EdgeInsets.all(8),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white),
                child: Icon(
                  Icons.gif,
                  size: 35,
                  color: Colors.blue,
                )),
          ),
          actions: [onGiphy()],
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/bg.png"),
                    fit: BoxFit.fitWidth),
              ),
            ),
            Form(
              key: _myFormId,
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 20.0, left: 20, right: 20),
                    child: TextFormField(
                      controller: text01,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 3)),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 3)),
                        errorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 1)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 3)),
                        errorStyle: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                        fillColor: Colors.white,
                        filled: true,
                        labelText: "Search Term",
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        hintText: "What do you want to find?",
                        suffixIcon: IconButton(
                            onPressed: () {
                              text01.clear();
                            },
                            icon: Icon(
                              Icons.close,
                            )),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Please fix issues and try again!"),
                            duration: Duration(seconds: 5),
                          ));
                          return "Please enter a search term";
                        }
                        doHttpMain();
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 20.0, left: 20, right: 20),
                    child: Container(
                      height: 63,
                      child: InputDecorator(
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 3)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 3)),
                            fillColor: Colors.white,
                            filled: true,
                            labelText: "Number of Results"),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                              isExpanded: true,
                              value: "$selectedResultAmt",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                              menuWidth: 412,
                              items: resultAmtsList,
                              onChanged: (selected) {
                                setState(() {
                                  selectedResultAmt = selected;
                                });
                              }),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 20.0, left: 20, right: 20),
                    child: Container(
                      height: 63,
                      child: InputDecorator(
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 3)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 3)),
                            fillColor: Colors.white,
                            filled: true,
                            labelText: "Max Content Rating"),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                              isExpanded: true,
                              value: "$selectedRating",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                              menuWidth: 412,
                              items: ratingsList,
                              onChanged: (selected) {
                                setState(() {
                                  selectedRating = selected;
                                });
                              }),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16, top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        showingText(),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: ElevatedButton(
                            onPressed: () {
                              text01.clear();
                              FocusManager.instance.primaryFocus?.unfocus();
                              setState(() {
                                itemCt = 0;
                              });
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(Colors.blue),
                                shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5)))),
                            child: Text(
                              "Reset",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: ElevatedButton(
                            onPressed: () {
                              _myFormId.currentState!.validate();
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(Colors.blue),
                                shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5)))),
                            child: Text(
                              "Find some Gifs!",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 425,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        alignment: Alignment.topCenter,
                        width: 375,
                        height: 425,
                        child: GridView.builder(
                          itemCount: itemCt,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10),
                          itemBuilder: (context, index) {
                            return GridTile(
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: Colors.blue[900],
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12))),
                                        content: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.center,
                                              child: Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 16),
                                                  child: Image(
                                                    height: 292,
                                                    width: 292,
                                                    image: CachedNetworkImageProvider(gifData[index]["images"]["original"]["url"])
                                                  )),
                                            ),
                                            Center(
                                              child: SizedBox(
                                                width: 292,
                                                child: SingleChildScrollView(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 12,
                                                            left: 10,
                                                            right: 10),
                                                    child: Text(
                                                      "Title: '${gifData[index]["title"]}' \n\nRating: ${gifData[index]["rating"].toUpperCase()} \n\nUpload Date: ${gifData[index]["import_datetime"]}",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 24
                                                        ),
                                                      textAlign: TextAlign.start,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        actions: [
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(bottom: 20.0),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  launchUrl(Uri.parse(gifData[index]["url"]), mode: LaunchMode.inAppWebView);
                                                },
                                                style: ButtonStyle(
                                                    shape: WidgetStatePropertyAll(
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5))),
                                                    backgroundColor:
                                                        const WidgetStatePropertyAll(
                                                            Colors.white)),
                                                child: Text(
                                                  "View on Giphy",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displaySmall,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              style: ButtonStyle(
                                                  shape: WidgetStatePropertyAll(
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5))),
                                                  backgroundColor:
                                                      const WidgetStatePropertyAll(
                                                          Colors.white)),
                                              child: Text(
                                                "Close",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displaySmall,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: CachedNetworkImage(
                                  imageUrl: gifData[index]["images"]["original"]
                                      ["url"],
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }

  Future doHttpMain() async {
    String link =
        "https://api.giphy.com/v1/gifs/search?api_key=$apiKey&q=${text01.text}&limit=$selectedResultAmt&rating=$selectedRating";

    var response = await http.get(Uri.parse(link));

    if (response.statusCode == 200) {
      httpData = jsonDecode(response.body);
      print(httpData);

      setState(() {
        searchUrl = "https://giphy.com/search/${text01.text}?rating=";
        if (selectedRating == "r")
          searchUrl == "r";
        else
          searchUrl += "pg-13";
        gifData = [];

        for (int i = 0; i < httpData["pagination"]["count"]; i++) {
          gifData.add(httpData["data"][i]);
          print("${httpData["data"][i]["images"]["original"]["url"]}");
        }

        itemCt = httpData["pagination"]["count"];
      });
    } else {
      print("ERROR: $response.statusCode");
    }
  }

  Container onGiphy() {
    if (itemCt > 0) {
      return Container(
          padding: EdgeInsets.only(right: 20),
          child: ElevatedButton(
              onPressed: () {
                launchUrl(Uri.parse(searchUrl), mode: LaunchMode.inAppWebView);
              },
              child: Text(
                  "Show all ${httpData["pagination"]["total_count"]} on Giphy")));
    } else
      return Container();
  }

  Text showingText() {
    if (itemCt > 0)
      return Text(
        "Showing $itemCt Results:",
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    else
      return Text("");
  }
}
