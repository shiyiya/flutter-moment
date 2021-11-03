import 'package:fl_chart/fl_chart.dart';
import "package:flutter/material.dart";

class MLine extends StatelessWidget {
  final List colors = const [
    Color(0xfff8b250),
    Color(0xff845bef),
    Color(0xff13d38e),
    Colors.amber,
    Colors.purpleAccent,
    Colors.lightBlue,
    Colors.brown,
    Colors.red
  ];
  final String title;
  final List<Widget> actions;
  final Map<double, dynamic> data;

  final bool isYearView;

  MLine(this.data, {this.title, this.actions, this.isYearView = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
            elevation: 0.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                      child: Text(
                        title ?? '',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(children: actions ?? []),
                    )
                  ],
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 3,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: AspectRatio(
                    aspectRatio: 1.23,
                    child: Container(
                      child: Padding(
                          padding:
                              const EdgeInsets.only(right: 16.0, left: 6.0),
                          child: LineChart(
                            sampleData1(),
                            swapAnimationDuration: Duration(milliseconds: 250),
                          )),
                    ),
                  ),
                )
              ],
            ))
      ],
    );
  }

  LineChartData sampleData1() {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(show: true, horizontalInterval: 20),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          // textStyle: TextStyle(
          //   color: const Color(0xff72719b),
          //   fontWeight: FontWeight.bold,
          //   fontSize: 12,
          // ),
          margin: 10,
          getTitles: getTitle,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          // textStyle: TextStyle(
          //   color: const Color(0xff75729e),
          //   fontWeight: FontWeight.bold,
          //   fontSize: 14,
          // ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return '0';
              case 20:
                return '20';
              case 40:
                return '40';
              case 60:
                return '60';
              case 80:
                return '80';
              case 100:
                return '100';
            }
            return '';
          },
          margin: 8,
          reservedSize: 25,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(
              color: const Color(0xff4e4965),
              width: 2,
            ),
            left: BorderSide(
              color: Colors.transparent,
            ),
            right: BorderSide(
              color: Colors.transparent,
            ),
            top: BorderSide(
              color: Colors.transparent,
            ),
          )),
      minX: 0,
      maxX: isYearView ? 13 : 15,
      maxY: 100,
      minY: 0,
      lineBarsData: linesBarData1(),
    );
  }

  List<LineChartBarData> linesBarData1() {
    final keys = data?.keys?.toList() ?? [];
    final values = data?.values?.toList() ?? [];

    LineChartBarData lineChartBarData1 = LineChartBarData(
      spots: keys.length > 0
          ? List.generate(keys.length, (i) {
              return FlSpot(keys[i].toDouble(), values[i].toDouble());
            })
          : [FlSpot(0, 0)],
      isCurved: true,
      colors: [
        Color(0xff4af699),
      ],
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );

    return [
      lineChartBarData1,
    ];
  }

  String getTitle(double value) {
    if (isYearView) {
      return getYearTitles(value);
    }

    if (value.toInt() == 0 || value.toInt() == 15) return '';
    return (value.toInt() * 2).toString();
  }

  String getYearTitles(value) {
    switch (value.toInt()) {
      case 2:
        return 'Feb';
      case 4:
        return 'Apr';
      case 6:
        return 'June';
      case 8:
        return 'Aug';
      case 10:
        return 'Oct';
      case 12:
        return 'Dec';
    }
    return '';
  }
}
