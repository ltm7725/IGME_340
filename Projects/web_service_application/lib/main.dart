import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_color_utils/flutter_color_utils.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
/// @auther: L Mavroudakis
/// @version: 1.0.0
/// @since: 2024-11-03
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
            textTheme: TextTheme(
                displaySmall:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                displayLarge:
                    TextStyle(fontWeight: FontWeight.w400, fontSize: 35),
                displayMedium:
                    TextStyle(fontWeight: FontWeight.w500, fontSize: 27),
                bodyMedium:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 22))));
  }
}
// END main

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
  late SharedPreferences myPrefs;

  // Color currently selected within the color picker
  Color pickerColor = Color(0xFFB76E79);
  // Color currently being searched
  Color currentColor = Color(0xFFB76E79);
  // Whether the color picker widget is currently visible
  bool showColorPicker = false;
  // Variable to hold RGB/HSL color attributes for currently-searched color (at top Container)
  String currColorAttributes = "";
  // Indicates whether RGB or HSL color attributes/controls are being displayed in areas where only one ever is
  bool useRGB = true;
  // Indicates whether RGB or HSL color controls hould be showing in the color picker (only one ever is shown)
  ColorModel currColorModel = ColorModel.rgb;
  // Text within button in the AppBar to switch between RGB/HSL attributes where only one is ever shown
  String colorModelText = "Swap to HSL";
  // Color of best contrast for text against the main-searched color (at top Container); black or white
  Color searchContrast = Colors.black;

  // Font weights for "Palette Colors"/"Other Closest Colors" menu buttons, to be updated depending on which is active
  FontWeight paletteButtonFontWeight = FontWeight.bold;
  FontWeight closestButtonFontWeight = FontWeight.normal;

  // Text/background colors for "Palette Colors"/"Other Closest Colors" menu buttons, to be updated depending on which is active
  Color activeButtonTextColor = Colors.white;
  Color activeButtonBGColor = Colors.black;
  Color inactiveButtonTextColor = Colors.black;
  Color inactiveButtonBGColor = Colors.white;
  Color paletteButtonTextColor = Colors.white;
  Color paletteButtonBGColor = Colors.black;
  Color closestButtonTextColor = Colors.black;
  Color closestButtonBGColor = Colors.white;

  // List of ALL colors in a given (user-defined) color database
  var fullColorList = [];
  // List of a certain number of colors closest to the search in a given (user-defined) color database
  var allClosestColors = [];
  // Containers with padding for all colors to be shown; derived from allClosestColors in BuildClosestResults()
  List<Padding> shownClosestResults = [];

  // Are SOME results ready? (Show at least "Palette Colors" results after running updateMenuState)
  bool resultsReady = false;
  // Show loading spinner instead of "Palette Colors" menu?
  bool showLoading = true;
  // Direct variable to show/hide "Palette Colors" menu
  bool showPalette = false;
  // Direct variable to show/hide "Other Closest Colors" menu
  bool showClosest = false;
  // SHOULD "Other Closest Colors" be loading? (does other logic on top of setting showClosest in updateMenuState)
  bool closestLoading = true;
  // Is "Palette Colors" menu selected?
  bool firstMenuSelected = true;
  // Should the transparent-black background on top of the main menus, behind other widgets/dialogs, be visible?
  bool showBlackdrop = false;

  // Selected keys for DropdownButtons
  // Selected color database
  String? selectedListKey = "default";
  // Selected amount of results to show in "Other Closest Colors" menu
  String? selectedClosestAmt = "20";
  // Method by which to sort "Other Closest Colors" results (reference sortMethods)
  int? selectedSortMethod = 1;

  // Collected hex values for colors in "Palette Colors" menu, to be displayed in their Containers
  String currColorHex = "";
  String complColorHex = "";
  String triadColorHex1 = "";
  String triadColorHex2 = "";
  String tetradColorHex1 = "";
  String tetradColorHex2 = "";
  String tetradColorHex3 = "";

  // Data maps for all colors in the "Palette Colors" menu, to be read from/parsed
  Map closestColor = Map();
  Map complimentaryColor = Map();
  Map triadicColor1 = Map();
  Map triadicColor2 = Map();
  Map tetradicColor1 = Map();
  Map tetradicColor2 = Map();
  Map tetradicColor3 = Map();

  // HSL values for all colors in the "Palette Colors" menu, to be read from to create attribute Strings to display
  HSLColor currHSL = HSLColor.fromColor(Color(0xFFB76E79));
  HSLColor complHSL = HSLColor.fromColor(Color(0xFFB76E79));
  HSLColor triadHSL1 = HSLColor.fromColor(Color(0xFFB76E79));
  HSLColor triadHSL2 = HSLColor.fromColor(Color(0xFFB76E79));
  HSLColor tetradHSL1 = HSLColor.fromColor(Color(0xFFB76E79));
  HSLColor tetradHSL2 = HSLColor.fromColor(Color(0xFFB76E79));
  HSLColor tetradHSL3 = HSLColor.fromColor(Color(0xFFB76E79));

  // Containers displaying information and search buttons for all colors meant to be in "Palette Colors" menu
  Container closestContainer = Container();
  Container complimentaryContainer = Container();
  Container triadicContainer1 = Container();
  Container triadicContainer2 = Container();
  Container tetradicContainer1 = Container();
  Container tetradicContainer2 = Container();
  Container tetradicContainer3 = Container();

  // If an error is hit with HTTP request, references this for placeholder data
  final Map colorJsonTemplate = {
    "name": "Test",
    "hex": "#aaaaaa",
    "rgb": {"r": 1, "g": 1, "b": 1},
    "hsl": {"h": 1, "s": 1.1, "l": 1.1},
    "lab": {"l": 1.1, "a": -1.1, "b": -1.1},
    "luminance": 1,
    "luminanceWCAG": 1.1,
    "bestContrast": "black",
    "swatchImg": {
      "svgNamed": "/v1/swatch/?color=1ecbe1&name=Caribbean%20Blue",
      "svg": "/v1/swatch/?color=1ecbe1"
    },
    "requestedHex": "#ffffff",
    "distance": 0
  };

  // DropdownButton options for Color Database(s) in top search controls
  final nameLists = [
    DropdownMenuItem(
        value: "default",
        child: Text("Handpicked Color Names (ALL Databases)")),
    DropdownMenuItem(value: "basic", child: Text("Basic")),
    DropdownMenuItem(value: "html", child: Text("HTML Colors")),
    DropdownMenuItem(
        value: "japaneseTraditional",
        child: Text("Traditional Colors of Japan")),
    DropdownMenuItem(value: "leCorbusier", child: Text("Le Corbusier")),
    DropdownMenuItem(
        value: "nbsIscc", child: Text("The Universal Color Language")),
    DropdownMenuItem(value: "ntc", child: Text("NTC.js")),
    DropdownMenuItem(value: "osxcrayons", child: Text("OS X Crayons")),
    DropdownMenuItem(value: "ral", child: Text("RAL Color")),
    DropdownMenuItem(
        value: "ridgway",
        child: Text("Robert Ridgway's Color Standards and Color Nomenclature")),
    DropdownMenuItem(
        value: "sanzoWadaI",
        child: Text("Wada Sanzō Japanese Color Dictionary Volume I")),
    DropdownMenuItem(value: "thesaurus", child: Text("The Color Thesaurus")),
    DropdownMenuItem(
        value: "werner", child: Text("Werner's Nomenclature of Colours")),
    DropdownMenuItem(
        value: "windows", child: Text("Microsoft Windows Color Names")),
    DropdownMenuItem(value: "wikipedia", child: Text("Wikipedia Color Names")),
    DropdownMenuItem(value: "french", child: Text("French Colors")),
    DropdownMenuItem(value: "spanish", child: Text("Spanish Colors")),
    DropdownMenuItem(value: "german", child: Text("German Colors")),
    DropdownMenuItem(value: "x11", child: Text("X11 Color Names")),
    DropdownMenuItem(value: "xkcd", child: Text("XKCD Colors")),
    DropdownMenuItem(value: "risograph", child: Text("Risograph Colors")),
    DropdownMenuItem(
        value: "chineseTraditional",
        child: Text("Traditional Colors of China")),
    DropdownMenuItem(value: "bestOf", child: Text("Best of Color Names")),
    DropdownMenuItem(value: "short", child: Text("Short Color Names")),
  ];

  // DropdownButton options for "Showing _ Results:" in "Other Closest Colors" menu
  final closestResultAmts = [
    DropdownMenuItem(value: "5", child: Text("5")),
    DropdownMenuItem(value: "10", child: Text("10")),
    DropdownMenuItem(value: "20", child: Text("20")),
    DropdownMenuItem(value: "50", child: Text("50")),
    DropdownMenuItem(value: "75", child: Text("75")),
    DropdownMenuItem(value: "100", child: Text("100")),
    DropdownMenuItem(value: "200", child: Text("200")),
    DropdownMenuItem(value: "500", child: Text("500")),
  ];

  // DropdownButton options for "Sort By:" in "Other Closest Colors" menu
  final sortMethods = [
    DropdownMenuItem(value: 1, child: Text("Closeness only")),
    DropdownMenuItem(value: 2, child: Text("Alphabetical")),
    DropdownMenuItem(value: 3, child: Text("Hue")),
    DropdownMenuItem(value: 4, child: Text("Saturation")),
    DropdownMenuItem(value: 5, child: Text("Lightness")),
    DropdownMenuItem(value: 6, child: Text("Red")),
    DropdownMenuItem(value: 7, child: Text("Green")),
    DropdownMenuItem(value: 8, child: Text("Blue")),
  ];

  // List of Icons containing content to go into ToggleButtons for ascending/descending sort in "Other Closest Colors" menu
  final ascendingDescending = [
    Icon(Icons.keyboard_double_arrow_up, color: Colors.black, size: 50),
    Icon(Icons.keyboard_double_arrow_down, color: Colors.black, size: 50)
  ];

  // List of bools for whether ascending or descending button in "Other Closest Colors" is toggled
  var orderButtonBools = [false, true];

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
    setState(() => pickerColor = color);
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
            "HSL(${currHSL.hue.toStringAsFixed(0)}°,${(currHSL.saturation * 100).toStringAsFixed(0)}%,${(currHSL.lightness * 100).toStringAsFixed(0)}%)";
        currColorModel = ColorModel.hsl;
        colorModelText = "Swap to RGB";
      } else {
        useRGB = true;
        currColorAttributes =
            "RGB(${currentColor.red},${currentColor.green},${currentColor.blue})";
        currColorModel = ColorModel.rgb;
        colorModelText = "Swap to HSL";
      }
      updateSharedPrefs();
      if (!init) updatePaletteResults();
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
      if (!useInputAttributes) currentColor = pickerColor;
      currHSL = HSLColor.fromColor(currentColor);
      if (useRGB)
        currColorAttributes =
            "RGB(${currentColor.red},${currentColor.green},${currentColor.blue})";
      else
        currColorAttributes =
            "HSL(${currHSL.hue.toStringAsFixed(0)}°,${(currHSL.saturation * 100).toStringAsFixed(0)}%,${(currHSL.lightness * 100).toStringAsFixed(0)}%)";
      currColorHex = "#${colorToHex(currentColor).substring(2).toLowerCase()}";
    });
  }

