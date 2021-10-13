import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subTitle;
  final Widget? trailing;

  MyListTile({this.leading, required this.title, this.subTitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color(0xffffe0e0e0),
              spreadRadius: 2,
              blurRadius: 2,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ]),
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subTitle,
        trailing: trailing,
      ),
    );
  }
}
