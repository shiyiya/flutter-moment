import "package:flutter/material.dart";
import 'package:share/share.dart';
import 'package:moment/utils/launcher.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('关于')),
      body: Column(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(8),
              child: Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.bug_report),
                      title: Text('Moment - 瞬记'),
                      subtitle: Text('@ 2019 CY'),
                    ),
                    ListTile(
                      leading: Icon(Icons.info),
                      title: Text('版本'),
                      subtitle: Text('1.0.0 (2)'),
                    ),
                    ListTile(
                      leading: Icon(Icons.email),
                      title: Text('邮件'),
                      subtitle: Text('shiyiya.11@gmail.com'),
                      onTap: () =>
                          launchURL('mailto:shiyiya.11@gmail.com?subject=News'),
                    ),
                  ],
                ),
              )),
          Padding(
              padding: EdgeInsets.all(8),
              child: Card(
                child: Column(
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(top: 15, left: 15, bottom: 7),
                        child: Row(children: <Widget>[
                          Text('分享 & 反馈', style: TextStyle(fontSize: 18))
                        ])),
                    ListTile(
                      leading: Icon(Icons.share),
                      title: Text('分享'),
                      onTap: () => Share.share(
                          '让我们记录这美好的瞬间~ (≧∇≦)ﾉ \r\n https://www.coolapk.com/apk/com.cy.moment'),
                    ),
                    ListTile(
                      leading: Icon(Icons.star),
                      title: Text('在应用市场评分或者评论'),
                      onTap: () {}, //todo
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
