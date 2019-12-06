import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LangProvider with ChangeNotifier {
  List<String> currentLanguageCode = ["zh", "CN"];
  String currentLanguage = "中文";
  Locale currentLocale = Locale('zh', "CN");

  LangProvider(this.currentLocale);

  Future<void> changeLang(Locale locale) async {
    currentLocale = locale;
    currentLanguageCode = [locale.languageCode, locale.countryCode];
    locale.countryCode == "CN"
        ? currentLanguage = "中文"
        : currentLanguage = "English";

    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString(
        "lang", '${currentLocale.languageCode},${locale.countryCode}');
    notifyListeners();
  }
}
