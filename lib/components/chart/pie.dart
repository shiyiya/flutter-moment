import 'package:fl_chart/fl_chart.dart';
import "package:flutter/material.dart";
import 'package:moment/components/chart/indicator.dart';

class MPieChart extends StatefulWidget {
  final Map<String, int> pieData;
  final List<String> pieKey;
  final List<int> pieVal;

  final String title;
  final List<Widget> actions;

  MPieChart(this.pieData, this.pieKey, this.pieVal, {this.title, this.actions});

  @override
  State<StatefulWidget> createState() => _MPieChartState();
}

class _MPieChartState extends State<MPieChart> {
  List colors = const [
    Color(0xfff8b250),
    Color(0xff845bef),
    Color(0xff13d38e),
    Colors.amber,
    Colors.purpleAccent,
    Colors.lightBlue,
    Colors.brown,
    Colors.red
  ];
  int touchedIndex;

  @override
  Widget build(BuildContext context) {
    final len = widget.pieKey.length;
    final List<String> top8Key =
        len >= 8 ? widget.pieKey.sublist(0, 8) : widget.pieKey;
    final List<int> top8Val =
        len >= 8 ? widget.pieVal.sublist(0, 8) : widget.pieVal;

    top8Val.sort((l, r) {
      return r.compareTo(l);
    });

    return Column(
      children: <Widget>[
        Card(
          elevation: 0.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Text(widget.title ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(children: widget.actions ?? []),
                  )
                ],
              ),
              len < 1
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          '暂无数据',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : AspectRatio(
                      aspectRatio: 1.8,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: PieChart(
                                PieChartData(
                                    pieTouchData: PieTouchData(
                                        //     touchCallback: (pieTouchResponse) {
                                        //   setState(() {
                                        //     if (pieTouchResponse.touchInput
                                        //             is FlLongPressEnd ||
                                        //         pieTouchResponse.touchInput
                                        //             is FlPanEnd) {
                                        //       touchedIndex = -1;
                                        //     } else {
                                        //       touchedIndex = pieTouchResponse
                                        //           .touchedSectionIndex;
                                        //     }
                                        //   });
                                        // }
                                        ),
                                    borderData: FlBorderData(
                                      show: false,
                                    ),
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 40,
                                    sections:
                                        showingSections(top8Key, top8Val)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
            ],
          ),
        ),
        Card(
            elevation: 0.0,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: len < 1
                  ? Center(
                      child: Text(
                        '暂无数据',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Column(
                      children: List.generate(len, (i) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              child: Indicator(
                                color: colors[i],
                                text: top8Key[i],
                                textColor: colors[i],
                                isSquare: true,
                              ),
                            ),
                            Text((top8Val[i]?.toString()) ?? '0')
                          ],
                        );
                      }),
                    ),
            ))
      ],
    );
  }

  List<PieChartSectionData> showingSections(List key, List val) {
    return List.generate(key.length, (i) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 20 : 14;
      final double radius = isTouched ? 60 : 50;

      return PieChartSectionData(
        color: colors[i],
        value: val[i] + 0.0,
        title: key[i].toString(),
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
      );
    });
  }
}
