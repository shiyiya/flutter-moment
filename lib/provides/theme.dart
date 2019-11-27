import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  int theme;
  bool isNightTheme = false;

  int get value => theme;

  ThemeProvider(this.theme);

  Future<void> setTheme(int index) async {
    theme = index;

    if (index == 2) {
      isNightTheme = true;
    } else {
      isNightTheme = false;
    }

    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setInt("theme", index);
    notifyListeners();
  }

  Future<void> switchNightTheme(bool value) async {
    isNightTheme = value;

    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setInt("isNightTheme", value ? 1 : 0);
    notifyListeners();
  }
}
