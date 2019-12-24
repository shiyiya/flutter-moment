import 'package:moment/service/sqlite.dart';

class FlagSQL {
  static Future newFlag({String title, int time, int notifyTime}) async {
    return await (await DBHelper.db).insert('moment_flag', {
      'title': title,
      'time': time,
      'notifyTime': notifyTime,
      'created': DateTime.now().millisecondsSinceEpoch
    });
  }

  static Future queryFlag(int id) async {
    return await (await DBHelper.db)
        .query('moment_flag', columns: ['*'], where: 'id = ?', whereArgs: [id]);
  }
}
