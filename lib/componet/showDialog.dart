import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showAlertDialog(BuildContext context, Widget title, Widget content,
    List<Widget> actions) async {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          title: title,
          titlePadding: EdgeInsets.all(10),
          contentPadding: EdgeInsets.all(0),
          content: content,
          actions: actions == [] ? [] : actions,
        );
      });
}
