import 'dart:ui';

import 'package:flutter/material.dart';
// import 'package:moment/pages/tucao_page.dart';
import 'package:moment/provides/theme.dart';
import 'package:moment/service/event_bus.dart';
import 'package:moment/service/instances.dart';
import 'package:moment/sql/query.dart';
import 'package:moment/type/moment.dart';
import 'package:provider/provider.dart';
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
      _queryAllMomentInfo();
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
              height: MediaQuery.of(context).size.height / 4,
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
                                color: Instances.currentThemeColor,
                              ),
                            ),
                            Text(' 条',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline3
                                        .color)),
                          ],
                        ),
                      )),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(_momentInfo.wordCount.toString(),
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Instances.currentThemeColor,
                                )),
                            Text(' 字',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline3
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
                                color: Instances.currentThemeColor,
                              ),
                            ),
                            Text(' 图',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline3
                                        .color)),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Card(
              elevation: 0,
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 30),
                title: const Text('夜间模式'),
                leading: Icon(Icons.brightness_3),
                trailing: Switch(
                  value: Provider.of<ThemeProvider>(context).isNightTheme,
                  onChanged: (bool val) {
                    Provider.of<ThemeProvider>(context)
                        .switchNightTheme(value: val);
                  },
                ),
                onTap: () =>
                    Provider.of<ThemeProvider>(context).switchNightTheme(),
              ),
            ),
            Card(
              elevation: 0,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                title: const Text('图表'),
                leading: const Icon(Icons.multiline_chart),
                trailing: Icon(Icons.chevron_right),
                onTap: () => _to('/statistics'),
              ),
            ),
            Card(
              elevation: 0,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                title: const Text('事件库'),
                leading: const Icon(Icons.turned_in_not),
                trailing: Icon(Icons.chevron_right),
                onTap: () => _to('/eventmanager'),
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
            // Card(
            //   elevation: 0,
            //   child: ListTile(
            //     contentPadding: EdgeInsets.symmetric(horizontal: 30),
            //     leading: const Icon(Icons.chat_bubble_outline),
            //     title: Text('吐个槽'),
            //     trailing: Icon(Icons.chevron_right),
            //     onTap: () {
            //       Navigator.pushAndRemoveUntil(
            //           context,
            //           MaterialPageRoute(builder: (_) => TuCaoPage()),
            //           (Route<dynamic> route) => true);
            //     },
            //   ),
            // ),
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
                      'text',
                    );
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
