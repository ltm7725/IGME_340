import 'package:flutter/material.dart';
import 'package:color_dictionary/classes.dart';
import 'package:color_dictionary/utils/update.dart';
import '../main.dart';
import 'package:flutter_color_utils/flutter_color_utils.dart';
import 'http.dart';
import 'saved_palettes.dart';

/**
 * Updates SharedPreferences whenever an option or menu displayed is changed,
 * so that when the app restarts it can come directly back to where the user left off.
 *
 * @author L Mavroudakis
 * @version 1.0.0
 */
void updateSharedPrefs(void Function(bool) updateMainColor,
    void Function(bool) updateMenuState, void Function(bool) toggleRGBorHSL) {
  myPrefs.setString("resultsNum", selectedClosestAmt.toString());
  myPrefs.setString("lastColor", currentColor.hex);
  myPrefs.setString("colorList", selectedListKey.toString());
  myPrefs.setString("rgbOrHsl", useRGB.toString());
  myPrefs.setString("menu", firstMenuSelected.toString());
  myPrefs.setString("sort", selectedSortMethod.toString());
  myPrefs.setString("ascending", orderButtonBools[0].toString());
  myPrefs.setString("showBurgerMenu", isBurgerMenuOpen.toString());
  myPrefs.setString("burgerMenu", showHistory.toString());
  updateSavedPaletteHistory();
}

/**s
 * Updates variables and calls functions when the app restarts that allows it to 
 * come directly back to where the user left off if used before. If not, uses
 * default values/options.
 *
 * @author L Mavroudakis
 * @version 1.0.0
 */
void restoreSharedPrefs(
    void Function(bool) updateMainColor,
    void Function(bool) updateMenuState,
    void Function(bool) toggleRGBorHSL,
    void Function(dynamic) updateSearchContrastSetState,
    void Function(Color, String) parseBestContrastSetState,
    BuildContext context,
    void Function(dynamic) launchHTTPSetState,
    void Function(Color, bool) closestResultSetState,
    void Function(int) buildHistoryColorsSetState,
    void Function(List<Padding>) updateSavedSetState,
    void Function(bool, bool) updateBurgerMenu) async {
  if (myPrefs.getString("resultsNum") != null) {
    selectedClosestAmt = myPrefs.getString("resultsNum").toString();
  }
  if (myPrefs.getString("lastColor") != null) {
    HexColor cfh = HexColor(myPrefs.getString("lastColor").toString());
    HSLColor hslfh =
        HSLColor.fromColor(Color.fromARGB(255, cfh.red, cfh.green, cfh.blue));
    currentColor = SearchColor(
        myPrefs.getString("lastColor").toString(),
        cfh.red,
        cfh.green,
        cfh.blue,
        hslfh.hue,
        hslfh.saturation,
        hslfh.lightness,
        "black");
    updateSearchContrast(currentColor, updateSearchContrastSetState,
        updateMainColor, updateMenuState, toggleRGBorHSL);
    updateMainColor(true);
  } else
    updateMainColor(false);
  if (myPrefs.getString("colorList") != null) {
    selectedListKey = myPrefs.getString("colorList").toString();
  }
  if (myPrefs.getString("menu") != null) {
    if (myPrefs.getString("menu").toString() == "false") {
      firstMenuSelected = false;
      updateMenuState(resultsReady);
    }
  }
  if (myPrefs.getString("sort") != null) {
    selectedSortMethod = int.parse(myPrefs.getString("sort").toString());
  }
  if (myPrefs.getString("ascending") != null) {
    if (myPrefs.getString("ascending").toString() == "true") {
      orderButtonBools[0] = true;
      orderButtonBools[1] = false;
    }
  }
  if (myPrefs.getString("rgbOrHsl") != null) {
    if (myPrefs.getString("rgbOrHsl").toString() == "false") {
      toggleRGBorHSL(true);
    }
  }
  if (myPrefs.getString("showBurgerMenu") != null) {
    if (myPrefs.getString("showBurgerMenu").toString() == "true") {
      isBurgerMenuOpen = true;
      burgerIcon = Icons.menu_open;
      appBarLeading = infoButton;
      innerScaffoldKey.currentState!.openEndDrawer();
    }
  }
  await updateSearchContrast(currentColor, updateSearchContrastSetState,
      updateMainColor, updateMenuState, toggleRGBorHSL);
  if (myPrefs.getString("history") != null) {
    historyContainers = updateHistoryColors(
        false,
        parseBestContrastSetState,
        context,
        updateMenuState,
        updateMainColor,
        launchHTTPSetState,
        closestResultSetState,
        buildHistoryColorsSetState,
        false,
        0,
        toggleRGBorHSL);
  } else 
    historyContainers = updateHistoryColors(
        true,
        parseBestContrastSetState,
        context,
        updateMenuState,
        updateMainColor,
        launchHTTPSetState,
        closestResultSetState,
        buildHistoryColorsSetState,
        false,
        0,
        toggleRGBorHSL);
  if(myPrefs.getString("burgerMenu") != null) {
    if(myPrefs.getString("burgerMenu") == "true") updateBurgerMenu(true, false);
    else updateBurgerMenu(false, false);
  }

  restoreSavedPalettes(closestResultSetState, updateMenuState, updateMainColor, launchHTTPSetState, updateSavedSetState);

}
