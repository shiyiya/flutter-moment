import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/delivery_header.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moment/components/row-icon-radio.dart';
import 'package:moment/constants/app.dart';
import 'package:moment/sql/query.dart';
import 'package:moment/type/moment.dart';
import 'package:moment/utils/date.dart';
import 'package:moment/components/drawer.dart';
import 'package:moment/pages/view_page.dart';
import 'package:moment/utils/img.dart';

import 'package:moment/service/event_bus.dart';

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

class _HomePageState extends State<HomePage> {
  EasyRefreshController _controller = EasyRefreshController();

  int _page = 0;
  List<Moment> _moments = [];

  // 筛选条件
  bool byFilter = false;
  int face;
  String event;
  int weather;
  int timeStart;
  int timeEnd;

  List<BottomNavigationBarItem> bottomBarList;

  @override
  void initState() {
    super.initState();
    print('----home page initstate----');

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
  }

  @override
  Widget build(BuildContext context) {
    int len = _moments?.length ?? 0;

    return Scaffold(
//      floatingActionButton: ModalRoute.of(context).isFirst
//          ? FloatingActionButton(
//              onPressed: () => Navigator.pushNamed(context, "/edit"),
//              tooltip: "记录瞬间",
//              child: Icon(Icons.add))
//          : null,
      drawer: ModalRoute.of(context).isFirst ? DrawerWidget() : null,
      appBar: AppBar(
        elevation: 1.0,
        titleSpacing: 0.0,
        title: Text('瞬间'),
        actions: <Widget>[
          IconButton(
            tooltip: '寻觅',
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: EasyRefresh.custom(
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
              if (index == 0) return buildWeather();
              if (index == 1 && len == 0) {
                // 记录为空
                return Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: Center(
                      child: Text(Constants.randomNilTip(),
                          style: Theme.of(context).textTheme.body2)),
                );
              }

              if (index <= len) {
                final i = len == 0 ? index - 2 : index - 1;
                return buildMomentCard(i);
              }
              return null;
            }, childCount: len + 2),
          )
        ],
      ),
    );
  }

  Widget buildWeather() {
    return Container(
      padding: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 8,
      margin: EdgeInsets.only(bottom: 5),
      color: Theme.of(context).backgroundColor,
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.wb_sunny),
              Text(
                '  你在的地方一定是晴天吧',
                style: Theme.of(context).textTheme.subtitle,
              ),
            ],
          ),
        ],
      )),
    );
  }

  Widget buildMomentCard(int index) {
    final Moment item = _moments[index];
    final String text =
        item.text.length > 50 ? item.text.substring(0, 20) : item.text;
    final String firstImg =
        item.alum.length < 1 ? null : item.alum?.split('|')[0];
    int face = item.face ?? 2;

    if (face % 20 > 0) {
      face = face ~/ 20;
    } else {
      face = (face ~/ 20) - 1;
    }

    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: Card(
          child: Column(
            children: <Widget>[
              ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  leading: Icon(
                    Constants.face[face],
                    size: 40,
                    color: Theme.of(context).accentColor,
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  subtitle: Text(text.trim()),
                  trailing: firstImg != null
                      ? Container(
                          width: 80,
//                          height: 300,
                          color: Colors.amber,
                          child: Img.isLocal(firstImg)
                              ? Image.file(
                                  File(firstImg),
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  firstImg,
                                  fit: BoxFit.cover,
                                ),
                        )
                      : null),
              ButtonTheme.bar(
                  child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        width: 1, color: Color.fromRGBO(128, 128, 128, 0.1)),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.query_builder,
                            color: Theme.of(context).textTheme.display3.color,
                            size: 12,
                          ),
                          Text(
                            '  ' +
                                Date.getDateFormatYMD(
                                    ms: _moments[index].created),
                            style: TextStyle(
                                fontSize: 10,
                                color:
                                    Theme.of(context).textTheme.display3.color,
                                textBaseline: TextBaseline.alphabetic),
                          ),
//                          Icon(
//                            Icons.location_on,
//                            color: Theme.of(context).textTheme.display3.color,
//                            size: 18,
//                          ),
//                          Text(
//                            ' 自己的世界',
//                            style: TextStyle(
//                              fontSize: 10,
//                              letterSpacing: 1,
//                              color: Theme.of(context).textTheme.display3.color,
//                            ),
//                          ),
                        ],
                      ),
                      Row(
                        children: _moments[index].event.length > 0
                            ? [
                                Text(
                                  ' ${_moments[index].event}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    letterSpacing: 1,
                                    color: Theme.of(context)
                                        .textTheme
                                        .display3
                                        .color,
                                  ),
                                ),
                              ]
                            : [],
                      ),
                    ]),
              ))
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return ViewPage(id: _moments[index].cid);
        }));
      },
      onLongPress: () {
        buildMomentCardDialog(_moments[index].cid);
      },
    );
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
                    if (i == face) {
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
              ButtonTheme.bar(
                child: ButtonBar(
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
                ),
              ),
            ],
          );
        });
  }

  void buildMomentCardDialog(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('是否删除本条瞬间？'),
            actions: <Widget>[
              ButtonTheme.bar(
                child: ButtonBar(
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
                        final bool d = await SQL.delMomentById(index);
                        if (d) {
                          setState(() {
                            _moments.removeWhere((m) => m.cid == index);
                          });
                        }
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
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
      Filter('face > ?', (face ?? 20) - 20),
      Filter('face <= ?', face),
      Filter('weather = ?', weather),
    ];
    where.retainWhere((f) => f.v != null);

    String whereColumns = '';
    where.forEach((w) => whereColumns += '${w.k} AND ');

    //从事件列进入
    if (widget.event != null && widget.event.length > 0) {
      if (whereColumns.length > 0) {
        whereColumns += 'event LIKE "%${widget.event}%"';
      } else {
        // by tag
        whereColumns = 'event LIKE "%${widget.event}%"';
      }
    } else {
      if (whereColumns.length > 0) {
        whereColumns = whereColumns.substring(0, whereColumns.length - 5);
      } else {
        setState(() {
          byFilter = false;
        });
        _loadMomentByPage(page);
        return;
      }
    }

    List whereArgs = where.map((w) => w.v).toList();

    print('---loade by filter page$page \r\n $whereColumns  \r\n  $whereArgs');

    final List<Moment> momentList =
        await SQL.queryMomentByPageWithFilter(page, whereColumns, whereArgs);

    setState(() {
      if (page == 0) {
        _moments = momentList;
        Fluttertoast.showToast(msg: '刷新成功 (#`O′)');
      } else {
        _moments.addAll(momentList);
      }
      _controller.finishRefresh(success: true);
      _page = page;
    });
  }
}
