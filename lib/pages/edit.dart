import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moment/utils/date.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:moment/components/alum.dart';
import 'package:moment/components/row-icon-radio.dart';

import 'package:moment/service/sqlite.dart';
import 'package:moment/constants/app.dart';
import 'package:moment/sql/query.dart';
import 'package:moment/type/moment.dart';
import 'package:moment/pages/view.dart';

class Edit extends StatefulWidget {
  int id;

  Edit({Key key, this.id}) : super(key: key);

  @override
  _EditState createState() => _EditState();
}

class _EditState extends State<Edit> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _textController = TextEditingController();

  GlobalKey<FormState> momentKey = new GlobalKey<FormState>();

  Moment moment = Moment();
  List<String> alum = [];

  @override
  void initState() {
    super.initState();

    print('---- init  ${widget.id}-----');

    initMoment(id: widget.id);

    if (widget.id != null) {
      // 编辑
      fetchMoment();
    }
  }

  void fetchMoment() async {
    final m = await SQL.queryMomentById(widget.id);
    if (m != null) {
      final res = m;

      final List<String> _alum = res.alum.split('|');
      _alum.removeWhere((e) => e.length < 1);

      setState(() {
        moment = m;
        alum = _alum;
        _titleController.text = moment.title;
        _textController.text = moment.text;
      });

      print(moment.cid);
      print(res);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(title: Text('此瞬间不存在'), actions: <Widget>[
              ButtonTheme.bar(
                  child: ButtonBar(children: <Widget>[
                FlatButton(
                    child: const Text('确定'),
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ]))
            ]);
          });
    }
  }

  void initMoment({int id}) {
    int now = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      moment = Moment(
        cid: id,
        created: now,
        modified: now,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(moment.cid == null ? "记录瞬间" : "编辑瞬间"),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.check),
                onPressed: publishMoment,
              ),
            ],
          ),
          body: ListView(
            children: <Widget>[
              Alum(
                img: alum,
                emptyPlaceholder: Center(
                  child: IconButton(
                    icon: Icon(
                      Icons.photo_camera,
                      size: 40,
                    ),
                    color: Theme.of(context).buttonColor,
                    onPressed: _getImageFromGallery,
                  ),
                ),
                onTap: (int index) {
                  print('tap $index');
                  //_removeImageByIndex(index);
                },
              ),
              Container(
                margin: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.calendar_today,
                          size: 20,
//                      color: Theme.of(context).textTheme.display3.color,
                        ),
                        Text(
                          moment.cid == null
                              ? '  ' + Date.getDateFormatYMD()
                              : Date.getDateFormatYMD(
                                  ms: DateTime.fromMicrosecondsSinceEpoch(
                                          moment.modified)
                                      .millisecondsSinceEpoch),
                          style: TextStyle(fontSize: 14),
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.tag_faces),
                          color: moment.face != null
                              ? Theme.of(context).accentColor
                              : Colors.grey,
                          onPressed: buildEmojioDialog,
                        ),
                        IconButton(
                          icon: Icon(Icons.brightness_high),
                          color: moment.weather != null
                              ? Theme.of(context).accentColor
                              : Colors.grey,
                          onPressed: buildWeatherDialog,
                        ),
                        IconButton(
                          icon: Icon(Icons.loyalty),
                          color: moment.event.length > 0
                              ? Theme.of(context).accentColor
                              : Colors.grey,
                          onPressed: buildMomentEventDialog,
                        ),
                        new IconButton(
                          icon: Icon(Icons.photo),
                          color: alum.length > 0
                              ? Theme.of(context).accentColor
                              : Colors.grey,
                          onPressed: _getImageFromGallery,
                        ),
//                    IconButton(
//                      icon: Icon(Icons.movie),
//                      color: Theme.of(context).accentColor,
//                      onPressed: () {},
//                    ),
                      ],
                    )
                  ],
                ),
              ),
              Form(
                key: momentKey,
                autovalidate: true,
                child: Container(
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    children: <Widget>[
                      new TextFormField(
                        style: Theme.of(context)
                            .textTheme
                            .title
                            .copyWith(fontWeight: FontWeight.normal),
                        controller: _titleController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: '标题',
                          suffixText: '标题',
                        ),
                        onChanged: (text) {
                          setState(() {
                            moment.title = text;
                          });
                        },
                        onSaved: (val) => {},
                        validator: (val) {
                          print(val);
                          return val.trim().length <= 0
                              ? "好像什么都没写呢 ,,ԾㅂԾ,,"
                              : null;
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          child: new TextFormField(
                            controller: _textController,
                            style: Theme.of(context).textTheme.body2.copyWith(
                                fontSize: 16,
                                wordSpacing: 1.2,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.normal),
                            maxLines: 10,
                            maxLength: 10000,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '内容',
                              suffixText: '内容',
                            ),
                            onChanged: (_text) {
                              setState(() {
                                moment.text = _text;
                              });
                            },
                            validator: (val) {
                              return val.length <= 0
                                  ? "好像什么都没写呢 ,,ԾㅂԾ,,"
                                  : null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('提示'),
            content: new Text('确定返回么？可能有未保存的内容哦'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('取消'),
              ),
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('确定'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _getImageFromGallery() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        alum.add(image.path);
      });
    }
  }

  /* todo
  Future<void> _removeImageByIndex(int index) async {
    setState(() {
      _img.removeRange(index, index + 1);
    });
  }
  */

  void buildEmojioDialog() async {
    final List iconList = Constants.face;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('此刻的心情'),
          content: RowIconRadio(
              selected: moment.face,
              icon: iconList,
              onTap: (int index) {
                setState(() {
                  moment.face = index;
                  Navigator.of(context).pop();
                });
              }),
        );
      },
    );
  }

  void buildWeatherDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('此刻的天气'),
            content: RowIconRadio(
                selected: moment.weather,
                icon: Constants.weather,
                onTap: (int index) {
                  setState(() {
                    moment.weather = index;
                    Navigator.of(context).pop();
                  });
                }),
          );
        });
  }

  void buildMomentEventDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('关键词：'),
          content: new TextField(
            controller: TextEditingController.fromValue(
                TextEditingValue(text: moment.event)),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(hintText: '如：图书馆/玩新游（使用 “/” 隔开'),
            onChanged: (t) {
              setState(() {
                moment.event = t;
              });
            },
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                '确定',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  publishMoment() async {
    if (!momentKey.currentState.validate()) {
      Fluttertoast.showToast(msg: '内容不完整！');
      return;
    }

    momentKey.currentState.save();

    String _alum = '';
    alum.forEach((i) {
      _alum += "$i|";
    });

    if (_alum.length > 0) {
      _alum = _alum.substring(0, _alum.length - 1);
    }

    final currDB = await DBHelper.db;

    //编辑
    if (moment.cid != null) {
      final u = await currDB.rawUpdate(
          'UPDATE moment_content SET created = ?, title = ?, text = ?,  face = ?, event = ?, alum = ?  WHERE cid = ?',
          [
            moment.created,
            moment.title,
            moment.text,
            moment.face,
            moment.event,
            _alum,
            moment.cid,
          ]);

      print('update moment: id -> ${moment.cid} -> $u\r\n');

      if (u == 1) {
        Fluttertoast.showToast(msg: '成功更新瞬间！');

        Future.delayed(Duration(microseconds: 700), () {
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return View(id: moment.cid);
          }));
        });
      }

      return;
    }

    // 新建
    var res = await currDB.insert('moment_content', {
      'title': moment.title,
      'text': moment.text,
      'face': moment.face,
      'event': moment.event,
      'created': moment.created,
      'alum': _alum
    });

    print('new moment: id -> $res');

    if (res is int) {
      setState(() {
        moment.cid = res;
      });
      Fluttertoast.showToast(msg: '成功记录瞬间！');

      Future.delayed(Duration(microseconds: 700), () {
        Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return View(id: moment.cid);
        }));
      });
    }
  }
}
