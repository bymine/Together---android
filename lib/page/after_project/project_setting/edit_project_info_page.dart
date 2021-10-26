import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/componet/input_field.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/live_project_model.dart';
import 'package:together_android/model/after_project_model/project_setting_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

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
  var typeList = ["스터디", "대외활동", "교내활동", "설정 안함"];
  String _selectedLevel = "";
  String _selectedType = "";
  late DateTime _selectedStart;
  late DateTime _selectedEnd;
  @override
  void initState() {
    super.initState();
    expController.text = widget.setting.projectExp;
    _selectedStart = DateTime.parse(widget.setting.startDate);
    _selectedEnd = DateTime.parse(widget.setting.endDate);
    _selectedLevel = projectEnumFromServer(widget.setting.level);
    _selectedType = projectEnumFromServer(widget.setting.type);
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
                  MyButton(
                      label: "Apply",
                      onTap: () async {
                        var projectIdx =
                            Provider.of<LiveProject>(context, listen: false)
                                .projectIdx;
                        var userIdx =
                            Provider.of<SignInModel>(context, listen: false)
                                .userIdx;
                        var code = await togetherPostSpecialAPI(
                            "/project/modifyInfo",
                            jsonEncode({
                              "project_exp": expController.text,
                              "start_date": _selectedStart.toIso8601String(),
                              "end_date": _selectedEnd.toIso8601String(),
                              "professionality":
                                  projectEnumFormat(_selectedLevel),
                              "project_type": projectEnumFormat(_selectedType),
                            }),
                            "/$userIdx/$projectIdx");

                        print(code.toString());
                        if (code.toString() == "success")
                          Navigator.of(context).pop(true);
                        else if (code.toString() == "not_leader")
                          Get.snackbar(
                              "프로젝트 설정 변경 실패", "팀장만이 프로젝트 정보를 수정할 수 있습니다.",
                              icon: Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.redAccent,
                              ));
                      })
                ],
              ),
              MyInputField(
                title: "Intro",
                hint: "",
                maxLine: 5,
                controller: expController,
              ),
              MyInputField(
                title: "Start",
                hint: toDate(_selectedStart),
                suffixIcon: IconButton(
                    onPressed: () {
                      _getDateFromUser(true);
                    },
                    icon: Icon(Icons.calendar_today)),
              ),
              MyInputField(
                title: "End",
                hint: toDate(_selectedEnd),
                suffixIcon: IconButton(
                    onPressed: () {
                      _getDateFromUser(false);
                    },
                    icon: Icon(Icons.calendar_today)),
              ),
              Container(
                margin: EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Project Type",
                      style: editTitleStyle,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GroupButton(
                      selectedColor: titleColor,
                      mainGroupAlignment: MainGroupAlignment.start,
                      groupingType: GroupingType.wrap,
                      spacing: 8,
                      selectedTextStyle:
                          editSubTitleStyle.copyWith(color: Colors.black),
                      unselectedTextStyle: editSubTitleStyle,
                      selectedButton: typeList.indexOf(_selectedType),
                      buttons: typeList,
                      onSelected: (index, isSelected) {
                        setState(() {
                          _selectedType = typeList[index];
                          print(_selectedType);
                        });
                      },
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Project Level",
                      style: editTitleStyle,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GroupButton(
                      selectedColor: titleColor,
                      mainGroupAlignment: MainGroupAlignment.start,
                      groupingType: GroupingType.wrap,
                      spacing: 8,
                      selectedTextStyle:
                          editSubTitleStyle.copyWith(color: Colors.black),
                      unselectedTextStyle: editSubTitleStyle,
                      selectedButton: levelList.indexOf(_selectedLevel),
                      buttons: levelList,
                      onSelected: (index, isSelected) {
                        setState(() {
                          _selectedLevel = levelList[index];
                          print(_selectedLevel);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _getDateFromUser(bool isStart) async {
    DateTime? _pickerDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2024));

    if (_pickerDate != null) {
      if (isStart == false) {
        //End time chose
        if (_pickerDate.isBefore(_selectedStart))
          setState(() {
            _selectedStart = _pickerDate.add(Duration(days: -7));
            _selectedEnd = _pickerDate;
          });
        else
          setState(() {
            _selectedEnd = _pickerDate;
          });
      } else {
        if (_pickerDate.isAfter(_selectedEnd))
          setState(() {
            _selectedStart = _pickerDate;
            _selectedEnd = _pickerDate.add(Duration(days: 7));
          });
        else
          setState(() {
            _selectedStart = _pickerDate;
          });
      }
    }
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
            selectedButton: buttons.indexOf(selected),
            buttons: buttons,
            onSelected: (index, isSelected) {
              setState(() {
                selected = buttons[index];
                print(selected);
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
