import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'classes.dart';
import 'utils/update.dart';
import 'dart:convert';
import 'utils/http.dart';
import 'utils/shared_prefs.dart';
import 'utils/saved_palettes.dart';

///
/// The app aims to function as a user-friendly portal into the Color Names API,
/// to find the closest named color to a search color chosen with a color picker
/// (or hex value) within most of the named-color lists on the Internet, their
/// name/color attributes, that of colors that match with it to create
/// complimentary/triadic/tetradic color palettes, and listing many other close
/// colors to the search color to get something potentially more desired.
/// All color results also give the ability to conduct a search with the
/// color in said result.
///
/// @author: L Mavroudakis
/// @version: 1.2.0
/// @since: 2024-12-3
///
/// todo:
///  - Enhance UI appearance further
///  - Catch HTTP errors in a user-friendly way, like when the device has no Internet connection
///  - Make the app functional in landscape mode (add "Show/Hide Search Queries" button when the screen is wide enough, give certain Containers SingleChildScrollAreas)
///  - Add info buttons within the DropdownButton for Color Database(s), giving the user a Dialog with the description of said list
///  - Progressive different loading indicators on the "Other Closest Colors" menu, showing the user what point in the search/analysis process it's at so they're not just sitting there waiting with no further information other than "loading"
///  - Add two more sections to the "Palette Colors" menu, giving sliders above two Containers that conduct an HTTP search whenever changed and show results for the search color hue-shifted and with different values of lightness (maybe saturation as well)
///  - Add a star button to all color results, which allows the user to save favorite colors and their information (this star automatically being filled in after a search if it's already favorited)
///  - A hamburger button in the AppBar which has two menus: history (with the actual RGB/HSL color searched not the closest result), and a favorites list, allowing the user to remove entries or search them at will (the favorites entries also having all info expanded)
///  - Potentially, folders within the Favorites menu to add/remove/organize colors within the app itself
///  - If these folders were in place, a display at the top when one is opened (and on screen when it's minimized) to show the entire color palette within the folder side-by-side
///  - A way to export color palettes, whether that be by text or even a generated image
///  - Make it so the UI doesn't jump to "Other Closest Colors" when search is initiated from certain points
///
/// notes:
///  After working for a good while I was unable to figure out how to trigger a SnackBar or change the words within the "Copy" buttons in expanded Closest Colors results to signify copying success

///
/// Main function that starts the program.
/// We use runApp to start the program with our StatelessWidget MainApp.
///

void main() {
  runApp(MainApp());
}
// END main

///
/// StatelessWidget that is the root of our program, calling the rest of the app to compile.
///
class MainApp extends StatelessWidget {
  MainApp({super.key});

  //
  // @return MaterialApp
  //
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: MyProject(),
        theme: ThemeData(
            fontFamily: "TransformaSans",
            textTheme: TextTheme(
                displaySmall:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                displayLarge:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                displayMedium:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 27),
                bodyMedium:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                labelMedium: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, height: 1.15))));
  }
}
// END main

// Variables used/changed in external files

// Is initial load running?
bool initRunning = true;

// Used to prevent visibilityChanged() of the background of the burger menu from triggering sharedPreference updating when updating is already occurring
bool updateRunning = true;

// Should the app be updating the history section?
bool updateHistory = true;

// Indicates whether RGB or HSL color attributes/controls are being displayed in areas where only one ever is
bool useRGB = true;

// Containers displaying information and search buttons for all colors meant to be in "Palette Colors" menu
Container closestContainer = Container();
Container complimentaryContainer = Container();
Container triadicContainer1 = Container();
Container triadicContainer2 = Container();
Container tetradicContainer1 = Container();
Container tetradicContainer2 = Container();
Container tetradicContainer3 = Container();

// Data in received object format from main HTTP request
Map mainData = {};

// Data maps for all colors in the "Palette Colors" menu, to be read from/parsed
Map closestColor = Map();
Map complimentaryColor = Map();
Map triadicColor1 = Map();
Map triadicColor2 = Map();
Map tetradicColor1 = Map();
Map tetradicColor2 = Map();
Map tetradicColor3 = Map();

// List of ALL colors in a given (user-defined) color database
List<ColorResult> fullColorList = [];
// List of a certain number of colors closest to the search in a given (user-defined) color database
List<ColorResult> allClosestColors = [];
// Containers with padding for all colors to be shown; derived from allClosestColors in BuildClosestResults()
List<Padding> shownClosestResults = [];

// Containers with padding and data for all previously-searched colors
List<Padding> historyContainers = [];
String historyColorsRaw = "";
List<SearchColor> historyColors = [];

// Color currently being searched
SearchColor currentColor =
    SearchColor("ffb76e79", 183, 110, 121, 351.0, 34.64055, 57.45098, "black");

// Selected amount of results to show in "Other Closest Colors" menu
String? selectedClosestAmt = "20";

// Method by which to sort "Other Closest Colors" results (reference sortMethods)
int? selectedSortMethod = 1;

// List of bools for whether ascending or descending button in "Other Closest Colors" is toggled
var orderButtonBools = [false, true];

// Selected keys for DropdownButtons
// Selected color database
String? selectedListKey = "default";

// SHOULD "Other Closest Colors" be loading? (does other logic on top of setting showClosest in updateMenuState)
bool closestLoading = true;

// Are SOME results ready? (Show at least "Palette Colors" results after running updateMenuState)
bool resultsReady = false;

late SharedPreferences myPrefs;

// Is "Palette Colors" menu selected?
bool firstMenuSelected = true;

final GlobalKey<ScaffoldState> innerScaffoldKey = GlobalKey();
Key burgerMenuBGKey = Key("burgerBG");

// Is the hamburger menu with history/saved colors open?
bool isBurgerMenuOpen = false;

// Changing icon in AppBar for Drawer menu
IconData burgerIcon = Icons.menu;

Padding? appBarLeading = null;
Padding? infoButton = null;

// Color of best contrast for text against the main-searched color (at top Container); black or white
Color searchContrast = Colors.black;
String searchContrastText = "black";

// Which screen in the burger menu should be showing, and what vars to indicate that are set to to accurately indicate
bool showHistory = true;
Color historyBGC = Colors.black;
Color historyTextC = Colors.white;
FontWeight historyTextFW = FontWeight.w500;
Color savedBG = Colors.white;
Color savedTextC = Colors.black;
FontWeight savedTextFW = FontWeight.bold;
 
// Text input controllers for naming/renaming saved color palettes, and Form keys to reference for form validation
final addNewPaletteTextController = TextEditingController();
final renamePaletteTextController = TextEditingController();
final GlobalKey<FormState> formKey1 = GlobalKey<FormState>();
final GlobalKey<FormState> formKey2 = GlobalKey<FormState>();

// List of possible saved color palettes to put a color being saved into, and corresponding data
List<Padding> savedPaletteOptions = [
  Padding(
      padding: EdgeInsets.all(10),
      child: Text(
        "New Palette...",
        style: TextStyle(color: Colors.black),
      )),
];
List<bool> paletteToSaveTo = [
  true,
];
int selectedPaletteToSaveTo = 0;
// Contains all saved color palettes
List<SavedPalette> savedPalettes = [];
List<Padding> savedPaletteContainers = [];

///
/// StatefulWidget that ensures state-updating for the app.
///
class MyProject extends StatefulWidget {
  MyProject({super.key});

  @override
  State<MyProject> createState() => _MyProjectState();
}
//END StatefulWidget

