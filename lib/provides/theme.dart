import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  int theme;

  int get value => theme;

  ThemeProvider(this.theme);

  Future<void> setTheme(int index) async {
    theme = index;
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setInt("theme", index);
    notifyListeners();
  }
}
