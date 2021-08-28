import 'package:flutter/material.dart';
import 'package:together_android/constant.dart';

class MatchMemberBody extends StatefulWidget {
  const MatchMemberBody({Key? key}) : super(key: key);

  @override
  _MatchMemberBodyState createState() => _MatchMemberBodyState();
}

class _MatchMemberBodyState extends State<MatchMemberBody> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: titleColor,
        title: Text("팀원 찾기"),
      ),
    );
  }
}
