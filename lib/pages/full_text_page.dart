import "package:flutter/material.dart";

class FullTextPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FullTextPageState();
}

class _FullTextPageState extends State<FullTextPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: Text('todo'),
      ),
    );
  }
}
