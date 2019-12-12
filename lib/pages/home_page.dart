import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/delivery_header.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:moment/components/drawer.dart';
import 'package:moment/components/icon_button_with_text.dart';
import 'package:moment/components/menu_icon.dart';
import 'package:moment/components/moment_card.dart';
import 'package:moment/components/row-icon-radio.dart';
import 'package:moment/constants/app.dart';
import 'package:moment/service/event_bus.dart';
import 'package:moment/sql/query.dart';
import 'package:moment/type/moment.dart';

class Filter {
  String k;
  dynamic v;

  Filter(this.k, this.v);
}

class HomePage extends StatefulWidget {
  final String event;

  HomePage({Key key, this.event}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class TabItem {
  const TabItem({this.title, this.position, this.icon});

  final String title;
  final int position;
  final Icon icon;
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  EasyRefreshController _controller = EasyRefreshController();

  List<TabItem> tabs = [
    TabItem(title: '瞬 间', position: 10),
    TabItem(title: '', icon: Icon(Icons.add))
  ];
  TabController _tabController;

  int _page = 0;
  List<Moment> _moments = [];

  // 筛选条件
  bool byFilter = false;
  int face;
  String event;
  int weather;
  int timeStart;
  int timeEnd;

  List<BottomNavigationBarItem> bottomBarList = [];

  @override
  void initState() {
    super.initState();
    print('----home page initstate by event ${widget.event}----');

    if (widget.event != null) {
      setState(() {
        byFilter = true;
      });
    }
    _loadMomentByPage(0);

    eventBus.on<HomeRefreshEvent>().listen((event) {
      if (event.needRefresh) {
        _loadMomentByPage(-1);
      }
    });
    _tabController = new TabController(vsync: this, length: tabs.length);
  }

  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
        centerTitle: false,
        expandedHeight: 20.0,
        floating: false,
        pinned: true,
        titleSpacing: 10,
        leading: SizedBox.shrink(),
        flexibleSpace: PreferredSize(
            child: Container(
              alignment: Alignment.topLeft,
              child: new TabBar(
                indicatorWeight: 2,
                indicatorPadding: EdgeInsets.only(left: 5, right: 5),
//                labelPadding: EdgeInsets.symmetric(horizontal: 10),
                indicatorSize: TabBarIndicatorSize.label,
                isScrollable: true,
                tabs: tabs.map((TabItem tabItem) {
                  return new Tab(
                    text: tabItem.title.isEmpty ? null : tabItem.title,
                    icon: tabItem.icon,
                  );
                }).toList(),
                controller: _tabController,
              ),
            ),
            preferredSize: new Size(double.infinity, 18.0)),
      ),
    ];
  }

  /*flexibleSpace: FlexibleSpaceBarSettings(
          toolbarOpacity: 0.5,
          minExtent: 1,
          maxExtent: 1,
          currentExtent: 1,
          child: Container(
            height: double.infinity,
//            decoration: BoxDecoration(
//              image: DecorationImage(
//                image: AssetImage('lib/asserts/images/bg_1.jpg'),
//                fit: BoxFit.cover,
//              ),
//            ),
            child: Text(
              Date.getDateFormatYMD(
                ms: DateTime.now().millisecondsSinceEpoch,
              ),
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),*/

  Widget momentWrap() {
    int len = _moments?.length ?? 0;
    return EasyRefresh.custom(
      controller: _controller,
      header: DeliveryHeader(),
      footer: MaterialFooter(enableInfiniteLoad: false),
      onRefresh: () async {
        _loadMomentByPage(0);
      },
      onLoad: () => _loadMoreMoment(),
      slivers: <Widget>[
        SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
          if (index == 0 && len == 0) {
            // 记录为空
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Center(
                  child: Text(Constants.randomNilTip(),
                      style: Theme.of(context).textTheme.body2)),
            );
          }
          if (index < len) {
            return MomentCard(
              moment: _moments[index],
              onLongPress: showDelMomentCardDialog,
            );
          }
          return null;
        }, childCount: len + 1))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: ModalRoute.of(context).isFirst
            ? FloatingActionButton(
                onPressed: () => Navigator.pushNamed(context, "/edit"),
                tooltip: "记录瞬间",
                child: Icon(Icons.add))
            : null,
        drawer: ModalRoute.of(context).isFirst ? DrawerWidget() : null,
        appBar: AppBar(
          elevation: 0.0,
          titleSpacing: 0.0,
          title: Text('瞬记'),
          leading: ModalRoute.of(context).isFirst
              ? Builder(
                  builder: (_) => IconButton(
                    icon: MenuIcon(
                      Theme.of(_).appBarTheme.iconTheme?.color ?? Colors.white,
                    ),
                    onPressed: () {
                      Scaffold.of(_).openDrawer();
                    },
                  ),
                )
              : null,
          actions: <Widget>[
            IconButton(
              tooltip: '寻觅',
              icon: Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
            ),
          ],
        ),
        body: ModalRoute.of(context).isFirst
            ? NestedScrollView(
                headerSliverBuilder: _sliverBuilder,
                body: TabBarView(controller: _tabController, children: <Widget>[
                  momentWrap(),
                  Center(child: Text('敬请期待')),
                ]))
            : momentWrap());
  }

  void _showFilterDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(
              '筛选',
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            children: [
              RowIconRadio(
                icon: Constants.face,
                selected: face == null ? null : face ~/ 20 - 1,
                onTap: (i) {
                  setState(() {
                    if ((i + 1) * 20 == face) {
                      face = null;
                    } else {
                      face = (i + 1) * 20;
                    }
                  });
                },
              ),
              RowIconRadio(
                icon: Constants.weather,
                selected: weather,
                onTap: (i) {
                  setState(() {
                    if (i == weather) {
                      weather = null;
                    } else {
                      weather = i;
                    }
                  });
                },
              ),
              ButtonBar(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FlatButton(
                    child: const Text('重置'),
                    onPressed: () {
                      setState(() {
                        byFilter = false;
                        face = null;
                        weather = null;
                      });
                      _loadMomentByPage(0);
                      Navigator.pop(context);
                    },
                  ),
                  FlatButton(
                    child: const Text('取消'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  FlatButton(
                    child: const Text('确定'),
                    onPressed: () {
                      setState(() {
                        byFilter = true;
                      });
                      _loadMomentByFilterWithPage(0);
                      Navigator.pop(context);
                    },
                  ),
                ],
              )
            ],
          );
        });
  }

  void _showNewsSwitch() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
          height: MediaQuery.of(context).size.height / 4,
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextIconButton(
                  icon: Icon(
                    Icons.plus_one,
                    color: Theme.of(context).backgroundColor,
                    size: 36,
                  ),
                  text: '瞬 间',
                  onTap: () => Navigator.popAndPushNamed(context, "/edit"),
                ),
                TextIconButton(
                  icon: Icon(
                    Icons.flag,
                    color: Theme.of(context).backgroundColor,
                    size: 36,
                  ),
                  text: '预 测',
                  onTap: () => Navigator.popAndPushNamed(context, '/new_flag'),
                ),
              ],
            ),
          )),
    );
  }

  void showDelMomentCardDialog(int cid) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('是否删除本条瞬间？'),
            actions: <Widget>[
              ButtonBar(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FlatButton(
                    child: const Text('取消'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  FlatButton(
                    child: const Text('确定'),
                    onPressed: () async {
                      final bool d = await SQL.delMomentById(cid);
                      if (d) {
                        setState(() {
                          _moments.removeWhere((m) => m.cid == cid);
                        });
                      }
                      Navigator.pop(context);
                    },
                  ),
                ],
              )
            ],
          );
        });
  }

  _loadMomentByPage(int page) async {
//    await _queryAllMomentInfo();

    // 刷新
    if (page < 0) {
      _loadMomentByPage(_page);
      return;
    }

    // 筛选
    if (byFilter) {
      await _loadMomentByFilterWithPage(page);
      return;
    }

    print('refresh monent by page $page');

    final List<Moment> momentList = await SQL.queryMomentByPage(page);

    if (momentList != null) {
      setState(() {
        if (page == 0) {
          _moments = momentList;
        } else {
          _moments.addAll(momentList);
        }
        _controller.finishRefresh(success: true);
        _page = page;
      });
    } else {
      if (page == 0) {
        //刷新
        setState(() {
          _moments = [];
        });
      }
      _controller.finishLoad(success: true, noMore: false);
    }
  }

  _loadMoreMoment() async {
    print('load more monent by page $_page');

    await _loadMomentByPage(_page + 1);
  }

  _loadMomentByFilterWithPage(int page) async {
    List<Filter> where = [
      Filter('face > ?', face == null ? null : (face ?? 20) - 20),
      Filter('face <= ?', face),
      Filter('weather = ?', weather),
    ];

    where.retainWhere((f) => f.v != null);
    if (where.length < 1 && widget.event == null) {
      setState(() {
        // reset
        byFilter = false;
        face = null;
        weather = null; // event 不可重置
      });
      _loadMomentByPage(0);
      return;
    }

    String whereArgs = '';
    where.forEach((w) {
      whereArgs += w.k.replaceAll('?', '${w.v} AND ');
    });

    //从事件列进入
    if (widget.event != null && widget.event.length > 0) {
      if (whereArgs.length > 0) {
        whereArgs += 'event LIKE "%${widget.event}%"';
      } else {
        // by tag
        whereArgs = 'name LIKE "%${widget.event}%"';
      }
    } else {
      if (whereArgs.length > 0) {
        whereArgs = whereArgs.substring(0, whereArgs.length - 5);
      } else {
        setState(() {
          byFilter = false;
        });
        _loadMomentByPage(page);
        return;
      }
    }

    print('---loade by filter page$page  \r\n  $whereArgs');

    final List<Moment> momentList =
        await SQL.queryMomentByPageWithFilter(page, whereArgs);

    setState(() {
      if (page == 0) {
        _moments = momentList;
      } else {
        _moments.addAll(momentList);
      }
      _controller.finishRefresh(success: true);
      _page = page;
    });
  }
}
