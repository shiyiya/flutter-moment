import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moment/components/gallery_photo_view.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
//import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:moment/components/alum.dart';
import 'package:moment/constants/app.dart';
import 'package:moment/sql/query.dart';
import 'package:moment/utils/date.dart';
import 'package:moment/pages/edit.dart';
import 'package:moment/type/moment.dart';
import 'package:share/share.dart';

class ViewPage extends StatefulWidget {
  final int id;

  ViewPage({Key key, this.id}) : super(key: key);

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
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
    print('--load monent by id $id --');

    final _moment = await SQL.queryMomentById(id);

    if (_moment != null) {
      setState(() {
        _id = id;
        moment = _moment;
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
      appBar: img.length > 0
          ? null
          : AppBar(title: Text(moment.title), actions: buildMenu()),
      body: hasLoaded
          ? status
              ? img.length > 0
                  ? CustomScrollView(
                      slivers: <Widget>[
                        buildWithAlumBar(img),
                        SliverList(
                          delegate: SliverChildListDelegate(
                              List.generate(2, (int index) {
                            if (index == 0) return buildMetaCard();
                            return buildContent();
                          })),
                        )
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[buildMetaCard(), buildContent()],
                    )
              : Center(child: Text('美好事物如昙花一现似流星一瞬而过，似烟花一而灭。'))
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget buildMetaCard() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 10,
        color: Theme.of(context).backgroundColor,
        child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(children: <Widget>[
                Icon(
                  Constants.face[moment.face],
                  size: 45,
                  color: Theme.of(context).accentColor,
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          "${Date.getWeekByMS(ms: moment.created)} | ",
                          style: Theme.of(context)
                              .textTheme
                              .title
                              .copyWith(fontWeight: FontWeight.normal),
                        ),
                        Icon(
                          Constants.weather[moment.weather],
                          size: 20,
                        )
                      ],
                    ),
                    Text(
                      Date.getDateFormatMDHM(ms: moment.created),
                      style: Theme.of(context).textTheme.body1,
                    ),
                  ],
                )
              ]),
              Padding(
                padding: EdgeInsets.only(right: 15, top: 15, bottom: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      moment.event,
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      moment.text.length.toString() + ' 字',
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.display3.color),
                    ),
                  ],
                ),
              ),
            ]));
  }

  Widget buildContent() {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 10),
      child: Text(
        moment.text,
        style: Theme.of(context)
            .textTheme
            .body2
            .copyWith(fontSize: 16, fontWeight: FontWeight.normal, height: 1.8),
      ),
    );
  }

  Widget buildWithAlumBar(List img) {
    return SliverAppBar(
      actions: buildMenu(),
      flexibleSpace: new FlexibleSpaceBar(
        background: Container(
          child: Alum(
            img: img,
            emptyPlaceholder: Image.asset(
              'lib/asserts/images/alum_placeholder.jpg',
              fit: BoxFit.cover,
            ),
            onTap: (int index) {
              _showImgView(img, index);
            },
          ),
        ),
        title: Text(
          moment.title,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            shadows: <Shadow>[
              Shadow(
                color: Theme.of(context).accentColor,
                offset: Offset(2, 2),
                blurRadius: 2,
              )
            ],
          ),
        ),
        collapseMode: CollapseMode.pin,
      ),
      expandedHeight: MediaQuery.of(context).size.height / 3,
      floating: false,
      pinned: true,
      snap: false,
    );
  }

  List<Widget> buildMenu() {
    return [
      IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          Navigator.of(context).pop();
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
          const PopupMenuItem<String>(
            value: "2",
            child: Text('删除本瞬间'),
          ),
        ],
        tooltip: "more",
        onSelected: (String result) {
          switch (result) {
            case "1":
              shareText();
              break;
            case "2":
              _delMoment();
              break;
          }
        },
      )
    ];
  }

  _delMoment() async {
    showDialog(
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
            onPressed: () async {
              bool delRes = await SQL.delMomentById(_id);
              if (delRes) {
                Future.delayed(Duration(microseconds: 700), () {
                  Navigator.pop(context);
                });
              }
              Navigator.of(context).pop(true);
            },
            child: new Text('确定'),
          ),
        ],
      ),
    );
  }

  _showImgView(List img, int initialIndex) {
    showDialog(
        context: context,
        builder: (BuildContext _) {
          return GalleryPhotoViewWrapper(
            galleryItems: img,
            initialIndex: initialIndex,
          );
        });
  }

  shareText() {
    Share.share(
        '${moment.title} \r\n ${Date.getDateFormatMDHM(ms: moment.created)} \r\n ${moment.text}');
  }
}
