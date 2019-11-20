import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/delivery_header.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:flutter_calendar/flutter_calendar.dart';

import 'package:moment/components/drawer.dart';
import 'package:moment/components/row-icon-radio.dart';
import 'package:moment/constants/app.dart';
import 'package:moment/sql/query.dart';
import 'package:moment/type/moment.dart';
import 'package:moment/utils/date.dart';

import 'package:moment/pages/view.dart';
import 'package:moment/utils/img.dart';

class Filter {
  String k;
  dynamic v;

  Filter(this.k, this.v);
}

class Home extends StatefulWidget {
  final String event;

  Home({Key key, this.event}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _page = 0;
  List<Moment> _moments = [];
  MomentInfo momentInfo;

  EasyRefreshController _controller = EasyRefreshController();

  // 筛选条件
  bool byFilter = false;
  int face;
  String event;
  int weather;
  int timeStart;
  int timeEnd;
  String keyword;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      setState(() {
        byFilter = true;
      });
    }
    _loadMomentByPage(0);
//    _queryAllMomentInfo()
  }

  @override
  Widget build(BuildContext context) {
    int len = _moments.length;

    return Scaffold(
      floatingActionButton: ModalRoute.of(context).isFirst
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, "/edit"),
              tooltip: "记录瞬间",
              child: Icon(Icons.add))
          : null,
      drawer: ModalRoute.of(context).isFirst ? DrawerWidget() : null,
      appBar: AppBar(
        title: Text(Constants.appName),
        actions: <Widget>[
          IconButton(
            tooltip: '刷新',
            icon: Icon(Icons.refresh),
            onPressed: () => _loadMomentByPage(-1),
          ),
          IconButton(
            tooltip: '寻觅',
            icon: Icon(Icons.sort),
            onPressed: _buildFilterDialog,
          ),
        ],
      ),
      body: EasyRefresh.custom(
        controller: _controller,
        header: DeliveryHeader(),
        footer: MaterialFooter(enableInfiniteLoad: false),
        onRefresh: () => _loadMomentByPage(0),
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
                      child: Text('与君初相识，犹如故人归。' /*Constants.randomNilTip()*/,
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

  /*_queryAllMomentInfo() async {
    final MomentInfo res = await SQL.queryAllMomentInfo();
    setState(() {
      momentInfo = res;
    });
  }*/

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
      Filter('face', face),
      Filter('weather', weather),
      Filter('keyword', keyword),
    ];
    where.retainWhere((f) => f.v != null);

    String whereColumns = '';
    where.forEach((w) => whereColumns += '${w.k} = ? AND ');

    print(whereColumns.length);

    if (widget.event != null && widget.event.length > 0) {
      print(1);
      if (whereColumns.length > 0) {
        print(2);
        whereColumns += 'event LIKE "%${widget.event}%"';
      } else {
        print(3);
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

  void _buildFilterDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('筛选条件'),
            contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            children: [
              RowIconRadio(
                icon: Constants.face,
                selected: face,
                onTap: (i) {
                  setState(() {
                    if (i == face) {
                      face = null;
                    } else {
                      face = i;
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
//              ListView(children: <Widget>[],),
//              new Calendar(),
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
                          keyword = null;
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

  Widget buildWeather() {
    return Container(
      padding: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 8,
      margin: EdgeInsets.only(bottom: 5),
      color: Theme.of(context).backgroundColor,
      child: Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.wb_sunny),
          Text(
            '  你在的地方一定是晴天吧',
            style: Theme.of(context).textTheme.subtitle,
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
    final int face = item.face ?? 2;

    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: Card(
          child: Column(
            children: <Widget>[
              ListTile(
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
                  subtitle: Text(text),
                  trailing: firstImg != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Img.isLocal(firstImg)
                              ? Image.file(
                                  File(firstImg),
                                  fit: BoxFit.cover,
                                )
                              : Image.network(firstImg),
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
//                          Icon(
//                            Icons.date_range,
//                            color: Theme.of(context).textTheme.display3.color,
//                            size: 18,
//                          ),
                          Text(
                            Date.getDateFormatMDHM(ms: _moments[index].created),
                            style: TextStyle(
                              fontSize: 10,
//                              letterSpacing: 1,
                              color: Theme.of(context).textTheme.display3.color,
                            ),
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
//                                Icon(
//                                  Icons.monochrome_photos,
//                                  color: Theme.of(context)
//                                      .textTheme
//                                      .display3
//                                      .color,
//                                  size: 12,
//                                ),
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
          return View(id: _moments[index].cid);
        }));
      },
      onLongPress: () {
        buildMomentCardDialog(_moments[index].cid);
      },
    );
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
}
