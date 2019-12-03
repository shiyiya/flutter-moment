import 'package:flutter/material.dart';
import 'package:share_extend/share_extend.dart';
import 'dart:math';

typedef themeFn = ThemeData Function({Color color});

class Constants {
  static String appName = "moment";
  static String appPkgName = 'moment';
  static String appDes = "记录美好瞬间";
  static String appSrc = "https://github.com/shiyiya/flutter-moment";

  static List<themeFn> theme = [
    ({Color color}) {
      return ThemeData(
        brightness: Brightness.light,
        primaryColor: color,
        accentColor: color,
        backgroundColor: color?.withOpacity(0.7),
      );
    },
    ({Color color}) {
      return ThemeData(
        brightness: Brightness.dark,
        primaryColor: color,
        accentColor: color,
        backgroundColor: color?.withOpacity(0.7),
      );
    }
  ];

  static List<DrawTabItem> sidebarTab = [
    DrawTabItem(icon: Icon(Icons.home), text: Text("首页"), path: "/home"),
    DrawTabItem(icon: Icon(Icons.event), text: Text("事件"), path: "/event"),
    DrawTabItem(icon: Icon(Icons.photo), text: Text("印相"), path: "/alum"),
    DrawTabItem(icon: Icon(Icons.settings), text: Text("设置"), path: "/setting"),
    DrawTabItem(
      icon: Icon(Icons.share),
      text: Text("分享"),
      f: () => ShareExtend.share(
          '让我们记录这美好的瞬间~ (≧∇≦)ﾉ \r\n https://www.coolapk.com/apk/com.cy.moment',
          'text'),
    ),
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
    '与君初相识，犹如故人归。',
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

class DrawTabItem {
  Icon icon;
  Text text;
  Function f;
  String path;

  DrawTabItem({this.icon, this.text, this.f, this.path});
}
