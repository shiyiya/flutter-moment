import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:moment/components/card_with_title.dart';
import 'package:moment/constants/app.dart';
import 'package:moment/service/event_bus.dart';
import 'package:moment/service/instances.dart';
import 'package:moment/service/sqlite.dart';
import 'package:moment/utils/date.dart';
import 'package:moment/utils/dialog.dart';
import 'package:moment/utils/path.dart';
import 'package:moment/utils/toast.dart';
import 'package:moment/utils/webdav.dart';
import 'package:path/path.dart' show basename;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class SyncPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  SharedPreferences _sp;

  String url;
  String username;
  String password;
  String wpath;

  final trailingWidget = Icon(
    Icons.chevron_right,
    color: Instances.currentThemeColor,
  );

  @override
  void initState() {
    getSp();
    super.initState();
  }

  getSp() async {
    final sp = await SharedPreferences.getInstance();

    setState(() {
      _sp = sp;
      url = sp.getString('webdavurl');
      username = sp.getString('webdavusername');
      password = sp.getString('webdavpassword');
      wpath = sp.getString('webdavpath');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据'),
      ),
      body: ListView(
        children: <Widget>[
          CardWithTitle(
            title: '本地',
            children: <Widget>[
              ListTile(
                title: const Text('本地导入'),
                subtitle: const Text('此操作将会覆盖本地数据且不可逆'),
                trailing: trailingWidget,
                onTap: _import,
              ),
              ListTile(
                title: const Text('本地备份'),
                subtitle: const Text('此操作将会将数据导出到 /Download 目录下'),
                trailing: trailingWidget,
                onTap: _export,
              ),
            ],
          ),
          CardWithTitle(
            title: 'WebDAV',
            children: <Widget>[
              ListTile(
                title: Text('拉取云端备份'),
                subtitle: Text('此操作将会覆盖本地数据且不可逆'),
                trailing: trailingWidget,
                onTap: _webDAVavLoad,
              ),
              ListTile(
                title: Text('推送到云端'),
                subtitle: Text('此操作将会覆盖云端数据且不可逆'),
                trailing: trailingWidget,
                onTap: _webDAVSync,
              ),
              ListTile(
                title: const Text('WebDAV 网址'),
                subtitle: Text(url ?? '点击填入网址'),
                onTap: () {
                  showAlertDialog(context,
                      title: const Text('WebDAV 网址'),
                      content: TextField(
                        controller: TextEditingController(text: url),
                        autofocus: true,
                        onChanged: (v) {
                          setState(() {
                            url = v;
                          });
                          _sp.setString('webdavurl', v);
                        },
                      ));
                },
              ),
              ListTile(
                title: const Text('WebDAV 账户'),
                subtitle: Text(username ?? '点击填入账户'),
                onTap: () {
                  showAlertDialog(context,
                      title: const Text('WebDAV 账户'),
                      content: TextField(
                        controller: TextEditingController(text: username),
                        autofocus: true,
                        onChanged: (v) {
                          setState(() {
                            username = v;
                          });
                          _sp.setString('webdavusername', v);
                        },
                      ));
                },
              ),
              ListTile(
                title: const Text('WebDAV 密码'),
                subtitle: Text(password ?? '点击填入密码'),
                onTap: () {
                  showAlertDialog(context,
                      title: const Text('WebDAV 密码'),
                      content: TextField(
                        autofocus: true,
                        controller: TextEditingController(text: password),
                        onChanged: (v) {
                          setState(() {
                            password = v;
                          });
                          _sp.setString('webdavpassword', v);
                        },
                      ));
                },
              ),
              ListTile(
                title: const Text('WebDAV 路径'),
                subtitle: Text(wpath ?? 'dav/'),
                onTap: () {
                  showAlertDialog(context,
                      title: const Text('WebDAV 路径'),
                      content: TextField(
                        autofocus: true,
                        controller: TextEditingController(text: wpath),
                        onChanged: (v) {
                          setState(() {
                            wpath = v;
                          });
                          _sp.setString('webdavpath', v);
                        },
                      ));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  _import() async {
    String filePath = await FilePicker.getFilePath(
        type: FileType.CUSTOM, fileExtension: 'zip');

    if (!filePath.contains('moment-backup')) {
      showAlertDialog(context,
          title: Text('错误'), content: Text('格式错误，请选择正确的备份文件'));
      return;
    }

    List<int> bytes = File(filePath).readAsBytesSync();
    Archive archive = ZipDecoder().decodeBytes(bytes);
    String dbDir = await getDatabasesPath();
    String picPath = await MPath.getPicPath();

    try {
      for (ArchiveFile file in archive) {
        String filename = file.name;
        String type = filename.substring(filename.length - 2, filename.length);

        List<int> data = file.content;
        if (file.isFile) {
          if (type == 'db') {
            File(dbDir + '/moment.db')
              ..createSync(recursive: true)
              ..writeAsBytesSync(data);
          } else {
            File(picPath + filename)
              ..createSync(recursive: true)
              ..writeAsBytesSync(data);
          }
        } else {
//        Directory('out/' + filename)..create(recursive: true);
        }
      }
    } catch (e) {}
    showAlertDialog(context,
        title: Text('成功'), content: Text('导入成功，一切似乎都很顺利~'), hideAction: true);
    eventBus.fire(HomeRefreshEvent());
  }

  _export() async {
    if (!await MPath.getStoragePermission(c: context, failText: '请授予存储权限以导出')) {
      return;
    }

    try {
      String timeMS = DateTime.now().millisecondsSinceEpoch.toString();
      String picPath = await MPath.getPicPath();

      if (!await Directory(picPath).exists()) Directory(picPath).createSync();

      File(await DBHelper().getDatabasePath()).copySync(
          '$picPath/moment-sqlite-${Date.getDateFormatYMD()}-$timeMS.db');

      String outFileName =
          'moment-backup-${Date.getDateFormatYMD()}-$timeMS.zip';

      await MPath.encodeDirFile2Download(picPath, outFileName);

      // 删除复制的 DB
      File('$picPath/moment-sqlite-${Date.getDateFormatYMD()}-$timeMS.db')
          .delete();

      showAlertDialog(context,
          title: Text('成功'), content: Text('导出成功，导出路径：/Download/$outFileName'));
    } catch (_) {
      showAlertDialog(context,
          title: Text('失败'), content: Text('备份失败了呢  \r\n 失败原因：$_'));
    }
  }

  Future<bool> check() async {
    if (url == null || username == null || password == null) {
      showAlertDialog(context,
          title: Text('提示'), content: Text('请填写配置信息'), hideCancel: true);
      return false;
    }
    return true;
  }

  _webDAVSync() async {
    if (!await check()) {
      return;
    }

    showCircularProgressDialog(context);
//    final Client webDAV = Client(
//      'dav.jianguoyun.com',
//      'i@runtua.cn',
//      'ahub2n74yn6pwv8x',
//      'dav/',
//      protocol: 'http',
//      port: 80,
//    );

    print('$url $username $password $wpath');

    Client webDAV = Client(url, username, password, wpath ?? 'dav/',
        protocol: 'http', port: 80);

    final dbPath = await DBHelper().getDatabasePath();
    String picPath = await MPath.getPicPath();

    try {
      await webDAV.mkdir('/moment');
      await webDAV.uploadFile(dbPath, '/moment/${Constants.dbName}');

      if (Directory(picPath).existsSync()) {
        final List<FileSystemEntity> imgList = Directory(picPath).listSync();
        imgList.forEach((f) {
          final name = basename(f.path);
          webDAV.upload(File(f.path).readAsBytesSync(), '/moment/$name');
        });
      }
    } catch (e) {
      Navigator.pop(context);
      final _e = e.statusCode != null ? e.statusCode : e;
      showAlertDialog(
        context,
        title: Text('提示'),
        content: Text('同步失败，错误详情 $_e'),
        hideCancel: true,
      );

      return;
    }
    Navigator.pop(context);
    showShortToast('同步成功');
  }

  _webDAVavLoad() async {
    if (!await check()) {
      return;
    }

    print('$url $username $password $wpath');

    showCircularProgressDialog(context);
    try {
      Client webDAV = Client(
        url,
        username,
        password,
        wpath ?? 'dav/',
        protocol: 'http',
        port: 80,
      );
      String picPath = await MPath.getPicPath();
      final dbPath = await DBHelper().getDatabasePath();
      final files = await webDAV.ls('/moment');
      if (!Directory(picPath).existsSync()) Directory(picPath).createSync();

      String __path = wpath ?? 'dav/';

      // 下载时移除多余路径  /path | path/ 皆可
      if (__path.endsWith('/')) {
        //   /dav/ -> /dav
        __path = __path.substring(0, __path.length - 1);
      }
      // dav -> /dav
      if (!__path.startsWith('/')) {
        __path = '/' + __path;
      }

      for (int i = 1; i < files.length; i++) {
        final name = basename(files[i].path);

        final p = files[i].path.replaceFirst(__path, '');

        print('云端path ${files[i].path} $p');

        if (p.endsWith('db')) {
          await webDAV.download(p, '$dbPath');
        } else {
          await webDAV.download(p, '$picPath$name');
        }
      }
    } catch (e) {
      Navigator.pop(context);
      final _e = e.statusCode != null ? e.statusCode : e;
      showAlertDialog(
        context,
        title: Text('提示'),
        content: Text('拉取失败，错误详情 $_e}'),
        hideCancel: true,
      );
      print(e);
      return;
    }
    Navigator.pop(context);
    showShortToast('拉取成功');
  }
}
