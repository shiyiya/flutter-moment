import 'dart:async';
import 'dart:io';

import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moment/app.dart';
import 'package:moment/constants/app.dart';
import 'package:moment/pages/about_page.dart';
import 'package:moment/pages/alum_page.dart';
import "package:moment/pages/edit.dart";
import 'package:moment/pages/edit_flage_page.dart';
import 'package:moment/pages/event.dart';
import "package:moment/pages/home_page.dart";
import 'package:moment/pages/search_page.dart';
import 'package:moment/pages/setting.dart';
import 'package:moment/pages/statistics_page.dart';
import 'package:moment/pages/view_page.dart';
import 'package:moment/provides/lang.dart';
import 'package:moment/provides/theme.dart';
import 'package:moment/utils/route.dart';
import 'package:provider/provider.dart';

// 修复 photo_view 高分辨率图片不显示
// https://github.com/flutter/flutter/issues/36191
void zoomImageHotfix() {
  WidgetsFlutterBinding.ensureInitialized();
  const maxBytes = 512 * (1 << 20);
  // Invoke both method names to ensure the correct one gets invoked.
  SystemChannels.skia.invokeMethod('setResourceCacheMaxBytes', maxBytes);
//  SystemChannels.skia.invokeMethod('Skia.setResourceCacheMaxBytes', maxBytes);
}

void main() async {
  zoomImageHotfix();
  Provider.debugCheckInvalidValueType = null;

  if (bool.fromEnvironment('dart.vm.product')) {
    // 替换红屏
    ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) {
      debugPrint(flutterErrorDetails.toString());
      return SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('哎呀 被抓到啦（长按按钮试试）'),
              IconButton(
                icon: Icon(Icons.bug_report),
                tooltip: '我是 Future<Feature> !',
                onPressed: () {}, //todo
              )
            ],
          ),
        ),
      );
    };

    // 错误捕获
    FlutterError.onError = (FlutterErrorDetails flutterErrorDetails) {
      // FlutterError.dumpErrorToConsole(details);
      Zone.current.handleUncaughtError(
          flutterErrorDetails.exception, flutterErrorDetails.stack);
    };
  }

  int theme = await getTheme();
  Color primaryColor = await getThemePrimaryColor();

  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor:
          Constants.theme[theme](color: primaryColor).backgroundColor,
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  MultiProvider provider = MultiProvider(
    providers: [
//        Provider<ThemeProvider>.value(value: themeProvide),
      ChangeNotifierProvider.value(value: ThemeProvider(theme, primaryColor)),
      ChangeNotifierProvider.value(value: LangProvider(Locale('zh', 'CN')))
    ],
    child: MyApp(),
  );

  runZoned<Future<void>>(() async {
    runApp(provider);
  }, onError: (error, stackTrace) async {
    Fluttertoast.showToast(msg: error + stackTrace);
    //todo
  });

  runApp(provider);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    final _langProvider = Provider.of<LangProvider>(context);
    final themeFn theme =
        Constants.theme[_themeProvider.isNightTheme ? 2 : _themeProvider.theme];

    return MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalMaterialLocalizations.delegate
        ],
        supportedLocales: [
          const Locale('en', 'US'),
          const Locale('zh', 'CN'),
        ],
        localeResolutionCallback:
            (Locale locale, Iterable<Locale> supportedLocales) {
          debugPrint(
              "localelang:$locale   supportedLocales:$supportedLocales  currentLocale:${_langProvider.currentLocale}");
          // 系统语言等于当前设置语言
          if (_langProvider.currentLocale == locale)
            return _langProvider.currentLocale;
          //遍历支持的语言
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale == locale) {
              _langProvider.changeLang(locale);
              return _langProvider.currentLocale;
            }
          }
          return _langProvider.currentLocale;
        },
        title: Constants.appName,
        debugShowCheckedModeBanner: false,
        theme: theme(color: _themeProvider.primaryColor),
        home: App(),
//        initialRoute: '/home',
        routes: {
          "/home": (_) => HomePage(),
          "/search": (_) => SearchPage(),
          "/edit": (_) => Edit(),
          "/view": (_) => ViewPage(),
          "/event": (_) => EventPage(),
          "/alum": (_) => AlumPage(),
          "/setting": (_) => Setting(),
          "/about": (_) => AboutPage(),
          "/statistics": (_) => StatisticsPage(),
          "/new_flag": (_) => EditFlagPage()
        },
        onGenerateRoute: (setting) {
          return MRouter.fadeIn(HomePage());
        });
  }
}

/*

name:CY
pwd:CY1215

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
