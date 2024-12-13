import 'package:flutter/material.dart';
import 'package:color_dictionary/classes.dart';
import 'package:color_dictionary/utils/update.dart';
import '../main.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_color_utils/flutter_color_utils.dart';
import 'package:flutter/services.dart';
import 'http.dart';
import 'analysis.dart';
import 'saved_palettes.dart';

/**
 * Builds a Container to be placed in the "Palette Colors" menu,
 * with all the color attributes of the given data and with
 * a specific size to the Container.
 *
 * @author L Mavroudakis
 * @version 1.1.0
 * @param theHeight - Intended Container height
 * @param theWidth - Intended Container width
 * @param data - parsed JSON data for color to create Container based on
 */
Container buildPaletteResult(
    double theHeight,
    double theWidth,
    BuildContext context,
    void Function(Map) paletteResultSetState,
    Map data,
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
  Color contrast;
  contrast = parseBestContrast(
      data["bestContrast"], false, false, parseBestContrastSetState);

  ColorResult cr = ColorResult("", "", 0, 0, 0, 0, 0, 0, "black");
  cr.setFromData(data, 2);

  return Container(
    child: Stack(children: [
      Align(
        alignment: Alignment.center,
        child: Container(
          height: theHeight + 15,
          width: theWidth + 15,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              gradient: LinearGradient(
                  colors: [Colors.black, Colors.white],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight)),
        ),
      ),
      Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.only(top: 7.5),
          child: Container(
            width: theWidth,
            height: theHeight,
            decoration: BoxDecoration(
                color: Color.fromARGB(
                    255, data["rgb"]["r"], data["rgb"]["g"], data["rgb"]["b"]),
                borderRadius: BorderRadius.circular(50)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "${data["name"]} \n${data["hex"]} \n${buildColorAttributes(data, useRGB)}",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: contrast),
                  textAlign: TextAlign.center,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        runAddSaved(
                            cr,
                            closestResultSetState,
                            updateMenuState,
                            updateMainColor,
                            launchHTTPSetState,
                            updateSavedSetState,
                            runAddSavedSetState);
                      },
                      child: Icon(
                        Icons.favorite_border,
                        size: 50,
                        color: contrast,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        paletteResultSetState(data);
                      },
                      child: Icon(
                        Icons.search,
                        size: 50,
                        color: contrast,
                      ),
                    ),

                    ///GestureDetector(
                    ///  onTap: () {},
                    ///  child: Icon(Icons.star_border, size: 50, color: contrast),
                    ///)
                  ],
                ),
              ],
            ),
          ),
        ),
      )
    ]),
  );
}

/**
 * Builds a Container to be placed in the "Other Closest Colors" menu,
 * with all the color attributes of the given data.
 *
 * @author L Mavroudakis
 * @version 1.1.0
 * @param data - parsed JSON data for color to create Container based on
 */
