import 'dart:convert';
import 'package:flutter/material.dart';
import '../main.dart';
import 'builders.dart';
import 'analysis.dart';
import '../classes.dart';

/**
 * Calls the building for all color containers in the "Palette Colors" menu.
 *
 * @author L Mavroudakis
 * @version 1.0.0
 */
void updatePaletteResults(
    BuildContext context,
    void Function(Map) paletteResultSetState,
    void Function(Color, String) parseBestContrastSetState,
    void Function(
            ColorResult,
            void Function(Color, bool),
            void Function(bool),
            void Function(bool),
            void Function(dynamic),
            void Function(List<Padding>),
            void Function(int, int))
        runAddSaved, 
    void Function(Color, bool) closestResultSetState,
    void Function(bool) updateMenuState,
    void Function(bool) updateMainColor,
    void Function(dynamic) launchHTTPSetState,
    void Function(List<Padding>) updateSavedSetState,
    void Function(int, int) runAddSavedSetState) {
  closestContainer = buildPaletteResult(
      200,
      300,
      context,
      paletteResultSetState,
      mainData,
      parseBestContrastSetState,
      runAddSaved,
      closestResultSetState,
      updateMenuState,
      updateMainColor,
      launchHTTPSetState,
      updateSavedSetState,
      runAddSavedSetState);
  complimentaryContainer = buildPaletteResult(
      200,
      300,
      context,
      paletteResultSetState,
      complimentaryColor,
      parseBestContrastSetState,
      runAddSaved,
      closestResultSetState,
      updateMenuState,
      updateMainColor,
      launchHTTPSetState,
      updateSavedSetState,
      runAddSavedSetState);
  triadicContainer1 = buildPaletteResult(
      200,
      300,
      context,
      paletteResultSetState,
      triadicColor1,
      parseBestContrastSetState,
      runAddSaved,
      closestResultSetState,
      updateMenuState,
      updateMainColor,
      launchHTTPSetState,
      updateSavedSetState,
      runAddSavedSetState);
  triadicContainer2 = buildPaletteResult(
      200,
      300,
      context,
      paletteResultSetState,
      triadicColor2,
      parseBestContrastSetState,
      runAddSaved,
      closestResultSetState,
      updateMenuState,
      updateMainColor,
      launchHTTPSetState,
      updateSavedSetState,
      runAddSavedSetState);
  tetradicContainer1 = buildPaletteResult(
      200,
      300,
      context,
      paletteResultSetState,
      tetradicColor1,
      parseBestContrastSetState,
      runAddSaved,
      closestResultSetState,
      updateMenuState,
      updateMainColor,
      launchHTTPSetState,
      updateSavedSetState,
      runAddSavedSetState);
  tetradicContainer2 = buildPaletteResult(
      200,
      300,
      context,
      paletteResultSetState,
      tetradicColor2,
      parseBestContrastSetState,
      runAddSaved,
      closestResultSetState,
      updateMenuState,
      updateMainColor,
      launchHTTPSetState,
      updateSavedSetState,
      runAddSavedSetState);
  tetradicContainer3 = buildPaletteResult(
      200,
      300,
      context,
      paletteResultSetState,
      tetradicColor3,
      parseBestContrastSetState,
      runAddSaved,
      closestResultSetState,
      updateMenuState,
      updateMainColor,
      launchHTTPSetState,
      updateSavedSetState,
      runAddSavedSetState);
}

/**
 * Calls analysis for all colors in a list based on search/sort queries,
 * and builds all containers to be displayed in "Other Closest Colors" menu,
 * returned to be placed into the Scaffold structure.
 *
 * @author L Mavroudakis
 * @version 1.0.0
 */
List<Padding> updateClosestResults(
    BuildContext context,
    void Function(bool) updateMenuState,
    void Function(bool) updateMainColor,
    void Function(Color, bool) closestResultSetState,
    void Function(dynamic) launchHTTPSetState,
    void Function(List<Padding>) updateSavedSetState,
    void Function(int, int) runAddSavedSetState) {
  List<Padding> list = [];

  analyzeClosestColors();

  String t = selectedClosestAmt.toString();

  if (selectedClosestAmt != null && selectedSortMethod != null) {
    for (int i = 0; i < int.parse(t); i++) {
      if (i > allClosestColors.length - 1) break;
      list.add(buildClosestResult(
          allClosestColors[i],
          context,
          updateMenuState,
          updateMainColor,
          closestResultSetState,
          launchHTTPSetState,
          updateSavedSetState,
          runAddSavedSetState));
    }
  }

  closestLoading = false;
  updateMenuState(resultsReady);
  return list;
}

/**
 * Compiles all containers to display history SearchColors in the burger menu, returning to apply it to the app elsewhere
 *
 * @author L Mavroudakis
 * @version 1.0.0
 * @param addCurrent - Do we add the currently-searched color to the history as this runs?
 * @param deletingEntry - Is this updating because a history color was deleted?
 * @param delIndex - ^ If so, where is it being deleted?
 */
