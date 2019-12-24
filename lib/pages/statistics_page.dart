import "package:flutter/material.dart";
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moment/components/chart/Line.dart';
import 'package:moment/components/chart/pie.dart';
import 'package:moment/sql/query_chart.dart';
import 'package:moment/utils/date.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPagePageState createState() => _StatisticsPagePageState();
}

class _StatisticsPagePageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin /*, AutomaticKeepAliveClientMixin*/ {
  TabController tabController;
  final List<Tab> _tabs = const [Tab(text: '情绪管理'), Tab(text: '事件管理')];

//事件
  Map<String, int> pie = Map();
  PieOpt pieOpt = PieOpt(DateTime.now().millisecondsSinceEpoch - YEAY_MS,
      DateTime.now().millisecondsSinceEpoch);

// 情绪
  bool isYearView = true;
  int lineYear = 2019;
  int lineMonth = 11;
  Map<double, dynamic> lineDate = Map();
  Map<double, dynamic> mothDate = Map();
  Map<String, int> facePie = Map();

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
    fetchFaceByYear();
  }

  fetchByEventData({int start, int end}) async {
    Map res;
    if (start != null && end != null) {
      if (end <= start) {
        Fluttertoast.showToast(msg: '开始时间需大于结束时间 ~');
        return;
      }
      res = await ChartSQL.queryEventByTimeRange(start: start, end: end);
    } else {
      res = await ChartSQL.queryEventByTimeRange();
    }

    setState(() {
      pie = res;
    });
  }

  fetchFaceByYear() async {
    final res = await ChartSQL.queryFaceByYearCaWithMonth(lineYear.toString());
    final res2 = await ChartSQL.queryEventByYear(lineYear.toString());

    setState(() {
      lineDate = res;
      facePie = res2;
    });
  }

  fetchFaceByMonth() async {
    final String time = '$lineYear${lineMonth > 9 ? lineMonth : "0$lineMonth"}';

    final res = await ChartSQL.queryFaceByMonth(time);
    final res2 = await ChartSQL.queryEventByMonth(time);

    setState(() {
      lineDate = res;
      facePie = res2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TabBar(
          controller: tabController,
          indicatorWeight: 2,
          indicatorPadding: const EdgeInsets.only(left: 5, right: 5),
          indicatorSize: TabBarIndicatorSize.label,
          isScrollable: true,
          tabs: _tabs,
        ),
        titleSpacing: 0,
      ),
      body: TabBarView(
        controller: tabController,
        children: <Widget>[
          ListView(
            children: <Widget>[
              MLine(
                lineDate,
                isYearView: isYearView,
                title: '情绪波动',
                actions: <Widget>[
                  PopupMenuButton(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(lineYear.toString()),
                    ),
                    onSelected: (i) {
                      setState(() {
                        lineYear = i;
                      });
                      fetchFaceByYear();
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
                  ),
                  if (!isYearView) Text('—'),
                  if (!isYearView)
                    PopupMenuButton(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(lineMonth.toString()),
                      ),
                      onSelected: (i) {
                        setState(() {
                          lineMonth = i;
                        });
                        fetchFaceByMonth();
                      },
                      initialValue: lineMonth,
                      itemBuilder: (_) {
                        return List.generate(12, (i) {
                          return PopupMenuItem(
                            child: Text('${i + 1}月'),
                            value: i + 1,
                          );
                        });
                      },
                    ),
                  IconButton(
                    tooltip: '切换年/月视图',
                    icon: Icon(Icons.swap_horiz),
                    onPressed: () {
                      setState(() {
                        isYearView = !isYearView;
                      });
                      if (isYearView) {
                        fetchFaceByYear();
                      } else {
                        fetchFaceByMonth();
                      }
                    },
                  )
                ],
              ),
              MPieChart(
                facePie,
                facePie.keys.toList(),
                facePie.values.toList(),
                title: '情感 TOP 8',
              ),
            ],
          ),
          MPieChart(
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
          )
        ],
      ),
    );
  }

  _showDatePicker(int defaultT, Cb cb) {
    const String MIN_DATETIME = '2018-12-15';
    const String MAX_DATETIME = '2029-12-25';

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
      },
    );
  }
}

class PieOpt {
  int start, end;

  PieOpt(this.start, this.end);
}

typedef void Cb(int);
