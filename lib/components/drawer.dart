import 'package:flutter/material.dart';
import "package:moment/constants/app.dart";

class DrawerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Widget> defaultDrawerList = [
      DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
        ),
        child: Center(
          child: Wrap(
            direction: Axis.vertical,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 100,
                height: 100,
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Image.asset(
                    'lib/asserts/logo/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                child: Text(
                  Constants.appDes,
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
                margin: EdgeInsets.only(top: 10),
              )
            ],
          ),
        ),
      ),
      Divider(height: 1),
    ];

    List<Widget> _buildTab() {
      List<Widget> tabWidget = [];
      for (var tab in Constants.sidebarTab) {
        tabWidget.add(ListTile(
            leading: tab.icon,
            title: tab.text,
            onTap: () {
              if (tab.f != null) {
                Navigator.pop(context);
                (tab.f)();
              } else if (tab.path != null && tab.path.length > 0) {
                if (tab.path == '/home') {
                  Navigator.pop(context);
                  return;
                }
                Navigator.popAndPushNamed(context, tab.path);
              }
            }));
        tabWidget.add(Divider(height: 1));
      }
      return tabWidget;
    }

    defaultDrawerList.addAll(_buildTab());

    return new Drawer(
      child: Container(
        child: new Column(
          children: defaultDrawerList,
        ),
      ),
    );
  }
}
