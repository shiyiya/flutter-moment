import 'package:moment/service/sqlite.dart';

class Model {
  static Future<List<Map<String, dynamic>>> loadMomentById(int id) async {
    final dynamic _moment = await (await DB.getInstance())
        .rawQuery('SELECT * FROM moment_content WHERE cid = ?', [id]);

    return _moment;
  }
}