/**
 * Preliminary contrast analyzer for top-searched color, setting the text above a color
 * to the best ascertained contrast (black or white) based on lightness.
 *
 * @author L Mavroudakis
 * @version 1.0.0
 */
  void updateSearchContrast() async {
    //setState(() {
    //  if (currHSL.lightness * 100 <= 50)
    //    searchContrast = Colors.white;
    //  else
    //     searchContrast = Colors.black;
    //});

    String link =
        "https://api.color.pizza/v1/?values=${colorToHex(currentColor).substring(2).toLowerCase()}&list=default";

    var response = await http.get(Uri.parse(link));

    if (response.statusCode == 200) {
      setState(() {
        var data = jsonDecode(response.body);

        if (data["colors"][0]["bestContrast"] == "black")
          searchContrast = Colors.black;
        else
          searchContrast = Colors.white;
      });
    } else {
      print("ERROR: $response.statusCode");
    }
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
  Color parseBestContrast(String color, bool? inverse) {
    if (color == "black" && inverse == true) return Colors.white;
    if (color == "white" && inverse == true) return Colors.black;
    if (color == "black") return Colors.black;
    if (color == "white") return Colors.white;
    return Colors.red;
  }

/**
 * Builds a Container to be placed in the "Palette Colors" menu,
 * with all the color attributes of the given data and with
 * a specific size to the Container.
 *
 * @author L Mavroudakis
 * @version 1.0.0
 * @param theHeight - Intended Container height
 * @param theWidth - Intended Container width
 * @param data - parsed JSON data for color to create Container based on
 */
  Container buildPaletteResult(double theHeight, double theWidth, Map data) {
    Color contrast;
    if (data["bestContrast"] == "black")
      contrast = Colors.black;
    else
      contrast = Colors.white;

    return Container(
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
            "${data["name"]} \n${data["hex"]} \n${buildColorAttributes(data)}",
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: contrast),
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 75,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(15)),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    updateMenuState(false);
                    currentColor = Color.fromARGB(255, data["rgb"]["r"],
                        data["rgb"]["g"], data["rgb"]["b"]);
                    updateMainColor(true);
                    launchHTTP();
                  });
                },
                child: Icon(
                  Icons.search,
                  size: 50,
                  color: contrast,
                ),
              ),
              Container(
                width: 75,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
              ),

              ///GestureDetector(
              ///  onTap: () {},
              ///  child: Icon(Icons.star_border, size: 50, color: contrast),
              ///)
            ],
          )
        ],
      ),
    );
  }