Padding buildClosestResult(
    ColorResult data,
    BuildContext context,
    void Function(bool) updateMenuState,
    void Function(bool) updateMainColor,
    void Function(Color, bool) closestResultSetState,
    void Function(dynamic) launchHTTPSetState,
    void Function(List<Padding>) updateSavedSetState,
    void Function(int, int) runAddSavedSetState) {
  Color contrast;
  Color inverseContrast;

  contrast = parseBestContrast(data.bestContrast, false, false, null);
  inverseContrast = parseBestContrast(data.bestContrast, true, false, null);

  Color contrastTransparent;
  Color inverseContrastTransparent;
  Color theColor = HexColor(data.hex);

  int backgroundOpacity = 192;

  if (contrast == Colors.black) {
    contrastTransparent = Color.fromARGB(backgroundOpacity, 0, 0, 0);
    inverseContrastTransparent =
        Color.fromARGB(backgroundOpacity, 255, 255, 255);
  } else {
    inverseContrastTransparent = Color.fromARGB(backgroundOpacity, 0, 0, 0);
    contrastTransparent = Color.fromARGB(backgroundOpacity, 255, 255, 255);
  }

  return Padding(
    padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
    child: Container(
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
          color: theColor,
          border: Border(
              left: BorderSide(color: Colors.black, width: 5),
              bottom: BorderSide(color: Colors.black, width: 5),
              right: BorderSide(color: Colors.white, width: 5),
              top: BorderSide(color: Colors.white, width: 5))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Container(
              width: MediaQuery.sizeOf(context).width - 230,
              child: Text(
                "\"${data.name}\"",
                softWrap: true,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: contrast, fontWeight: FontWeight.w700, fontSize: 24),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 20.0, top: 10, bottom: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    runAddSaved(
                        data,
                        closestResultSetState,
                        updateMenuState,
                        updateMainColor,
                        launchHTTPSetState,
                        updateSavedSetState,
                        runAddSavedSetState);
                  },
                  child: Icon(
                    Icons.favorite_border,
                    size: 50,
                    color: contrast,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: contrastTransparent,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: theColor, width: 10),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          title: Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    Icons.close,
                                    color: inverseContrast,
                                    size: 60,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    firstMenuSelected = false;
                                    updateMenuState(false);
                                    currentColor = SearchColor(
                                        "#${data.hex}",
                                        data.rgb["r"],
                                        data.rgb["g"],
                                        data.rgb["b"],
                                        data.hsl["h"],
                                        data.hsl["s"],
                                        data.hsl["l"],
                                        data.bestContrast);
                                    updateMainColor(true);
                                    launchHTTP(launchHTTPSetState);
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    Icons.search,
                                    color: inverseContrast,
                                    size: 60,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Text(
                                "\"${data.name}\"",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(
                                        color: inverseContrast,
                                        fontWeight: FontWeight.bold),
                              ),
                            ),
                          ]),
                          content: OverflowBox(
                            maxHeight: double.infinity,
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 6),
                                        child: Container(
                                          height: 222,
                                          width: 222,
                                          decoration: BoxDecoration(
                                              color: inverseContrast,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20))),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                          padding: EdgeInsets.only(top: 16),
                                          child: Container(
                                            height: 202,
                                            width: 202,
                                            decoration: BoxDecoration(
                                                color: theColor,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 80,
                                                    height: 80,
                                                    decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        20),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        20))),
                                                  ),
                                                  Container(
                                                    width: 80,
                                                    height: 80,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topRight: Radius
                                                                    .circular(
                                                                        20),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        20))),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 292,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: 24, left: 10, right: 10),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12.0),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8.0),
                                                  child: Text(
                                                    "${data.hex}",
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displayMedium
                                                        ?.copyWith(
                                                            color:
                                                                inverseContrast,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            WidgetStatePropertyAll(
                                                                inverseContrastTransparent)),
                                                    onPressed: () {
                                                      Clipboard.setData(
                                                          ClipboardData(
                                                              text:
                                                                  "${data.hex}"));
                                                    },
                                                    child: Text("Copy",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .displayMedium
                                                            ?.copyWith(
                                                                color:
                                                                    contrast)))
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12.0),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8.0),
                                                  child: Text(
                                                    "RGB( ${data.rgb["r"]}, ${data.rgb["g"]}, ${data.rgb["b"]} )",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displayMedium
                                                        ?.copyWith(
                                                            color:
                                                                inverseContrast,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 24),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            WidgetStatePropertyAll(
                                                                inverseContrastTransparent)),
                                                    onPressed: () {
                                                      Clipboard.setData(
                                                          ClipboardData(
                                                              text:
                                                                  "RGB( ${data.rgb["r"]}, ${data.rgb["g"]}, ${data.rgb["b"]} )"));
                                                    },
                                                    child: Text("Copy",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .displayMedium
                                                            ?.copyWith(
                                                                color:
                                                                    contrast)))
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12.0),
                                            child: Column(
                                              children: [
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 8.0),
                                                    child: Text(
                                                      "HSL( ${data.hsl["h"]}, ${data.hsl["s"]}, ${data.hsl["l"]} )",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .displayMedium
                                                          ?.copyWith(
                                                              color:
                                                                  inverseContrast,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            WidgetStatePropertyAll(
                                                                inverseContrastTransparent)),
                                                    onPressed: () {
                                                      Clipboard.setData(
                                                          ClipboardData(
                                                              text:
                                                                  "HSL( ${data.hsl["h"]}, ${data.hsl["s"]}, ${data.hsl["l"]} )"));
                                                    },
                                                    child: Text("Copy",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .displayMedium
                                                            ?.copyWith(
                                                                color:
                                                                    contrast)))
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          actions: [],
                        );
                      },
                    );
                  },
                  child: Icon(
                    Icons.fullscreen,
                    size: 60,
                    color: contrast,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    closestResultSetState(theColor, false);
                  },
                  child: Icon(
                    Icons.search,
                    size: 60,
                    color: contrast,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ),
  );
}

