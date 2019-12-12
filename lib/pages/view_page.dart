import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:moment/components/alum.dart';
import 'package:moment/components/gallery_photo_view.dart';
import 'package:moment/constants/app.dart';
import 'package:moment/pages/edit.dart';
import 'package:moment/service/event_bus.dart';
import 'package:moment/service/face.dart';
import 'package:moment/sql/query.dart';
import 'package:moment/type/moment.dart';
import 'package:moment/utils/date.dart';
import 'package:share_extend/share_extend.dart';

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
    List<String> img = [];
    if (moment.alum != null) {
      img = moment.alum.split('|');
      img.removeWhere((e) => e.isEmpty);
    }

    /**
     *
     * markdown 示例不被支持
        ListView(
        children: <Widget>[
        img.length > 0 ? Alum(img: img) : Container(),
        buildMetaCard(),
        buildContent()
        ],
        )

     */

    return Scaffold(
      appBar: img.length > 0
          ? null
          : AppBar(
              title: Text(moment.title),
              titleSpacing: -5,
              actions: buildMenu(),
              elevation: 0.0,
            ),
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
//                      ),
                    )
                  : ListView(
                      children: <Widget>[buildMetaCard(), buildContent()],
                    )
//                  Container(
//                    decoration: BoxDecoration(
//                      image: DecorationImage(
//                          image: AssetImage('lib/asserts/images/bg_1.jpg'),
//                          fit: BoxFit.cover),
//                    ),
//                      child: ListView(
//                        children: <Widget>[buildMetaCard(), buildContent()],
//                      ),
//                    )
              : Center(child: Text(Constants.randomErrorTip()))
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget buildMetaCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      color: Theme.of(context).cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '捕捉于${Date.getWeekByMS(ms: moment.created)}',
                style: Theme.of(context).textTheme.caption,
              ),
              SizedBox(height: 5),
              Text(
                '${Date.getDateFormatYMD(ms: moment.created, prefix: '-')} ${Date.getDateFormatHMByMS(ms: moment.created)}',
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Constants.face[Face.getIndexByNum(moment.face)],
                    color: Theme.of(context).textTheme.caption.color,
                    size: 20,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Constants.weather[moment.weather],
                    color: Theme.of(context).textTheme.caption.color,
                    size: 20,
                  )
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    '${moment.eName ?? ''}  ',
                    style: Theme.of(context).textTheme.caption.copyWith(
                      shadows: <Shadow>[
                        Shadow(
                          color: Theme.of(context).accentColor,
                          offset: Offset(0, 0),
                          blurRadius: 8,
                        )
                      ],
                    ),
                  ),
                  Text(
                    moment.text
                            .replaceAll('\n', '')
                            .replaceAll(' ', '')
                            .length
                            .toString() +
                        ' 字',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildContent() {
    return Container(
//      color: Theme.of(context).backgroundColor,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 100),
      child: Text(
        moment.text,
        style: Theme.of(context).textTheme.body2.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              height: 1.8,
            ),
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
            onTap: (int index) {
              _showImgView(img, index);
            },
          ),
        ),
        title: Text(
          moment.title,
          style: TextStyle(
            // color: Theme.of(context).primaryColor,
            shadows: <Shadow>[
              Shadow(
                color: Theme.of(context).accentColor,
                offset: Offset(0, 0),
                blurRadius: 10,
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
        tooltip: 'edit',
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return Edit(id: _id);
          }));
        },
      ),
      PopupMenuButton(
        icon: Icon(Icons.share),
        offset: Offset(100, 100),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: "1",
            child: Text('分享为纯文本'),
          ),
//          const PopupMenuItem<String>(
//            value: "2",
//            child: Text('分享为图片'),
//          ),
        ],
        tooltip: "share",
        onSelected: (String result) {
          switch (result) {
            case "1":
              share2Text();
              break;
//            case "2":
//              share2Image();
              break;
          }
        },
      ),
      PopupMenuButton(
        //todo 格式化内容
        icon: Icon(Icons.more_horiz),
        offset: Offset(100, 100),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: "0",
            child: Text('删除该条瞬间'),
          ),
        ],
        tooltip: "more",
        onSelected: (String result) {
          switch (result) {
            case "0":
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
        content: new Text('确定本条删除么？'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('取消'),
          ),
          new FlatButton(
            onPressed: () async {
              bool delRes = await SQL.delMomentById(_id);
              if (delRes) {
                eventBus.fire(HomeRefreshEvent(true));
                Future.delayed(Duration(milliseconds: 400), () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                });
              }
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

  share2Text() {
    ShareExtend.share(
        '${moment.title} \r\n ${Date.getDateFormatMDHM(ms: moment.created)} \r\n ${moment.text}',
        'text');
  }

//  share2Image() async {
//    RenderRepaintBoundary boundary =
//        _repaintKey.currentContext.findRenderObject();
//    ui.Image image = await boundary.toImage();
//    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//    Uint8List finalPngBytes = byteData.buffer.asUint8List();
//    String temp = (await getTemporaryDirectory()).path;
//    final imageFile = File(p.join(
//        temp, DateTime.now().millisecondsSinceEpoch.toString() + '.png'));
//    await imageFile.writeAsBytes(finalPngBytes);
//
//    ShareExtend.share(imageFile.path, 'image');
//  }
}
