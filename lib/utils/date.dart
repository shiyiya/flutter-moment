class Date {
  static List weekMap = [
    '周一',
    '周二',
    '周三',
    '周四',
    '周五',
    '周六',
    '周日',
  ];

  static DateTime getDateTimeByMS({int ms}) {
    return ms != null
        ? DateTime.fromMicrosecondsSinceEpoch(ms * 1000)
        : DateTime.now();
  }

  static String getDateFormatYMD({String prefix = '-', int ms}) {
    DateTime now = getDateTimeByMS(ms: ms);
    int y = now.year;

    return "$y$prefix${getDateFormatMD(ms: ms)}";
  }

  static String getDateFormatMD({String prefix = '-', int ms}) {
    DateTime now = getDateTimeByMS(ms: ms);

    int m = now.month;
    int d = now.day;

    return "$m$prefix$d";
  }

  static getWeekByMS({int ms}) {
    DateTime now = getDateTimeByMS(ms: ms);

    return weekMap[now.weekday - 1];
  }

  String getBeforeTimeByMS({int ms}) {
    DateTime now = getDateTimeByMS();
    DateTime t = getDateTimeByMS(ms: ms);

    var d = now.difference(t);
    if (d.isNegative) {
      return t.toIso8601String();
    } else if (d.inMilliseconds < 1000) {
      return "刚刚";
    } else if (d.inSeconds < 60) {
      return d.inSeconds.toString() + "秒前";
    } else if (d.inMinutes < 60) {
      return d.inMinutes.toString() + "分钟前";
    } else if (d.inHours < 24) {
      return d.inHours.toString() + "小时前";
    } else if (d.inDays < 7) {
      return d.inDays.toString() + "天前";
    } else if (d.inDays < 30) {
      return (d.inDays ~/ 7).toString() + "周前";
    } else if (d.inDays < 180) {
      return (d.inDays ~/ 30).toString() + "个月前";
    } else {
      return t.day.toString() +
          "-" +
          t.month.toString() +
          "-" +
          t.day.toString();
    }
  }
}
