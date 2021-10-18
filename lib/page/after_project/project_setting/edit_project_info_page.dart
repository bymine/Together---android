import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/componet/input_field.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_project_model/project_setting_model.dart';

// ignore: must_be_immutable
class EditProjectInfo extends StatefulWidget {
  ProjectSetting setting;
  EditProjectInfo({Key? key, required this.setting}) : super(key: key);

  @override
  _EditProjectInfoState createState() => _EditProjectInfoState();
}

class _EditProjectInfoState extends State<EditProjectInfo> {
  TextEditingController expController = TextEditingController();
  var levelList = ["상", "중", "하", "설정 안함"];
  var typeList = ["스터디", "대외활동", "교내활동", "설정안함"];

  @override
  void initState() {
    super.initState();
    expController.text = widget.setting.projectExp;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: _appBar(context),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
              left: width * 0.04, right: width * 0.04, bottom: height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Edit Project Info", style: headingStyle),
                  MyButton(label: "Apply", onTap: () {})
                ],
              ),
              MyInputField(
                title: "Intro",
                hint: "",
                maxLine: 5,
                controller: expController,
              ),
              MyInputField(title: "Start", hint: ""),
              MyInputField(title: "End", hint: ""),
              projectGroypButton(
                  title: "Project Type",
                  buttons: typeList,
                  selected: widget.setting.type),
              projectGroypButton(
                  title: "Project Personality",
                  buttons: levelList,
                  selected: widget.setting.level),
            ],
          ),
        ),
      ),
    );
  }

  projectGroypButton(
      {required String title,
      required List<String> buttons,
      required String selected}) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: editTitleStyle,
          ),
          SizedBox(
            height: 10,
          ),
          GroupButton(
            selectedColor: titleColor,
            mainGroupAlignment: MainGroupAlignment.start,
            groupingType: GroupingType.wrap,
            spacing: title == "Project Type" ? 12 : 8,
            selectedTextStyle: editSubTitleStyle.copyWith(color: Colors.black),
            unselectedTextStyle: editSubTitleStyle,
            selectedButton: typeList.indexOf(selected),
            buttons: buttons,
            onSelected: (index, isSelected) {
              setState(() {
                selected = typeList[index];
              });
            },
          ),
        ],
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
