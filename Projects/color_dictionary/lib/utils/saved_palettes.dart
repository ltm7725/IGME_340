import 'package:flutter/material.dart';
import '../classes.dart';
import 'update.dart';
import '../main.dart';
import 'dart:convert';

/**
 * Shows interactive AlertDialog to add a ColorResult to a SavedPalette, or create a new of the latter
 *
 * @author L Mavroudakis
 * @version 1.0.0
 * @param color - Info on the color to add to a palette
 */
void runAddSaved(
    ColorResult color,
    void Function(Color, bool) closestResultSetState,
    void Function(bool) updateMenuState,
    void Function(bool) updateMainColor,
    void Function(dynamic) launchHTTPSetState,
    void Function(List<Padding>) updateSavedSetState,
    void Function(int, int) runAddSavedSetState) {
  BuildContext context = innerScaffoldKey.currentState!.context;

  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Column(
            children: [
              Text("Save color to Palette..."),
              ToggleButtons(
                direction: Axis.vertical,
                children: savedPaletteOptions,
                textStyle: TextStyle(fontSize: 18),
                isSelected: paletteToSaveTo,
                borderWidth: 3,
                borderRadius: BorderRadius.circular(20),
                fillColor: Colors.grey,
                onPressed: (int index) {
                  //print(paletteToSaveTo);
                  runAddSavedSetState(1, index);
                  selectedPaletteToSaveTo = index;
                  //print(paletteToSaveTo);
                  Navigator.pop(context);
                  runAddSaved(
                      color,
                      closestResultSetState,
                      updateMenuState,
                      updateMainColor,
                      launchHTTPSetState,
                      updateSavedSetState,
                      runAddSavedSetState);
                },
              ),
            ],
          ),
          // Text("Add color to Palette..."),
          // content: TextField(
          //   controller: addNewPaletteTextController,
          //   decoration: InputDecoration(hintText: "mehmehmeh"),
          // ),
          actions: [
            ElevatedButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                  runAddSavedSetState(2, 0);
                }),
            ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context, addNewPaletteTextController.text);
                  if (selectedPaletteToSaveTo == paletteToSaveTo.length - 1) {
                    runCreateNewPalette(
                        color,
                        closestResultSetState,
                        updateMenuState,
                        updateMainColor,
                        launchHTTPSetState,
                        updateSavedSetState);
                  } else {
                    savedPalettes[selectedPaletteToSaveTo].colors.add(color);
                    updateSavedPalettes(
                        context,
                        closestResultSetState,
                        updateMenuState,
                        updateMainColor,
                        launchHTTPSetState,
                        updateSavedSetState);
                    selectedPaletteToSaveTo = paletteToSaveTo.length - 1;
                  }
                  runAddSavedSetState(3, 0);
                }),
          ],
        );
      });
}

/**
 * Runs another AlertDialog following runAddSaved() to get the user's text input to name the SavedPalette
 *
 * @author L Mavroudakis
 * @version 1.0.0
 * @param color - Info on the color to add to a palette
 */
void runCreateNewPalette(
    ColorResult color,
    void Function(Color, bool) closestResultSetState,
    void Function(bool) updateMenuState,
    void Function(bool) updateMainColor,
    void Function(dynamic) launchHTTPSetState,
    void Function(List<Padding>) updateSavedSetState) {
  BuildContext context = innerScaffoldKey.currentState!.context;

  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add to new Palette..."),
          content: Form(
            key: formKey1,
            child: TextFormField(
              controller: addNewPaletteTextController,
              validator: (value) {
                if (value?.replaceAll(" ", "") == "") return "Enter a name!";
                return null;
              },
              decoration: InputDecoration(hintText: "Enter A Palette Name!"),
            ),
          ),
          actions: [
            ElevatedButton( 
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                  selectedPaletteToSaveTo = paletteToSaveTo.length - 1;
                  addNewPaletteTextController.clear();
                }),
            ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  if (formKey1.currentState!.validate()) {
                    Navigator.pop(context, addNewPaletteTextController.text);
                    createNewPalette(null, color, null, true);
                    savedPalettes.insert(
                        0,
                        SavedPalette(
                            addNewPaletteTextController.text, [color], true));
                    selectedPaletteToSaveTo = paletteToSaveTo.length - 1;
                    addNewPaletteTextController.clear();
                    updateSavedPalettes(
                      context,
                      closestResultSetState,
                      updateMenuState,
                      updateMainColor,
                      launchHTTPSetState,
                      updateSavedSetState,
                    );
                  }
                  else addNewPaletteTextController.clear();
                }),
          ],
        );
      });
}

