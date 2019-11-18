import 'package:flutter/material.dart';

typedef OnTap = void Function(int index);

class RowIconRadio extends StatefulWidget {
  final List<IconData> icon;
  int selected;
  final Colors selectedColor;
  final OnTap onTap;

  RowIconRadio(
      {Key,
      key,
      @required this.icon,
      this.selectedColor,
      this.selected,
      this.onTap})
      : super(key: key);

  @override
  _RowIconRadioState createState() => _RowIconRadioState();
}

class _RowIconRadioState extends State<RowIconRadio> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.icon
          .asMap()
          .keys
          .map((i) => IconButton(
                icon: Icon(widget.icon[i]),
                onPressed: () {
                  setState(() {
                    if (i == widget.selected) {
                      widget.selected = null;
                    } else {
                      widget.selected = i;
                    }
                  });
                  widget.onTap(i);
                },
                color: widget.selected == i
                    ? Theme.of(context).accentColor
                    : Colors.grey,
              ))
          .toList(),
    );
  }
}
