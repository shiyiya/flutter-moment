import 'dart:io';

import 'package:flutter/material.dart';
import 'package:moment/components/md_body.dart';
import 'package:moment/constants/app.dart';
import 'package:moment/pages/view_page.dart';
import 'package:moment/service/face.dart';
import 'package:moment/type/moment.dart';
import 'package:moment/utils/date.dart';
import 'package:moment/utils/img.dart';

class MomentCard extends StatelessWidget {
  final Moment moment;
  final Function(int cid) onLongPress;

  MomentCard({this.moment, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final String text =
        moment.text.length > 50 ? moment.text.substring(0, 28) : moment.text;
    final String firstImg =
        moment.alum.length < 1 ? null : moment.alum?.split('|')[0];
    final hasImg = firstImg != null && firstImg.length > 0;
    final int face = Face.getIndexByNum(moment.face);

    final _moment = Moment(
        title: moment.title.trim(),
        text: text.trim(),
        alum: firstImg,
        face: face,
        weather: moment.weather,
        created: moment.created,
        cid: moment.cid);

    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(3.0)),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 1),
              blurRadius: 1,
            )
          ],
        ),
        child: hasImg
            ? withImgCard(context, _moment)
            : normalCard(context, _moment),
      ),
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return ViewPage(id: moment.cid);
        }));
      },
      onLongPress: () {
        if (onLongPress != null) {
          onLongPress(moment.cid);
        }
      },
    );
  }

  Widget withImgCard(BuildContext context, Moment _) {
    final medSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Column(
      children: <Widget>[
        Container(
          height: medSize.height / 5,
          width: double.infinity,
          child: Img.isLocal(_.alum)
              ? Image.file(
                  File(_.alum),
                  fit: BoxFit.cover,
                )
              : Image.network(
                  _.alum,
                  fit: BoxFit.cover,
                ),
        ),
        Container(
          padding: _.title.length > 0
              ? EdgeInsets.symmetric(horizontal: 10)
              : EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          width: double.infinity,
          child: _.title.length > 0
              ? ListTile(
                  contentPadding: EdgeInsets.all(0),
                  title: Text(_.title),
                  subtitle: MDBody(_.text),
                )
              : MDBody(_.text),
        ),
        bar(
          context,
          rChild: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              Constants.face[_.face],
              size: 12,
              color: theme.textTheme.headline3.color,
            ),
          ),
        )
      ],
    );
  }

  Widget normalCard(BuildContext context, Moment _) {
    return Card(
      elevation: 0.0,
      child: Column(
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            leading: Icon(
              Constants.face[_.face],
              size: 40,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text(_.title),
            subtitle: MDBody(_.text),
          ),
          bar(context)
        ],
      ),
    );
  }

  Widget bar(BuildContext _, {Widget rChild}) {
    final iconColor = Theme.of(_).textTheme.headline3.color;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 1, color: Color.fromRGBO(128, 128, 128, 0.1)),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Icon(
                  Icons.query_builder,
                  color: iconColor,
                  size: 12,
                ),
                Text(
                  ' ${Date.getDateFormatMD(ms: moment.created, prefix: '.')}',
                  style: TextStyle(
                    fontSize: 10,
                    color: iconColor,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (rChild != null) rChild,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    Constants.weather[moment.weather],
                    color: iconColor,
                    size: 12,
                  ),
                ),
                if (moment.eName != null && moment.eName.length > 0)
                  Text(
                    '${moment.eName}',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1,
                      color: iconColor,
                    ),
                  ),
              ],
            ),
          ]),
    );
  }

  Widget imgWidget(String img) {
    return Img.isLocal(img)
        ? Image.file(
            File(img),
            fit: BoxFit.cover,
          )
        : Image.network(
            img,
            fit: BoxFit.cover,
          );
  }
}
