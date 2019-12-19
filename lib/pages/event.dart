import "package:flutter/material.dart";
import 'package:moment/constants/app.dart';
import 'package:moment/pages/home_page.dart';
import 'package:moment/service/face.dart';
import 'package:moment/service/sqlite.dart';

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
    final faceEvent = await db.rawQuery(
        'select C.face,E.name from content_event AS CE left join moment_content as C on CE.cid = C.cid left join moment_event as E on CE.eid = E.id');

    print(faceEvent);

    final List l = faceEvent.toList();
    l.removeWhere((l) => l['name'] == null || l['name'].isEmpty);

    setState(() {
      _events = l;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('事件'),
        ),
        body: _events.length > 0
            ? Container(
                padding: const EdgeInsets.all(8),
                alignment: Alignment.topCenter,
                margin: const EdgeInsets.only(top: 20),
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
            padding: const EdgeInsets.all((0)),
            child: Chip(
              avatar: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(
                    Constants.face[Face.getIndexByNum(e['face'])],
                    color: Theme.of(context).primaryColor,
                  )),
              label: Text(e['name']),
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return HomePage(event: e['name']);
              }), (Route<dynamic> route) => true);
            }))
        .toList();
  }
}
