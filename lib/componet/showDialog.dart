import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showAlertDialog(BuildContext context, Widget? title, Widget content,
    List<Widget> actions) async {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: EdgeInsets.all(0),
          contentPadding: EdgeInsets.all(0),
          actionsPadding: EdgeInsets.all(0),
          title: title == Container() ? null : title,
          content: content == Container() ? null : content,
          actions: actions == [] ? [] : actions,
        );
      });
}

loadingAlert(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: new Row(
      children: [
        CircularProgressIndicator(),
        Container(margin: EdgeInsets.only(left: 5), child: Text("Loading")),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
