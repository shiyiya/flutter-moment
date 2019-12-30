import 'package:fluttertoast/fluttertoast.dart';
import 'package:moment/service/sqlite.dart';
import 'package:moment/type/moment.dart';
import 'package:sqflite/sqflite.dart';

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
        (await (await DBHelper.db).query('moment_content', columns: ['alum']))
            .toList();

    res.removeWhere((r) => r['alum'].length < 1);

    String alumList = '';
    res.forEach((r) {
      alumList += r['alum'];
    });

    return alumList.isEmpty ? 0 : alumList.split('|').length;
  }

  static Future<MomentInfo> queryAllMomentInfo() async {
    final int count = await queryAllMomentCount();
    final int wordCount = await queryAllMomentWordCount();
    final int imgCount = await queryAllMomentImgCount();

    return MomentInfo(count: count, wordCount: wordCount, imgCount: imgCount);
  }

  static Future<List<Moment>> queryAllMoment() async {
    final res = await (await DBHelper.db).rawQuery(
        'select C.* , E.name as eName, E.id as eid from moment_content as C left join content_event as CE on CE.cid = C.cid left join moment_event as E on E.id = CE.eid ORDER BY created desc');

    if (res.length < 1) {
      Fluttertoast.showToast(msg: '没有更多啦 ∑( 口 ||');
    }
    return res.map((r) => Moment.fromJson(r)).toList();
  }

  static Future<List<Moment>> queryAllMomentByFilter(String whereArgs) async {
    final res = await (await DBHelper.db).rawQuery(
        'select C.* , E.name as eName from moment_content as C left join content_event as CE on CE.cid = C.cid left join moment_event as E on E.id = CE.eid where $whereArgs ORDER BY created desc');

    return res.map((r) => Moment.fromJson(r)).toList();
  }

  // todo 多 Tag
  /*
      1. 修改tag 需要修改关联表对应id
      2. 首页需要手动拼接数据 先查 post 在查tag whereIn 在进行手动合并
   */
  static Future<List<Moment>> queryMomentByPage(int page) async {
    final res = await (await DBHelper.db).rawQuery(
        'select C.* , E.name as eName, E.id as eid from moment_content as C left join content_event as CE on CE.cid = C.cid left join moment_event as E on E.id = CE.eid ORDER BY created desc limit 10 offset ${page * 10}');

    return res.map((r) => Moment.fromJson(r)).toList();
  }

  static Future<List<Moment>> queryMomentByPageWithFilter(
      int page, String whereArgs) async {
    final res = await (await DBHelper.db).rawQuery(
        'select C.* , E.name as eName from moment_content as C left join content_event as CE on CE.cid = C.cid left join moment_event as E on E.id = CE.eid where $whereArgs ORDER BY created desc limit 10 offset ${page * 10}');

    if (res.length < 1) {
      Fluttertoast.showToast(msg: '没有更多啦 ∑( 口 ||');
      return [];
    }

    return res.map((r) => Moment.fromJson(r)).toList();
  }

  static Future<Moment> queryMomentById(int id) async {
    final List<Map<String, dynamic>> res = await (await DBHelper.db)
        .rawQuery('SELECT * FROM moment_content WHERE cid = ?', [id]);
    final eName = await (await DBHelper.db).rawQuery(
        'select E.name,E.id,CE.id as ceid from content_event as CE left join moment_event as E on E.id = CE.eid where cid =$id');

    if (res.length < 1) {
      Fluttertoast.showToast(msg: '哎呀，什么都没抓到');
    }

    final m = Moment.fromJson(res[0]);
    if (eName.length > 0) {
      m.eName = eName[0]['name'];
      m.eid = eName[0]['id'];
      m.ceid = eName[0]['ceid'];
    }

    return m;
  }

  static Future<bool> delMomentById(int id) async {
    int count = await (await DBHelper.db)
        .rawDelete('DELETE FROM moment_content WHERE cid = ?', [id]);
    await (await DBHelper.db)
        .delete('content_event', where: 'cid = ?', whereArgs: [id]);

    if (count == 1) {
      Fluttertoast.showToast(msg: '删除成功');
      return true;
    } else {
      Fluttertoast.showToast(msg: '删除失败');
      return false;
    }
  }
}