///
/// MyProject State Widget that holds most information about and logic in the app
///
class _MyProjectState extends State<MyProject> {
  // Color currently selected within the color picker
  SearchColor pickerColor = SearchColor(
      "ffb76e79", 183, 110, 121, 351.0, 34.64055, 57.45098, "black");

  // Whether the color picker widget is currently visible
  bool showColorPicker = false;
  // Variable to hold RGB/HSL color attributes for currently-searched color (at top Container)
  String currColorAttributes = "";

  // Indicates whether RGB or HSL color controls hould be showing in the color picker (only one ever is shown)
  ColorModel currColorModel = ColorModel.rgb;
  // Text within button in the AppBar to switch between RGB/HSL attributes where only one is ever shown
  String colorModelText = "RGB";

  // Font weights for "Palette Colors"/"Other Closest Colors" menu buttons, to be updated depending on which is active
  FontWeight paletteButtonFontWeight = FontWeight.normal;
  FontWeight closestButtonFontWeight = FontWeight.bold;

  // Text/background colors for "Palette Colors"/"Other Closest Colors" menu buttons, to be updated depending on which is active
  Color activeButtonTextColor = Colors.white;
  Color activeButtonBGColor = Color.fromARGB(255, 87, 87, 87);
  Color inactiveButtonTextColor = Colors.black;
  Color inactiveButtonBGColor = Colors.white;
  Color paletteButtonTextColor = Colors.white;
  Color paletteButtonBGColor = Color.fromARGB(255, 87, 87, 87);
  Color closestButtonTextColor = Colors.black;
  Color closestButtonBGColor = Colors.white;

  // Show loading spinner instead of "Palette Colors" menu?
  bool showLoading = true;
  // Direct variable to show/hide "Palette Colors" menu
  bool showPalette = false;
  // Direct variable to show/hide "Other Closest Colors" menu
  bool showClosest = false;

  // Should the transparent-black background on top of the main menus, behind other widgets/dialogs, be visible?
  bool showBlackdrop = false;

  // Collected hex values for colors in "Palette Colors" menu, to be displayed in their Containers
  String currColorHex = "";
  String complColorHex = "";
  String triadColorHex1 = "";
  String triadColorHex2 = "";
  String tetradColorHex1 = "";
  String tetradColorHex2 = "";
  String tetradColorHex3 = "";

  // HSL values for all colors in the "Palette Colors" menu, to be read from to create attribute Strings to display
  HSLColor currHSL = HSLColor.fromColor(Color(0xFFB76E79));
  HSLColor complHSL = HSLColor.fromColor(Color(0xFFB76E79));
  HSLColor triadHSL1 = HSLColor.fromColor(Color(0xFFB76E79));
  HSLColor triadHSL2 = HSLColor.fromColor(Color(0xFFB76E79));
  HSLColor tetradHSL1 = HSLColor.fromColor(Color(0xFFB76E79));
  HSLColor tetradHSL2 = HSLColor.fromColor(Color(0xFFB76E79));
  HSLColor tetradHSL3 = HSLColor.fromColor(Color(0xFFB76E79));

  // DropdownButton options for "Showing _ Results:" in "Other Closest Colors" menu
  final closestResultAmts = [
    DropdownMenuItem(value: "5", child: Text("5", textAlign: TextAlign.center)),
    DropdownMenuItem(
        value: "10", child: Text("10", textAlign: TextAlign.center)),
    DropdownMenuItem(
        value: "20", child: Text("20", textAlign: TextAlign.center)),
    DropdownMenuItem(
        value: "50", child: Text("50", textAlign: TextAlign.center)),
    DropdownMenuItem(
        value: "75", child: Text("75", textAlign: TextAlign.center)),
    DropdownMenuItem(
        value: "100", child: Text("100", textAlign: TextAlign.center)),
    DropdownMenuItem(
        value: "200", child: Text("200", textAlign: TextAlign.center)),
    DropdownMenuItem(
        value: "500", child: Text("500", textAlign: TextAlign.center)),
  ];

  // DropdownButton options for "Sort By:" in "Other Closest Colors" menu
  final sortMethods = [
    DropdownMenuItem(
        value: 1, child: Text("Closeness only", textAlign: TextAlign.center)),
    DropdownMenuItem(
        value: 2, child: Text("Alphabetical", textAlign: TextAlign.center)),
    DropdownMenuItem(value: 3, child: Text("Hue", textAlign: TextAlign.center)),
    DropdownMenuItem(
        value: 4, child: Text("Saturation", textAlign: TextAlign.center)),
    DropdownMenuItem(
        value: 5, child: Text("Lightness", textAlign: TextAlign.center)),
    DropdownMenuItem(value: 6, child: Text("Red", textAlign: TextAlign.center)),
    DropdownMenuItem(
        value: 7, child: Text("Green", textAlign: TextAlign.center)),
    DropdownMenuItem(
        value: 8, child: Text("Blue", textAlign: TextAlign.center)),
  ];

  // List of Icons containing content to go into ToggleButtons for ascending/descending sort in "Other Closest Colors" menu
  final ascendingDescending = [
    Icon(Icons.keyboard_double_arrow_up, color: Colors.black, size: 50),
    Icon(Icons.keyboard_double_arrow_down, color: Colors.black, size: 50)
  ];

  // Function snippets from other .dart files that use setState

  /**
        * Updates the pickerColor variable to display the current-selected color 
        * in the colorpicker in multiple places on the display, and to be referenced
        * from to assign currentColor variable if the search button in the widget is hit.
        *
        * @author L Mavroudakis
        * @version 1.0.0
        * @param color - Currently-selected color in the color picker, to update other display components
        */
  void changePickerColor(Color color) {
    setState(() => pickerColor = SearchColor(
        colorToHex(color),
        color.red,
        color.green,
        color.blue,
        HSLColor.fromColor(color).hue,
        HSLColor.fromColor(color).saturation,
        HSLColor.fromColor(color).lightness,
        searchContrastText));
  }

  /**
         * Code from buildPaletteResult() in utils/buiders.dart which requires setState()
         *
         * @author L Mavroudakis
         * @version 1.0.0
         * @param data - Mapped data of the color to be displayed/given information on
         */
  void paletteResultSetState(Map data) {
    setState(() {
      firstMenuSelected = true;
      updateMenuState(false);
      currentColor = SearchColor(
          "ffb76e79", 183, 110, 121, 351.0, 34.64055, 57.45098, "black");
      currentColor.setFromData(data);
      currentColor.hex = "#" + currentColor.hex;
      updateMainColor(true);
      launchHTTP(launchHTTPSetState);
    });
  }

  /**
         * Code from buildClosestResult() in utils/buiders.dart which requires setState()
         *
         * @author L Mavroudakis
         * @version 1.0.0
         * @param theColor - Color information to be utilized/displayed/given information on
         */
  void closestResultSetState(Color theColor, bool fromBurgerMenu) {
    //print("1${myPrefs.getString("lastColor")}");
    setState(() {
      if (!fromBurgerMenu) firstMenuSelected = false;
      updateMenuState(false);
      currentColor = SearchColor(
          colorToHex(theColor),
          theColor.red,
          theColor.green,
          theColor.blue,
          HSLColor.fromColor(theColor).hue,
          HSLColor.fromColor(theColor).saturation,
          HSLColor.fromColor(theColor).lightness,
          searchContrastText);
      updateMainColor(true);
      launchHTTP(launchHTTPSetState);
    });
  }

