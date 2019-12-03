import 'dart:io';

import 'package:flutter/material.dart';
import 'package:moment/components/card_with_title.dart';
import 'package:moment/service/event_bus.dart';
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
import 'package:flutter_colorpicker/material_picker.dart';

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
          CardWithTitle(
            title: '外观',
            children: <Widget>[
              ListTile(
                title: Text('选择主题'),
                leading: Icon(Icons.format_color_fill),
                trailing: Icon(Icons.chevron_right,
                    color: Theme.of(context).accentColor),
                onTap: _buildThemeSwitchDialog,
              ),
              ListTile(
                title: Text('选择主色调'),
                leading: Icon(Icons.color_lens),
                trailing: Icon(Icons.chevron_right,
                    color: Theme.of(context).accentColor),
                onTap: _showColorPicker,
              ),
//              ListTile(
//                title: Text('自动切换夜间模式'),
//                leading: Icon(Icons.brightness_2),
//                trailing: Switch(
//                  value: Provider.of<ThemeProvider>(context).isNightTheme,
//                  onChanged: (bool val) {
//                    Provider.of<ThemeProvider>(context).switchNightTheme(val);
//                  },
//                ),
//                onTap: _buildThemeSwitchDialog,
//              ),
            ],
          ),
          CardWithTitle(
            title: '备份 & 恢复',
            children: <Widget>[
              ListTile(
                title: Text('覆盖导入'),
                leading: Icon(Icons.archive),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).accentColor,
                ),
                onTap: _import,
              ),
              ListTile(
                title: Text('导出 ZIP'),
                leading: Icon(Icons.unarchive),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).accentColor,
                ),
                onTap: _export,
              ),
            ],
          ),
          CardWithTitle(
            title: '其他',
            children: <Widget>[
              ListTile(
                title: Text('关于'),
                leading: Icon(Icons.info),
                trailing: Icon(Icons.chevron_right,
                    color: Theme.of(context).accentColor),
                onTap: () => Navigator.of(context).pushNamed('/about'),
              ),
            ],
          ),
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
                  title: Text('Light'),
                  onChanged: (i) => setTheme(theme, i),
                ),
                RadioListTile(
                  groupValue: theme.value,
                  value: 1,
                  title: Text('Dark'),
                  onChanged: (i) => setTheme(theme, i),
                )
              ]),
            ));
  }

  setTheme(ThemeProvider theme, int i) {
    theme.setTheme(i);
    Navigator.of(context).pop();
  }

  void _showColorPicker() {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            elevation: 0.0,
            title: Text('选择'),
            content: SingleChildScrollView(
              child: MaterialPicker(
                pickerColor: Theme.of(context).primaryColor,
                onColorChanged: (color) {
                  Provider.of<ThemeProvider>(context)
                      .setThemePrimaryColor(color);
                },
                enableLabel: true,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  '取消',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(
                  '默认',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onPressed: () {
                  Provider.of<ThemeProvider>(context)
                      .setThemePrimaryColor(Colors.teal);
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('确认'),
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  _import() async {
//    Map<PermissionGroup, PermissionStatus> permissions =
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);

    String filePath = await FilePicker.getFilePath(type: FileType.ANY);
    if (!filePath.endsWith('zip') || !filePath.contains('moment-backup')) {
      _showDialog(context, '错误', '格式错误，请选择正确的 ZIP 备份包');
      return;
    }

    List<int> bytes = File(filePath).readAsBytesSync();
    Archive archive = ZipDecoder().decodeBytes(bytes);
    String dbDir = await getDatabasesPath();

    String picPath = (await getExternalStorageDirectory()).path + '/Pictures';

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
    _showDialog(context, '成功', '导入成功，一切似乎都很顺利~');
    eventBus.fire(HomeRefreshEvent(true));
  }

  _export() async {
//    Map<PermissionGroup, PermissionStatus> permissions =
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);

    try {
      String timeMS = DateTime.now().millisecondsSinceEpoch.toString();

      String picPath = (await getExternalStorageDirectory()).path + '/Pictures';

      File(await DBHelper().getDatabasePath()).copySync(
          '$picPath/moment-sqlite-${Date.getDateFormatYMD()}-$timeMS.db');

      String outFileName =
          'moment-backup-${Date.getDateFormatYMD()}-$timeMS.zip';

      await MPath.encodeDirFile2Download(picPath, outFileName);

      // 删除复制的 DB
      File('$picPath/moment-sqlite-${Date.getDateFormatYMD()}-$timeMS.db')
          .delete();

      _showDialog(context, '成功', '导出成功，导出路径：/Download/$outFileName', children: [
        FlatButton(
          child: Text('确定'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ]);
    } catch (_) {
      _showDialog(context, '失败', '备份失败了呢');
    }
  }

  _showDialog(BuildContext _, String title, String content,
      {List<Widget> children}) {
    showDialog(
      context: _,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: children,
      ),
    );
  }
}
