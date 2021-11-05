import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/componet/input_field.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

class ConditionTeamPage extends StatefulWidget {
  const ConditionTeamPage({Key? key}) : super(key: key);

  @override
  _ConditionTeamPageState createState() => _ConditionTeamPageState();
}

class _ConditionTeamPageState extends State<ConditionTeamPage> {
  bool isSave = false;
  var levelList = ["상", "중", "하", "설정 안함"];
  var typeList = ["스터디", "대외활동", "교내활동", "설정 안함"];
  String _selectedLevel = "설정 안함";
  String _selectedType = "설정 안함";
  DateTime _selectedStart = DateTime.now();
  DateTime _selectedEnd = DateTime.now();

  List<String> category = [];
  List<String> tag = [];
  List<String> containTag = [];
  List<String> selectList = [];

  String selectTag = "";
  String selectCategory = "";

  Map mappingTag = Map<String, String>();
  Map mappingIdx = Map<String, String>();
  String selectedCategory = "";
  String selectedTag = "";

  getTagList() async {
    List parsedTag = await togetherGetAPI("/project/getTagList", "");
    parsedTag.forEach((element) {
      mappingIdx[element['tag_detail_name']] = element['tag_idx'].toString();
      if (category.contains(element['tag_name']) == false) {
        category.add(element['tag_name']);
      }
      if (tag.contains(element['tag_detail_name']) == false) {
        tag.add(element['tag_detail_name']);
        mappingTag[element['tag_detail_name']] = element['tag_name'];
      }
    });
    category.removeAt(0);
    tag.removeAt(0);
    selectedCategory = category.first;
    selectedTag = tag.first;
  }

  @override
  void initState() {
    super.initState();
    getTagList();
  }

//  5, 10 ,15 ,20 , 25  , 상관없음 ==999
// 태그 하나만 전송
// save:1, not save:0

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<SignInModel>(context, listen: false);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: _appBar(context),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
              left: width * 0.08,
              right: width * 0.08,
              bottom: height * 0.02,
              top: height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("프로젝트 조건 검색", style: headingStyle),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                value: isSave,
                                onChanged: (value) {
                                  setState(() {
                                    isSave = value!;
                                  });
                                }),
                          ),
                          Text(
                            "Save",
                            style: editTitleStyle,
                          )
                        ],
                      )
                    ],
                  ),
                  MyButton(
                      label: "설정하기",
                      onTap: () async {
                        // any --> ""
                        Navigator.of(context).pop(jsonEncode({
                          "user_idx": user.userIdx,
                          "tag_name": selectCategory, // ""
                          "tag_detail_name": selectTag, // ""
                          "start_date": _selectedStart.toIso8601String(),
                          "end_date": _selectedEnd.toIso8601String(),
                          "professionality":
                              projectEnumFormat(_selectedLevel) == "Any"
                                  ? ""
                                  : projectEnumFormat(_selectedLevel),
                          "project_type":
                              projectEnumFormat(_selectedType) == "Any"
                                  ? ""
                                  : projectEnumFormat(_selectedType),
                          "member_num": 5,
                          "flag": isSave ? 1 : 0
                        }));
                      })
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "프로젝트 유형",
                      style: editTitleStyle,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GroupButton(
                      selectedColor: titleColor,
                      mainGroupAlignment: MainGroupAlignment.start,
                      groupingType: GroupingType.wrap,
                      spacing: 0.1,
                      selectedTextStyle:
                          editSubTitleStyle.copyWith(color: Colors.black),
                      unselectedTextStyle: editSubTitleStyle,
                      selectedButton: typeList.indexOf(_selectedType),
                      buttons: typeList,
                      onSelected: (index, isSelected) {
                        setState(() {
                          _selectedType = typeList[index];
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
                      "프로젝트 난이도",
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
                        });
                      },
                    ),
                    MyInputField(
                      title: "태그",
                      hint: selectTag,
                      suffixIcon: IconButton(
                        onPressed: () {
                          tagSheet(context, width, height);
                        },
                        icon: Icon(
                          Icons.tag,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    MyInputField(
                      title: "시작 날짜",
                      hint: toDate(_selectedStart),
                      suffixIcon: IconButton(
                          onPressed: () {
                            _getDateFromUser(true);
                          },
                          icon: Icon(Icons.calendar_today)),
                    ),
                    MyInputField(
                      title: "종료 날짜",
                      hint: toDate(_selectedEnd),
                      suffixIcon: IconButton(
                          onPressed: () {
                            _getDateFromUser(false);
                          },
                          icon: Icon(Icons.calendar_today)),
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

  tagSheet(BuildContext context, double width, double height) {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        context: context,
        builder: (context) {
          containTag = [];
          mappingTag.keys.forEach((element) {
            if (mappingTag[element] == selectedCategory)
              containTag.add(element);
          });
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                  left: width * 0.08,
                  right: width * 0.08,
                  top: height * 0.02,
                  bottom: height * 0.02),
              child: Wrap(
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("태그 선택", style: headingStyle),
                          MyButton(
                              width: width * 0.25,
                              height: 50,
                              label: "+ 추가",
                              onTap: () {
                                setState(() {
                                  if (selectTag != selectedTag)
                                    selectTag = selectedTag;
                                  selectCategory = selectedCategory;
                                });
                                Navigator.of(context).pop();
                              })
                        ],
                      ),
                      MyInputField(
                        title: "카테고리",
                        hint: selectedCategory,
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: DropdownButton(
                            dropdownColor: Colors.blueGrey,
                            underline: Container(),
                            value: selectedCategory,
                            items: category.map((value) {
                              return DropdownMenuItem(
                                  value: value,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 14,
                                    ),
                                    child: Text(value,
                                        style: editSubTitleStyle.copyWith(
                                            color: Colors.white)),
                                  ));
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value.toString();

                                containTag = [];
                                mappingTag.keys.forEach((element) {
                                  if (mappingTag[element] == selectedCategory)
                                    containTag.add(element);
                                });
                                selectedTag = containTag.first;
                              });
                            },
                          ),
                        ),
                      ),
                      MyInputField(
                        title: "태그",
                        hint: selectedTag,
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: DropdownButton(
                            dropdownColor: Colors.blueGrey,
                            underline: Container(),
                            value: selectedTag,
                            items: containTag.map((value) {
                              return DropdownMenuItem(
                                  value: value,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 14),
                                    child: Text(
                                      value,
                                      style: editSubTitleStyle.copyWith(
                                          color: Colors.white),
                                    ),
                                  ));
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedTag = value.toString();
                              });
                            },
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            );
          });
        }).then((value) => setState(() {}));
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
