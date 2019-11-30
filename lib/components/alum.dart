import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:moment/utils/img.dart';

typedef AlumOnTap = void Function(int index);

class Alum extends StatefulWidget {
  final List img;
  final AlumOnTap onTap;
  final Widget emptyPlaceholder;

  final Widget defaultEmptyPlaceholder = Center(
    child: Text('No picture'),
  );

  Alum({Key key, @required this.img, this.emptyPlaceholder, this.onTap})
      : super(key: key);

  @override
  _AlumState createState() => _AlumState();
}

class _AlumState extends State<Alum> {
  ScrollController _scrollController;
  SwiperController _swiperController;

  @override
  Widget build(BuildContext context) {
    final img = widget.img;
    final emptyPlaceholder = widget.emptyPlaceholder != null
        ? widget.emptyPlaceholder
        : widget.defaultEmptyPlaceholder;
    final List imgFile = img
        .map((i) => Img.isLocal(i)
            ? Image.file(File(i), fit: BoxFit.cover)
            : Image.network(i))
        .toList();

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 3,
      color: imgFile.length > 0
          ? Colors.transparent
          : Theme.of(context).backgroundColor,
      child: img.length < 1
          ? emptyPlaceholder
          : Swiper(
              //viewportFraction: .9,
              //scale: 0.9,
              //loop: true,
              itemCount: img.length,
              autoplay: img.length > 1 ? true : false,
              autoplayDelay: 3000,
              autoplayDisableOnInteraction: true,
              duration: 1000,
              controller: _swiperController,
              itemBuilder: (BuildContext ctx, int index) {
                return Container(
                  child: imgFile[index],
                );
              },
              pagination: SwiperPagination(
                  builder: DotSwiperPaginationBuilder(size: 6, activeSize: 6)),
              onTap: (int index) {
                if (widget.onTap != null) {
                  widget.onTap(index);
                }
              },
            ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(() {});
    _swiperController = SwiperController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _swiperController.stopAutoplay();
    _swiperController.dispose();
    super.dispose();
  }
}
