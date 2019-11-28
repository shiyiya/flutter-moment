import 'package:flutter/material.dart';
import 'package:moment/pages/home_page.dart';
import 'package:moment/pages/me_page.dart';

// switch tab bar 载体
class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  int currentPageIndex = 0;
  PageController pageController;

  final List<Widget> switchPages = [HomePage(), Container(), MePage()];

  final bottomBarListItem = [
    _TabBarItem('首页', Icon(Icons.shutter_speed), Icon(Icons.shutter_speed)),
    _TabBarItem(
      '新建',
      Icon(Icons.control_point, size: 35),
      Icon(Icons.control_point, size: 35),
    ),
    _TabBarItem(
      '管理',
      Icon(Icons.bubble_chart, size: 30), //避免图标差异导致大小不协调
      Icon(Icons.bubble_chart, size: 30),
    )
  ];

  List<BottomNavigationBarItem> bottomBarList;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentPageIndex);

    bottomBarList = bottomBarListItem
        .map((item) => BottomNavigationBarItem(
            icon: item.normalIcon,

            // https://github.com/flutter/flutter/issues/17099
            // https://github.com/flutter/flutter/pull/22804
            // https://github.com/flutter/flutter/issues/22882

            title: SizedBox.shrink(),
            /* title: Text(item.name, style: TextStyle(fontSize: 12))*/
            activeIcon: item.activeIcon))
        .toList();
  }

  // 不使用 page view，避免重载
  _getPageWidget(int index) {
    return Offstage(
      offstage: currentPageIndex != index,
      child: TickerMode(
        enabled: currentPageIndex == index,
        child: switchPages[index],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
//      appBar: currentPageIndex == 0 ? null : _buildAppBar(),
//      drawer: currentPageIndex == 0 ? null : DrawerWidget(),
      body: Stack(
        children: <Widget>[
          _getPageWidget(0),
          _getPageWidget(1),
          _getPageWidget(2),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: bottomBarList,
        iconSize: 25,
        currentIndex: currentPageIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            if (index == 1) {
              Navigator.pushNamed(context, "/edit");
              return;
            }
            currentPageIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return new AppBar(
      title: new Text(
        bottomBarListItem[currentPageIndex].name,
        style: new TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),
      ),
//      elevation: 0.0,
      brightness: Brightness.light,
      centerTitle: false,
      actions: [
        new InkWell(
          child: new Container(
            width: 60.0,
            child: Icon(Icons.search),
          ),
          onTap: () => Navigator.of(context).pushNamed('/search'),
        ),
      ],
    );
  }
}

class _TabBarItem {
  String name;
  Widget activeIcon, normalIcon;

  _TabBarItem(this.name, this.activeIcon, this.normalIcon);
}