/**
 * Builds a Container to be placed in the "Other Closest Colors" menu,
 * with all the color attributes of the given data.
 *
 * @author L Mavroudakis
 * @version 1.0.0
 * @param data - parsed JSON data for color to create Container based on
 */
  Padding buildClosestResult(Map data) {
    Color contrast = parseBestContrast(data["bestContrast"], false);
    Color inverseContrast = parseBestContrast(data["bestContrast"], true);
    Color contrastTransparent;
    Color inverseContrastTransparent;
    Color theColor = HexColor(data["hex"]);

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
                width: MediaQuery.sizeOf(context).width - 200,
                child: Text(
                  "\"${data["name"]}\"",
                  softWrap: true,
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(color: contrast),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      currentColor = Color.fromARGB(
                                          255,
                                          data["rgb"]["r"],
                                          data["rgb"]["g"],
                                          data["rgb"]["b"]);
                                      updateMainColor(true);
                                      launchHTTP();
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
                                  "\"${data["name"]}\"",
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
                                            height: 272,
                                            width: 272,
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
                                              height: 252,
                                              width: 252,
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
                                                      width: 100,
                                                      height: 100,
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
                                                      width: 100,
                                                      height: 100,
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
                                                      "${data["hex"]}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .displayMedium
                                                          ?.copyWith(
                                                              color:
                                                                  inverseContrast),
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
                                                                    "${data["hex"]}"));
                                                      },
                                                      child: Text("Copy",
                                                          style: Theme.of(
                                                                  context)
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
                                                      "RGB( ${data["rgb"]["r"]}, ${data["rgb"]["g"]}, ${data["rgb"]["b"]} )",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .displayMedium
                                                          ?.copyWith(
                                                              color:
                                                                  inverseContrast),
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
                                                                    "RGB( ${data["rgb"]["r"]}, ${data["rgb"]["g"]}, ${data["rgb"]["b"]} )"));
                                                      },
                                                      child: Text("Copy",
                                                          style: Theme.of(
                                                                  context)
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
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 8.0),
                                                      child: Text(
                                                        "HSL( ${data["hsl"]["h"]}, ${data["hsl"]["s"]}, ${data["hsl"]["l"]} )",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .displayMedium
                                                            ?.copyWith(
                                                                color:
                                                                    inverseContrast),
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
                                                                    "HSL( ${data["hsl"]["h"]}, ${data["hsl"]["s"]}, ${data["hsl"]["l"]} )"));
                                                      },
                                                      child: Text("Copy",
                                                          style: Theme.of(
                                                                  context)
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
                      setState(() {
                        updateMenuState(false);
                        currentColor = theColor;
                        updateMainColor(true);
                        launchHTTP();
                      });
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
  String buildColorAttributes(Map data) {
    if (useRGB)
      return "RGB(${data["rgb"]["r"]},${data["rgb"]["g"]},${data["rgb"]["b"]})";
    else
      return "HSL(${data["hsl"]["h"].toStringAsFixed(0)}°,${data["hsl"]["s"].toStringAsFixed(0)}%,${data["hsl"]["l"].toStringAsFixed(0)}%)";
  }

/**
 * Initial search HTTP request, searching based on several queries placed into the link, 
 * getting info for the main closest color to the search query in the given list,
 * launching other requests and other update functions, and setting many reference variables
 * 
 * @author L Mavroudakis
 * @version 1.0.0
 */
  void launchHTTP() async {
    String link =
        "https://api.color.pizza/v1/?values=${colorToHex(currentColor).substring(2).toLowerCase()}&list=$selectedListKey";

    var response = await http.get(Uri.parse(link));

    if (response.statusCode == 200) {
      setState(() {
        closestColor = jsonDecode(response.body)["colors"][0];
        print(closestColor);

        complHSL = HSLColor.fromAHSL(1, (currHSL.hue + 180) % 360,
            currHSL.saturation, currHSL.lightness);
        triadHSL1 = HSLColor.fromAHSL(1, (currHSL.hue + 120) % 360,
            currHSL.saturation, currHSL.lightness);
        triadHSL2 = HSLColor.fromAHSL(1, (currHSL.hue + 240) % 360,
            currHSL.saturation, currHSL.lightness);
        tetradHSL1 = HSLColor.fromAHSL(
            1, (currHSL.hue + 90) % 360, currHSL.saturation, currHSL.lightness);
        tetradHSL2 = HSLColor.fromAHSL(1, (currHSL.hue + 180) % 360,
            currHSL.saturation, currHSL.lightness);
        tetradHSL3 = HSLColor.fromAHSL(1, (currHSL.hue + 270) % 360,
            currHSL.saturation, currHSL.lightness);
        complColorHex = colorToHex(complHSL.toColor()).substring(2);
        triadColorHex1 = colorToHex(triadHSL1.toColor()).substring(2);
        triadColorHex2 = colorToHex(triadHSL2.toColor()).substring(2);
        tetradColorHex1 = colorToHex(tetradHSL1.toColor()).substring(2);
        tetradColorHex2 = colorToHex(tetradHSL2.toColor()).substring(2);
        tetradColorHex3 = colorToHex(tetradHSL3.toColor()).substring(2);

        secondaryHTTP();
      });
    } else {
      if (response.statusCode != 200) print("ERROR: ${response.statusCode}");
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
  void secondaryHTTP() async {
    String link =
        "https://api.color.pizza/v1/?values=${complColorHex.toLowerCase()},${triadColorHex1.toLowerCase()},${triadColorHex2.toLowerCase()},${tetradColorHex1.toLowerCase()},${tetradColorHex2.toLowerCase()},${tetradColorHex3.toLowerCase()}&list=$selectedListKey";

    var response = await http.get(Uri.parse(link));

    if (response.statusCode == 200) {
      Map data = jsonDecode(response.body);
      complimentaryColor = data["colors"][0];
      triadicColor1 = data["colors"][1];
      triadicColor2 = data["colors"][2];
      tetradicColor1 = data["colors"][3];
      tetradicColor2 = data["colors"][4];
      tetradicColor3 = data["colors"][5];
      setState(await () {
        updateSearchContrast();
        updatePaletteResults();
      });

      updateMenuState(true);
      tertiaryHTTP();
    } else {
      print("ERROR: ${response.statusCode}");
    }
  }

/**
 * Collects information for all colors within a given color database, calling
 * updates to display components as well as analysis for the data collected.
 *
 * @author L Mavroudakis
 * @version 1.0.0
 */
  void tertiaryHTTP() async {
    String link = "https://color-names.herokuapp.com/v1/?list=$selectedListKey";

    var response = await http.get(Uri.parse(link));

    if (response.statusCode == 200) {
      fullColorList = jsonDecode(response.body)["colors"];
      setState(await () {
        shownClosestResults = updateClosestResults();
        closestLoading = false;
      });
      updateMenuState(true);
    } else {
      print("ERROR: ${response.statusCode}");
    }

    updateSharedPrefs();
  }

/**
 * Calls the building for all color containers in the "Palette Colors" menu.
 *
 * @author L Mavroudakis
 * @version 1.0.0
 */
  void updatePaletteResults() {
    closestContainer = buildPaletteResult(200, 300, closestColor);
    complimentaryContainer = buildPaletteResult(200, 300, complimentaryColor);
    triadicContainer1 = buildPaletteResult(200, 300, triadicColor1);
    triadicContainer2 = buildPaletteResult(200, 300, triadicColor2);
    tetradicContainer1 = buildPaletteResult(200, 300, tetradicColor1);
    tetradicContainer2 = buildPaletteResult(200, 300, tetradicColor2);
    tetradicContainer3 = buildPaletteResult(200, 300, tetradicColor3);
  }

/**
 * Calls analysis for all colors in a list based on search/sort queries,
 * and builds all containers to be displayed in "Other Closest Colors" menu,
 * returned to be placed into the Scaffold structure.
 *
 * @author L Mavroudakis
 * @version 1.0.0
 */
  List<Padding> updateClosestResults() {
    List<Padding> list = [];

    analyzeClosestColors();

    String t = selectedClosestAmt.toString();

    if (selectedClosestAmt != null && selectedSortMethod != null) {
      for (int i = 0; i < int.parse(t); i++) {
        if (i >= allClosestColors.length - 1) break;
        list.add(buildClosestResult(allClosestColors[i]));
      }
    }

    closestLoading = false;
    updateMenuState(resultsReady);
    return list;
  }

/**
 * Analyzes and sorts all entries in a given color database based on given queries/options.
 *
 * @author L Mavroudakis
 * @version 1.0.0
 */
  void analyzeClosestColors() {
    allClosestColors = fullColorList;
    allClosestColors.sort((a, b) => currentColor
        .match(HexColor(a["hex"]))
        .compareTo(currentColor.match(HexColor(b["hex"]))));

    allClosestColors = allClosestColors.reversed.toList();

    List someClosestColors = [];

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
        allClosestColors.sort((a, b) => a["name"].compareTo(b["name"]));
        if (orderButtonBools[1])
          allClosestColors = allClosestColors.reversed.toList();
        break;
      case 3:
        allClosestColors.sort((a, b) => a["hsl"]["h"].compareTo(b["hsl"]["h"]));
        if (orderButtonBools[1])
          allClosestColors = allClosestColors.reversed.toList();
        break;
      case 4:
        allClosestColors.sort((a, b) => a["hsl"]["s"].compareTo(b["hsl"]["s"]));
        if (orderButtonBools[1])
          allClosestColors = allClosestColors.reversed.toList();
        break;
      case 5:
        allClosestColors.sort((a, b) => a["hsl"]["l"].compareTo(b["hsl"]["l"]));
        if (orderButtonBools[1])
          allClosestColors = allClosestColors.reversed.toList();
        break;
      case 6:
        allClosestColors.sort((a, b) => a["rgb"]["r"].compareTo(b["rgb"]["r"]));
        if (orderButtonBools[1])
          allClosestColors = allClosestColors.reversed.toList();
        break;
      case 7:
        allClosestColors.sort((a, b) => a["rgb"]["g"].compareTo(b["rgb"]["g"]));
        if (orderButtonBools[1])
          allClosestColors = allClosestColors.reversed.toList();
        break;
      case 8:
        allClosestColors.sort((a, b) => a["rgb"]["b"].compareTo(b["rgb"]["b"]));
        if (orderButtonBools[1])
          allClosestColors = allClosestColors.reversed.toList();
        break;
    }

    //print("TEST ${allClosestColors[1]}");
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

      if (showPalette) {
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
    });
  }

/**
 * Updates SharedPreferences whenever an option or menu displayed is changed,
 * so that when the app restarts it can come directly back to where the user left off.
 *
 * @author L Mavroudakis
 * @version 1.0.0
 */
  void updateSharedPrefs() {
    myPrefs.setString("resultsNum", selectedClosestAmt.toString());
    myPrefs.setString("lastColor", colorToHex(currentColor));
    myPrefs.setString("colorList", selectedListKey.toString());
    myPrefs.setString("rgbOrHsl", useRGB.toString());
    myPrefs.setString("menu", firstMenuSelected.toString());
    myPrefs.setString("sort", selectedSortMethod.toString());
    myPrefs.setString("ascending", orderButtonBools[0].toString());
  }

/**s
 * Updates variables and calls functions when the app restarts that allows it to 
 * come directly back to where the user left off if used before. If not, uses
 * default values/options.
 *
 * @author L Mavroudakis
 * @version 1.0.0
 */
  void restoreSharedPrefs() {
    if (myPrefs.getString("resultsNum") != null) {
      selectedClosestAmt = myPrefs.getString("resultsNum").toString();
    }
    if (myPrefs.getString("lastColor") != null) {
      currentColor = HexColor(myPrefs.getString("lastColor").toString());
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
  }

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
    //await myPrefs.clear();
    restoreSharedPrefs();
    updateMenuState(false);
    launchHTTP();
  }
  
  /// Build function with most components for the app
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: ElevatedButton(
                    onPressed: () {
                      toggleRGBorHSL(false);
                      updateSharedPrefs();
                    },
                    child: Text(colorModelText)),
              ),
              GestureDetector(
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
                                  padding: const EdgeInsets.only(
                                      left: 30.0, top: 30.0),
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
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 20.0, left: 20, right: 20),
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

