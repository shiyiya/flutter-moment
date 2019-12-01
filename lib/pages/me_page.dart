import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:moment/provides/theme.dart';
import 'package:moment/type/moment.dart';
import 'package:provider/provider.dart';
import 'package:moment/sql/query.dart';
import 'package:moment/service/event_bus.dart';
import 'package:moment/utils/launcher.dart';
import 'package:share_extend/share_extend.dart';

class MePage extends StatefulWidget {
  @override
  _MePageState createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  MomentInfo _momentInfo = MomentInfo();

  @override
  void initState() {
    super.initState();
    _queryAllMomentInfo();

    eventBus.on<HomeRefreshEvent>().listen((event) {
      if (event.needRefresh) {
        _queryAllMomentInfo();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(
                  15, MediaQueryData.fromWindow(window).padding.top, 15, 15),
              height: MediaQuery.of(context).size.height / 5,
              color: Theme.of(context).backgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Image.asset(
                              'lib/asserts/logo/logo.png',
                              width: 50,
                              height: 50,
                            ),
                            Text('  瞬记')
                          ],
                        ),
//                  SizedBox(
//                    child: Icon(Icons.chevron_right),
//                  ),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              _momentInfo.count.toString(),
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Theme.of(context).accentColor),
                            ),
                            Text(' 条',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context)
                                        .textTheme
                                        .display3
                                        .color)),
                          ],
                        ),
                      )),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              _momentInfo.wordCount.toString(),
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Theme.of(context).accentColor),
                            ),
                            Text(' 字',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context)
                                        .textTheme
                                        .display3
                                        .color)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              _momentInfo.imgCount.toString(),
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Theme.of(context).accentColor),
                            ),
                            Text(' 张',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context)
                                        .textTheme
                                        .display3
                                        .color)),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            /* Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              color: Theme.of(context).cardColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/statistics');
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.multiline_chart),
                        Text('统计')
                      ],
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      print('1234');
                    },
                    child: Column(
                      children: <Widget>[Icon(Icons.turned_in_not), Text('事件')],
                    ),
                  )
                ],
              ),
            ),*/
            SizedBox(height: 15),
            Card(
              elevation: 0,
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 30),
                title: Text('统计'),
                leading: Icon(Icons.multiline_chart),
                trailing: Icon(Icons.chevron_right),
                onTap: () => _to('/statistics'),
              ),
            ),
            Card(
              elevation: 0,
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 30),
                title: Text('夜间模式'),
                leading: Icon(Icons.brightness_2),
                trailing: Switch(
                  value: Provider.of<ThemeProvider>(context).isNightTheme,
                  onChanged: (bool val) {
                    Provider.of<ThemeProvider>(context).switchNightTheme(val);
                  },
                ),
              ),
            ),
            Card(
              elevation: 0,
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 30),
                title: Text('设置'),
                leading: Icon(Icons.settings),
                trailing: Icon(Icons.chevron_right),
                onTap: () => _to('/setting'),
              ),
            ),
            Card(
              elevation: 0,
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 30),
                leading: Icon(Icons.mode_comment),
                title: Text('反馈 - 酷安'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  launchURL('market://details?id=com.cy.moment');
                },
              ),
            ),
            Card(
              elevation: 0,
              child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 30),
                  title: Text('分享'),
                  leading: Icon(Icons.share),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    ShareExtend.share(
                        '让我们记录这美好的瞬间~ (≧∇≦)ﾉ \r\n https://www.coolapk.com/apk/com.cy.moment',
                        'text');
                  }),
            )
          ],
        ),
      ),
    );
  }

  _to(String path) {
    Navigator.of(context).pushNamed(path);
  }

  _queryAllMomentInfo() async {
    final MomentInfo res = await SQL.queryAllMomentInfo();
    setState(() {
      _momentInfo = res;
    });
  }
}