  /**
         * Code from launchHTTP() in utils/http.dart which requires setState()
         *
         * @author L Mavroudakis
         * @version 1.0.0
         * @param response - JSON-parsed response from API with color information
         */
  void launchHTTPSetState(dynamic response) async {
    setState(() {
      closestColor = jsonDecode(response.body)["colors"][0];
      mainData = closestColor;
      // print(closestColor);

      complHSL = HSLColor.fromAHSL(
          1, (currHSL.hue + 180) % 360, currHSL.saturation, currHSL.lightness);
      triadHSL1 = HSLColor.fromAHSL(
          1, (currHSL.hue + 120) % 360, currHSL.saturation, currHSL.lightness);
      triadHSL2 = HSLColor.fromAHSL(
          1, (currHSL.hue + 240) % 360, currHSL.saturation, currHSL.lightness);
      tetradHSL1 = HSLColor.fromAHSL(
          1, (currHSL.hue + 90) % 360, currHSL.saturation, currHSL.lightness);
      tetradHSL2 = HSLColor.fromAHSL(
          1, (currHSL.hue + 180) % 360, currHSL.saturation, currHSL.lightness);
      tetradHSL3 = HSLColor.fromAHSL(
          1, (currHSL.hue + 270) % 360, currHSL.saturation, currHSL.lightness);
      complColorHex = colorToHex(complHSL.toColor()).substring(2);
      triadColorHex1 = colorToHex(triadHSL1.toColor()).substring(2);
      triadColorHex2 = colorToHex(triadHSL2.toColor()).substring(2);
      tetradColorHex1 = colorToHex(tetradHSL1.toColor()).substring(2);
      tetradColorHex2 = colorToHex(tetradHSL2.toColor()).substring(2);
      tetradColorHex3 = colorToHex(tetradHSL3.toColor()).substring(2);
    });

    await updateSearchContrast(currentColor, updateSearchContrastSetState,
        updateMainColor, updateMenuState, toggleRGBorHSL);

    setState(() {
      if (!initRunning)
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
      else
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
      secondaryHTTP(
          complColorHex,
          triadColorHex1,
          triadColorHex2,
          tetradColorHex1,
          tetradColorHex2,
          tetradColorHex3,
          secondaryHTTPSetState,
          tertiaryHTTPSetState,
          updateMenuState,
          updateMainColor,
          toggleRGBorHSL);
    });
  }

  /**
         * Code from secondaryHTTP() in utils/http.dart which requires setState()
         *
         * @author L Mavroudakis
         * @version 1.0.0
         * @param otherColors - JSON-parsed API response with information on all
         * colors meant to match certain color palettes with the main search result
         */
  void secondaryHTTPSetState(List<Map>? otherColors) async {
    setState(await () {
      Map a = {};
      Map b = {};
      Map c = {};
      Map d = {};
      Map e = {};
      Map f = {};
      if (otherColors != null) {
        [a, b, c, d, e, f] = otherColors;
        complimentaryColor = a;
        triadicColor1 = b;
        triadicColor2 = c;
        tetradicColor1 = d;
        tetradicColor2 = e;
        tetradicColor3 = f;
      }
      initRunning = false;
      updatePaletteResults(
          context,
          paletteResultSetState,
          parseBestContrastSetState,
          runAddSaved,
          closestResultSetState,
          updateMenuState,
          updateMainColor,
          launchHTTPSetState,
          updateSavedSetState,
          runAddSavedSetState);
    });
  }

  /**
         * Code from tertiaryHTTP() in utils/http.dart which requires setState()
         *
         * @author L Mavroudakis
         * @version 1.0.0
         * @param otherColors - JSON-parsed API response with information on all
         * colors remotely similar to the main search result
         */
  void tertiaryHTTPSetState(dynamic allColors) async {
    setState(await () {
      fullColorList = allColors;
      shownClosestResults = updateClosestResults(
          context,
          updateMenuState,
          updateMainColor,
          closestResultSetState,
          launchHTTPSetState,
          updateSavedSetState,
          runAddSavedSetState);
      closestLoading = false;
    });
  }

  /**
         * Code from updateSearchContrast() in utils/http.dart which requires setState()
         * (Performs another API call)
         *
         * @author L Mavroudakis
         * @version 1.0.0
         * @param otherColors - JSON-parsed API response with information on the closest
         * color to the one selected, used to set contrast on certain UI aspects before
         * the main search result comes in
         */
  void updateSearchContrastSetState(dynamic response) {
    setState(() {
      var data = jsonDecode(response.body);

      if (data["colors"][0]["bestContrast"] == "black") {
        searchContrast = Colors.black;
        searchContrastText = "black";
      } else {
        searchContrast = Colors.white;
        searchContrastText = "white";
      }
    });
  }

  /**
         * Code from parseBestContrast() in utils/analysis.dart which requires setState()
         *
         * @author L Mavroudakis
         * @version 1.0.0
         * @param theColor - basic color information for the main contrast color for the searched color
         * @param color - the text corresponding to the color of theColor (searchContrast)
         */
  parseBestContrastSetState(Color theColor, String color) {
    setState(() {
      searchContrast = theColor;
      searchContrastText = color;
    });
  }

  void buildHistoryColorsSetState(int delIndex) {
    setState(() {
      historyContainers = updateHistoryColors(
          false,
          parseBestContrastSetState,
          context,
          updateMenuState,
          updateMainColor,
          launchHTTPSetState,
          closestResultSetState,
          buildHistoryColorsSetState,
          true,
          delIndex,
          toggleRGBorHSL);
    });
  }

  /**
         * Code from updateSavedPalettes() in utils/update.dart which requires setState()
         * (Performs another API call)
         *
         * @author L Mavroudakis
         * @version 1.0.0
         * @param palettes - list of all saved color palettes as visual/interactive containers, which is assigned to the variable put in place in the app
         */
  void updateSavedSetState(List<Padding> palettes) {
    setState(() {
      savedPaletteContainers = palettes;
      updateSavedPaletteHistory();
    });
  }

  /**
         * Code from buildSavedPalette() in utils/builders.dart which requires setState()
         * (Performs another API call)
         *
         * @author L Mavroudakis
         * @version 1.0.0
         * @param indexInList - indicates the index of a given SavedPalette in savedPalettes[]
         * @param opened - indicates whether the saved palette should be expanded or not automatically
         */
  void buildSavedPaletteSetState(int indexInList, bool opened) {
    setState(() {
      if (opened)
        savedPalettes[indexInList].opened = false;
      else
        savedPalettes[indexInList].opened = true;
      updateSavedPalettes(context, closestResultSetState, updateMenuState,
          updateMainColor, launchHTTPSetState, updateSavedSetState);
      //print(savedPalettes[indexInList].opened);
    });
  }

  /**
         * Code from runAddSaved() in utils/saved_palette4s.dart which requires setState()
         * (Performs another API call)
         *
         * @author L Mavroudakis
         * @version 1.0.0
         * @param piece - indicates the protocol being done from runAddSaved(), since multiple parts need setState() functions
         * @param index - in protocol 1, is used to set all but the selected SavedPalette's buttons to deactivated when adding a color to one
         */
  void runAddSavedSetState(int piece, int index) {
    if (piece == 1) {
      setState(() {
        for (int i = 0; i < paletteToSaveTo.length; i++) {
          paletteToSaveTo[i] = true;
          if (i != index) paletteToSaveTo[i] = false;
        }
      });
    } else if (piece == 2) {
      setState(() {
        for (int i = 0; i < paletteToSaveTo.length; i++) {
          paletteToSaveTo[i] = false;
        }
        paletteToSaveTo[paletteToSaveTo.length - 1] = true;
        selectedPaletteToSaveTo = paletteToSaveTo.length - 1;
      });
    } else if (piece == 3) {
      setState(() {
        for (int i = 0; i < paletteToSaveTo.length; i++) {
          paletteToSaveTo[i] = false;
        }
        paletteToSaveTo[paletteToSaveTo.length - 1] = true;
      });
    }
  }

