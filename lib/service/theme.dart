import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvide with ChangeNotifier {
  int theme;

  int get value => theme;

  ThemeProvide();

  Future<void> setTheme(int index) async {
    theme = index;
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setInt("theme", index);
    notifyListeners();
  }
}
