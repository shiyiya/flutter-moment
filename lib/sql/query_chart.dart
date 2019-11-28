import 'package:moment/service/sqlite.dart';
import 'package:moment/utils/date.dart';

class ChartSQL {
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

  static Future<Map> queryFaceByMonth(String time /* eg: 201901 */) async {
    final _month = DateTime.parse('${time}01');
    final start = _month.millisecondsSinceEpoch;
    final end = _month.millisecondsSinceEpoch + MONTH_MS;

    final List monthData = await (await DBHelper.db).rawQuery(
        'select created, face from moment_content where created>=$start AND created<$end');

    print(monthData);

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
    print(dayData);

    return dayData;
  }

  static Future<Map<String, int>> queryEventByTimeRange(
      {int start, int end}) async {
    List r;
    Map<String, int> tagMap = {};

    if (start == null || end == null) {
      r = await (await DBHelper.db).query('moment_content', columns: ['event']);
    } else {
      r = await (await DBHelper.db).rawQuery(
          'select event from moment_content where created>=$start AND created<$end');
    }

    r.forEach((tag) {
      if (tag['event'].length > 0) {
        if (tagMap[tag['event']] != null) {
          tagMap[tag['event']] += 1;
        } else {
          tagMap[tag['event']] = 1;
        }
      }
    });

    print(tagMap.keys.toList());
    print(tagMap.values.toList());
    return tagMap;
  }

  // ----

  static Future<List> queryByMonth(String time) async {
    final _year = DateTime.parse("${time}01");

    final timeStartMS = _year.millisecondsSinceEpoch;
    final timeEndMS = _year.millisecondsSinceEpoch + MONTH_MS;
    return await queryByTimeRang(timeStartMS, timeEndMS);
  }

  // 前七天
  static queryByPreWeek(String time) async {
    final timeEndMS = DateTime.now().millisecondsSinceEpoch;
    final timeStartMS = timeEndMS - WEEK_MS;

    queryByTimeRang(timeStartMS, timeEndMS);
  }

  static queryByTimeRang(int start, int end) async {
    final r = await (await DBHelper.db).rawQuery(
        'select face from moment_content where created>=$start AND created<$end');

    return r;
  }

  static Future<Map<String, int>> queryFaceByTimeRange(
      {int start, int end}) async {
    List r;
    Map<String, int> tagMap = {};

    if (start == null || end == null) {
      r = await (await DBHelper.db).query('moment_content', columns: ['face']);
    } else {
      r = await (await DBHelper.db).rawQuery(
          'select face from moment_content where created>=$start AND created<$end');
    }

    r.forEach((tag) {
      if (tag['event'].length > 0) {
        if (tagMap[tag['event']] != null) {
          tagMap[tag['event']] += 1;
        } else {
          tagMap[tag['event']] = 1;
        }
      }
    });

    print(tagMap.keys.toList());
    print(tagMap.values.toList());
    return tagMap;
  }
}

class Face {
  int face;

  Face(this.face);
}

class Tag {
  int event;

  Tag(this.event);
}

class CreateWithFace {
  int face, created;
}
