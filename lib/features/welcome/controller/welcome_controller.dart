import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeController extends ChangeNotifier {
  static const _key = 'isFirstLaunch';

  bool _isFirstLaunch = true;
  bool get isFirstLaunch => _isFirstLaunch;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = prefs.getBool(_key) ?? true;
    notifyListeners();
  }

  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, false);
    _isFirstLaunch = false;
    notifyListeners();
  }
}
