import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moment/service/sqlite.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
//import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:moment/components/alum.dart';
import 'package:moment/constants/app.dart';
import 'package:moment/utils/date.dart';
import 'package:moment/pages/edit.dart';
import 'package:moment/type/moment.dart';
import 'package:share/share.dart';

class View extends StatefulWidget {
  final int id;

  View({Key key, this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ViewState();
}

class ViewState extends State<View> {
  ScrollController _scrollController;
  SwiperController _swiperController;

  Moment moment = Moment(); // todo type
  bool hasLoaded = false;
  int _id;
  bool status;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()..addListener(() {});
    _swiperController = SwiperController();

    if (widget.id != null) {
      loadMomentById(widget.id);
    }
  }

  loadMomentById(int id) async {
    final dynamic _moment = await (await DB.getInstance())
        .rawQuery('SELECT * FROM moment_content WHERE cid = ?', [id]);

    print('load monent by page $id');

    if (_moment.length > 0) {
      setState(() {
        _id = id;
        moment = Moment.fromJson(_moment[0]);
        status = true;
        hasLoaded = true;
      });
    } else {
      setState(() {
        status = false;
        hasLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _swiperController.stopAutoplay();
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List img = [];
    if (moment.alum != null) {
      img = moment.alum.split('|');
      img.removeWhere((e) => e.length < 1);
    }

    return Scaffold(
      body: hasLoaded
          ? status
              ? CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar(
                      actions: buildMenu(),
                      flexibleSpace: new FlexibleSpaceBar(
                        background: Container(
//                          margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                          child: Alum(
                            img: img,
                            emptyPlaceholder: Image.network(
                              'https://cdn.jsdelivr.net/npm/typecho-theme-sagiri@1.1.5/assert/img/banner.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(moment.title),
                        collapseMode: CollapseMode.pin,
                      ),
                      expandedHeight: MediaQuery.of(context).size.height / 3,
                      floating: false,
                      pinned: true,
                      snap: false,
                    ),
                    SliverList(
                      delegate:
                          SliverChildListDelegate(List.generate(2, (int index) {
                        if (index == 0)
                          return Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height / 10,
                              color: Theme.of(context).backgroundColor,
                              child: Flex(
                                  direction: Axis.horizontal,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(children: <Widget>[
                                      Icon(
                                        Constants.face[moment.face],
                                        size: 45,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "${Date.getWeekByMS(ms: moment.created)} | ",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .title,
                                              ),
                                              Icon(
                                                Constants
                                                    .weather[moment.weather],
                                                size: 20,
                                              )
                                            ],
                                          ),
                                          Text(
                                            Date.getDateFormatYMD(
                                                ms: moment.created),
                                            style: Theme.of(context)
                                                .textTheme
                                                .body1,
                                          ),
                                        ],
                                      )
                                    ]),
                                    Padding(
                                      padding: EdgeInsets.only(right: 15),
                                      child: Text(
                                        moment.title,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ]));
                        return Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(top: 10),
                          child: Text(
                            moment.text,
                            style: Theme.of(context).textTheme.body2.copyWith(
                                fontSize: 16, fontWeight: FontWeight.normal),
                          ),
                        );
                      })),
                    )
                  ],
                )
              : Center(child: Text('美好事物如昙花一现似流星一瞬而过，似烟花一而灭。'))
          : Center(child: CircularProgressIndicator()),
    );
  }

  buildMenu() {
    return [
      IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return Edit(id: _id);
          }));
        },
      ),
      PopupMenuButton(
        icon: Icon(Icons.more_horiz),
        offset: Offset(100, 100),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: "1",
            child: Text('分享为纯文本'),
          ),
//          const PopupMenuItem<String>(
//            value: "2",
//            child: Text('分享为截图'),
//          ),
        ],
        tooltip: "more",
        onSelected: (String result) {
          switch (result) {
            case "1":
              shareText();
              break;
            case "2":
              break;
          }
        },
      )
    ];
  }

  shareText() {
    Share.share(moment.title + '\r\n' + moment.text);
  }
}

/*
  

//todo sup markdown
//                ListBody(
//                  children: [
//                    Markdown(
//                      data: moment['text'] != null ? moment['text'] : '',
//                    )
//                  ],
//                )
                  ],
                )
  
*/