  /**
         * Swaps the color attributes from RGB to HSL and vice versa (as well
         * as the text in the toggle button itself) wherever only one of the 
         * two is displayed, compiling the text to be put into these attribute 
         * sections and assigning to variables that are refrenced in the app.
         *
         * @author L Mavroudakis
         * @version 1.0.0
         * @param init - If this function is being called from init(); if so 
         * doesn't update results during initial color search, evading an error
         */
  void toggleRGBorHSL(bool init) {
    setState(() {
      if (useRGB) {
        useRGB = false;
        currColorAttributes =
            "HSL(${currentColor.hsl["h"].toStringAsFixed(0)}°,${(currentColor.hsl["s"]).toStringAsFixed(0)}%,${(currentColor.hsl["l"]).toStringAsFixed(0)}%)";
        currColorModel = ColorModel.hsl;
        colorModelText = "HSL";
      } else {
        useRGB = true;
        currColorAttributes =
            "RGB(${currentColor.rgb["r"]},${currentColor.rgb["g"]},${currentColor.rgb["b"]})";
        currColorModel = ColorModel.rgb;
        colorModelText = "RGB";
      }
      if (!init)
        updatePaletteResults(
            context,
            paletteResultSetState,
            parseBestContrastSetState,
            runAddSaved,
            closestResultSetState,
            updateMenuState,
            updateMainColor,
            launchHTTPSetState,
            updateSavedSetState,
            runAddSavedSetState);
    });
  }

  /**
         * Updates the currentColor variable based on the picked color in color picker,
         * also setting variables corresponding to the current displayed color attribute
         * and hex code of the selected color.
         *
         * @author L Mavroudakis
         * @version 1.0.0
         * @param useInputAttributes - If true, signifies that currentColor was set elsewhere
         * (a search button has been hit on a Container), and doesn't update it based on pickerColor
         */
  void updateMainColor(bool useInputAttributes) {
    setState(() {
      if (!useInputAttributes) {
        currentColor = pickerColor;
      }
      currHSL = HSLColor.fromColor(Color.fromARGB(255, currentColor.rgb["r"],
          currentColor.rgb["g"], currentColor.rgb["b"]));
      if (useRGB)
        currColorAttributes =
            "RGB(${currentColor.rgb["r"]},${currentColor.rgb["g"]},${currentColor.rgb["b"]})";
      else
        currColorAttributes =
            "HSL(${currentColor.hsl["h"].toStringAsFixed(0)}°,${(currentColor.hsl["s"]).toStringAsFixed(0)}%,${(currentColor.hsl["l"]).toStringAsFixed(0)}%)";
      currColorHex = "#${currentColor.hex.substring(2).toLowerCase()}";
    });
  }

  /**
         * Updates the display when results are newly ready/unready to be displayed,
         * showing/hiding these sections. Also updates "Palette Colors"/"Other Closest Colors" 
         * buttons when one is pressed, visibly indicated which one is active.
         *
         * @author L Mavroudakis
         * @version 1.0.0
         * @param ready - Are SOME results ready to be displayed in the app? ("Other Closest Colors" MIGHT still be loading)
         */
  void updateMenuState(bool ready) {
    setState(() {
      resultsReady = ready;
      if (ready) {
        showLoading = false;
        if (firstMenuSelected) {
          showClosest = false;
          showPalette = true;
        } else {
          showPalette = false;
          if (closestLoading) {
            showClosest = false;
            showLoading = true;
          } else
            showClosest = true;
        }
      } else {
        showLoading = true;
        showPalette = false;
        showClosest = false;
        closestLoading = true;
      }
      print("a${initRunning}");
      print("b${showPalette}");
      if (!initRunning) {
        if (firstMenuSelected) {
          paletteButtonTextColor = activeButtonTextColor;
          paletteButtonBGColor = activeButtonBGColor;
          closestButtonTextColor = inactiveButtonTextColor;
          closestButtonBGColor = inactiveButtonBGColor;
          paletteButtonFontWeight = FontWeight.normal;
          closestButtonFontWeight = FontWeight.bold;
        } else {
          paletteButtonTextColor = inactiveButtonTextColor;
          paletteButtonBGColor = inactiveButtonBGColor;
          closestButtonTextColor = activeButtonTextColor;
          closestButtonBGColor = activeButtonBGColor;
          paletteButtonFontWeight = FontWeight.bold;
          closestButtonFontWeight = FontWeight.normal;
        }
      }
    });
  }

  void updateBurgerMenu(bool sh, bool update) {
    setState(() {
      if (sh) {
        showHistory = true;
        historyBGC = const Color.fromRGBO(87, 87, 87, 1);
        historyTextC = Colors.white;
        historyTextFW = FontWeight.w500;
        savedBG = Colors.white;
        savedTextC = const Color.fromRGBO(87, 87, 87, 1);
        savedTextFW = FontWeight.bold;
      } else {
        showHistory = false;
        historyBGC = Colors.white;
        historyTextC = const Color.fromRGBO(87, 87, 87, 1);
        historyTextFW = FontWeight.bold;
        savedBG = const Color.fromRGBO(87, 87, 87, 1);
        savedTextC = Colors.white;
        savedTextFW = FontWeight.w500;
      }
    });
    if (update)
      updateSharedPrefs(updateMainColor, updateMenuState, toggleRGBorHSL);
  }

  // End function snippets from other .dart files and/or that use setState

  ///
  /// Root function called as soon as the app begins
  ///
  @override
  void initState() {
    super.initState();
    init();
  }

/**
 * Runs all logic and functions required at the very beginning of the app running,
 * restoring SharedPreferences, updating the display, and launching a primary API search
 *
 * @author L Mavroudakis
 * @version 1.0.0
 */
  Future init() async {
    myPrefs = await SharedPreferences.getInstance();
    //myPrefs.clear();
    //await myPrefs.clear();
    restoreSharedPrefs(
        updateMainColor,
        updateMenuState,
        toggleRGBorHSL,
        updateSearchContrastSetState,
        parseBestContrastSetState,
        context,
        launchHTTPSetState,
        closestResultSetState,
        buildHistoryColorsSetState,
        updateSavedSetState,
        updateBurgerMenu);
    updateMenuState(false);
    launchHTTP(launchHTTPSetState);
    updateMenuState(false);
  }

