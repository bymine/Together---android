import 'package:flutter/material.dart';

class TextFormFieldWidget extends StatefulWidget {
  final Widget header;
  final Widget body;
  final Widget? footer;
  final double heightPadding;

  TextFormFieldWidget(
      {required this.header,
      required this.body,
      required this.footer,
      required this.heightPadding});

  @override
  _TextFormFieldWidgetState createState() => _TextFormFieldWidgetState();
}

class _TextFormFieldWidgetState extends State<TextFormFieldWidget> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.header,
          SizedBox(
            height: height * 0.01,
          ),
          widget.body,
          SizedBox(
            height: height * 0.01,
          ),
          widget.footer ?? Container(),
          SizedBox(
            height: widget.heightPadding,
          )
        ],
      ),
    );
  }
}
