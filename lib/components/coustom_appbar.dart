import 'package:flutter/material.dart';

class CustomAppbar extends StatefulWidget implements PreferredSizeWidget {
  final double contentHeight;
  final Color navigationBarBackgroundColor;
  final Widget leadingWidget;
  final Widget trailingWidget;
  final Widget centerWidget;

  CustomAppbar({
    this.leadingWidget,
    this.centerWidget,
    this.contentHeight = 44,
    this.navigationBarBackgroundColor,
    this.trailingWidget,
  }) : super();

  @override
  State<StatefulWidget> createState() {
    return new _CustomAppbarState();
  }

  @override
  Size get preferredSize => new Size.fromHeight(contentHeight);
}

///  statusheight = MediaQuery.of(context).padding.top;

class _CustomAppbarState extends State<CustomAppbar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: widget.navigationBarBackgroundColor ??
          Theme.of(context).appBarTheme.color,
      child: new SafeArea(
        top: true,
        child: new Container(
//            decoration: new UnderlineTabIndicator(
//              borderSide: BorderSide(width: 1.0, color: Color(0xFFeeeeee)),
//            ),
            height: widget.contentHeight,
            child: new Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned(
                  left: 0,
                  child: new Container(
                    padding: const EdgeInsets.only(left: 5),
                    child: widget.leadingWidget,
                  ),
                ),
                new Container(child: widget.centerWidget),
                Positioned(
                  right: 0,
                  child: new Container(
                    padding: const EdgeInsets.only(right: 5),
                    child: widget.trailingWidget,
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
