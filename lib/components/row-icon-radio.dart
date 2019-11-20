import 'package:flutter/material.dart';

typedef OnTap = void Function(int index);

class RowIconRadio extends StatefulWidget {
  final List<IconData> icon;
  final int selected;
  final Colors selectedColor;
  final OnTap onTap;

  RowIconRadio(
      {Key key,
      @required this.icon,
      this.selectedColor,
      this.selected,
      this.onTap})
      : super(key: key);

  @override
  _RowIconRadioState createState() => _RowIconRadioState();
}

class _RowIconRadioState extends State<RowIconRadio> {
  int active;

  @override
  void initState() {
    super.initState();

    active = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    int _active =
        widget.selected == active ? active ?? widget.selected : active;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.icon
          .asMap()
          .keys
          .map(
            (i) => IconButton(
                icon: Icon(widget.icon[i]),
                onPressed: () {
                  setState(() {
                    if (i == _active) {
                      setState(() {
                        active = null;
                      });
                    } else {
                      setState(() {
                        active = i;
                      });
                    }
                  });
                  widget.onTap(i);
                },
                color:
                    _active == i ? Theme.of(context).accentColor : Colors.grey),
          )
          .toList(),
    );
  }
}