List<Padding> updateHistoryColors(
    bool addCurrent,
    void Function(Color, String) parseBestContrastSetState,
    BuildContext context,
    void Function(bool) updateMenuState,
    void Function(bool) updateMainColor,
    void Function(dynamic) launchHTTPSetState,
    void Function(Color, bool) closestResultSetState,
    void Function(int) buildHistoryColorsSetState,
    bool deletingEntry,
    int delIndex,
    void Function(bool) toggleRGBorHSL) {
  int c = 0;
  bool showEmpty = false;

  c = historyColors.length;

  if (c <= 1 && deletingEntry) showEmpty = true;
  if (!deletingEntry && c == 0) showEmpty = false;
  if (initRunning && c <= 1) showEmpty = false;

  if (deletingEntry) {
    int index = 0;
    addCurrent = false;

    try {
      historyColors.removeAt(delIndex);
    } catch (e) {
      print("Error; tried to remove at invalid historyColor index");
      return historyContainers;
    }

    historyColorsRaw = "{ \"colors\":\[";
    for (var a in historyColors) {
      String colorText = "";
      colorText =
          "{\"hex\": \"${a.hex}\", \"rgb\": {\"r\": ${a.rgb["r"]}, \"g\": ${a.rgb["g"]}, \"b\": ${a.rgb["b"]}}, \"hsl\": {\"h\": ${a.hsl["h"]}, \"s\": ${a.hsl["s"]}, \"l\": ${a.hsl["l"]}}, \"bestContrast\": \"${a.bestContrast}\"}";

      if (index != 0) colorText = ", " + colorText;
      index++;
      historyColorsRaw += colorText;
    }
    historyColorsRaw += "]}";
    myPrefs.setString("history", historyColorsRaw);
    historyColors = [];
  }

  //print("AAA$c");

  // Preventing from running twice in init
  if (initRunning && historyColors.length > 0) return historyContainers;

  //print("c${myPrefs.getString("lastColor")}");
  if (historyColors.length > 0 &&
      !deletingEntry &&
      currentColor.hex.substring(2).toLowerCase() ==
          myPrefs.getString("lastColor")?.substring(2).toLowerCase()) {
    //print("CATCH");
    addCurrent = false;
  }

  List<Padding> list = [
    Padding(
      padding: EdgeInsets.all(20),
      child: Visibility(
        visible: showEmpty,
        child: Container(
          width: MediaQuery.sizeOf(context).width,
          child: Text(
            "Your history is empty!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, fontFamily: "TransformaSans"),
          ),
        ),
      ),
    )
  ];
  historyColorsRaw = "{ \"colors\":\[";
  historyColors = [];
  int index = 0;
  var colors;
  if (myPrefs.getString("history") != null) {
    colors = jsonDecode(myPrefs.getString("history").toString());
    //print(colors);

    for (var a in colors["colors"]) {
      String colorText = "";
      SearchColor t = SearchColor("", 0, 0, 0, 0, 0, 0, "");
      t.setFromData(a);
      historyColors.add(t);
      list.add(buildHistoryResult(
          a,
          false,
          parseBestContrastSetState,
          context,
          updateMenuState,
          updateMainColor,
          launchHTTPSetState,
          closestResultSetState,
          buildHistoryColorsSetState,
          index));
      //print(index);

      colorText =
          "{\"hex\": \"${a["hex"]}\", \"rgb\": {\"r\": ${a["rgb"]["r"]}, \"g\": ${a["rgb"]["g"]}, \"b\": ${a["rgb"]["b"]}}, \"hsl\": {\"h\": ${a["hsl"]["h"]}, \"s\": ${a["hsl"]["s"]}, \"l\": ${a["hsl"]["l"]}}, \"bestContrast\": \"${a["bestContrast"]}\"}";

      if (index != 0) colorText = ", " + colorText;
      index++;
      historyColorsRaw += colorText;
    }
  }
  if (addCurrent) {
    String colorText = "";

    colorText =
        "{\"hex\": \"${currentColor.hex.substring(2).toLowerCase()}\", \"rgb\": {\"r\": ${currentColor.rgb["r"]}, \"g\": ${currentColor.rgb["g"]}, \"b\": ${currentColor.rgb["b"]}}, \"hsl\": {\"h\": ${currentColor.hsl["h"]}, \"s\": ${currentColor.hsl["s"]}, \"l\": ${currentColor.hsl["l"]}}, \"bestContrast\": \"${searchContrastText}\"}";

    list.add(buildHistoryResult(
        jsonDecode(colorText),
        true,
        parseBestContrastSetState,
        context,
        updateMenuState,
        updateMainColor,
        launchHTTPSetState,
        closestResultSetState,
        buildHistoryColorsSetState,
        index));
    if (index != 0) colorText = ", " + colorText;
    historyColors.add(currentColor);
    historyColorsRaw += colorText;
  }

  historyColorsRaw += "]}";

  //print("FFFFFFFFF${historyColors.length}");
  //print("AAAAAAAAAAA${historyColorsRaw}");
  //**********
  //print(jsonEncode(historyColors));
  myPrefs.setString("history", historyColorsRaw);

  return list;
}

/**
 * Compiles all build components of the Saved Palettes menu to display them accordingly
 *
 * @author L Mavroudakis
 * @version 1.0.0
 */
void updateSavedPalettes(
    BuildContext context,
    void Function(Color, bool) closestResultSetState,
    void Function(bool) updateMenuState,
    void Function(bool) updateMainColor,
    void Function(dynamic) launchHTTPSetState,
    void Function(List<Padding>) updateSavedSetState) {

  List<Padding> palettes = [];

  for (int i = 0; i < savedPalettes.length; i++) {
    palettes.add(buildSavedPalette(
        savedPalettes[i],
        context,
        closestResultSetState,
        updateMenuState,
        updateMainColor,
        launchHTTPSetState,
        updateSavedSetState,
        i));
  }
  updateSavedSetState(palettes);
}
