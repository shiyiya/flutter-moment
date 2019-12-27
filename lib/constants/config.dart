import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Configs {
  static final bool isDebug = !kReleaseMode && false;

  // 段首缩进
  static bool lineHeadIndent = false;

  // 预览字号
  static final int mFontSize = 15;

  static Future<SharedPreferences> getSP() async {
    return await SharedPreferences.getInstance();
  }
}
