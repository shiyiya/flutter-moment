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
import 'package:moment/service/sqlite.dart';
import 'package:moment/utils/date.dart';

import 'package:moment/pages/view.dart';

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
  List _moments = [];

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
  }

  @override
  Widget build(BuildContext context) {
    int len = _moments.length;

    return Scaffold(
      floatingActionButton: ModalRoute.of(context).isFirst
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, "/edit"),
              tooltip: "Increment",
              child: Icon(Icons.add))
          : null,
      drawer: ModalRoute.of(context).isFirst ? DrawerWidget() : null,
      appBar: AppBar(
        title: Text(Constants.appName),
        actions: <Widget>[
          IconButton(
            tooltip: '寻觅',
            icon: Icon(Icons.sort),
            onPressed: _buildFilterDialog,
          ),
        ],
      ),
      body: EasyRefresh.custom(
        header: DeliveryHeader(),
        footer: MaterialFooter(enableInfiniteLoad: false),
        onRefresh: () => _loadMomentByPage(0),
        onLoad: () => _loadMoreMoment(),
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index == 0) return buildWeather();
              if (index <= len) {
                return buildMomentCard(index - 1);
              }
              return null;
            }, childCount: len + 1),
          )
        ],
      ),
    );
  }

  _loadMomentByPage(int page) async {
    if (byFilter) {
      _loadMomentByFilterWithPage(page);
      return;
    }

    print('refresh monent by page $page');

    List res = await (await DB.getInstance()).query('moment_content',
        columns: ['*'], limit: 10, offset: page * 10, orderBy: 'created desc');

    if (res.length > 0) {
      setState(() {
        if (page == 0) {
          List r = [];
          r.addAll(res);
          _moments = r;
        } else {
          _moments.addAll(res);
        }
        _page = page;
      });
      Fluttertoast.showToast(msg: '加载成功 (#`O′)');
    } else {
      Fluttertoast.showToast(msg: '没有更多啦 ∑( 口 ||');
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
      // by tag
      whereColumns = 'event LIKE "%${widget.event}%"';
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

    final db = await DB().get();
    final res = await db.query(
      'moment_content',
      columns: ['*'],
      where: whereColumns,
      whereArgs: whereArgs,
      limit: 10,
      offset: page * 10,
      orderBy: 'created DESC',
    );

    setState(() {
      if (page == 0) {
        List r = [];
        r.addAll(res);
        _moments = r;
        Fluttertoast.showToast(msg: '刷新成功 (#`O′)');
      } else {
        _moments.addAll(res);
      }
      _page = page;
    });
  }

  void _buildFilterDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
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
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: Card(
          child: Column(
            children: <Widget>[
              ListTile(
                  leading: Icon(
                    Constants.face[_moments[index]['face'] is int
                        ? _moments[index]['face']
                        : 4],
                    size: 40,
                  ),
                  title: Text(_moments[index]['title']),
                  subtitle: Text(
                    _moments[index]['text'].length > 50
                        ? _moments[index]['text'].substring(0, 20)
                        : _moments[index]['text'],
//                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: _moments[index]['alum'] is String &&
                          _moments[index]['alum'].length > 0
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.file(
                            File(_moments[index]['alum'].split('|')[0]),
                            fit: BoxFit.cover,
                          ),
                        )
                      : null),
              ButtonTheme.bar(
                  child: Container(
                padding: EdgeInsets.fromLTRB(10, 0, 8, 5),
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
                            Date.getDateFormatMD(
                                ms: _moments[index]['created']),
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
                        children: _moments[index]['event'].length > 0
                            ? [
                                Icon(
                                  Icons.monochrome_photos,
                                  color: Theme.of(context)
                                      .textTheme
                                      .display3
                                      .color,
                                  size: 12,
                                ),
                                Text(
                                  ' ${_moments[index]['event']}',
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
          return View(id: _moments[index]['cid']);
        }));
      },
      onLongPress: () {
        buildMomentCardDialog(index);
      },
    );
  }

  void buildMomentCardDialog(int index) {
//    showDatePicker(context: context, initialDate: null, firstDate: null, lastDate: null)
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
                      onPressed: () {
                        setState(() {
                          _delMomentById(index);
                        });
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

  void _delMomentById(int index) async {
    final currDB = await DB.getInstance();

    final count = await currDB
        .rawDelete('DELETE FROM moment_content WHERE cid = ?', [index]);

    if (count == 1) {
      Fluttertoast.showToast(msg: '删除成功');
    } else {
      Fluttertoast.showToast(msg: '删除失败');
    }
  }
}
