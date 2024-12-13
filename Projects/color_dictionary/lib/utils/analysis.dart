import 'package:flutter/material.dart';
import '../main.dart';
import '../classes.dart';
import 'package:flutter_color_utils/flutter_color_utils.dart'; 

/**
 * Analyzes and sorts all entries in a given color database based on given queries/options.
 *
 * @author L Mavroudakis
 * @version 1.0.0
 */
void analyzeClosestColors() {
  allClosestColors = fullColorList;

  allClosestColors.sort((a, b) => Color.fromARGB(255, currentColor.rgb["r"],
          currentColor.rgb["g"], currentColor.rgb["b"])
      .match(HexColor(a.hex))
      .compareTo(Color.fromARGB(255, currentColor.rgb["r"],
              currentColor.rgb["g"], currentColor.rgb["b"])
          .match(HexColor(b.hex))));

  allClosestColors = allClosestColors.reversed.toList();

  List<ColorResult> someClosestColors = [];

  for (int i = 0; i < int.parse(selectedClosestAmt.toString()); i++) {
    if (i == allClosestColors.length - 1) break;
    someClosestColors.add(allClosestColors[i]);
  }

  allClosestColors = someClosestColors;

  switch (selectedSortMethod) {
    case 1:
      if (orderButtonBools[0])
        allClosestColors = allClosestColors.reversed.toList();
      break;
    case 2:
      allClosestColors.sort((a, b) => a.name.compareTo(b.name));
      if (orderButtonBools[1])
        allClosestColors = allClosestColors.reversed.toList();
      break;
    case 3:
      allClosestColors.sort((a, b) => a.hsl["h"].compareTo(b.hsl["h"]));
      if (orderButtonBools[1])
        allClosestColors = allClosestColors.reversed.toList();
      break;
    case 4:
      allClosestColors.sort((a, b) => a.hsl["s"].compareTo(b.hsl["s"]));
      if (orderButtonBools[1])
        allClosestColors = allClosestColors.reversed.toList();
      break;
    case 5:
      allClosestColors.sort((a, b) => a.hsl["l"].compareTo(b.hsl["l"]));
      if (orderButtonBools[1])
        allClosestColors = allClosestColors.reversed.toList();
      break;
    case 6:
      allClosestColors.sort((a, b) => a.rgb["r"].compareTo(b.rgb["r"]));
      if (orderButtonBools[1])
        allClosestColors = allClosestColors.reversed.toList();
      break;
    case 7:
      allClosestColors.sort((a, b) => a.rgb["g"].compareTo(b.rgb["g"]));
      if (orderButtonBools[1])
        allClosestColors = allClosestColors.reversed.toList();
      break;
    case 8:
      allClosestColors.sort((a, b) => a.rgb["b"].compareTo(b.rgb["b"]));
      if (orderButtonBools[1])
        allClosestColors = allClosestColors.reversed.toList();
      break;
  }

  //print("TEST ${allClosestColors[1]}");
}

/**
 * Parses the "bestContrast" String given in API results for a color,
 * returning the actual color the String signifies (black or white),
 * or its inverse if the UI calls for such.
 *
 * @author L Mavroudakis
 * @version 1.0.0
 * @param color - String indicating the best contrast against a certain
 * color; "black" or "white"
 * @param inverse - Return the inverse color of what the actual best contrast is?
 */
Color parseBestContrast(String color, bool? inverse, bool currColor, void Function(Color, String)? parseBestContrastSetState) {
  Color theColor = Colors.red;

  if (color == "black" && inverse == true) theColor = Colors.white;
  else if (color == "black") theColor = Colors.black;
  if (color == "white" && inverse == true) theColor = Colors.black;
  else if (color == "white") theColor = Colors.white;

  if (currColor) {
    parseBestContrastSetState!(theColor, color);
  }

  return theColor;
}

/**
 * Takes a loose group of data once from a SavedPalette, and parses it to a list of ColorResults 
 *
 * @author L Mavroudakis
 * @version 1.0.0
 * @param l - Information on the palette to reform into ColorResults
 */
List<ColorResult> dataToColorResultList(var list) {
  List<ColorResult> colors = [];
  //print("HHHHHHHHHHHHHHH${list}");
  for (var a in list) {
    colors.add(ColorResult(
        a["name"],
        a["hex"],
        a["rgb"]["r"],
        a["rgb"]["g"],
        a["rgb"]["b"],
        double.parse(a["hsl"]["h"].toString()),
        double.parse(a["hsl"]["s"].toString()),
        double.parse(a["hsl"]["l"].toString()),
        a["bestContrast"]));
  }
  return colors;
}
