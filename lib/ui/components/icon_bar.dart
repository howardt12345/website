import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'dart:html' as html;
import 'dart:math';

class IconBarButton extends StatefulWidget {
  const IconBarButton({Key key, this.url, this.iconData}) : super(key: key);

  final String url;
  final IconData iconData;

  @override
  _IconBarButtonState createState() => _IconBarButtonState();
}

class _IconBarButtonState extends State<IconBarButton> {
  Color _color = Colors.black;

  void _onTap() {
    html.window.open(widget.url, '${Random.secure().nextInt(1000000000)}');
  }

  void _changeButtonColor(Color color) {
    setState(() {
      _color = color;
    });
  }

  void _onPointerExit(PointerExitEvent event) {
    _changeButtonColor(Theme.of(context).textTheme.button.color);
  }

  void _onPointerHover(PointerHoverEvent event) {
    _changeButtonColor(Theme.of(context).buttonColor);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onExit: _onPointerExit,
      onHover: _onPointerHover,
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
          child: Icon(
            widget.iconData,
            color: _color,
            size: 24,
          ),
        ),
      ),
    );
  }
}