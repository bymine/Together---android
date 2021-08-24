import 'package:flutter/material.dart';
import 'package:together_android/constant.dart';

class MakeProjectBody extends StatefulWidget {
  const MakeProjectBody({Key? key}) : super(key: key);

  @override
  _MakeProjectBodyState createState() => _MakeProjectBodyState();
}

class _MakeProjectBodyState extends State<MakeProjectBody> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: titleColor,
        title: Text('project make'),
      ),
    );
  }
}
