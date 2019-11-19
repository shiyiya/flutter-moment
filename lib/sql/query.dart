import 'package:sqflite/sqflite.dart';
import 'package:moment/service/sqlite.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moment/type/moment.dart';

class SQL {
  static Future<int> queryAllMomentCount() async {
    return Sqflite.firstIntValue(await (await DBHelper.db)
        .rawQuery('SELECT COUNT(*) FROM moment_content'));
  }

  static Future<int> queryAllMomentWordCount() async {
    final List<Map<String, dynamic>> text =
    await (await DBHelper.db).rawQuery('SELECT text FROM moment_content');

    int count = 0;
    text.forEach((t) {
      count += t['text'].length;
    });

    return count;
  }

  static Future<int> queryAllMomentImgCount() async {
    final List<Map<String, dynamic>> res =
    await (await DBHelper.db).rawQuery('SELECT alum FROM moment_content');

    //todo
  }

  static Future<MomentInfo> queryAllMomentInfo() async {
    final int count = await queryAllMomentCount();
    final int wordCount = await queryAllMomentWordCount();

    return MomentInfo(count: count, wordCount: wordCount);
  }

  static Future<List<Moment>> queryMomentByPage(int page) async {
    final res = await (await DBHelper.db).query('moment_content',
        columns: ['*'], limit: 10, offset: page * 10, orderBy: 'created desc');

    if (res.length < 1) {
      Fluttertoast.showToast(msg: '没有更多啦 ∑( 口 ||');
      return null;
    }
    Fluttertoast.showToast(msg: '加载成功 (#`O′)');
    return res.map((r) => Moment.fromJson(r)).toList();
  }

  static Future<List<Moment>> queryMomentByPageWithFilter(int page,
      String whereColumns, List whereArgs) async {
    final res = await (await DBHelper.db).query(
      'moment_content',
      columns: ['*'],
      where: whereColumns,
      whereArgs: whereArgs,
      limit: 10,
      offset: page * 10,
      orderBy: 'created DESC',
    );

    if (res.length < 1) {
      Fluttertoast.showToast(msg: '没有更多啦 ∑( 口 ||');
      return null;
    }

    Fluttertoast.showToast(msg: '加载成功 (#`O′)');
    return res.map((r) => Moment.fromJson(r)).toList();
  }

  static Future<Moment> queryMomentById(int id) async {
    final List<Map<String, dynamic>> res = await (await DBHelper.db)
        .rawQuery('SELECT * FROM moment_content WHERE cid = ?', [id]);

    if (res.length < 1) {
      Fluttertoast.showToast(msg: '哎呀，没抓到那条瞬间');
      return null;
    }

    Fluttertoast.showToast(msg: '加载成功 (#`O′)');
    return Moment.fromJson(res[0]);
  }

  static Future<bool> delMomentById(int id) async {
    int count = await (await DBHelper.db)
        .rawDelete('DELETE FROM moment_content WHERE cid = ?', [id]);

    if (count == 1) {
      Fluttertoast.showToast(msg: '删除成功');
      return true;
    } else {
      Fluttertoast.showToast(msg: '删除失败');
      return false;
    }
  }
}
