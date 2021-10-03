import 'package:flutter/material.dart';

class MakeProjectBody extends StatefulWidget {
  @override
  _MakeProjectBodyState createState() => _MakeProjectBodyState();
}

class _MakeProjectBodyState extends State<MakeProjectBody> {
  String projectLevel = "상";
  String projectType = "스터디";
  var levelList = ["상", "중", "하", "설정 안함"];
  var typeList = ["스터디", "대외활동", "교내활동", "설정 안함"];
  TextEditingController titleController = TextEditingController();
  TextEditingController expController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: _appBar(context),
      body: SingleChildScrollView(
        child: Container(),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Icon(
          Icons.arrow_back_ios,
          size: 20,
          color: Colors.black,
        ),
      ),
      actions: [
        Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.help_outline,
              color: Colors.grey,
              size: 24,
            )),
        SizedBox(
          width: 20,
        )
      ],
    );
  }
}
