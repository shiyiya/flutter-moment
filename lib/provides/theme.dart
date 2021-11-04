import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  int theme;
  bool isNightTheme = false;
  Color primaryColor;

  int get value => theme;

  ThemeProvider(this.theme, this.primaryColor);

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

  Future<void> setThemePrimaryColor(Color color) async {
    primaryColor = color;

    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setInt("primaryColor", primaryColor.value);
    notifyListeners();
  }

  Future<void> switchNightTheme({bool value}) async {
    isNightTheme = value ?? !isNightTheme;

    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setInt("isNightTheme", value ? 1 : 0);
    notifyListeners();
  }
}

Future<int> getTheme() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  int theme = sp.getInt("theme");
  return null == theme ? 0 : theme;
}

Future<Color> getThemePrimaryColor() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  int primaryColor = sp.getInt("primaryColor");
  return null == primaryColor ? Colors.blue : Color(primaryColor);
}
