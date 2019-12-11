import 'package:moment/service/face.dart';
import 'package:moment/service/sqlite.dart';
import 'package:moment/utils/date.dart';

class ChartSQL {
  // 情绪折线图 年
  static Future<Map<double, dynamic>> queryFaceByYearCaWithMonth(
      String year) async {
    final _year = DateTime.parse('${year}0101');
    final start = _year.millisecondsSinceEpoch;
    final end = _year.millisecondsSinceEpoch + YEAY_MS;

    final List yearData = await (await DBHelper.db).rawQuery(
        'select created, face from moment_content where created>=$start AND created<$end');

    final Map<double, dynamic> monthDate = Map();
    yearData.forEach((data) {
      final double month =
          (((data['created'] - start) / MONTH_MS).floor()).toDouble();

      if (monthDate[month] == null) {
        monthDate[month] = [data['face']];
      } else {
        monthDate[month].add(data['face']);
      }
    });

    monthDate.forEach((k, v) {
      final total = v.reduce((l, r) => l + r);
      monthDate[k] = total / v.length;
    });
    return monthDate;
  }

  // 情绪折线图 月
  static Future<Map> queryFaceByMonth(String time /* eg: 201901 */) async {
    final _month = DateTime.parse('${time}01');
    final start = _month.millisecondsSinceEpoch;
    final end = _month.millisecondsSinceEpoch + MONTH_MS;

    final List monthData = await (await DBHelper.db).rawQuery(
        'select created, face from moment_content where created>=$start AND created<$end');

    final Map<double, dynamic> dayData = Map();
    monthData.forEach((data) {
      final double day =
          ((data['created'] - start) / DAY_MS).round() / 2; //图标显示刻度为15天

      if (dayData[day] == null) {
        dayData[day] = [data['face']];
      } else {
        dayData[day].add(data['face']);
      }
    });

    dayData.forEach((k, v) {
      final total = v.reduce((l, r) => l + r);
      dayData[k] = total / v.length;
    });

    return dayData;
  }

  // 情绪饼图 年
  static Future<Map<String, int>> queryEventByYear(String year
      /* eg: 201901 */) async {
    final _year = DateTime.parse('${year}0101');
    final start = _year.millisecondsSinceEpoch;
    final end = _year.millisecondsSinceEpoch + YEAY_MS;

    return await queryFaceByTimeRange(start: start, end: end);
  }

  // 情绪饼图 月
  static Future<Map<String, int>> queryEventByMonth(String time
      /* eg: 201901 */) async {
    final _month = DateTime.parse('${time}01');
    final start = _month.millisecondsSinceEpoch;
    final end = _month.millisecondsSinceEpoch + MONTH_MS;
    return await queryFaceByTimeRange(start: start, end: end);
  }

  // 事件 ByTimeRange
  static Future<Map<String, int>> queryEventByTimeRange(
      {int start, int end}) async {
    List r;
    Map<String, int> tagMap = {};

    if (start == null || end == null) {
      r = await (await DBHelper.db).rawQuery('select E.name from content_event as CE left join moment_event as E on E.id = CE.eid');
    } else {
      r = await (await DBHelper.db).rawQuery(
          'select E.name from content_event as CE left join moment_event as E on E.id = CE.eid where created>=$start AND created<$end');
    }

    r.forEach((tag) {
      if (tag['name'].length > 0) {
        if (tagMap[tag['name']] != null) {
          tagMap[tag['name']] += 1;
        } else {
          tagMap[tag['name']] = 1;
        }
      }
    });

    return tagMap;
  }

  // 情绪 ByTimeRange
  static Future<Map<String, int>> queryFaceByTimeRange(
      {int start, int end}) async {
    List r;

    if (start == null || end == null) {
      r = await (await DBHelper.db).query('moment_content', columns: ['face']);
    } else {
      r = await (await DBHelper.db).rawQuery(
          'select face from moment_content where created>=$start AND created<$end');
    }

    Map<String, int> faceMap = {};
    r.forEach((item) {
      final String key = Face.getStatusByNum(item['face']);
      if (faceMap[key] != null) {
        faceMap[key] += 1;
      } else {
        faceMap[key] = 1;
      }
    });

    return faceMap;
  }
}