/**
 * Builds the text to be placed into areas where Containers only show 
 * one or the other color attribute group (RGB/HSL), to assign such
 * to the widget being updated when RGB/HSL is swapped between with the
 * button in the AppBar.
 *
 * @author L Mavroudakis
 * @version 1.0.0
 * @param data - parsed JSON data for color to create attribute String based on
 */
String buildColorAttributes(Map data, bool useRGB) {
  if (useRGB)
    return "RGB(${data["rgb"]["r"]},${data["rgb"]["g"]},${data["rgb"]["b"]})";
  else
    return "HSL(${data["hsl"]["h"].toStringAsFixed(0)}°,${data["hsl"]["s"].toStringAsFixed(0)}%,${data["hsl"]["l"].toStringAsFixed(0)}%)";
}

/**
 * Builds a single history color to be displayed in the history menu
 *
 * @author L Mavroudakis
 * @version 1.0.0
 * @param c - Information on the color to be built around
 * @param currColor - is this the currently-searched color?
 * @param delIndex - If a history color is being deleted, where from?
 */
Padding buildHistoryResult(
    var c,
    bool currColor,
    void Function(Color, String) parseBestContrastSetState,
    BuildContext context,
    void Function(bool) updateMenuState,
    void Function(bool) updateMainColor,
    void Function(dynamic) launchHTTPSetState,
    void Function(Color, bool) closestResultSetState,
    void Function(int) buildHistoryColorsSetState,
    int delIndex) {
  Color theColor = HexColor(c["hex"]);
  Color contrast = parseBestContrast(c["bestContrast"], false, false, null);
  Color inverseContrast =
      parseBestContrast(c["bestContrast"], true, false, null);
  Color contrastTransparent;
  Color inverseContrastTransparent;
  String hexText;

  if (c["hex"].length > 6) {
    //print("CATCH LONG");
    hexText = "#${c["hex"].substring(c["hex"].length - 6)}";
  } else
    hexText = "#${c["hex"]}";

  if (contrast == Colors.black) {
    contrastTransparent = Color.fromARGB(128, 0, 0, 0);
    inverseContrastTransparent = Color.fromARGB(128, 255, 255, 255);
  } else {
    contrastTransparent = Color.fromARGB(128, 255, 255, 255);
    inverseContrastTransparent = Color.fromARGB(128, 0, 0, 0);
  }

  if (currColor)
    parseBestContrast(
        c["bestContrast"], false, currColor, parseBestContrastSetState);
  //print("OKOKOK${c}");
  Padding p = Padding(
    padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
    child: Container(
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
          color: theColor,
          border: Border(
              left: BorderSide(color: Colors.black, width: 5),
              bottom: BorderSide(color: Colors.black, width: 5),
              right: BorderSide(color: Colors.white, width: 5),
              top: BorderSide(color: Colors.white, width: 5))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Container(
              width: 150,
              child: Text(
                hexText.toLowerCase(),
                softWrap: true,
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(color: contrast, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 20.0, top: 10, bottom: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: contrastTransparent,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: theColor, width: 10),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          title: Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    Icons.close,
                                    color: inverseContrast,
                                    size: 60,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    updateMenuState(false);
                                    currentColor = SearchColor(
                                        "ff${c["hex"]}",
                                        c["rgb"]["r"],
                                        c["rgb"]["g"],
                                        c["rgb"]["b"],
                                        double.parse(c["hsl"]["h"].toString()),
                                        double.parse(c["hsl"]["s"].toString()),
                                        double.parse(c["hsl"]["l"].toString()),
                                        c["bestContrast"]);
                                    updateMainColor(true);
                                    launchHTTP(launchHTTPSetState);
                                    Navigator.pop(context);
                                    isBurgerMenuOpen = false;
                                    innerScaffoldKey.currentState!
                                        .closeEndDrawer();
                                  },
                                  child: Icon(
                                    Icons.search,
                                    color: inverseContrast,
                                    size: 60,
                                  ),
                                ),
                              ],
                            ),
                          ]),
                          content: OverflowBox(
                            maxHeight: double.infinity,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 6),
                                          child: Container(
                                            height: 222,
                                            width: 222,
                                            decoration: BoxDecoration(
                                                color: inverseContrast,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                            padding: EdgeInsets.only(top: 16),
                                            child: Container(
                                              height: 202,
                                              width: 202,
                                              decoration: BoxDecoration(
                                                  color: theColor,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20))),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 80,
                                                      height: 80,
                                                      decoration: BoxDecoration(
                                                          color: Colors.black,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          20),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          20))),
                                                    ),
                                                    Container(
                                                      width: 80,
                                                      height: 80,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          20),
                                                                  bottomRight:
                                                                      Radius.circular(
                                                                          20))),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 292,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: 24, left: 10, right: 10),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12.0),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8.0),
                                                  child: Text(
                                                    hexText.toLowerCase(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: inverseContrast,
                                                        fontSize: 28),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            WidgetStatePropertyAll(
                                                                inverseContrastTransparent)),
                                                    onPressed: () {
                                                      Clipboard.setData(
                                                          ClipboardData(
                                                              text: hexText
                                                                  .toLowerCase()));
                                                    },
                                                    child: Text("Copy",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .displayMedium
                                                            ?.copyWith(
                                                                color:
                                                                    contrast)))
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12.0),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8.0),
                                                  child: Text(
                                                    "RGB( ${c["rgb"]["r"]}, ${c["rgb"]["g"]}, ${c["rgb"]["b"]} )",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: inverseContrast,
                                                        fontSize: 26),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            WidgetStatePropertyAll(
                                                                inverseContrastTransparent)),
                                                    onPressed: () {
                                                      Clipboard.setData(
                                                          ClipboardData(
                                                              text:
                                                                  "RGB( ${c["rgb"]["r"]}, ${c["rgb"]["g"]}, ${c["rgb"]["b"]} )"));
                                                    },
                                                    child: Text("Copy",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .displayMedium
                                                            ?.copyWith(
                                                                color:
                                                                    contrast)))
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12.0),
                                            child: Column(
                                              children: [
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 8.0),
                                                    child: Text(
                                                      "HSL( ${c["hsl"]["h"].toStringAsFixed(5)}, ${c["hsl"]["s"].toStringAsFixed(5)}, ${c["hsl"]["l"].toStringAsFixed(5)} )",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color:
                                                              inverseContrast,
                                                          fontSize: 28),
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            WidgetStatePropertyAll(
                                                                inverseContrastTransparent)),
                                                    onPressed: () {
                                                      Clipboard.setData(
                                                          ClipboardData(
                                                              text:
                                                                  "HSL( ${c["hsl"]["h"].toStringAsFixed(5)}, ${c["hsl"]["s"].toStringAsFixed(5)}, ${c["hsl"]["l"].toStringAsFixed(5)} )"));
                                                    },
                                                    child: Text("Copy",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .displayMedium
                                                            ?.copyWith(
                                                                color:
                                                                    contrast)))
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          actions: [],
                        );
                      },
                    );
                  },
                  child: Icon(
                    Icons.fullscreen,
                    size: 60,
                    color: contrast,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: GestureDetector(
                    onTap: () {
                      closestResultSetState(theColor, true);
                      isBurgerMenuOpen = false;
                      innerScaffoldKey.currentState!.closeEndDrawer();
                    },
                    child: Icon(
                      Icons.search,
                      size: 60,
                      color: contrast,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    buildHistoryColorsSetState(delIndex);
                  },
                  child: Icon(
                    Icons.close,
                    size: 60,
                    color: contrast,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    ),
  );
  return p;
}

