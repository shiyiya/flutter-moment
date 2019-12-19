import 'package:flutter/material.dart';

Widget _alertDialog(BuildContext _,
    {Widget title,
    Widget content,
    void Function() lF,
    void Function() rF,
    hideAction = false}) {
  final p = Theme.of(_).primaryColor;

  return AlertDialog(
    title: title,
    content: content,
    actions: hideAction
        ? null
        : <Widget>[
            FlatButton(
              child: Text('取消', style: TextStyle(color: p.withOpacity(0.7))),
              onPressed: () {
                if (lF != null) lF();
                Navigator.pop(_);
              },
            ),
            FlatButton(
              child: Text(
                '确定',
                style: TextStyle(color: p),
              ),
              onPressed: () {
                if (rF != null) rF();
                Navigator.pop(_);
              },
            ),
          ],
  );
}

Widget _simpleDialog(BuildContext _,
    {Widget title,
    EdgeInsetsGeometry contentPadding,
    List<Widget> children,
    hideAction = true}) {
  return SimpleDialog(
    title: title,
    contentPadding: contentPadding,
    children: children,
  );
}

void showAlertDialog(BuildContext context,
    {Widget title,
    Widget content,
    void Function() lF,
    void Function() rF,
    hideAction = false}) {
  showDialog(
    context: context,
    builder: (_) => _alertDialog(
      _,
      title: title,
      content: content,
      lF: lF,
      rF: rF,
      hideAction: hideAction,
    ),
  );
}

void showSimpleDialog(BuildContext context,
    {Widget title, EdgeInsetsGeometry contentPadding, List<Widget> children}) {
  showDialog(
    context: context,
    builder: (_) => _simpleDialog(
      _,
      title: title,
      contentPadding: contentPadding,
      children: children,
    ),
  );
}
