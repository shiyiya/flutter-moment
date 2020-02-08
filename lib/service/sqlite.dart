import 'dart:math';

import 'package:fluttertoast/fluttertoast.dart';
import "package:moment/constants/app.dart";
import 'package:moment/type/event.dart';
import "package:path/path.dart";
import "package:sqflite/sqflite.dart";

class DBHelper {
  static final DBHelper _instance = DBHelper.internal();

  factory DBHelper() => _instance;

  static Database _db;

  static Future<Database> get db async {
    if (_db == null) {
      _db = await DBHelper().init();
    }
    return _db;
  }

  DBHelper.internal();

  Future<String> getDatabasePath() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, Constants.dbName);
    return path;
  }

  init() async {
    String path = await getDatabasePath();

    Database db = await openDatabase(path, version: 2,
        onUpgrade: (Database db, int o, int n) async {
      print('$o ->>>> $n');
      if (o == 1 && n == 2) {
        Fluttertoast.showToast(msg: '正在更新数据库');
        try {
          const newSQL = [
            '''
CREATE TABLE if not exists moment_event (
"id" INTEGER NOT NULL PRIMARY KEY,
"authorId" int(10) default '0',
"icon" varchar(32) default NULL,
"name" varchar(200) default NULL,
"created" int(10) default '0',
"description" varchar(200) default '',
"status" int(10) default '0' )
         ''',
            '''
CREATE TABLE if not exists content_event (
"id" INTEGER NOT NULL PRIMARY KEY,
"authorId" int(10) default '0',
"eid" int(10) default NULL,
"cid" int(10) default NULL,
"created" int(10) default '0' )
'''
          ];

          for (var i = 0; i < newSQL.length; i++) {
            await db.rawQuery(newSQL[i]);
          }

          final events = await db
              .query('moment_content', columns: ['event', 'cid', 'created']);

          for (var i = 0; i < events.length; i++) {
            final eventID = await db.insert('moment_event', {
              'name': events[i]['event'],
            });

            await db.insert('content_event', {
              'cid': events[i]['cid'],
              'eid': eventID,
              'created': events[i]['created']
            });
          }
        } catch (e) {
          print(e);
          Fluttertoast.showToast(msg: '更新数据库数据库失败，请备份数据库并联系开发者，以免数据丢失 \r\n $e');
        }
        Fluttertoast.showToast(msg: '更新数据库数据库成功');
      }
    }, onCreate: _onCreate);

    return db;
  }

  void _onCreate(Database db, int v) async {
    print('---create new database---');
    // final sql = await rootBundle.loadString("./lib/asserts/SQLite.sql");

    const sql = [
      '''
CREATE TABLE moment_content (
"cid" INTEGER NOT NULL PRIMARY KEY,
"title" varchar(200) default NULL ,
"created" int(10) default '0' ,
"modified" int(10) default '0' ,
"text" text default '',
"authorId" int(10) default '0' ,
"status" varchar(16) default 'publish' ,
"password" varchar(32) default NULL ,
"event" varchar(32) default '',
"location" varchar(16) default '',
"face" int(10) default '4',
"weather" int (10) default '3',
"alum" varchar(200) default '',
"commentsNum" int(10) default '0' ,
"allowComment" int(10) default '0' )
''',
      '''
CREATE TABLE moment_event (
"id" INTEGER NOT NULL PRIMARY KEY,
"authorId" int(10) default '0',
"icon" varchar(32) default NULL,
"name" varchar(200) default NULL,
"created" int(10) default '0' ,
"description" varchar(200) default '',
"status" int(10) default '0' )
           ''',
      '''
CREATE TABLE content_event (
"id" INTEGER NOT NULL PRIMARY KEY,
"authorId" int(10) default '0',
"eid" int(10) default NULL,
"cid" int(10) default NULL,
"created" int(10) default '0' )
'''
    ];
    sql.forEach((s) async {
      await db.rawQuery(s);
    });

    if (bool.fromEnvironment('dart.vm.product')) {
      await initProdData(db);
    } else {
      await initDevData(db);
    }
  }

  Future<void> initDevData(Database db) async {
    print('---init dev data---');
    List text = [
      '通宵值完班回到家，胡乱写了一张字，真的是胡乱写，写着写着心思就飘到别的地方去。这让我有点烦躁，一是字没写好，二是没有认真做事，不认真这件事比没得到好结果更让我愧疚且沮丧，觉得是在浪费。可能是睡眠不足的原因，我这样安慰自己。洗个澡睡个觉，起来认认真真看书写字吧。',
      '看完单词，躺床上睡不着。害 这两天有点春心荡漾，有波动很正常。克制还是放纵，这是个问题。',
      '准备换衣服去上班，妈妈在厨房准备我的晚饭。越年长越懂得父母伟大与不易，就会想要做一个自私的人，不生孩子。对孩子的无条件付出和包容，这几乎是一辈子的事，我恐怕做不好，也害怕做得很好。',
      '现在是下午一点，从九点半到现在，300个单词还没看完。这几天状态好差，总是走神，定不下心。加油啊',
      ''' 这两天心里状态极不利于学习，刚刚思考了一下：好像四五年前的我，学习不下去时候也是这般。
      那时候还不会思考太长远的人生，没有非做不可的事，还有恋爱可谈，虽然也焦虑，但也不觉得过于难受。
      还是进步了的，但几千个日子就这点长进，还真是让人难过。
      要找个法子调整过来，加油。''',
      '''
      昨晚做了一个梦，梦里一位朋友过世，我亲眼看着咽气，并且打电话给她母亲报丧。更恐怖更压抑的梦不是没有做过，但这个梦里我止不住号啕大哭，知道这是个梦，极力清醒，半醒之间却感觉脸上也是想要痛哭的表情。
真是让人难过。日子这么苦吗，在梦里都是哭''',
      '''经期腹痛，前几天的情绪起伏似乎找到原因了。
越是禁止越想做，上班一个月，今天格外想喝冷饮。''',
      '''买的时间记录本到货了，明天开始记录。
学会不骄不躁，踏踏实实勤勤恳恳学习好吗'''
    ];

    List time = [
      '20191027',
      '20191027',
      '20191028',
      '20191101',
      '20191102',
      '20191103',
      '20191105',
      '20191112'
    ];

    List<Event> event = [
      Event(name: '图书馆'),
      Event(name: '爬山'),
      Event(name: '表白'),
      Event(name: '看演唱会'),
      Event(name: '学习新语言'),
      Event(name: '新朋友'),
      Event(name: '第一次'),
      Event(name: '新电脑'),
      Event(name: '新游戏'),
      Event(name: '生日')
    ];

    for (var i = 0; i < event.length; i++) {
      await db.insert('moment_event', {
        'name': event[i].name,
      });
    }

    //https://www.douban.com/group/topic/156219920/
    for (var i = 0; i < text.length; i++) {
      final e = Random().nextInt(event.length - 1);
      final cid = await db.insert('moment_content', {
        'title': '随机标题 $i',
        'text': text[i],
        'face': Random().nextInt(100),
//        'event': event[i].name,
        'event': e,
        'created': DateTime.parse(time[i]).millisecondsSinceEpoch,
        'alum': ''
      });
      await db.insert('content_event', {
        'cid': cid,
        'eid': e,
        'created': DateTime.parse(time[i]).millisecondsSinceEpoch
      });
    }
  }

  initProdData(Database db) async {
    final cid = await db.insert('moment_content', {
      'title': 'Moment (瞬记)',
      'text': '''
**捕捉** & **记录**生活中的美好**瞬间**。
如你所见，它很简单；也许，你可以用它来 ~~写日记~~。
      ''',
      'face': 80,
      'created': DateTime.now().millisecondsSinceEpoch,
      'alum': '' //https://i.loli.net/2019/11/20/6wI8eTmkbYQ5Zy9.gif
    });

    final eid = await db.insert('moment_event', {
      'name': '相识',
      'created': DateTime.now().millisecondsSinceEpoch,
    });
    await db.insert('content_event', {
      'cid': cid,
      'eid': eid,
      'created': DateTime.now().millisecondsSinceEpoch
    });
  }

  Future<void> close() async {
    await _db.close();
  }

  Future<int> delete() async {
    return await _db.delete('moment_content');
  }
}
