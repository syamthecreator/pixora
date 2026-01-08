import 'package:flutter/material.dart';
import 'package:pixora/features/camera/widgets/quick_settings_sheet.dart';
import 'package:pixora/routes/app_routes.dart';

/// Supported camera aspect ratios
enum CameraRatio { oneOne, fourThree, sixteenNine, full }

/// Manages camera settings, UI states, and quick settings overlay
class SettingsController extends ChangeNotifier {
  // -------------------- Constants --------------------
  static const List<String> _availableRatios = ["1:1", "4:3", "16:9", "Full"];
  static const List<String> _availableTimers = ["Off", "3s", "5s", "10s"];
  static const Duration _quickSettingsAnimationDuration =
      Duration(milliseconds: 300);
  static const double _quickSettingsBarrierOpacity = 0.6;

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
  String selectedTimer = "Off";

  /// Updates selected aspect ratio
  void selectRatio(String ratio) {
    if (selectedRatio != ratio) {
      selectedRatio = ratio;
      notifyListeners();
    }
  }

  /// Updates selected timer
  void selectTimer(String timer) {
    if (selectedTimer != timer) {
      selectedTimer = timer;
      notifyListeners();
    }
  }

  /// Returns selected ratio index
  int getRatioIndex() => _availableRatios.indexOf(selectedRatio);

  /// Returns selected timer index
  int getTimerIndex() => _availableTimers.indexOf(selectedTimer);


  // -------------------- Quick Settings UI --------------------

  /// Shows quick settings overlay
  void showQuickSettings(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: "QuickSettings",
      barrierDismissible: true,
      barrierColor: Colors.black.withAlpha(
        (255 * _quickSettingsBarrierOpacity).toInt(),
      ),
      transitionDuration: _quickSettingsAnimationDuration,
      pageBuilder: (_, _, _) => Align(
        alignment: Alignment.topCenter,
        child: QuickSettingsSheet(
          onClose: () => hideQuickSettings(context),
          onMoreSettings: () => moreSettings(context),
          settingsController: this,
        ),
      ),
      transitionBuilder: (_, animation, _, child) => SlideTransition(
        position: Tween(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    );
  }

  /// Closes quick settings overlay
  void hideQuickSettings(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Opens full settings screen
  void moreSettings(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(AppRoutes.settingsScreen);
  }

  // -------------------- Toggle Actions --------------------

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
