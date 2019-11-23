import 'dart:io';
import 'package:flutter/services.dart';
import "package:flutter/material.dart";
import 'package:moment/pages/about_page.dart';
import "package:moment/pages/home_page.dart";
import "package:moment/pages/edit.dart";
import 'package:moment/pages/view_page.dart';
import 'package:moment/pages/event.dart';
import 'package:moment/pages/setting.dart';
import 'package:moment/pages/alum.dart';
import 'package:moment/pages/search_page.dart';
import 'package:moment/utils/route.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:moment/provides/theme.dart';
import 'package:moment/constants/app.dart';

Future<int> getTheme() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  int theme = sp.getInt("theme");
  return null == theme ? 0 : theme;
}

void main() async {
  Provider.debugCheckInvalidValueType = null;

  int theme = await getTheme();
  var themeProvide = ThemeProvider(theme);

  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Constants.theme[theme].backgroundColor);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  if (bool.fromEnvironment('dart.vm.product')) {
    ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) {
      debugPrint(flutterErrorDetails.toString());
      return SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.bug_report),
                tooltip: '哎呀 被抓到啦（BUG）',
                onPressed: () {}, //todo
              )
            ], // todo restart app
          ),
        ),
      );
    };
  }

  runApp(MultiProvider(
      providers: [Provider<ThemeProvider>.value(value: themeProvide)],
      child: MyApp(theme)));
}

class MyApp extends StatelessWidget {
  final int theme;

  MyApp(this.theme);

  @override
  Widget build(BuildContext context) {
    final _theme = Provider.of<ThemeProvider>(context);
    return MaterialApp(
        title: Constants.appName,
        debugShowCheckedModeBanner: false,
        theme: Constants.theme[_theme.value != null ? _theme.value : theme],
        home: HomePage(),
//        initialRoute: '/home',
        routes: {
          "/home": (_) => HomePage(),
          "/search": (_) => SearchPage(),
          "/edit": (_) => Edit(),
          "/view": (context) => ViewPage(),
          "/event": (context) => EventPage(),
          "/alum": (context) => AlumPage(),
          "/setting": (context) => Setting(),
          "/about": (_) => AboutPage()
        },
        onGenerateRoute: (setting) {
          return MRouter.fadeIn(HomePage());
        });
  }
}

//todo image_picker 2 file_picker
// export db

//todo 开屏页  https://www.cnblogs.com/hupo376787/p/10261424.html

/*
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

/*

生成密钥：
keytool -genkey -v -keystore key.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias key

cool eg: : jarsigner -verbose -keystore demo.keystore -signedjar signed.apk CoolApkDevVerify_no_sign.apk demo.keystore

最终：
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore key.jks CoolApkDevVerify_no_sign.apk -signedjar  CoolApkDevVerify_signed.apk key


 flutter build apk --target-platform android-arm,android-arm64 --split-per-abi

 flutter build apk

 flutter build aot --release --extra-gen-snapshot-options=--print-snapshot-sizes
 Building AOT snapshot in release mode (android-arm-release)...
VMIsolate(CodeSize): 4660
Isolate(CodeSize): 2585632
ReadOnlyData(CodeSize): 2693576
Instructions(CodeSize): 8064816
Total(CodeSize): 13348684
Built to build/aot/.
Instructions：代表AOT编译后生成的二进制代码大小

ReadOnlyData：代表生成二进制代码的元数据（例如PcDescriptor， StackMap，CodeSourceMap等）和字符串大小

VMIsolate/Isolate：代表剩下的对象的大小总和（例如代码中定义的常量和虚拟机特定元数据）


执行如下命令编译出一个arm64架构的App.framework,并将它的包组成结构放到指定目录build/aot.json文件中
flutter --suppress-analytics build aot --output-dir=build/aot --target-platform=ios --target=lib/main.dart --release --ios-arch=arm64 --extra-gen-snapshot-options="--dwarf_stack_traces,--print-snapshot-sizes,--print_instructions_sizes_to=build/aot.json"
dart ./bin/run_binary_size_analysis.dart  build/aot.json path_to_webpage_dir


//编译release包并打印size
flutter build aot --release --extra-gen-snapshot-options=--print-snapshot-sizes

//--dwarf_stack_traces， -->减少6.2%大小
flutter build aot --release --extra-gen-snapshot-options="--dwarf_stack_traces,--print-snapshot-sizes"

//--obsfuscation， -->减少2.5%大小
flutter build aot --release --extra-gen-snapshot-options="--dwarf_stack_traces,--print-snapshot-sizes,--obfuscate"

//总大小减少8.7%

https://github.com/flutter/flutter
https://github.com/flutter/engine
https://github.com/flutter/flutter/issues/21813
https://github.com/flutter/flutter/issues/20671

 */
