import 'package:flutter/material.dart';
import 'package:together_android/constant.dart';

class BottomSheetTopBar extends StatefulWidget {
  final String title;
  final VoidCallback onPressed;

  BottomSheetTopBar({required this.title, required this.onPressed});

  @override
  _BottomSheetTopBarState createState() => _BottomSheetTopBarState();
}

class _BottomSheetTopBarState extends State<BottomSheetTopBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: Colors.grey))),
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.close)),
          Expanded(
            child: Text(widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          TextButton(
            style: TextButton.styleFrom(primary: titleColor),
            onPressed: widget.onPressed,
            child: Text(
              "Save",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
