import "package:flutter/material.dart";
import 'package:moment/constants/app.dart';
import 'package:moment/service/sqlite.dart';
import 'package:moment/pages/home_page.dart';

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  loadEvents() async {
    final db = await DBHelper.db;
    final event = await db.query('moment_content', columns: ['event', 'face']);

    final List l = event.toList();
    l.removeWhere((_) {
      return _['event'] == null || _['event'].length < 1;
    });

    setState(() {
      _events = l;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('事件'),
        ),
        body: _events.length > 0
            ? Container(
                padding: EdgeInsets.all(8),
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(top: 20),
                child: Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  direction: Axis.horizontal,
                  children: buildEventTag(),
                ),
              )
            : Center(
                child: Text(Constants.randomNilTip(),
                    style: Theme.of(context).textTheme.body2),
              ));
  }

  List<Widget> buildEventTag() {
    return _events
        .map((e) => MaterialButton(
            padding: EdgeInsets.all((0)),
            child: Chip(
              avatar: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(
                    Constants.face[e['face']],
                    color: Theme.of(context).primaryColor,
                  )),
              label: Text(e['event']),
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return HomePage(event: e['event']);
              }), (Route<dynamic> route) => true);
            }))
        .toList();
  }
}
