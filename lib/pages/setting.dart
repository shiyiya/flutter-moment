import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:moment/provides/theme.dart';
import 'package:moment/service/sqlite.dart';
import 'package:moment/utils/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:moment/utils/date.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import "package:sqflite/sqflite.dart";

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('选择主题'),
            leading: Icon(Icons.format_color_fill),
            trailing:
                Icon(Icons.chevron_right, color: Theme.of(context).accentColor),
            onTap: _buildThemeSwitchDialog,
          ),
          Divider(height: 0),
          ListTile(
            title: Text('关于'),
            leading: Icon(Icons.info),
            trailing:
                Icon(Icons.chevron_right, color: Theme.of(context).accentColor),
            onTap: () => Navigator.of(context).pushNamed('/about'),
          ),
          Divider(height: 0),
          // ListTile(
          //   title: Text('导入 / 导出'),
          //   leading: Icon(Icons.import_export),
          //   onTap: _buildImpExpDialog,
          // ),
          // Divider(height: 0),
        ],
      ),
    );
  }

  _buildThemeSwitchDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) => Consumer(
              builder: (_context, ThemeProvider theme, Widget child) =>
                  SimpleDialog(children: <Widget>[
                RadioListTile(
                  groupValue: theme.value,
                  value: 0,
                  title: Text('light'),
                  onChanged: (i) => setTheme(theme, i),
                ),
                RadioListTile(
                  groupValue: theme.value,
                  value: 1,
                  title: Text('dark'),
                  onChanged: (i) => setTheme(theme, i),
                )
              ]),
            ));
  }

  setTheme(ThemeProvider theme, int i) async {
    theme.setTheme(i);
    Navigator.of(context).pop();
  }

  _buildImpExpDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                    onPressed: _import,
                    tooltip: '导入',
                    icon: Icon(Icons.vertical_align_bottom)),
                IconButton(
                    onPressed: _export,
                    tooltip: '导出',
                    icon: Icon(Icons.vertical_align_top))
              ],
            ),
          );
        });
  }

  _import() async {
//    Map<PermissionGroup, PermissionStatus> permissions =
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);

    String filePath = await FilePicker.getFilePath(type: FileType.ANY);
    List<int> bytes = File(filePath).readAsBytesSync();
    Archive archive = ZipDecoder().decodeBytes(bytes);
    String dbDir = await getDatabasesPath();

    String picPath = (await getExternalStorageDirectory()).path + '/Pictures';

    for (ArchiveFile file in archive) {
      String filename = file.name;
      String type = filename.substring(filename.length - 2, filename.length);

      List<int> data = file.content;
      if (file.isFile) {
        if (type == 'db') {
          File(dbDir + 'moment.db')
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
  }

  _export() async {
//    Map<PermissionGroup, PermissionStatus> permissions =
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            children: <Widget>[Center(child: CircularProgressIndicator())],
          );
        });

    await Future.delayed(Duration(microseconds: 500));

    String timeMS = DateTime.now().millisecondsSinceEpoch.toString();

    String picPath = (await getExternalStorageDirectory()).path + '/Pictures';

    File(await DBHelper().getDatabasePath()).copySync(
        '$picPath/moment-sqlite-${Date.getDateFormatYMD()}-$timeMS.db');

    String outFileName = 'moment-backup-${Date.getDateFormatYMD()}-$timeMS.zip';

    await MPath.encodeDirFile2Download(picPath, outFileName);

    Navigator.pop(context);

    // 删除复制的 DB
    File('$picPath/moment-sqlite-${Date.getDateFormatYMD()}-$timeMS.db')
        .delete();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('导出成功，/Download/$outFileName'),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  '确定',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
