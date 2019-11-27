import "package:flutter/material.dart";
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moment/components/chart/Line.dart';
import 'package:moment/components/chart/pie.dart';

import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:moment/sql/query_chart.dart';
import 'package:moment/utils/date.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPagePageState createState() => _StatisticsPagePageState();
}

class _StatisticsPagePageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin /*, AutomaticKeepAliveClientMixin*/ {
  TabController tabController;
  final _tabs = const ['情绪管理', '事件管理'];

  Map<String, int> pie = Map();
  PieOpt pieOpt = PieOpt(DateTime.now().millisecondsSinceEpoch - YEAY_MS,
      DateTime.now().millisecondsSinceEpoch);

  int lineYear = 2019;
   Map<int, dynamic> lineDate = Map();
  final a =Map();

//  @override
//  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: _tabs.length,
      vsync: this,
    )..addListener(() {
        if (tabController.index.toDouble() == tabController.animation.value) {
          //switch (tabController.index)
        }
      });
    fetchData();
  }

  fetchData() {
    fetchByEventData();
    fetchByFace();
  }

  fetchByEventData({int start, int end}) async {
    Map res;
    if (start != null && end != null) {
      if (end <= start) {
        Fluttertoast.showToast(msg: '开始时间需大于结束时间 ~');
        return;
      }
      res = await ChartSQL.queryTagByTimeRange(start: start, end: end);
    } else {
      res = await ChartSQL.queryTagByTimeRange();
    }

    setState(() {
      pie = res;
    });
  }

  fetchByFace() async {
    final res = await ChartSQL.queryFaceByYearCaWithMonth(lineYear.toString());
    setState(() {
      lineDate = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('图表'),
        centerTitle: true,
        bottom: TabBar(
          controller: tabController,
          tabs: _tabs
              .map((String name) => Container(
                    child: Text(
                      name,
                    ),
                    padding: const EdgeInsets.only(bottom: 5.0),
                  ))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: <Widget>[
          MLine(
            lineDate,
            title: '情感线',
            actions: <Widget>[
              Text(lineYear.toString()),
              PopupMenuButton(
                onSelected: (i) {
                  setState(() {
                    lineYear = i;
                  });
                  fetchByFace();
                },
                initialValue: lineYear,
                itemBuilder: (_) {
                  const year = 2018;
                  return List.generate(7, (i) {
                    return PopupMenuItem(
                      child: Text((year + i).toString()),
                      value: year + i,
                    );
                  });
                },
              )
            ],
          ),
          Container(
            child: MPieChart(
              pie,
              pie.keys.toList(),
              pie.values.toList(),
              title: '事件 TOP 8',
              actions: <Widget>[
                MaterialButton(
                  minWidth: 14,
                  onPressed: () {
                    _showDatePicker(pieOpt.start, (t) {
                      setState(() {
                        pieOpt.start = t;
                      });
                      fetchByEventData(start: pieOpt.start, end: pieOpt.end);
                    });
                  },
                  child: Text(
                    pieOpt.start.toString() != null
                        ? Date.getDateFormatYMD(ms: pieOpt.start)
                        : '',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Text('—'),
                MaterialButton(
                  minWidth: 14,
                  onPressed: () {
                    _showDatePicker(pieOpt.end, (t) {
                      setState(() {
                        pieOpt.end = t;
                      });
                      fetchByEventData(start: pieOpt.start, end: pieOpt.end);
                    });
                  },
                  child: Text(
                    pieOpt.end != null
                        ? Date.getDateFormatYMD(ms: pieOpt.end)
                        : '',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _showDatePicker(int defaultT, Cb cb) {
    const String MIN_DATETIME = '2018-12-15';
    const String MAX_DATETIME = '2050-12-25';

    DatePicker.showDatePicker(
      context,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
        confirm: Text(
          '确定',
          style: TextStyle(color: Theme.of(context).accentColor),
        ),
        cancel:
            Text('取消', style: TextStyle(color: Theme.of(context).hintColor)),
      ),
      minDateTime: DateTime.parse(MIN_DATETIME),
      maxDateTime: DateTime.parse(MAX_DATETIME),
      initialDateTime: DateTime.fromMicrosecondsSinceEpoch(defaultT * 1000),
      locale: DateTimePickerLocale.zh_cn,
      onConfirm: (DateTime dateTime, List<int> index) {
        cb(dateTime.millisecondsSinceEpoch);
//        fetchData(start: pieOpt.start, end: pieOpt.end);
        print(
            'fetch ${DateTime.fromMicrosecondsSinceEpoch(pieOpt.start * 1000)} - ${DateTime.fromMicrosecondsSinceEpoch(pieOpt.end * 1000)}');
      },
    );
  }
}

class PieOpt {
  int start, end;

  PieOpt(this.start, this.end);
}

typedef void Cb(int);
