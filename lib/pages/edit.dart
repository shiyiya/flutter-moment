import 'dart:io';

// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:moment/service/face.dart';
import 'package:moment/utils/date.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:moment/components/alum.dart';
import 'package:moment/components/row-icon-radio.dart';

import 'package:moment/service/sqlite.dart';
import 'package:moment/constants/app.dart';
import 'package:moment/sql/query.dart';
import 'package:moment/type/moment.dart';
import 'package:moment/pages/view_page.dart';

import 'package:moment/service/event_bus.dart';

class Edit extends StatefulWidget {
  final int id;

  Edit({Key key, this.id}) : super(key: key);

  @override
  _EditState createState() => _EditState();
}

class _EditState extends State<Edit> with WidgetsBindingObserver {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _textController = TextEditingController();
  TextEditingController _faceController = TextEditingController();

  GlobalKey<FormState> momentKey = new GlobalKey<FormState>();

  Moment moment = Moment();
  List<String> alum = [];

  bool showToolBar = false;

  @override
  void initState() {
    super.initState();

    print('---- init  ${widget.id}-----');

    initMoment(id: widget.id);

    if (widget.id != null) {
      // 编辑
      fetchMoment();
    }

    /*KeyboardVisibilityNotification().addNewListener(onChange: (bool value) {
      print(value);
      setState(() {
        showToolBar = value;
      });
    });*/
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
        _faceController.text = moment.face.toString();
      });
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
        body: Stack(
          children: <Widget>[
            ListView(
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
                      onPressed: showSelectImageMethod,
                    ),
                  ),
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
                            color: Theme.of(context).textTheme.display3.color,
                          ),
                          Text(
                            moment.cid == null
                                ? '  ${Date.getDateFormatYMD()}'
                                : '  ${Date.getDateFormatYMD(ms: moment.created)}',
                            style: TextStyle(
                                fontSize: 14,
                                color:
                                    Theme.of(context).textTheme.display3.color),
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
                            onPressed: showSelectImageMethod,
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
                            return val.trim().isEmpty
                                ? "好像什么都没写呢 ,,ԾㅂԾ,,"
                                : null;
                          },
                        ),
                        Container(
                          child: new TextFormField(
                            controller: _textController,
                            style: Theme.of(context).textTheme.body2.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  height: 1.8,
                                ),
                            maxLines: 13,
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
                              return val.isEmpty ? "好像什么都没写呢 ,,ԾㅂԾ,," : null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            /*if (showToolBar) //todo
                  Positioned(
                    bottom: 0.0,
                    child: Container(
                      color: Theme.of(context).backgroundColor,
                      width: MediaQuery.of(context).size.width,
                      height: 30,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[
                          SizedBox(
                            width: 45,
                            child: FlatButton(
                              padding: EdgeInsets.all(0),
                              child: Text(
                                '缩进',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).textTheme.caption.color,
                                ),
                              ),
                              onPressed: () {
                                _textController.text += '    ';
                                _textController.selection =
                                    TextSelection.fromPosition(TextPosition(
                                  affinity: TextAffinity.downstream,
                                  offset: _textController.text.length,
                                ));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )*/
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() {
    if (moment.text.length > 0) {
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
    return Future.value(true);
  }

  showSelectImageMethod() {
    showDialog(
        context: context,
        builder: (_) {
          return SimpleDialog(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                      icon: Icon(Icons.camera_alt),
                      tooltip: '拍照',
                      onPressed: () {
                        _getImageFrom(ImageSource.camera);
                        Navigator.of(context).pop();
                      }),
                  IconButton(
                    icon: Icon(Icons.photo_library),
                    tooltip: '相册选取',
                    onPressed: () {
                      _getImageFrom(ImageSource.gallery);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              )
            ],
          );
        });
  }

  Future<void> _getImageFrom(ImageSource source) async {
    File image = await ImagePicker.pickImage(source: source);
//    await FilePicker.getMultiFile(type: FileType.IMAGE); //todo copy file to app data direct

    print('-----${image.path}----');

    if (image != null) {
      setState(() {
        alum.add(image.path);
      });
    }
  }

/*  Future<void> _removeImageByIndex(int index) async {
    final filePath = alum[index];
    File(filePath).delete();

    setState(() {
      alum.removeRange(index, index + 1);
    });
  }
 */

  void buildEmojioDialog() async {
    final List iconList = Constants.face;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            title: Text('此刻的心情'),
            children: [
              RowIconRadio(
                  selected: Face.getIndexByNum(moment.face),
                  icon: iconList,
                  onTap: (int index) {
                    setState(() {
                      moment.face = (index + 1) * 20;
                      _faceController.text = ((index + 1) * 20).toString();
                      Navigator.of(context).pop();
                    });
                  }),
              TextField(
                controller: _faceController,
                maxLength: 3,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(hintText: '或者填入一百以内的数字'),
                onChanged: (t) {
                  if (int.parse(t) < 0) {
                    _faceController.text = '0';
                    Fluttertoast.showToast(msg: '心情数值异常(⊙ˍ⊙), 已自动修正');
                    setState(() {
                      moment.face = 0;
                    });
                    return;
                  } else if (int.parse(t) > 100) {
                    _faceController.text = '100';
                    Fluttertoast.showToast(msg: '心情数值异常(⊙ˍ⊙), 已自动修正');
                    setState(() {
                      moment.face = 100;
                    });
                    return;
                  }
                  setState(() {
                    moment.face = int.parse(t);
                  });
                },
              ),
              Align(
                child: MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    '确定',
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                ),
              )
            ]);
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
          content: TextField(
            controller: TextEditingController.fromValue(
                TextEditingValue(text: moment.event)),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(hintText: '如：图书馆/玩新游'),
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

    //移除末尾符号
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
            return ViewPage(id: moment.cid);
          }));
        });
      }

      eventBus.fire(HomeRefreshEvent(true));
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
      eventBus.fire(HomeRefreshEvent(true));
      Future.delayed(Duration(microseconds: 700), () {
        Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return ViewPage(id: moment.cid);
        }));
      });
    }
  }
}
