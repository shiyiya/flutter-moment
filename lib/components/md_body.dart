import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:moment/utils/dialog.dart';
import 'package:moment/utils/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class MDBody extends StatelessWidget {
  final String data;
  MDBody(this.data);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MarkdownBody(
        data: data,
        styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
        styleSheet: MarkdownStyleSheet(
          blockquotePadding: EdgeInsets.fromLTRB(10.0, 0, 0, 0),
          blockquoteDecoration: BoxDecoration(
            border:
                Border(left: BorderSide(width: 2.0, color: theme.primaryColor)),
          ),
          a: TextStyle(color: theme.primaryColor),
        ),
        onTapLink: (url) async {
          showAlertDialog(
            context,
            title: const Text('提示'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  const Text('是否使用外部打开该链接？'),
                  const SizedBox(height: 10),
                  Text('$url', style: TextStyle(color: theme.primaryColor))
                ],
              ),
            ),
            rF: () async {
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                showCenterErrorShortToast('打开链接失败');
              }
            },
          );
        });
  }
}
