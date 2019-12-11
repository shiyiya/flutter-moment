import "package:flutter/material.dart";
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moment/constants/app.dart';
import 'package:moment/sql/query_event.dart';
import 'package:moment/type/event.dart';

class EventManagerPage extends StatefulWidget {
  @override
  _EventManagerPageState createState() => _EventManagerPageState();
}

class _EventManagerPageState extends State<EventManagerPage> {
  List<Event> event;
  String newE;
  String newED;

  @override
  initState() {
    super.initState();
    queryEvent();
  }

  void queryEvent() async {
    final List<Event> res = await EventSQL.queryEvent();
    setState(() {
      event = res;
    });
  }

  void delEvent(int id) async {
    final res = await EventSQL.delEvent(id);

    if (res) {
      setState(() {
        event.removeWhere((e) => e.id == id);
      });
    }
  }

  void newEvent() async {
    // todo 过滤重复名 此 sql 不支持 unique
    if (newE == null || newE.length < 1) return;

    final _event = Event(
      name: newE,
      description: newED,
      created: DateTime.now().millisecondsSinceEpoch,
    );
    final res = await EventSQL.newEvent(_event);

    if (res is int) {
      setState(() {
        event.add(_event);
      });
    } else {
      Fluttertoast.showToast(msg: '添加失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: showNewEventDialog,
            )
          ],
          expandedHeight: 150.0,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            title: Text('事件库'),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(List.generate(1, (int index) {
            return Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                height: (event == null || event.length < 1)
                    ? MediaQuery.of(context).size.height * 0.5
                    : null,
                child: (event == null || event.length < 1)
                    ? Center(child: Text(Constants.randomNilTip()))
                    : SingleChildScrollView(
                        child: Wrap(
                          spacing: 10,
                          children: event
                              .map((Event e) => InputChip(
                                    label: Text(e.name),
                                    deleteButtonTooltipMessage: "删除",
                                    onSelected: (_) {},
                                    onDeleted: () {
                                      delEvent(e.id);
                                    },
                                  ))
                              .toList(),
                        ),
                      ));
          })),
        ),
      ]),
    );
  }

  void showNewEventDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            title: Text('事件'),
            content: Wrap(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    hintText: '请输入事件简称',
                  ),
                  onChanged: (e) {
                    setState(() {
                      newE = e;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: '请输入事件描述（非必选）',
                  ),
                  onChanged: (e) {
                    setState(() {
                      newED = e;
                    });
                  },
                )
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('确认'),
                onPressed: () {
                  newEvent();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