/**
 * Builds the larger SavedPalette visual structure for each palette in the burger menu
 *
 * @author L Mavroudakis
 * @version 1.0.0
 * @param s - Info on the palette to add to the list
 * @param indexInList - where the given palette is within savedPalettes[]
 */
Padding buildSavedPalette(
    SavedPalette s,
    BuildContext context,
    void Function(Color, bool) closestResultSetState,
    void Function(bool) updateMenuState,
    void Function(bool) updateMainColor,
    void Function(dynamic) launchHTTPSetState,
    void Function(List<Padding>) updateSavedSetState,
    int indexInList) {
  BuildContext theContext = innerScaffoldKey.currentState!.context;

  return Padding(
    padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
    child: Column(
      children: [
        Container(
          width: MediaQuery.sizeOf(theContext).width - 25,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)
              // border: Border(
              //     left: BorderSide(color: Colors.black, width: 5),
              //     bottom: BorderSide(color: Colors.black, width: 5),
              //     right: BorderSide(color: Colors.white, width: 5),
              //     top: BorderSide(color: Colors.white, width: 5))
              ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Row(children: [
                  Container(
                    width: MediaQuery.sizeOf(theContext).width - 180,
                    child: Text(
                      s.name,
                      softWrap: true,
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          fontFamily: "TransformaSans"),
                    ),
                  ),
                  GestureDetector(
                      onTap: () {
                        if (savedPalettes[indexInList].opened)
                          savedPalettes[indexInList].opened = false;
                        else
                          savedPalettes[indexInList].opened = true;
                        updateSavedPalettes(
                            context,
                            closestResultSetState,
                            updateMenuState,
                            updateMainColor,
                            launchHTTPSetState,
                            updateSavedSetState);
                        //print(savedPalettes[indexInList].opened);
                      },
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: theContext,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Rename \"${s.name}\":"),
                                      content: Form(
                                        key: formKey2,
                                        child: TextFormField(
                                          controller:
                                              renamePaletteTextController,
                                          validator: (value) {
                                            if (value?.replaceAll(" ", "") ==
                                                "") return "Enter a name!";
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                              hintText:
                                                  "Enter A Palette Name!"),
                                        ),
                                      ),
                                      actions: [
                                        ElevatedButton( 
                                            child: const Text("Cancel"),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              renamePaletteTextController
                                                  .clear();
                                            }),
                                        ElevatedButton(
                                            child: const Text('OK'),
                                            onPressed: () {
                                              if (formKey2.currentState!
                                                  .validate()) {
                                                Navigator.pop(context);
                                                savedPalettes[indexInList]
                                                        .name =
                                                    renamePaletteTextController
                                                        .text;
                                                renamePaletteTextController
                                                    .clear();
                                                savedPaletteOptions[indexInList] =
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: Text(
                                                          savedPalettes[
                                                                  indexInList]
                                                              .name,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ));
                                                updateSavedPalettes(
                                                  theContext,
                                                  closestResultSetState,
                                                  updateMenuState,
                                                  updateMainColor,
                                                  launchHTTPSetState,
                                                  updateSavedSetState,
                                                );
                                              } else
                                                renamePaletteTextController
                                                    .clear();
                                            }),
                                      ],
                                    );
                                  });
                            },
                            child:
                                Icon(Icons.edit, size: 40, color: Colors.black),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: theContext,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                            "Are you sure you want to delete this palette, \"${s.name}\"?"),
                                        // Text("Add color to Palette..."),
                                        // content: TextField(
                                        //   controller: addNewPaletteTextController,
                                        //   decoration: InputDecoration(hintText: "mehmehmeh"),
                                        // ),
                                        actions: [
                                          ElevatedButton(
                                              child: const Text("No"),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              }),
                                          ElevatedButton(
                                              child: const Text('Yes'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                savedPalettes
                                                    .removeAt(indexInList);
                                                savedPaletteOptions
                                                    .removeAt(indexInList);
                                                selectedPaletteToSaveTo = 0;
                                                paletteToSaveTo
                                                    .removeAt(indexInList);
                                                updateSavedPalettes(
                                                    context,
                                                    closestResultSetState,
                                                    updateMenuState,
                                                    updateMainColor,
                                                    launchHTTPSetState,
                                                    updateSavedSetState);
                                              }),
                                        ],
                                      );
                                    });
                              },
                              child: Icon(
                                Icons.close,
                                color: Colors.black,
                                size: 40,
                              ),
                            ),
                          ),
                          Stack(
                            children: [
                              Visibility(
                                visible: savedPalettes[indexInList].opened,
                                child: Icon(
                                  Icons.expand_more,
                                  color: Colors.black,
                                  size: 40,
                                ),
                              ),
                              Visibility(
                                visible: !savedPalettes[indexInList].opened,
                                child: Icon(
                                  Icons.keyboard_arrow_up,
                                  color: Colors.black,
                                  size: 40,
                                ),
                              )
                            ],
                          ),
                        ],
                      )),
                ]),
              ),
            ],
          ),
        ),
        Visibility(
          visible: !savedPalettes[indexInList].opened &&
              savedPalettes[indexInList].colors.length > 0,
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(theContext).width - 50),
            decoration: BoxDecoration(
                color: Color.fromARGB(128, 255, 255, 255),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Wrap(
                children: buildColorPreviews(s),
              ),
            ),
          ),
        ),
        Visibility(
          visible: savedPalettes[indexInList].colors.length == 0 &&
              savedPalettes[indexInList].opened,
          child: Container(
              color: Color.fromARGB(128, 255, 255, 255),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "(This palette is empty.)",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      fontFamily: "TransformaSans"),
                ),
              )),
        ),
        Visibility(
          visible: savedPalettes[indexInList].opened,
          child: Column(
            children: buildSavedPaletteColors(
                s,
                context,
                closestResultSetState,
                updateMenuState,
                updateMainColor,
                launchHTTPSetState,
                updateSavedSetState,
                indexInList),
          ),
        )
      ],
    ),
  );
}