/**
 * Either adds options to companion variables to have user options match standing results,
 * or adds a SavedPalette to savedPalettes from sharedPreference information
 *
 * @author L Mavroudakis
 * @version 1.0.0
 * @param color - Info on the color to add to a palette
 */
void createNewPalette(
    String? name, ColorResult? color, List<dynamic>? colorList, bool opened) {
  if (colorList != null) {
    String theName = "";
    if (name != null) theName = name;

    List<ColorResult> theColorList = [];
    for (var z in colorList) {
      theColorList.add(ColorResult(
          z["name"],
          z["hex"],
          z["rgb"]["r"],
          z["rgb"]["g"],
          z["rgb"]["b"],
          double.parse(z["hsl"]["h"].toString()),
          double.parse(z["hsl"]["s"].toString()),
          double.parse(z["hsl"]["l"].toString()),
          z["bestContrast"]));
    }

    savedPalettes.add(SavedPalette(theName, theColorList, opened));
  } else {
    savedPaletteOptions.insert(
      0,
      Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            addNewPaletteTextController.text,
            style: TextStyle(color: Colors.black),
          )),
    );
    paletteToSaveTo.insert(0, false);
  }
}

/**
 * Takes all information from savedPalettes[] and writes it to sharedPreferences
 *
 * @author L Mavroudakis
 * @version 1.0.0
 */
void updateSavedPaletteHistory() {
  int paletteIndex = 0;
  String savedPalettesRaw = "{ \"palettes\":\[";
  for (var a in savedPalettes) {
    String paletteText = "";
    int colorIndex = 0;

    //print(a.name);

    paletteText =
        "{\"name\": \"${a.name}\", \"opened\": ${a.opened}, \"colors\":\[";
    //print(inspect(a.colors));
    for (int j = 0; j < a.colors.length; j++) {
      //print(a.colors[j].name);
      String colorText =
          "{\"name\": \"${a.colors[j].name}\", \"hex\": \"${a.colors[j].hex}\", \"rgb\": {\"r\": ${a.colors[j].rgb["r"]}, \"g\": ${a.colors[j].rgb["g"]}, \"b\": ${a.colors[j].rgb["b"]}}, \"hsl\": {\"h\": ${a.colors[j].hsl["h"]}, \"s\": ${a.colors[j].hsl["s"]}, \"l\": ${a.colors[j].hsl["l"]}}, \"bestContrast\": \"${a.colors[j].bestContrast}\"}";
      if (colorIndex != 0) colorText = ", " + colorText;
      paletteText += colorText;
      colorIndex++;
    }
    paletteText += "]}";
    if (paletteIndex != 0) paletteText = ", " + paletteText;
    savedPalettesRaw += paletteText;
    paletteIndex++;
  }
  savedPalettesRaw += "]}";

  //print("QQQ${savedPalettesRaw}");
  myPrefs.setString("palettes", savedPalettesRaw);
}

/**
 * Parses information from sharedPreferences to regain all previous SavedPalettes and display them
 *
 * @author L Mavroudakis
 * @version 1.0.0
 */
void restoreSavedPalettes(
    void Function(Color, bool) closestResultSetState,
    void Function(bool) updateMenuState,
    void Function(bool) updateMainColor,
    void Function(dynamic) launchHTTPSetState,
    void Function(List<Padding>) updateSavedSetState) {
  if (myPrefs.getString("palettes") != null) {
    var palettes = jsonDecode(myPrefs.getString("palettes").toString());
    //print(colors);

    savedPaletteContainers = [];
    while (savedPaletteOptions.length > 1) savedPaletteOptions.removeAt(0);
    savedPalettes = [];
    paletteToSaveTo = [true];
    selectedPaletteToSaveTo = 0;

    for (var z in palettes["palettes"])
      createNewPalette(z["name"], null, z["colors"], z["opened"]);

    for (int i = palettes["palettes"].length - 1; i >= 0; i--) {
      savedPaletteOptions.insert(
        0,
        Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              palettes["palettes"][i]["name"],
              style: TextStyle(color: Colors.black),
            )),
      );
      paletteToSaveTo.insert(0, false);
    }

    updateSavedPalettes(
        innerScaffoldKey.currentState!.context,
        closestResultSetState,
        updateMenuState,
        updateMainColor,
        launchHTTPSetState,
        updateSavedSetState);
  }
}
