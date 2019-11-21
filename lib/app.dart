import 'package:flutter/material.dart';
import 'package:moment/pages/home_page.dart';
import 'package:moment/pages/calendar_page.dart';
import 'package:moment/components/drawer.dart';

// switch tab bar 载体
class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  int currentPageIndex = 0;
  PageController pageController;

  final List<Widget> switchPages = [HomePage(), CalendarPage()];

  final bottomBarListItem = [
    _TabBarItem('首页', Icon(Icons.home), Icon(Icons.home)),
    _TabBarItem('日历', Icon(Icons.calendar_today), Icon(Icons.calendar_today))
  ];

  List<BottomNavigationBarItem> bottomBarList;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentPageIndex);

    bottomBarList = bottomBarListItem
        .map((item) => BottomNavigationBarItem(
            icon: item.normalIcon,
            title: Text(item.name, style: TextStyle(fontSize: 12)),
            activeIcon: item.activeIcon))
        .toList();
  }

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
      appBar: currentPageIndex == 0 ? null : _buildAppBar(),
      drawer: currentPageIndex == 0 ? null : DrawerWidget(),
      body: Stack(
        children: <Widget>[
          _getPageWidget(0),
          _getPageWidget(1),
        ],
      ),

      /*PageView.builder(
        itemBuilder: (BuildContext context, int index) {
          return switchPages[index];
        },
        controller: pageController,
        itemCount: switchPages.length,
        physics: Platform.isAndroid
            ? new ClampingScrollPhysics()
            : new NeverScrollableScrollPhysics(),
        onPageChanged: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
      ),*/
      bottomNavigationBar: BottomNavigationBar(
        items: bottomBarList,
        iconSize: 20,
        currentIndex: currentPageIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            currentPageIndex = index;
//          pageController.jumpToPage((currentPageIndex));
          });
        },
        unselectedFontSize: 10.0,
        selectedFontSize: 10.0,
//        elevation: 0,
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
  Icon activeIcon, normalIcon;

  _TabBarItem(this.name, this.activeIcon, this.normalIcon);
}