  /// Build function with most components for the app
  @override
  Widget build(BuildContext context) {
    // DropdownButton options for Color Database(s) in top search controls
    final nameLists = [
      DropdownMenuItem(
          value: "default",
          child: Text("Handpicked Color Names \n(ALL Databases)",
              style: Theme.of(context).textTheme.labelMedium)),
      DropdownMenuItem(
          value: "basic",
          child: Text("Basic", style: Theme.of(context).textTheme.labelMedium)),
      DropdownMenuItem(
          value: "html",
          child: Text("HTML Colors",
              style: Theme.of(context).textTheme.labelMedium)),
      DropdownMenuItem(
          value: "japaneseTraditional",
          child: Text("Traditional Colors of Japan",
              style: Theme.of(context).textTheme.labelMedium)),
      DropdownMenuItem(
          value: "leCorbusier",
          child: Text("Le Corbusier",
              style: Theme.of(context).textTheme.labelMedium)),
      DropdownMenuItem(
          value: "nbsIscc",
          child: Text("The Universal Color Language",
              style: Theme.of(context).textTheme.labelMedium)),
      DropdownMenuItem(
          value: "ntc",
          child:
              Text("NTC.js", style: Theme.of(context).textTheme.labelMedium)),
      DropdownMenuItem(
          value: "osxcrayons",
          child: Text("OS X Crayons",
              style: Theme.of(context).textTheme.labelMedium)),
      DropdownMenuItem(
          value: "ral",
          child: Text("RAL Color",
              style: Theme.of(context).textTheme.labelMedium)),
      DropdownMenuItem(
          value: "ridgway",
          child: Text("Robert Ridgway's Color Standards and Color Nomenclature",
              style: Theme.of(context).textTheme.labelMedium)),
      DropdownMenuItem(
          value: "sanzoWadaI",
          child: Text("Wada Sanzō Japanese Color Dictionary Volume I",
              style: Theme.of(context).textTheme.labelMedium)),
      DropdownMenuItem(
          value: "thesaurus",
          child: Text("The Color Thesaurus",
              style: Theme.of(context).textTheme.labelMedium)),
      DropdownMenuItem(
          value: "werner",
          child: Text("Werner's Nomenclature of Colours",
              style: Theme.of(context).textTheme.labelMedium)),
      DropdownMenuItem(
          value: "windows",
          child: Text("Microsoft Windows Color Names",
              style: Theme.of(context).textTheme.labelMedium)),
      DropdownMenuItem(
          value: "wikipedia",
          child: Text("Wikipedia Color Names",
              style: Theme.of(context).textTheme.labelMedium)),
      DropdownMenuItem(
          value: "french",
          child: Text("French Colors",
              style: Theme.of(context).textTheme.labelMedium)),
      DropdownMenuItem(
          value: "spanish",
          child: Text("Spanish Colors",
              style: Theme.of(context).textTheme.labelMedium)),
      DropdownMenuItem(
          value: "german",
          child: Text("German Colors",
              style: Theme.of(context).textTheme.labelMedium)),
      DropdownMenuItem(
          value: "x11",
          child: Text("X11 Color Names",
              style: Theme.of(context).textTheme.labelMedium)),
      DropdownMenuItem(
          value: "xkcd",
          child: Text("XKCD Colors",
              style: Theme.of(context).textTheme.labelMedium)),
      DropdownMenuItem(
          value: "risograph",
          child: Text("Risograph Colors",
              style: Theme.of(context).textTheme.labelMedium)),
      DropdownMenuItem(
          value: "chineseTraditional",
          child: Text("Traditional Colors of China",
              style: Theme.of(context).textTheme.labelMedium)),
      DropdownMenuItem(
          value: "bestOf",
          child: Text("Best of Color Names",
              style: Theme.of(context).textTheme.labelMedium)),
      DropdownMenuItem(
          value: "short",
          child: Text("Short Color Names",
              style: Theme.of(context).textTheme.labelMedium)),
    ];

    // Info button to trigger About page & documentation; only shown in AppBar on certain occasions
    infoButton = Padding(
      padding: EdgeInsets.only(left: 15),
      child: GestureDetector(
        onTap: () {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return Container(
                height: MediaQuery.sizeOf(context).height,
                width: MediaQuery.sizeOf(context).width,
                color: Color.fromARGB(192, 255, 255, 255),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 30.0, top: 30.0),
                          child: Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 60,
                          ),
                        ),
                      ),
                    ),
                    DefaultTextStyle(
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      child: Text(
                        "About",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: "TransformaSans",
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 20.0, left: 20, right: 20),
                      child: Container(
                        height: MediaQuery.sizeOf(context).height - 250,
                        width: MediaQuery.sizeOf(context).width,
                        color: Color.fromARGB(192, 128, 128, 128),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: DefaultTextStyle(
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                              child: Text(
                                """
Color Dictionary™ 
L Mavroudakis
RIT Fall 2024
IGME.340.01

The app aims to function as a user-friendly portal into the Color Names API, to find the closest named color to a search color chosen with a color picker (or hex value) within most of the named-color lists on the Internet, their name/color attributes, that of colors that match with it to create complimentary/triadic/tetradic color palettes, and listing many other close colors to the search color to get something potentially more desired. All color results also give the ability to conduct a search with the color in said result.

*RESOURCES UTILIZED*

  - Made in Flutter with Dart language
  - Applicable Flutter docs
  - Flutter libraries: http, flutter_colorpicker, flutter_color_utils, convert, services, shared_preferences
  - API: Color Name API by David Aerne (GitHub: meodai)
  - Icons: Google Fonts
  - Loading spinner: appseconnect.com

*HOW I MET REQUIREMENTS - PROJECT 2*

  - The app successfully requests from the Color Name API and parses/displays information in a comprehensive way, in a pretty succinct user experience (and no CORS issues)
  - Shared preferences are stored, either returning the user to exactly where they left off with search/display value/sort options (or showing a default color with default search/display/order options if nothing is saved yet); Search color, RGB/HSL displayed, selected color database, menu (Palette Colors/Other Closest Colors) selected, sort type, ascending/descending, and result amounts are saved in this way
  - ~7 user controls (listed in bullet above)
  - Generally pleasing design (which could still be enhanced), with well-labeled widgets (and loading/state indicators) where needed and otherwise indicated well to the user with icons, the user most likely able to traverse and utilize the app with no instruction after a few seconds of playing with it
  - No errors possible/unhandled, besides maybe if there's no Internet on the device (which the rubric didn't indicate needed to be caught in a user-friendly way)
  - Functions for otherwise-duplicate code, vairables and functions well-commented to make fairly easy to understand

*I don't think there's anything stand-out that I'd want people to see here that isn't pretty clear, but given time I didn't do absolutely everything I wanted to do with it despite hitting all requirements. If I were to come back, I'd like to:*

  - Enhance UI appearance further
  - Catch HTTP errors in a user-friendly way, like when the device has no Internet connection
  - Add info buttons within the DropdownButton for Color Database(s), giving the user a Dialog with the description of said list
  - Make the app functional in landscape mode (add "Show/Hide Search Queries" button when the screen is wide enough, give certain Containers SingleChildScrollAreas)
  - Progressive different loading indicators on the "Other Closest Colors" menu, showing the user what point in the search/analysis process it's at so they're not just sitting there waiting with no further information other than "loading"
  - Add two more sections to the "Palette Colors" menu, giving sliders above two Containers that conduct an HTTP search whenever changed and show results for the search color hue-shifted and with different values of lightness (maybe saturation as well)
  - Add a star button to all color results, which allows the user to save favorite colors and their information (this star automatically being filled in after a search if it's already favorited)
  - A hamburger button in the AppBar which has two menus: history (with the actual RGB/HSL color searched not the closest result), and a favorites list, allowing the user to remove entries or search them at will (the favorites entries also having all info expanded)
  - Potentially, folders within the Favorites menu to add/remove/organize colors within the app itself
  - If these folders were in place, a display at the top when one is opened (and on screen when it's minimized) to show the entire color palette within the folder side-by-side
  - A way to export color palettes, whether that be by text or even a generated image

*GENERAL DOCUMENTATION/PROCESS*

  - Started off with making sure intended search method was plausible, creating a pseudo-dialog containing two components from the flutter_colorpicker library, prompted by a "CHANGE COLOR" button next to it and stored within a variable at the same point that will launch the HTTP request and data parsing
  - Made sure this colorpicker widget doesn't cover AppBar so that I can put a control up there later; also added cancel and confirm search buttons, ensuring that "currentColor" Color variable stays the one that's currently searched even when another is selected but then cancelled
  - Added one Container below the search queries menu (only "Palette Colors" menu below at this point), for the HTTP request to write its color and information onto to prove that this API request process doesn't have any issues 
  - This Container is given height based on the height of the phone screen, so it's not always hitting right at the bottom but generally spans the rest of the screen (same thing with the "Other Closest Colors" bit I made later)
  - Added a secondary HTTP request to be launched after the first one completes, the code calculating values for colors that match the closest one the API database has based on the search color, this 2nd API request getting the information for all of these colors collectively
  - Created a function to build the color containers, assigning the return value to variables corresponding to each palette color needed and placing them in the correct place in the "Palette Colors" menu (also taking a "bestContrast" color value from the API request and applying it to the text and icons in the Container)
  - Added a DropdownButton in the top search queries menu, including all color databases able to be used from the API (the top one including all lists together; you can't select multiple at the same time so it's not checkboxes); changing option automatically launches search
  - Added a variable to be changed during HTTP process to only display results Container when process is complete, showing a loading spinner when it's not up
  - Set variables that the internals of the color results reference for their displayed color attributes, changed whenever new button in the AppBar is pressed, swapping out the RGB attributes to HSL and vice versa (doing the same in the "Search Color" section at the top and in the controls for the color picker!)
  - Added a row to the bottom of the Palette Colors Containers with black and white blocks to show their contrast, and a search button to launch a search with the color included in the Container when pressed
  - Experimented with another endpoint for the API which lists all colors in a given list, and utilizing Flutter's color_utils library to calculate closeness to the searched color and ranking them; this gave justification to create the 2nd part of the app included in my proposal, the "Other Closest Colors" menu
  - Created a state system with variables to be able to include both menus in the general Scaffold body structure but only show one at a time, depending on the button selected underneath the search queries menu
  - Created another function to build Containers, this time with less information and prompts to search and look at more info within a Dialog
  - Applied the function created in experimentation above to the Container-creating function, listing results within "Other Closest Colors" as soon as the process is done
  - The "Other Closest Colors" bit takes much longer than the "Palette Colors" search, so put in some checks to display the latter as soon as it's done and still show the loading spinner under the former when it's the only thing loading
  - Created Dialog structure within Container-creating function for "Other Closest Colors" to show the color with contrast blocks on top of it, and copyable hex code and RGB/HSL values below
  - NOTE: After working for a good while I was unable to figure out how to trigger a SnackBar or change the words within the "Copy" buttons to signify copying success
  - Added a DropdownButton WITHIN the "Other Closest Colors" Container to refresh the results without re-searching everything, changing the amount of results displayed
  - Added an error-evading bit so that if the requested amount of results is more than the selected his HAS, it just stops building containers and shows everything that does exist in the given sort order
  - Then added another set of controls in this section, letting the user sort closest results by closeness alone, or also by alphabet or any color attributes (and ascending/descending), with protocols to analyze and display the results in this same Container Column structure with no issue
  - Added SharedPreferences protocols whenever a selection is changed and at init, so that the app starts exactly where you left off every time (if no shared preferences searches a Rose Gold color with all lists, listing 20 and descending by Closeness within "Other Closest Colors")
  - Added Dialog in AppBar to show information about the app, documentation, and explanation of requirement-meeting
  - Added this text to the About Dialog

  --- Begin Project 3 ---

  - Separated all code not using saveState to files outside of main.dart, hooked everything up
  - Brought all commenting up to spec for this stage (Project 3 Prototype submission)
  - Added a hamburger menu with changing-indicating icon (and eventually meant for saved/history colors), and made it so the info button to launch this documentation only shows when the menu is visible as well
  - Hooked hamburger menu triggers up to shared preferences, so that if a user exits the app with it open it opens once again when they return to the app
  - Fixed overflow error on main menu Column when text box in color-picker is opened, telling it to ignore said overflow because such area isn't functional at that time anyway
  - Added scroll column with Column that connects to built containers for history colors to display color search history
  - Made it so another history entry isn't created if your last-searched color is the same
  - Fixed "Closest" containers to show correct contrast for each individual entry
  - Added a VisibilityDetector to the background of the burger menu to allow the AppBar to change accordingly if the burger menu is dismissed by swiping, and transition cleanly (only ever being changed by this onVisibilityChanged)
  - Added the ability to remove entries from color search history, and an indicator that your history is empty if it is
  - Fixed bug so that history empty indicator shows if history is empty when app reloads
  - Fixed bug where a color searched from the history menu wouldn't save to the menu even if not the most recent search
  - Added burger menu toggle between history and saved-palettes menus
  - Created framework for saved palettes, and a class to hold each's information and all colors within
  - Hooked up heart icons on search result colors to Dialogs for the user to select between existing saved palettes and creating a new one, with a prompt to name it if the latter
  - Lined up information and info-dialogs for saved results to appear effectively in the menu
  - Added ability to remove colors from palettes
  - Added ability to delete entire palettes, with a prompt to do so if a palette is completely emptied out
  - Implemented show/hide function for palette viewing, to either show color names and interactions, or basic boxes of the colors next to each other if closed
  - Added ability to rename palettes with an included icon
  - Added input validation for TextFormFields to name/change names of SavedPalettes
  - Hooked up all interactions and info for saved palette data, and the aspect of the burger menu opened, to shared preferences
  - Added custom font and cleaned up UI aspects somewhat
  - Fixed bug where even when Palette Colors was selected, it would appear as though Other Closest Colors was selected while the former was loading
  - Fixed bug where after adding a color to a pre-existing palette, adding the next to a new palette would instead add it to the previously-selected palette

*HOW I MET REQUIREMENTS - PROJECT 3*

  - The app is really useful in certain cases, and very easy to use after a brief bit of tinkering
  - There is as much functionality (beyond for things like responsiveness) as was generally realistic and helpful for this state of the project
  - Input validation for setting the name of and renaming color palettes, so that there's no empty entries
  - Custom splash screen/icon, with a nice name where there really wasn't much more clever to put (as much as I tried lol)
  - Shared_Preferences utilized to return the user to exactly where they were in their previous session on the app (besides when they close it while the About page is opened)
  - The app has technically 5 different pages
  - App never crashes
  - Documentation is present (HERE!!)
  - Pretty reasonable graphic design, definitely not clunky like previous versions
  - Widgets are very well-labeled throughout where reasonable
  - Users should be able to figure out the app quick (but that's up to others I guess)
  - Solid layout for a portrait-turned device; not responsive at this state
  - No giant images, and custom font utilized throughout; **Attempting to use audio hit a compatibility issue with Java somehow--not implemented**
  - 3 Classes utilized for majority of information being sent around the app/functions
  - Generally not using var--only when something's read from which doesn't have a distinct type but information is being extracted from
  - Only repeated code where somewhat necessary (at least in terms of what I understand about the platform)
  - Different .dart files for different categories of functions, classes, and majority main app code
  - Only using single-letter variables where they are extremely local
  - Every function (and I believe every variable/category of variables) is commented/described
  - ONLY http-related print statements for API requests still active in debug console
""",
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
        child: Icon(Icons.info, size: 40, color: Colors.white),
      ),
    );

    return MaterialApp(
      home: Scaffold(
          primary: true,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: appBarLeading,
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: Visibility(
                  visible: (burgerIcon == Icons.menu),
                  child: Container(
                    width: 122,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.white)),
                        onPressed: () {
                          toggleRGBorHSL(false);
                          updateSharedPrefs(
                              updateMainColor, updateMenuState, toggleRGBorHSL);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.swap_horiz,
                                color: Colors.black, size: 40),
                            Text(
                              colorModelText,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900),
                            ),
                          ],
                        )),
                  ),
                ),
              ),
              Builder(builder: (context) {
                return GestureDetector(
                  onTap: () {
                    if (!isBurgerMenuOpen) {
                      innerScaffoldKey.currentState!.openEndDrawer();
                      isBurgerMenuOpen = true;
                      burgerIcon = Icons.menu_open;
                      appBarLeading = infoButton;
                      setState(() {
                        updateSharedPrefs(
                            updateMainColor, updateMenuState, toggleRGBorHSL);
                      });
                    } else {
                      innerScaffoldKey.currentState!.closeEndDrawer();
                      isBurgerMenuOpen = false;
                      burgerIcon = Icons.menu;
                      appBarLeading = null;
                      setState(() {
                        updateSharedPrefs(
                            updateMainColor, updateMenuState, toggleRGBorHSL);
                      });
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Icon(burgerIcon, size: 40, color: Colors.white),
                  ),
                );
              })
            ],
            title: Text(
              "Color Dictionary™",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: "TransformaSans",
                  fontSize: 20),
            ),
            backgroundColor: Colors.grey[700],
          ),
          body: Scaffold(
            key: innerScaffoldKey,
            primary: false,
            endDrawer: Drawer(
              width: MediaQuery.sizeOf(context).width,
              child: Stack(
                children: [
                  VisibilityDetector(
                    key: burgerMenuBGKey,
                    onVisibilityChanged: (VisibilityInfo info) {
                      //print(info.visibleFraction);
                      if (info.visibleFraction < .5) {
                        isBurgerMenuOpen = false;
                        setState(() {
                          burgerIcon = Icons.menu;
                          appBarLeading = null;
                        });
                      } else {
                        isBurgerMenuOpen = true;
                        setState(() {
                          burgerIcon = Icons.menu_open;
                          appBarLeading = infoButton;
                        });
                      }
                      if (!updateRunning)
                        updateSharedPrefs(
                            updateMainColor, updateMenuState, toggleRGBorHSL);
                    },
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      color: Colors.grey,
                    ),
                  ),
                  OverflowBox(
                    maxHeight: double.infinity,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  updateBurgerMenu(true, true);
                                },
                                child: Container(
                                  color: historyBGC,
                                  height: 75,
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Center(
                                        child: Text(
                                      "History",
                                      style: TextStyle(
                                          color: historyTextC,
                                          fontSize: 24,
                                          fontWeight: historyTextFW,
                                          fontFamily: "TransformaSans"),
                                    )),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  updateBurgerMenu(false, true);
                                },
                                child: Container(
                                  color: savedBG,
                                  height: 75,
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Center(
                                        child: Text(
                                      "Saved \nPalettes",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: savedTextC,
                                          fontSize: 24,
                                          fontWeight: savedTextFW,
                                          fontFamily: "TransformaSans"),
                                    )),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Visibility(
                          visible: showHistory,
                          child: Container(
                            height: MediaQuery.sizeOf(context).height - 193,
                            child: SingleChildScrollView(
                              child: Column(
                                verticalDirection: VerticalDirection.up,
                                children: historyContainers,
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: !showHistory,
                          child: Container(
                            height: MediaQuery.sizeOf(context).height - 193,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Visibility(
                                    visible: !showHistory &&
                                        savedPalettes.length == 0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Wrap(children: [
                                        Text(
                                          "You have no saved palettes! Press the heart",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: "TransformaSans"),
                                        ),
                                        Center(
                                            child: Icon(Icons.favorite_border,
                                                color: Colors.black, size: 30)),
                                        Text(
                                          "on any color result to make one!",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: "TransformaSans"),
                                        )
                                      ]),
                                    ),
                                  ),
                                  Column(
                                    children: savedPaletteContainers,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            body: Stack(
              children: [
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Colors.grey[500],
                ),
                OverflowBox(
                  maxHeight: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        width: double.infinity,
                        height: 260,
                        color: Color.fromARGB(255, 212, 212, 212),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: Text(
                                "Search Color:",
                                style: Theme.of(context).textTheme.displayLarge,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Container(
                                    width: 225,
                                    height: 67,
                                    decoration: BoxDecoration(
                                        color: Color.fromARGB(
                                            255,
                                            currentColor.rgb["r"],
                                            currentColor.rgb["g"],
                                            currentColor.rgb["b"]),
                                        border: Border(
                                            left: BorderSide(
                                                color: Colors.black, width: 5),
                                            bottom: BorderSide(
                                                color: Colors.black, width: 5),
                                            right: BorderSide(
                                                color: Colors.white, width: 5),
                                            top: BorderSide(
                                                color: Colors.white,
                                                width: 5))),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
                                          child: Text(
                                            currColorHex,
                                            style: TextStyle(
                                                fontFamily: "TransformaSans",
                                                color: searchContrast,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        ),
                                        Text(
                                          currColorAttributes,
                                          style: TextStyle(
                                              fontFamily: "TransformaSans",
                                              color: searchContrast,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 67,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        pickerColor = currentColor;
                                        showColorPicker = true;
                                        showBlackdrop = true;
                                      });
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                          Colors.grey[800]),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        "CHANGE \nCOLOR",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: "TransformaSans",
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 12.0),
                                    child: Text("Color \nDatabase(s):",
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium
                                            ?.copyWith(
                                                decoration:
                                                    TextDecoration.combine([
                                                  TextDecoration.underline
                                                ]),
                                                decorationThickness: 2,
                                                decorationStyle:
                                                    TextDecorationStyle.solid)),
                                  ),
                                  Container(
                                    width: 200,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 20.0),
                                      child: DropdownButton(
                                        isExpanded: true,
                                        value: "$selectedListKey",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                        menuWidth: 300,
                                        itemHeight: 75,
                                        items: nameLists,
                                        onChanged: (selected) {
                                          setState(() {
                                            selectedListKey = selected;
                                            setState(() {
                                              updateMenuState(false);
                                              showColorPicker = false;
                                              showBlackdrop = false;
                                              updateMainColor(true);
                                              launchHTTP(launchHTTPSetState);
                                            });
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        firstMenuSelected = true;
                                        updateMenuState(resultsReady);
                                        updateSharedPrefs(updateMainColor,
                                            updateMenuState, toggleRGBorHSL);
                                      },
                                      child: Container(
                                        color: paletteButtonBGColor,
                                        height: 51,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: 8,
                                              left: 4,
                                              right: 4,
                                              bottom: 4),
                                          child: Center(
                                              child: Text(
                                            "Palette Colors",
                                            style: TextStyle(
                                                fontFamily: "TransformaSans",
                                                color: paletteButtonTextColor,
                                                fontSize: 22,
                                                fontWeight:
                                                    paletteButtonFontWeight),
                                          )),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        firstMenuSelected = false;
                                        updateMenuState(resultsReady);
                                        updateSharedPrefs(updateMainColor,
                                            updateMenuState, toggleRGBorHSL);
                                      },
                                      child: Container(
                                        color: closestButtonBGColor,
                                        height: 51,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: 8,
                                              left: 4,
                                              right: 4,
                                              bottom: 4),
                                          child: Center(
                                              child: OverflowBox(
                                            maxHeight: double.infinity,
                                            child: Text(
                                              "Other \nClosest Colors",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontFamily: "TransformaSans",
                                                  height: 1,
                                                  color: closestButtonTextColor,
                                                  fontSize: 20,
                                                  fontWeight:
                                                      closestButtonFontWeight),
                                            ),
                                          )),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Stack(children: [
                        Visibility(
                          visible: showPalette,
                          child: Container(
                            height: MediaQuery.sizeOf(context).height - 368,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 30,
                                        bottom: 10,
                                        left: 10,
                                        right: 10),
                                    child: Text("Closest Color:",
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium),
                                  ),
                                  closestContainer,
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 30,
                                        bottom: 10,
                                        left: 10,
                                        right: 10),
                                    child: Text(
                                      "Closest Complimentary:",
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium,
                                    ),
                                  ),
                                  complimentaryContainer,
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 30,
                                        bottom: 10,
                                        left: 10,
                                        right: 10),
                                    child: Text(
                                      "Closest Triadic Counterparts:",
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium,
                                    ),
                                  ),
                                  triadicContainer1,
                                  Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: triadicContainer2,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 30,
                                        bottom: 10,
                                        left: 10,
                                        right: 10),
                                    child: Text(
                                      "Closest Tetradic Counterparts:",
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium,
                                    ),
                                  ),
                                  tetradicContainer1,
                                  Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: tetradicContainer2,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: tetradicContainer3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                            visible: showLoading,
                            child: Container(
                              height: MediaQuery.sizeOf(context).height - 368,
                              child: Image(
                                  image: AssetImage("assets/gifs/Loading.gif")),
                            ))
                      ]),
                      Stack(children: [
                        Visibility(
                          visible: showClosest,
                          child: Container(
                            height: MediaQuery.sizeOf(context).height - 368,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            "Sort By:",
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium,
                                          ),
                                          Container(
                                            width: 150,
                                            height: 50,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10.0, top: 5),
                                              child: DropdownButton(
                                                isExpanded: true,
                                                value: selectedSortMethod,
                                                style: TextStyle(
                                                    fontFamily:
                                                        "TransformaSans",
                                                    height: 1.1,
                                                    color: Colors.black,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                menuWidth: 200,
                                                itemHeight: 50,
                                                items: sortMethods,
                                                onChanged: (selected) {
                                                  setState(() {
                                                    selectedSortMethod =
                                                        selected;
                                                    closestLoading = true;
                                                    updateMenuState(
                                                        resultsReady);
                                                    shownClosestResults =
                                                        updateClosestResults(
                                                            context,
                                                            updateMenuState,
                                                            updateMainColor,
                                                            closestResultSetState,
                                                            launchHTTPSetState,
                                                            updateSavedSetState,
                                                            runAddSavedSetState);
                                                    updateSharedPrefs(
                                                        updateMainColor,
                                                        updateMenuState,
                                                        toggleRGBorHSL);
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: ToggleButtons(
                                              children: ascendingDescending,
                                              isSelected: orderButtonBools,
                                              borderWidth: 3,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              fillColor: Colors.grey,
                                              onPressed: (int index) {
                                                setState(() {
                                                  orderButtonBools[index] =
                                                      true;
                                                  if (index == 1)
                                                    orderButtonBools[0] = false;
                                                  else
                                                    orderButtonBools[1] = false;

                                                  closestLoading = true;
                                                  updateMenuState(resultsReady);
                                                  shownClosestResults =
                                                      updateClosestResults(
                                                          context,
                                                          updateMenuState,
                                                          updateMainColor,
                                                          closestResultSetState,
                                                          launchHTTPSetState,
                                                          updateSavedSetState,
                                                          runAddSavedSetState);
                                                  updateSharedPrefs(
                                                      updateMainColor,
                                                      updateMenuState,
                                                      toggleRGBorHSL);
                                                });
                                              },
                                            ),
                                          )
                                        ]),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(right: 12.0),
                                          child: Text("Showing",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w800)),
                                        ),
                                        Container(
                                          width: 100,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Padding(
                                            padding:
                                                EdgeInsets.only(left: 20.0),
                                            child: DropdownButton(
                                              isExpanded: true,
                                              value: "$selectedClosestAmt",
                                              style: TextStyle(
                                                  fontFamily: "TransformaSans",
                                                  color: Colors.black,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold),
                                              menuWidth: 100,
                                              itemHeight: 50,
                                              items: closestResultAmts,
                                              onChanged: (selected) {
                                                setState(() {
                                                  selectedClosestAmt = selected;
                                                  closestLoading = true;
                                                  updateSharedPrefs(
                                                      updateMainColor,
                                                      updateMenuState,
                                                      toggleRGBorHSL);
                                                  updateMenuState(resultsReady);
                                                  shownClosestResults =
                                                      updateClosestResults(
                                                          context,
                                                          updateMenuState,
                                                          updateMainColor,
                                                          closestResultSetState,
                                                          launchHTTPSetState,
                                                          updateSavedSetState,
                                                          runAddSavedSetState);
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 12.0),
                                          child: Text("Results:",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w800)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(children: shownClosestResults)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ])
                    ],
                  ),
                ),
                Visibility(
                  visible: showBlackdrop,
                  child: Stack(children: [
                    Container(
                      height: MediaQuery.sizeOf(context).height,
                      width: MediaQuery.sizeOf(context).width,
                      color: Color.fromARGB(128, 0, 0, 0),
                    ),
                  ]),
                ),
                Visibility(
                  visible: showColorPicker,
                  child: OverflowBox(
                    maxHeight: double.infinity,
                    child: Stack(children: [
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 370,
                          height: 700,
                          decoration: BoxDecoration(
                              color: Color.fromARGB(196, 255, 255, 255),
                              border: Border.all(
                                  color: Color.fromARGB(
                                      255,
                                      pickerColor.rgb["r"],
                                      pickerColor.rgb["g"],
                                      pickerColor.rgb["b"]),
                                  width: 20),
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.only(top: 40.0),
                          child: Container(
                            width: 300,
                            height: 660,
                            color: Colors.transparent,
                            child: OverflowBox(
                              maxHeight: double.infinity,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              pickerColor = currentColor;
                                              showColorPicker = false;
                                              showBlackdrop = false;
                                            });
                                          },
                                          child: Icon(
                                            Icons.close,
                                            size: 80,
                                            color: Colors.black,
                                          )),
                                      GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              updateMenuState(false);
                                              showColorPicker = false;
                                              showBlackdrop = false;
                                              updateMainColor(false);
                                              launchHTTP(
                                                launchHTTPSetState,
                                              );
                                            });
                                          },
                                          child: Icon(
                                            Icons.search,
                                            size: 80,
                                            color: Colors.black,
                                          ))
                                    ],
                                  ),
                                  HueRingPicker(
                                    pickerColor: Color.fromARGB(
                                        255,
                                        pickerColor.rgb["r"],
                                        pickerColor.rgb["g"],
                                        pickerColor.rgb["b"]),
                                    onColorChanged: changePickerColor,
                                    displayThumbColor: true,
                                    enableAlpha: false,
                                  ),
                                  SlidePicker(
                                    pickerColor: Color.fromARGB(
                                        255,
                                        pickerColor.rgb["r"],
                                        pickerColor.rgb["g"],
                                        pickerColor.rgb["b"]),
                                    onColorChanged: changePickerColor,
                                    enableAlpha: false,
                                    sliderSize: Size(300, 50),
                                    showIndicator: false,
                                    sliderTextStyle: Theme.of(context)
                                        .textTheme
                                        .displaySmall,
                                    colorModel: currColorModel,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          )),
    );
  }
  // END build
}
// END MyProject State Widget
