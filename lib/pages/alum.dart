import 'dart:io';

import "package:flutter/material.dart";
import 'package:moment/components/gallery_photo_view.dart';
import 'package:moment/constants/app.dart';
import 'package:moment/service/sqlite.dart';

//import 'package:moment/pages/home.dart';
import 'package:moment/type/alum.dart';

class AlumPage extends StatefulWidget {
  @override
  _AlumPage createState() => _AlumPage();
}

class _AlumPage extends State<AlumPage> {
  List<Alum> _alum = [];
  int currentIndex;

  @override
  void initState() {
    super.initState();
    loadAlums();
  }

  loadAlums() async {
    final db = await DBHelper.db;
    final List<Map<String, dynamic>> res =
        await db.query('moment_content', columns: ['alum', 'cid']);

    List<Alum> alum = res.toList().map((l) {
      return Alum.fromJson(l);
    }).toList();

    alum.removeWhere((a) => a.alum.length < 1);

    setState(() {
      _alum = alum;
    });
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
                  (i) => GestureDetector(
                    onTap: () {
                      print(_alum[i].alum);
                      _showImgView(_alum[i].alum.split('|'));
                    },
                    child: Image.file(
                      File(_alum[i].alum.split('|')[0]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ))
            : Center(
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(Constants.randomNilTip(),
                      style: Theme.of(context).textTheme.body2),
                ),
              ));
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  _showImgView(List img) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext _) {
          return GalleryPhotoViewWrapper(galleryItems: img);
        });
  }
}