/**
 * Builds a single saved color to be displayed near a SavedPalette container in the Saved Palettes aspect of the burger menu 
 *
 * @author L Mavroudakis
 * @version 1.0.0
 * @param s - Information on the color to be built around
 * @param indexInList - where the given palette is within savedPalettes[]
 */
List<Container> buildSavedPaletteColors(
    SavedPalette s,
    BuildContext context,
    void Function(Color, bool) closestResultSetState,
    void Function(bool) updateMenuState,
    void Function(bool) updateMainColor,
    void Function(dynamic) launchHTTPSetState,
    void Function(List<Padding>) updateSavedSetState,
    int indexInList) {
  List<Container> colors = [];

  BuildContext theContext = innerScaffoldKey.currentState!.context;

  for (int i = 0; i < s.colors.length; i++) {
    Color contrast =
        parseBestContrast(s.colors[i].bestContrast, false, false, null);
    Color inverseContrast =
        parseBestContrast(s.colors[i].bestContrast, true, false, null);
    Color contrastTransparent;
    Color inverseContrastTransparent;
    Color? color;
    Color theColor = Colors.black;

    //print("Test1${s.colors[i].hex}");

    color = colorFromHex(s.colors[i].hex);
    if (color != null) theColor = color;

    if (contrast == Colors.black) {
      contrastTransparent = Color.fromARGB(192, 0, 0, 0);
      inverseContrastTransparent = Color.fromARGB(192, 255, 255, 255);
    } else {
      inverseContrastTransparent = Color.fromARGB(192, 0, 0, 0);
      contrastTransparent = Color.fromARGB(192, 255, 255, 255);
    }

    colors.add(Container(
      width: MediaQuery.sizeOf(theContext).width - 100,
      decoration: BoxDecoration(
          color: theColor,
          border: Border(
              left: BorderSide(color: Colors.black, width: 5),
              bottom: BorderSide(color: Colors.black, width: 5),
              right: BorderSide(color: Colors.white, width: 5),
              top: BorderSide(color: Colors.white, width: 5))),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 15, left: 15, right: 15),
            child: Container(
              width: MediaQuery.sizeOf(theContext).width - 100,
              child: Text(
                "\"${s.colors[i].name}\"",
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(
                    fontSize: 27,
                    color: contrast,
                    fontWeight: FontWeight.bold,
                    fontFamily: "TransformaSans"),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 50.0, left: 50, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      barrierDismissible: false,
                      context: theContext,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: contrastTransparent,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: theColor, width: 10),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          title: Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    Icons.close,
                                    color: inverseContrast,
                                    size: 50,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    firstMenuSelected = false;
                                    updateMenuState(false);
                                    currentColor = SearchColor(
                                        "#${s.colors[i].hex}",
                                        s.colors[i].rgb["r"],
                                        s.colors[i].rgb["g"],
                                        s.colors[i].rgb["b"],
                                        double.parse(
                                            s.colors[i].hsl["h"].toString()),
                                        double.parse(
                                            s.colors[i].hsl["s"].toString()),
                                        double.parse(
                                            s.colors[i].hsl["l"].toString()),
                                        s.colors[i].bestContrast);
                                    updateMainColor(true);
                                    launchHTTP(launchHTTPSetState);
                                    Navigator.pop(theContext);
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    Icons.search,
                                    color: inverseContrast,
                                    size: 50,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Text(
                                "\"${s.colors[i].name}\"",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 27,
                                    color: inverseContrast,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "TransformaSans"),
                              ),
                            ),
                          ]),
                          content: OverflowBox(
                            maxHeight: double.infinity,
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 6),
                                        child: Container(
                                          height: 222,
                                          width: 222,
                                          decoration: BoxDecoration(
                                              color: inverseContrast,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20))),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                          padding: EdgeInsets.only(top: 16),
                                          child: Container(
                                            height: 202,
                                            width: 202,
                                            decoration: BoxDecoration(
                                                color: theColor,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 80,
                                                    height: 80,
                                                    decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        20),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        20))),
                                                  ),
                                                  Container(
                                                    width: 80,
                                                    height: 80,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topRight: Radius
                                                                    .circular(
                                                                        20),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        20))),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 292,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: 24, left: 10, right: 10),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12.0),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8.0),
                                                  child: Text(
                                                    "${s.colors[i].hex}",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 27,
                                                        color: inverseContrast,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            "TransformaSans"),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            WidgetStatePropertyAll(
                                                                inverseContrastTransparent)),
                                                    onPressed: () {
                                                      Clipboard.setData(
                                                          ClipboardData(
                                                              text:
                                                                  "${s.colors[i].hex}"));
                                                    },
                                                    child: Text("Copy",
                                                        style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 27)
                                                            .copyWith(
                                                                color:
                                                                    contrast)))
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12.0),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8.0),
                                                  child: Text(
                                                    "RGB( ${s.colors[i].rgb["r"]}, ${s.colors[i].rgb["g"]}, ${s.colors[i].rgb["b"]} )",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 24,
                                                        color: inverseContrast,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            "TransformaSans"),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            WidgetStatePropertyAll(
                                                                inverseContrastTransparent)),
                                                    onPressed: () {
                                                      Clipboard.setData(
                                                          ClipboardData(
                                                              text:
                                                                  "RGB( ${s.colors[i].rgb["r"]}, ${s.colors[i].rgb["g"]}, ${s.colors[i].rgb["b"]} )"));
                                                    },
                                                    child: Text("Copy",
                                                        style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 27)
                                                            .copyWith(
                                                                color:
                                                                    contrast)))
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12.0),
                                            child: Column(
                                              children: [
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 8.0),
                                                    child: Text(
                                                      "HSL( ${s.colors[i].hsl["h"]}, ${s.colors[i].hsl["s"]}, ${s.colors[i].hsl["l"]} )",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 24,
                                                          color:
                                                              inverseContrast,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              "TransformaSans"),
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            WidgetStatePropertyAll(
                                                                inverseContrastTransparent)),
                                                    onPressed: () {
                                                      Clipboard.setData(
                                                          ClipboardData(
                                                              text:
                                                                  "HSL( ${s.colors[i].hsl["h"]}, ${s.colors[i].hsl["s"]}, ${s.colors[i].hsl["l"]} )"));
                                                    },
                                                    child: Text("Copy",
                                                        style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 27)
                                                            .copyWith(
                                                                color:
                                                                    contrast)))
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          actions: [],
                        );
                      },
                    );
                  },
                  child: Icon(
                    Icons.fullscreen,
                    size: 50,
                    color: contrast,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: GestureDetector(
                    onTap: () {
                      closestResultSetState(theColor, true);
                      isBurgerMenuOpen = false;
                      innerScaffoldKey.currentState!.closeEndDrawer();
                    },
                    child: Icon(
                      Icons.search,
                      size: 50,
                      color: contrast,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    s.colors.removeWhere(
                        (ColorResult c) => s.colors[i].name == c.name);
                    updateSavedPalettes(
                        context,
                        closestResultSetState,
                        updateMenuState,
                        updateMainColor,
                        launchHTTPSetState,
                        updateSavedSetState);
                    if (savedPalettes[indexInList].colors.length == 0)
                      showDialog(
                          context: theContext,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                  "Do you want to delete this palette, \"${s.name}\"?"),
                              // Text("Add color to Palette..."),
                              // content: TextField(
                              //   controller: addNewPaletteTextController,
                              //   decoration: InputDecoration(hintText: "mehmehmeh"),
                              // ),
                              actions: [
                                ElevatedButton(
                                    child: const Text("No, leave it empty"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      savedPalettes[indexInList].opened = false;
                                      updateSavedPalettes(
                                          context,
                                          closestResultSetState,
                                          updateMenuState,
                                          updateMainColor,
                                          launchHTTPSetState,
                                          updateSavedSetState);
                                    }),
                                ElevatedButton(
                                    child: const Text('Yes'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      savedPalettes.removeAt(indexInList);
                                      savedPaletteOptions.removeAt(indexInList);
                                      selectedPaletteToSaveTo = 0;
                                      paletteToSaveTo.removeAt(indexInList);
                                      updateSavedPalettes(
                                          context,
                                          closestResultSetState,
                                          updateMenuState,
                                          updateMainColor,
                                          launchHTTPSetState,
                                          updateSavedSetState);
                                    }),
                              ],
                            );
                          });
                  },
                  child: Icon(
                    Icons.close,
                    size: 50,
                    color: contrast,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    ));
  }

  return colors;
}

/**
 * Builds small squares to be displayed below SavedPalettes in the burger menu when one is collapsed 
 *
 * @author L Mavroudakis
 * @version 1.0.0
 * @param s - Information on the palette to build all of the squares corresponding to the colors of
 */
List<Container> buildColorPreviews(SavedPalette s) {
  List<Container> list = [];
  for (ColorResult color in s.colors) {
    list.add(Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
          color: HexColor(color.hex), borderRadius: BorderRadius.circular(10)),
    ));
  }
  return list;
}
