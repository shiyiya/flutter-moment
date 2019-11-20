import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'dart:math';

class Constants {
  static String appName = "moment";
  static String appPkgName = 'moment';
  static String appDes = "记录美好瞬间";
  static String appSrc = "https://github.com/shiyiya/flutter-moment";

  static List<ThemeData> theme = [
    ThemeData.light(),
    ThemeData.dark(),
  ];

  static List<Map> sidebarTab = [
//    {"icon": Icon(Icons.calendar_today), "text": Text("日历"), "path": ""},
    {"icon": Icon(Icons.home), "text": Text("首页"), "path": "/home"},
//    {"icon": Icon(Icons.event), "text": Text("记事本")},

    {"icon": Icon(Icons.event), "text": Text("事件"), 'path': '/event'},
    {"icon": Icon(Icons.photo), "text": Text("印相"), 'path': '/alum'},
//    {"icon": Icon(Icons.), "text": Text("遇见"), 'path': '/event'},
    {"icon": Icon(Icons.settings), "text": Text("设置"), "path": "/setting"},
    {
      "icon": Icon(Icons.share),
      "text": Text("分享"),
      'f': () {
        Share.share('让我们记录这美好的瞬间~ (≧∇≦)ﾉ');
      }
    },
//    {"icon": Icon(Icons.info), "text": Text("关于"), "path": ""},
  ];

  static String weatherApi =
      "https://www.tianqiapi.com/api/?appid=94788224&appsecret=SJLpTJI6&version=v6";

  static String dbName = 'moment.db';

  static List<IconData> face = [
    Icons.sentiment_very_dissatisfied,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_satisfied,
    Icons.sentiment_very_satisfied,
    Icons.child_care
  ];

  static List<IconData> weather = [
    Icons.ac_unit,
    Icons.beach_access,
    Icons.cloud_queue,
    Icons.wb_sunny,
    Icons.whatshot
  ];

  static List tips = [
    '春有百花秋有月，夏有凉风冬有雪',
    '我想，这世间能称之为的美好的东西，\r\n大概都像这四时四景，生而美好，恰逢其时。',
    '想珍惜的时间，每一秒都宝贵 \r\n 想珍惜的人，每一个瞬间都想铭记。',
    '人生须尽欢，诗酒趁年华。',
    '终于见到你回来，我怎能不欢喜。',
    '草在结它的种子，风在摇它的叶子，\r\n我们站着，不说话，就十分美好。',
    '所有美好的出现，都有机缘。',
  ];

  static List errorTips = [
    '美好事物如昙花一现似流星一瞬而过，似烟花一而灭。',
  ];

  static List nilTips = [
    '往事已成空,还如一梦中。',
    '此情可待成追忆, 只是当时已惘然。',
  ];

  static String randomTip() {
    return tips[Random().nextInt(tips.length)];
  }

  static String randomErrorTip() {
    return errorTips[Random().nextInt(errorTips.length)];
  }

  static String randomNilTip() {
    return nilTips[Random().nextInt(nilTips.length)];
  }
}
