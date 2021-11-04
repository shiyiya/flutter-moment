// import 'package:android_intent/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moment/pages/home_page.dart';
import 'package:moment/pages/me_page.dart';
import 'package:moment/utils/toast.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  int currentPageIndex = 0;
  final List<Widget> tabPages = [HomePage(), MePage()];

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
      child: PersistentTabView(
        context,
        screens: tabPages,
        items: [
          PersistentBottomNavBarItem(
            icon: Icon(Icons.home),
            title: ("Home"),
            activeColorPrimary: CupertinoColors.activeBlue,
            inactiveColorPrimary: CupertinoColors.systemGrey,
          ),
          PersistentBottomNavBarItem(
            icon: Icon(Icons.person_pin),
            title: ("Settings"),
            activeColorPrimary: CupertinoColors.activeBlue,
            inactiveColorPrimary: CupertinoColors.systemGrey,
          ),
        ],
        onItemSelected: (index) {
          if (index == currentPageIndex) {
            return;
          }
          setState(() => currentPageIndex = index);
        },
      ),
    );
  }

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
}
