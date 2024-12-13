/** 
 * A color result obtained from the API
*/
class ColorResult {
  String name = "";
  String hex = "";
  Map rgb = {"r": 0, "g": 0, "b": 0};
  Map hsl = {"h": 0, "s": 0, "l": 0};
  String bestContrast = "";

  void setFromData(var data, int protocol) {
    if (protocol == 1) {
      this.name = data.name;
      this.hex = data.hex;
      this.rgb = data.rgb;
      this.hsl = data.hsl;
      this.bestContrast = data.bestContrast;
    } else if (protocol == 2) {
      this.name = data["name"]; 
      this.hex = data["hex"];
      this.rgb = data["rgb"];
      this.hsl = data["hsl"];
      this.bestContrast = data["bestContrast"];
    }
  }

  ColorResult(String theName, String theHex, int red, int green, int blue,
      double hue, double saturation, double lightness, String bestContrast) {
    this.name = theName;
    this.hex = theHex;
    this.rgb["r"] = red;
    this.rgb["g"] = green;
    this.rgb["b"] = blue;
    this.hsl["h"] = hue;
    this.hsl["s"] = saturation;
    this.hsl["l"] = lightness;
    this.bestContrast = bestContrast;
  }
}

/**
 * A color searched by the user, either from the colorPicker or by hitting the search button on a ColorResult
 */
class SearchColor {
  String hex = "";
  Map rgb = {"r": 0, "g": 0, "b": 0};
  Map hsl = {"h": 0.0, "s": 0.0, "l": 0.0};

  String bestContrast = "";

  void setFromData(var data) {
    this.hex = data["hex"];
    this.rgb = data["rgb"];
    this.hsl = data["hsl"];
    this.bestContrast = data["bestContrast"];
  }

  SearchColor(String theHex, int red, int green, int blue, double hue,
      double saturation, double lightness, String bestContrast) {
    this.hex = theHex;
    this.rgb["r"] = red;
    this.rgb["g"] = green;
    this.rgb["b"] = blue;
    this.hsl["h"] = hue;
    this.hsl["s"] = saturation;
    this.hsl["l"] = lightness;
    this.bestContrast = bestContrast;
  }
}

/**
 * A collection of user-created groups of ColorResults, with a name and toggle to expand visually
 */
class SavedPalette {
  String name = "";
  List<ColorResult> colors = [];
  bool opened = true;

  SavedPalette(String theName, List<ColorResult> theColors, bool? open) {
    this.name = theName;
    this.opened = true;
    this.colors = theColors;
    this.opened = true;
    if(open != null) this.opened = open;
  }
}
