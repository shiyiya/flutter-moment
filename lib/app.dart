import 'package:cuberto_bottom_bar/cuberto_bottom_bar.dart';
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

  final List<Widget> switchPages = [HomePage(), MePage()];

  final tabItems = [
    _TabBarItem(
      '首页',
      Icons.home,
    ),
    _TabBarItem(
      '管理',
      Icons.person_pin,
    )
  ];

  List<TabData> tabs = List();

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentPageIndex);

    tabs = tabItems
        .map((tab) => TabData(iconData: tab.iconData, title: tab.title))
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
        ],
      ),
      bottomNavigationBar: CubertoBottomBar(
        tabStyle: CubertoTabStyle.STYLE_FADED_BACKGROUND,
        initialSelection: 0,
        tabs: tabs,
        onTabChangedListener: (position, title, color) {
          setState(() {
            currentPageIndex = position;
          });
        },
      ),
    );
  }

//  Widget _buildAppBar() {
//    return new AppBar(
//      title: new Text(
//        bottomBarListItem[currentPageIndex].name,
//        style: new TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),
//      ),
////      elevation: 0.0,
//      brightness: Brightness.light,
//      centerTitle: false,
//      actions: [
//        new InkWell(
//          child: new Container(
//            width: 60.0,
//            child: Icon(Icons.search),
//          ),
//          onTap: () => Navigator.of(context).pushNamed('/search'),
//        ),
//      ],
//    );
//  }
}

class _TabBarItem {
  String title;
  IconData iconData;
  Color tabColor;

  _TabBarItem(this.title, this.iconData, {this.tabColor});
}
