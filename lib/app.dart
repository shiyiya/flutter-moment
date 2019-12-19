// import 'dart:io';
// import 'package:android_intent/android_intent.dart';
import 'package:cuberto_bottom_bar/cuberto_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moment/pages/home_page.dart';
import 'package:moment/pages/me_page.dart';
import 'package:moment/utils/toast.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  int currentPageIndex = 0;

  final List<TabData> tabs = [
    TabData(iconData: Icons.home, title: '首页'),
    TabData(iconData: Icons.person_pin, title: '管理')
  ];
  final List<Widget> tabPages = [HomePage(), MePage()];

  // Future<bool> _runAppBackground() async {
  //   if (Platform.isAndroid) {
  //     AndroidIntent intent = AndroidIntent(
  //       action: 'android.intent.action.MAIN',
  //       category: "android.intent.category.HOME",
  //     );
  //     await intent.launch();
  //   }

  //   return Future.value(false);
  // }

  int lastBack = 0;

  Future<bool> doubleBackExit() {
    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastBack > 800) {
      showShortToast("再按一次退出");
      lastBack = DateTime.now().millisecondsSinceEpoch;
    } else {
      cancelToast();
      SystemNavigator.pop();
    }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: doubleBackExit,
      child: new Scaffold(
        body: IndexedStack(
          index: currentPageIndex,
          children: [for (var i = 0; i < tabs.length; i++) tabPages[i]],
        ),
        bottomNavigationBar: CubertoBottomBar(
          tabs: tabs,
          selectedTab: currentPageIndex,
          tabStyle: CubertoTabStyle.STYLE_FADED_BACKGROUND,
          barShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, -1),
              blurRadius: 1,
            ),
          ],
          onTabChangedListener: (position, title, color) {
            setState(() {
              currentPageIndex = position;
            });
          },
        ),
      ),
    );
  }
}
