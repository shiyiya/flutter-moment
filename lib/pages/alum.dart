import 'dart:io';

import "package:flutter/material.dart";
import 'package:moment/constants/app.dart';
import 'package:moment/service/sqlite.dart';
import 'package:moment/pages/home.dart';

class AlumPage extends StatefulWidget {
  @override
  _AlumPage createState() => _AlumPage();
}

class _AlumPage extends State<AlumPage> {
  List<Map<String, dynamic>> _alum = [];

  @override
  void initState() {
    super.initState();
    loadAlums();
  }

  loadAlums() async {
    final db = await DB().get();
    final List<Map<String, dynamic>> alum =
        await db.query('moment_content', columns: ['alum', 'cid']);

    final List l = alum.toList();
    l.removeWhere((_) {
      return _['alum'] == null || _['alum'].length < 1;
    });

    setState(() {
      _alum = l;
    });

    print(_alum);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('印相'),
        ),
        body: _alum.length > 0
            ? GridView.count(
                padding: EdgeInsets.all(5),
                crossAxisCount: 2,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                children: List.generate(
                  _alum.length,
                  (i) => Image.file(
                    File(_alum[i]['alum'].split('|')[0]),
                    fit: BoxFit.cover,
                  ),
                ))
            : Center(
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    Constants.randomNilTip(),
                  ),
                ),
              ));
  }
}
