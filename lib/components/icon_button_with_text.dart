import 'package:flutter/material.dart';

/*
  icon
  text

  结果如上
 */

class TextIconButton extends StatelessWidget {
  final Icon icon;
  final String text;
  final Function onTap;

  TextIconButton({@required this.icon, @required this.text, this.onTap})
      : assert(icon != null),
        assert(text != null && text.length > 0);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap != null) onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        margin: EdgeInsets.only(bottom: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: icon,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(50.0),
                  ),
                  color: Theme.of(context).backgroundColor.withOpacity(0.3)),
            ),
            Text(
              text,
              style: Theme.of(context).textTheme.caption,
            )
          ],
        ),
      ),
    );
  }
}
