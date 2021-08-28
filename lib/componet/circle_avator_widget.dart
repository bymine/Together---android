import 'package:flutter/material.dart';

class CircleAvatorComponent extends StatefulWidget {
  final double width;
  final double height;
  final String serverImage;

  CircleAvatorComponent(
      {required this.width, required this.height, required this.serverImage});

  @override
  _CircleAvatorComponentState createState() => _CircleAvatorComponentState();
}

class _CircleAvatorComponentState extends State<CircleAvatorComponent> {
  @override
  Widget build(BuildContext context) {
    return widget.serverImage.contains('assets')
        ? Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
                border: Border.all(width: 3, color: Colors.grey),
                shape: BoxShape.circle,
                image: DecorationImage(image: AssetImage(widget.serverImage))),
          )
        : Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
                border: Border.all(width: 3, color: Colors.grey),
                shape: BoxShape.circle,
                image:
                    DecorationImage(image: NetworkImage(widget.serverImage))),
          );
  }
}