*HOW I MET REQUIREMENTS*

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
                child: Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Icon(Icons.info, size: 40, color: Colors.white),
                ),
              )
            ],
            title: Text(
              "Color Dictionary™",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.grey[700],
          ),
          body: Stack(
            children: [
              Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.grey,
              ),
              Column(
                children: [
                  Container(
                    alignment: Alignment.topCenter,
                    width: double.infinity,
                    height: 260,
                    color: Color.fromARGB(255, 212, 212, 212),
                    child: Column(
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
                                height: 50,
                                decoration: BoxDecoration(
                                    color: currentColor,
                                    border: Border(
                                        left: BorderSide(
                                            color: Colors.black, width: 5),
                                        bottom: BorderSide(
                                            color: Colors.black, width: 5),
                                        right: BorderSide(
                                            color: Colors.white, width: 5),
                                        top: BorderSide(
                                            color: Colors.white, width: 5))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 10.0),
                                      child: Text(
                                        currColorHex,
                                        style: TextStyle(
                                            color: searchContrast,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 10.0),
                                      child: Text(
                                        currColorAttributes,
                                        style: TextStyle(
                                            color: searchContrast,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  pickerColor = currentColor;
                                  showColorPicker = true;
                                  showBlackdrop = true;
                                });
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(Colors.grey[800]),
                              ),
                              child: Text(
                                "CHANGE COLOR",
                                style: TextStyle(color: Colors.white),
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
                                child: Text(
                                  "Color \nDatabase(s):",
                                  style:
                                      Theme.of(context).textTheme.displayMedium,
                                ),
                              ),
                              Container(
                                width: 200,
                                color: Colors.white,
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
                                          launchHTTP();
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    firstMenuSelected = true;
                                    updateMenuState(resultsReady);
                                    updateSharedPrefs();
                                  },
                                  child: Container(
                                    color: paletteButtonBGColor,
                                    height: 56,
                                    child: Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Center(
                                          child: Text(
                                        "Palette Colors",
                                        style: TextStyle(
                                            color: paletteButtonTextColor,
                                            fontSize: 18,
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
                                    updateSharedPrefs();
                                  },
                                  child: Container(
                                    color: closestButtonBGColor,
                                    height: 56,
                                    child: Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Center(
                                          child: Text(
                                        "Other Closest Colors",
                                        style: TextStyle(
                                            color: closestButtonTextColor,
                                            fontSize: 18,
                                            fontWeight:
                                                closestButtonFontWeight),
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
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  "Closest Color:",
                                  style:
                                      Theme.of(context).textTheme.displayMedium,
                                ),
                              ),
                              closestContainer,
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  "Closest Complimentary:",
                                  style:
                                      Theme.of(context).textTheme.displayMedium,
                                ),
                              ),
                              complimentaryContainer,
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  "Closest Triadic Counterparts:",
                                  style:
                                      Theme.of(context).textTheme.displayMedium,
                                ),
                              ),
                              triadicContainer1,
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: triadicContainer2,
                              ),
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  "Closest Tetradic Counterparts:",
                                  style:
                                      Theme.of(context).textTheme.displayMedium,
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
                        child: Image.network(
                            "https://www.appseconnect.com/wp-content/uploads/2017/08/loader.gif"))
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
                                        color: Colors.white,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: DropdownButton(
                                            isExpanded: true,
                                            value: selectedSortMethod,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                            menuWidth: 200,
                                            itemHeight: 50,
                                            items: sortMethods,
                                            onChanged: (selected) {
                                              setState(() {
                                                selectedSortMethod = selected;
                                                closestLoading = true;
                                                updateMenuState(resultsReady);
                                                shownClosestResults =
                                                    updateClosestResults();
                                                updateSharedPrefs();
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      ToggleButtons(
                                        children: ascendingDescending,
                                        isSelected: orderButtonBools,
                                        borderWidth: 3,
                                        borderRadius: BorderRadius.circular(20),
                                        fillColor: Colors.white,
                                        borderColor: Colors.white,
                                        onPressed: (int index) {
                                          setState(() {
                                            orderButtonBools[index] = true;
                                            if (index == 1)
                                              orderButtonBools[0] = false;
                                            else
                                              orderButtonBools[1] = false;

                                            closestLoading = true;
                                            updateMenuState(resultsReady);
                                            shownClosestResults =
                                                updateClosestResults();
                                            updateSharedPrefs();
                                          });
                                        },
                                      )
                                    ]),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 12.0),
                                      child: Text(
                                        "Showing",
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium,
                                      ),
                                    ),
                                    Container(
                                      width: 100,
                                      color: Colors.white,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 20.0),
                                        child: DropdownButton(
                                          isExpanded: true,
                                          value: "$selectedClosestAmt",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                          menuWidth: 100,
                                          itemHeight: 50,
                                          items: closestResultAmts,
                                          onChanged: (selected) {
                                            setState(() {
                                              selectedClosestAmt = selected;
                                              closestLoading = true;
                                              updateSharedPrefs();
                                              updateMenuState(resultsReady);
                                              shownClosestResults =
                                                  updateClosestResults();
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 12.0),
                                      child: Text(
                                        "Results:",
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium,
                                      ),
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
                            border: Border.all(color: pickerColor, width: 20),
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
                                            launchHTTP();
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
                                  pickerColor: pickerColor,
                                  onColorChanged: changePickerColor,
                                  displayThumbColor: true,
                                  enableAlpha: false,
                                ),
                                SlidePicker(
                                  pickerColor: pickerColor,
                                  onColorChanged: changePickerColor,
                                  enableAlpha: false,
                                  sliderSize: Size(300, 50),
                                  showIndicator: false,
                                  sliderTextStyle:
                                      Theme.of(context).textTheme.displaySmall,
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
          )),
    );
  }
  // END build
}
// END MyProject State Widget
