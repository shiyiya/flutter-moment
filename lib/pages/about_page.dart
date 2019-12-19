import "package:flutter/material.dart";
import 'package:moment/components/card_with_title.dart';
import 'package:moment/utils/launcher.dart';
import 'package:package_info/package_info.dart';
import 'package:share_extend/share_extend.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String appName = '';
  String packageName = '';
  String version = '';
  String buildNumber = '';

  @override
  void initState() {
    getPackageInfo();
    super.initState();
  }

  getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      appName = packageInfo.appName;
      version = packageInfo.version;
      packageName = packageInfo.packageName;
      buildNumber = packageInfo.buildNumber;
    });
  }

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
                    title: Text(appName),
                    subtitle: Text('@ 2019 CY'),
                  ),
                  ListTile(
                    leading: Icon(Icons.info),
                    title: Text('版本'),
                    subtitle: Text('$version ($buildNumber)'),
                  ),
                ],
              ),
            ),
          ),
          CardWithTitle(
            padding: EdgeInsets.all(8),
            title: '分享 & 反馈',
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.share),
                title: Text('分享'),
                onTap: () => ShareExtend.share(
                    '让我们记录这美好的瞬间~ (≧∇≦)ﾉ \r\n https://www.coolapk.com/apk/$packageName',
                    'text'),
              ),
              ListTile(
                leading: Icon(Icons.star),
                title: Text('在应用市场(酷安)评分或者评论'),
                onTap: () {
                  launchURL('market://details?id=$packageName');
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
