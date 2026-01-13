import 'package:flutter/material.dart';

/// Supported camera aspect ratios
enum CameraRatio { oneOne, fourThree, sixteenNine, full }

/// Manages camera settings, UI states, and quick settings overlay
class SettingsController extends ChangeNotifier {
  // -------------------- Constants --------------------
  static const List<String> _availableRatios = ["1:1", "4:3", "16:9", "Full"];
  List<String> get availableRatios => _availableRatios;

  // -------------------- Quick Toggles --------------------
  bool gridLines = true;
  bool level = true;
  bool watermark = false;
  bool hdr = true;

  // -------------------- Persistent Settings --------------------
  final Map<String, bool> _settingsValues = {};

  /// Returns stored value or fallback
  bool getValue(String key, {bool defaultValue = false}) =>
      _settingsValues[key] ?? defaultValue;

  /// Updates a setting value
  void toggle(String key, bool value) {
    _settingsValues[key] = value;
    notifyListeners();
  }

  /// Clears all stored settings
  void restoreDefaults() {
    _settingsValues.clear();
    notifyListeners();
  }

  // -------------------- Ratio & Timer --------------------
  String selectedRatio = "Full";

  /// Updates selected aspect ratio
  void selectRatio(String ratio) {
    if (selectedRatio != ratio) {
      selectedRatio = ratio;
      notifyListeners();
    }
  }

  /// Returns selected ratio index
  int getRatioIndex() => _availableRatios.indexOf(selectedRatio);

  /// Toggles grid overlay
  void toggleGridLines() {
    gridLines = !gridLines;
    notifyListeners();
  }

  /// Toggles level indicator
  void toggleLevel() {
    level = !level;
    notifyListeners();
  }

  /// Toggles watermark
  void toggleWatermark() {
    watermark = !watermark;
    notifyListeners();
  }

  /// Toggles HDR mode
  void toggleHDR() {
    hdr = !hdr;
    notifyListeners();
  }
}
