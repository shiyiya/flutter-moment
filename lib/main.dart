import "package:flutter/material.dart";
import "package:moment/pages/home.dart";
import "package:moment/pages/edit.dart";
import 'package:moment/pages/view.dart';
import 'package:moment/pages/event.dart';
import 'package:moment/pages/setting.dart';
import 'package:moment/pages/alum.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:provide/provide.dart';
import 'package:moment/service/theme.dart';
import 'package:moment/constants/app.dart';

Future<int> getTheme() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  int theme = sp.getInt("theme");
  return null == theme ? 0 : theme;
}

void main() async {
  var themeProvide = ThemeProvide();
  var providers = Providers();

  providers..provide(Provider.function((context) => themeProvide));

  int theme = await getTheme();

  runApp(ProviderNode(
    providers: providers,
    child: MyApp(theme),
  ));

  ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) {
    debugPrint(flutterErrorDetails.toString());
    return Center(child: Text('哎呀 被抓到啦（BUG）'));
  };
}

class MyApp extends StatelessWidget {
  final int theme;

  MyApp(this.theme);

  @override
  Widget build(BuildContext context) {
    Provide.value<ThemeProvide>(context).setTheme(theme);

    return Provide<ThemeProvide>(builder: (context, child, _theme) {
      return MaterialApp(
        theme: Constants.theme[_theme.value != null ? _theme.value : theme],
        home: Home(),
        routes: {
          "/home": (_) => Home(),
          "/edit": (_) => Edit(),
          "/view": (context) => View(),
          "/event": (context) => EventPage(),
          "/alum": (context) => AlumPage(),
          "/setting": (context) => Setting()
        },
      );
    });
  }
}

//todo 开屏页  https://www.cnblogs.com/hupo376787/p/10261424.html

/*
  flutter build apk --target-platform android-arm,android-arm64 --split-per-abi


 // template


import "package:flutter/material.dart";

class CCC extends StatefulWidget {
  @override
  _CCCState createState() => _CCCState();
}

class _CCCState extends State<CCC> {
  @override
  Widget build(BuildContext context) {
    return null;
  }
}


 */
