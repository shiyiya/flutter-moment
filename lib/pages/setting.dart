import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/material_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moment/components/card_with_title.dart';
import 'package:moment/provides/theme.dart';
import 'package:moment/service/event_bus.dart';
import 'package:moment/service/sqlite.dart';
import 'package:moment/utils/date.dart';
import 'package:moment/utils/dialog.dart';
import 'package:moment/utils/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
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
          CardWithTitle(
            title: '外观',
            children: <Widget>[
              ListTile(
                title: Text('主题'),
                leading: Icon(Icons.format_color_fill),
                trailing: Icon(Icons.chevron_right,
                    color: Theme.of(context).accentColor),
                onTap: _buildThemeSwitchDialog,
              ),
              ListTile(
                title: Text('主题强调色'),
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
                title: Text('本地备份'),
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
                ),
                RadioListTile(
                  groupValue: theme.value,
                  value: 2,
                  title: Text('夜间模式'),
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
                  final themeProvider = Provider.of<ThemeProvider>(context);

                  if (themeProvider.theme > 1) {
                    Fluttertoast.showToast(msg: '自带主题无法切换强调色~');
                    Navigator.of(context).pop();
                  } else {
                    Provider.of<ThemeProvider>(context)
                        .setThemePrimaryColor(color);
                  }
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
    eventBus.fire(HomeRefreshEvent(true));
  }

  _export() async {
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);

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
}
