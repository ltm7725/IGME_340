import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart';
import 'analysis.dart';
import '../classes.dart';

/**
 * Initial search HTTP request, searching based on several queries placed into the link, 
 * getting info for the main closest color to the search query in the given list,
 * launching other requests and other update functions, and setting many reference variables
 * 
 * @author L Mavroudakis
 * @version 1.0.0
 */
void launchHTTP(void Function(dynamic) launchHTTPSetState) async {
  updateRunning = true;
  String link =
      "https://api.color.pizza/v1/?values=${currentColor.hex.substring(2).toLowerCase()}&list=$selectedListKey";
  print(link);
  var response = await http.get(Uri.parse(link));

  if (response.statusCode == 200) {
    launchHTTPSetState(response);
  } else {
    if (response.statusCode != 200) print("ERROR1: ${response.statusCode}");
  }
}

/**
 * Secondary HTTP request, getting info for colors which match the closest color to
 * the search query in complimentary/triadic/tetradic color pallettes, updating reference
 * variables, calling updates for display components, and launching one last HTTP request.
 *
 * @author L Mavroudakis
 * @version 1.0.0
 */
void secondaryHTTP(
    String complColorHex,
    String triadColorHex1,
    String triadColorHex2,
    String tetradColorHex1,
    String tetradColorHex2,
    String tetradColorHex3,
    void Function(List<Map>?) secondaryHTTPSetState,
    void Function(dynamic) tertiaryHTTPSetState, 
    void Function(bool) updateMenuState,
    void Function(bool) updateMainColor,
    void Function(bool) toggleRGBorHSL) async {
  String link =
      "https://api.color.pizza/v1/?values=${complColorHex.toLowerCase()},${triadColorHex1.toLowerCase()},${triadColorHex2.toLowerCase()},${tetradColorHex1.toLowerCase()},${tetradColorHex2.toLowerCase()},${tetradColorHex3.toLowerCase()}&list=$selectedListKey";

  var response = await http.get(Uri.parse(link));

  if (response.statusCode == 200) {
    Map data = jsonDecode(response.body);
    Map complimentaryColor = data["colors"][0];
    Map triadicColor1 = data["colors"][1];
    Map triadicColor2 = data["colors"][2];
    Map tetradicColor1 = data["colors"][3];
    Map tetradicColor2 = data["colors"][4];
    Map tetradicColor3 = data["colors"][5];
    secondaryHTTPSetState([
      complimentaryColor,
      triadicColor1,
      triadicColor2,
      tetradicColor1,
      tetradicColor2,
      tetradicColor3
    ]);

    updateMenuState(true);
    tertiaryHTTP(
        updateMenuState, tertiaryHTTPSetState, updateMainColor, toggleRGBorHSL);
  } else {
    print("ERROR2: ${response.statusCode}");
  }
}

/**
 * Collects information for all colors within a given color database, calling
 * updates to display components as well as analysis for the data collected.
 *
 * @author L Mavroudakis
 * @version 1.0.0
 */
void tertiaryHTTP(
    void Function(bool) updateMenuState,
    void Function(dynamic) tertiaryHTTPSetState,
    void Function(bool) updateMainColor,
    void Function(bool) toggleRGBorHSL) async {

      updateRunning = false;

  String link = "https://color-names.herokuapp.com/v1/?list=$selectedListKey";

  var response = await http.get(Uri.parse(link));

  if (response.statusCode == 200) {
    fullColorList = dataToColorResultList(jsonDecode(response.body)["colors"]);
    tertiaryHTTPSetState(fullColorList);
    updateMenuState(true);
  } else {
    print("ERROR3: ${response.statusCode}");
  }
}

/**
 * Preliminary contrast analyzer for top-searched color, setting the text above a color
 * to the best ascertained contrast (black or white) based on lightness.
 *
 * @author L Mavroudakis
 * @version 1.0.0
 */
Future updateSearchContrast(
    SearchColor currentColor,
    void Function(dynamic) updateSearchContrastSetState,
    void Function(bool) updateMainColor,
    void Function(bool) updateMenuState,
    void Function(bool) toggleRGBorHSL) async {
  if (currentColor.hsl["l"] * 100 <= 50)
    searchContrast = Colors.white;
  else
    searchContrast = Colors.black;

  //print("a${myPrefs.getString("lastColor")}");

  String link =
      "https://api.color.pizza/v1/?values=${currentColor.hex.substring(2).toLowerCase()}&list=default";

  dynamic response = await http.get(Uri.parse(link));

  if (response.statusCode == 200) {
    //print("b${myPrefs.getString("lastColor")}");
    updateSearchContrastSetState(response);
  } else {
    print("ERROR4: $response.statusCode");
  }

  return 1;
}
