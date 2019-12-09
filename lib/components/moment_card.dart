import 'dart:io';

import 'package:flutter/material.dart';
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
        moment.text.length > 50 ? moment.text.substring(0, 20) : moment.text;
    final String firstImg =
        moment.alum.length < 1 ? null : moment.alum?.split('|')[0];
    final int face = Face.getIndexByNum(moment.face);
    final title = moment.title.length > 0
        ? Text(
            moment.title,
            style: TextStyle(
              color: Theme.of(context).accentColor,
            ),
          )
        : null;

    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: Card(
          elevation: 0.5,
          child: Column(
            children: <Widget>[
              ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  leading: Icon(
                    Constants.face[face],
                    size: 40,
                    color: Theme.of(context).accentColor,
                  ),
                  title: title,
                  subtitle: Text(text.trim()),
                  trailing: firstImg != null
                      ? Container(
                          width: 80,
                          color: Colors.amber,
                          child: Img.isLocal(firstImg)
                              ? Image.file(
                                  File(firstImg),
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  firstImg,
                                  fit: BoxFit.cover,
                                ),
                        )
                      : null),
              ButtonTheme.bar(
                  child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        width: 1, color: Color.fromRGBO(128, 128, 128, 0.1)),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Icon(
                            Icons.query_builder,
                            color: Theme.of(context).textTheme.display3.color,
                            size: 12,
                          ),
                          Text(
                            ' ${Date.getDateFormatMD(ms: moment.created, prefix: '.')}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).textTheme.display3.color,
                              textBaseline: TextBaseline.alphabetic,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Constants.weather[moment.weather],
                            color: Theme.of(context).textTheme.display3.color,
                            size: 12,
                          ),
                          if (moment.event.length > 0)
                            Text(
                              ' ${moment.event}',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1,
                                color:
                                    Theme.of(context).textTheme.display3.color,
                              ),
                            ),
                        ],
                      ),
                    ]),
              ))
            ],
          ),
        ),
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
}
