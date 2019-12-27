import 'package:flutter/material.dart';
import 'package:moment/components/drawer.dart';
import 'package:moment/components/moment_card.dart';
import 'package:moment/components/row-icon-radio.dart';
import 'package:moment/constants/app.dart';
import 'package:moment/service/event_bus.dart';
import 'package:moment/sql/query.dart';
import 'package:moment/type/moment.dart';
import 'package:moment/utils/dialog.dart';

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
  const TabItem({this.title, this.icon});

  final String title;
  final Icon icon;
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  ScrollController _scrollController = ScrollController();

  final tabs = [Tab(text: '瞬间', icon: null)];

  List<Moment> _moments = [];

  // 筛选条件
  bool byFilter = false;
  int face;
  String event;
  int weather;
  int timeStart;
  int timeEnd;

  @override
  void initState() {
    eventBus.on<HomeRefreshEvent>().listen((event) {
      _loadAllMoment();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('todo');
        // todo
      }
    });

    if (widget.event != null) {
      setState(() {
        byFilter = true;
      });
    } else {
      _loadAllMomentByFilter();
    }

    _tabController = new TabController(vsync: this, length: tabs.length);
    super.initState();
  }

  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
        pinned: true,
        floating: true,
        forceElevated: innerBoxIsScrolled,
        snap: true,
        title: Text('瞬记'),
        bottom: PreferredSize(
            preferredSize: Size(double.infinity, kToolbarHeight),
            child: Container(
              alignment: Alignment.topLeft,
              child: TabBar(
                indicatorWeight: 2,
                indicatorPadding: EdgeInsets.only(left: 5, right: 5),
//                labelPadding: EdgeInsets.symmetric(horizontal: 10),
                indicatorSize: TabBarIndicatorSize.label,
                isScrollable: true,
                tabs: tabs,
                controller: _tabController,
              ),
            )),
        actions: ModalRoute.of(context).isFirst
            ? <Widget>[
                IconButton(
                  tooltip: '寻觅',
                  icon: Icon(Icons.filter_list),
                  onPressed: _showFilterDialog,
                ),
              ]
            : [],
      ),
    ];
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
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: _sliverBuilder,
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            _moments.length > 0
                ? ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      return MomentCard(
                        moment: _moments[index],
                        onLongPress: showDelMomentCardDialog,
                      );
                    },
                    itemCount: _moments.length,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: Center(
                      child: Text(
                        Constants.randomNilTip(),
                        style: Theme.of(context).textTheme.body2,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  /* Positioned(
                bottom: 20.0,
                left: MediaQuery.of(context).size.width / 2 - 20,
                child: Container(
                  width: 40,
                  height: 40,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      color: Theme.of(context).scaffoldBackgroundColor),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                  ),
                ),
              ),*/

  void _showFilterDialog() {
    showSimpleDialog(context,
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
            children: <Widget>[
              FlatButton(
                child: const Text(
                  '重置',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onPressed: () {
                  setState(() {
                    byFilter = false;
                    face = null;
                    weather = null;
                  });
                  _loadAllMoment();
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text(
                  '取消',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor.withOpacity(0.7)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text(
                  '确定',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onPressed: () {
                  setState(() {
                    byFilter = true;
                  });
                  _loadAllMomentByFilter();
                  Navigator.pop(context);
                },
              ),
            ],
          )
        ]);
  }

  /* void _showNewsSwitch() {
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
  }*/

  void showDelMomentCardDialog(int cid) {
    showAlertDialog(context, title: Text('是否删除本条瞬间？'), rF: () async {
      final bool r = await SQL.delMomentById(cid);
      if (r) {
        setState(() {
          _moments.removeWhere((m) => m.cid == cid);
        });
      }
    });
  }

  Future<void> _loadAllMoment() async {
    final List<Moment> momentList = await SQL.queryAllMoment();
    await Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _moments = momentList;
      });
    });
  }

  Future<void> _loadAllMomentByFilter() async {
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
      _loadAllMoment();
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
        _loadAllMoment();
        return;
      }
    }

    print('---loade by filter \r\n  $whereArgs');

    final List<Moment> momentList = await SQL.queryAllMomentByFilter(whereArgs);

    setState(() {
      _moments = momentList;
    });
  }
}
