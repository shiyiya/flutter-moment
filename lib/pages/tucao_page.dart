import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class TuCaoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebviewScaffold(
        appBar: AppBar(title: Text('吐个槽'), titleSpacing: 0.0),
        url: 'https://support.qq.com/products/111413',
//        enableAppScheme: true,
        withJavascript: true,
        withLocalStorage: true,
        resizeToAvoidBottomInset: true,
        hidden: true,
        initialChild: Container(
          child: const Center(
            child: Text('Waiting.....'),
          ),
        ),
      ),
    );
  }
}
