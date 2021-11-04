import 'package:flutter/material.dart';

class CardWithTitle extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  CardWithTitle({Key key, this.title, this.children, this.padding})
      : super(key: key);

  final _padding = const EdgeInsets.all(0);

  @override
  Widget build(BuildContext context) {
    final List<Widget> titleWidget = [
      Padding(
          padding: EdgeInsets.only(top: 15, left: 15, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.secondary,
            ),
          )),
    ];
    titleWidget.addAll(children);
    return Padding(
      padding: padding ?? _padding,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: titleWidget,
        ),
      ),
    );
  }
}
