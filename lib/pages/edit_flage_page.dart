// import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:moment/utils/date.dart';

class EditFlagPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EditFlagPageState();
  }
}

class _EditFlagPageState extends State<EditFlagPage> {
  TextEditingController _textController = TextEditingController();
  int time;
  int timeDay;
  int notifyTime;
  String text = '';

  @override
  void initState() {
    super.initState();
    _textController.text = text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.clear),
                    iconSize: 36,
                    onPressed: () {},
                  ),
                  SizedBox(height: 40),
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '预言即将发生...',
                    ),
                    maxLength: 10,
                    style: TextStyle(fontSize: 48),
                  ),
                  SizedBox(height: 20),
                  ListTile(
                    leading: Icon(Icons.alarm_add),
                    title: Text(time != null
                        ? Date.getDateFormatYMD(ms: time)
                        : '何日发生'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: _showDatePicker,
                  ),
                  ListTile(
                    leading: Icon(Icons.alarm),
                    title: Text(timeDay != null
                        ? Date.getDateFormatHMByMS(ms: (time + timeDay))
                        : '何时发生'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: _showTimePicker,
                  ),
//                  ListTile(
//                    leading: Icon(Icons.notifications_active),
//                    title: Text(notifyTime != null
//                        ? Date.getDateFormatHMByMS(
//                            ms: (time + timeDay + notifyTime))
//                        : '何时告知'),
//                    trailing: PopupMenuButton(
//                      child: Icon(Icons.chevron_right),
//                      itemBuilder: (_) {
//                        return List.generate(12, (i) {
//                          return PopupMenuItem(
//                            child: i + 1 <= 6
//                                ? Text('提前${i + 1}小时')
//                                : Text('延后${i + 1 - 6}小时'),
//                            value: i + 1 <= 6 ? i + 1 : -(i + 1 - 6),
//                          );
//                        });
//                      },
//                      onSelected: (i) {
//                        print(i);
//                        setState(() {
//                          notifyTime = i * HOUR_MS;
//                        });
//                      },
//                    ),
//                  ),
                  SizedBox(height: 40),
                  Center(
                    child: MaterialButton(
                      minWidth: MediaQuery.of(context).size.width * 0.8,
                      height: 50,
                      child: Text('Biu ~'),
                      color: Theme.of(context).backgroundColor.withOpacity(0.6),
                      onPressed: _biu,
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }

  _showDatePicker() async {
    final _time = await showDatePicker(
        context: context,
        initialDatePickerMode: DatePickerMode.day,
        initialDate: time != null
            ? DateTime.fromMicrosecondsSinceEpoch(time * 1000)
            : DateTime.now(),
        firstDate: DateTime.parse('20181215'),
        lastDate: DateTime.parse('20291215'));

    setState(() {
      time = _time.millisecondsSinceEpoch;
    });
  }

  _showTimePicker() async {
    final _time = await showTimePicker(
        context: context,
        initialTime: timeDay != null
            ? TimeOfDay.fromDateTime(DateTime.fromMicrosecondsSinceEpoch(
                time * 1000 + timeDay * 1000))
            : TimeOfDay.now());

    if (_time == null) return;

    final hours = _time.hour * HOUR_MS;
    final minutes = _time.hour * MINUTE_MS;
    final _timeMS = hours + minutes;

    print(
        '${_time.hour < 10 ? "0${_time.hour}" : _time.hour}:${_time.minute < 10 ? "0${_time.minute}" : _time.minute}');

    setState(() {
      timeDay = _timeMS;
    });
  }

  _biu() async {
//    print('--- $text $time $notifyTime ---');
    // final res = await FlagSQL.newFlag(
    //     title: _textController.text, time: time, notifyTime: notifyTime);

//    if (res is int) {
//      final Event event = Event(
//        title: '预言即将到来：${_textController.text}',
//        description: '预言即将到来：${_textController.text}',
//        startDate:
//            DateTime.fromMicrosecondsSinceEpoch(time * 1000 + timeDay * 1000),
//        endDate: DateTime.fromMicrosecondsSinceEpoch(
//            time * 1000 + timeDay * 1000 + 1),
//      );
//      Add2Calendar.addEvent2Cal(event);
//    print(await FlagSQL.queryFlag(res));

//    }
  }
}

// todo 颜色
