import 'package:flutter/material.dart';
import 'package:together_android/constant.dart';

class MatchProjectBody extends StatefulWidget {
  const MatchProjectBody({Key? key}) : super(key: key);

  @override
  _MatchProjectBodyState createState() => _MatchProjectBodyState();
}

class _MatchProjectBodyState extends State<MatchProjectBody> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: titleColor,
        title: Text("프로젝트 찾기"),
      ),
    );
  }
}
