import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moment/components/card_with_title.dart';
// import 'package:moment/pages/tucao_page.dart';
import 'package:moment/provides/theme.dart';
import 'package:moment/service/instances.dart';
import 'package:provider/provider.dart';

class Setting extends StatelessWidget {
  final Widget trailing = Icon(
    Icons.chevron_right,
    color: Instances.currentThemeColor,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: <Widget>[
          CardWithTitle(
            title: '外观',
            children: <Widget>[
              ListTile(
                title: const Text('主题'),
                leading: const Icon(Icons.format_color_fill),
                trailing: trailing,
                onTap: () => _buildThemeSwitchDialog(context),
              ),
              ListTile(
                title: const Text('主题强调色'),
                leading: const Icon(Icons.color_lens),
                trailing: trailing,
                onTap: () => _showColorPicker(context),
              ),
            ],
          ),
          CardWithTitle(
            title: '其他',
            children: <Widget>[
              ListTile(
                title: const Text('备份 & 恢复'),
                leading: const Icon(Icons.sync),
                trailing: trailing,
                onTap: () => Navigator.of(context).pushNamed('/sync'),
              ),
              // ListTile(
              //   title: const Text('吐个槽'),
              //   leading: const Icon(Icons.chat_bubble_outline),
              //   trailing: trailing,
              //   onTap: () {
              //     Navigator.pushAndRemoveUntil(
              //         context,
              //         MaterialPageRoute(builder: (_) => TuCaoPage()),
              //         (Route<dynamic> route) => true);
              //   },
              // ),
              ListTile(
                title: const Text('关于'),
                leading: const Icon(Icons.info_outline),
                trailing: trailing,
                onTap: () => Navigator.of(context).pushNamed('/about'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _buildThemeSwitchDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => Consumer(
              builder: (_context, ThemeProvider theme, Widget child) =>
                  SimpleDialog(children: <Widget>[
                RadioListTile(
                  groupValue: theme.value,
                  value: 0,
                  title: const Text('Light'),
                  onChanged: (i) => setTheme(context, theme, i),
                ),
                RadioListTile(
                  groupValue: theme.value,
                  value: 1,
                  title: const Text('Dark'),
                  onChanged: (i) => setTheme(context, theme, i),
                ),
                RadioListTile(
                  groupValue: theme.value,
                  value: 2,
                  title: const Text('夜间模式'),
                  onChanged: (i) => setTheme(context, theme, i),
                )
              ]),
            ));
  }

  void setTheme(BuildContext context, ThemeProvider theme, int i) {
    theme.setTheme(i);
    Navigator.of(context).pop();
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0))),
            elevation: 0.0,
            title: const Text('选择主色调'),
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
                child: const Text('确认'),
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
