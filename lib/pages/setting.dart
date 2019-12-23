import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/material_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moment/components/card_with_title.dart';
import 'package:moment/provides/theme.dart';
import 'package:provider/provider.dart';

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
            title: '其他',
            children: <Widget>[
              ListTile(
                title: Text('备份 & 恢复'),
                leading: Icon(Icons.local_library),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).accentColor,
                ),
                onTap: () => Navigator.of(context).pushNamed('/sync'),
              ),
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
}
