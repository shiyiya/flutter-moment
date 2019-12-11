import 'package:fluttertoast/fluttertoast.dart';
import 'package:moment/service/sqlite.dart';
import 'package:moment/type/event.dart';

class EventSQL {
  static Future<int> newEvent(Event event) async {
    return await (await DBHelper.db).insert('moment_event', event.toJson());
  }

  static Future<List<Event>> queryEvent() async {
    final res = await (await DBHelper.db).query('moment_event');
    return res.map((r) => Event.fromJson(r)).toList();
  }

  static Future<bool> delEvent(int id) async {
    final res = await (await DBHelper.db)
        .delete('moment_event', where: 'id = ?', whereArgs: [id]);
    if (res is int) {
      Fluttertoast.showToast(msg: '删除成功');
      return true;
    }
    return false;
  }

  static Future<List<Event>> randomEvent() async {
    final res = await (await DBHelper.db)
        .rawQuery('SELECT * FROM moment_event ORDER BY RANDOM() limit 8');
    return res.map((r) => Event.fromJson(r)).toList();
  }
}
