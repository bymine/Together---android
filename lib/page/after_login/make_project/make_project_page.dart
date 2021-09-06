import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/textfield_widget.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/sign_in_model.dart';
import 'package:together_android/model/user_profile_model.dart';
import 'package:together_android/page/after_login/make_project/show_user_detail_page.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';
import 'package:search_page/search_page.dart';

class MakeProjectBody extends StatefulWidget {
  @override
  _MakeProjectBodyState createState() => _MakeProjectBodyState();
}

class _MakeProjectBodyState extends State<MakeProjectBody> {
  int _currentStep = 0;

  String projectLevel = "상";
  String projectType = "스터디";
  var levelList = ["상", "중", "하", "설정 안함"];
  var typeList = ["스터디", "대외활동", "교내활동", "설정 안함"];
  TextEditingController titleController = TextEditingController(text: "1");
  TextEditingController expController = TextEditingController();

  TextEditingController categoryController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  final makeStep1 = GlobalKey<FormState>();
  final makeStep2 = GlobalKey<FormState>();
  final makeStep3 = GlobalKey<FormState>();

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  List<String> userList = [];
  List<String> member = [];
  List<String> category = [];
  List<String> tag = [];
  List<String> containTag = [];
  String selectedCategory = "게임";
  String selectedTag = "롤";
  List<String> projectCategory = [];
  List<String> projectTag = [];
  Map mappingTag = Map<String, String>();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    continued() async {
      if (_currentStep == 0) {
        if (makeStep1.currentState!.validate()) {
          _currentStep < 2 ? setState(() => _currentStep += 1) : null;

          var parsedNickName = await togetherPostAPI(
              '/project/searchMember',
              jsonEncode({
                "user_idx":
                    Provider.of<SignInModel>(context, listen: false).userIdx
              }));
          parsedNickName.map((element) {
            element as String;
            if (userList.contains(element) == false) {
              userList.add(element);
            }
          }).toList();
        }
      } else if (_currentStep == 1) {
        List parsedTag = await togetherGetAPI("/project/getTagList", "");
        parsedTag.forEach((element) {
          if (category.contains(element['tag_name']) == false) {
            category.add(element['tag_name']);
          }
          if (tag.contains(element['tag_detail_name']) == false) {
            tag.add(element['tag_detail_name']);
            mappingTag[element['tag_detail_name']] = element['tag_name'];
          }
        });

        category.add('기타');
        ;

        print(category);
        print(tag);
        print(mappingTag);

        _currentStep < 2 ? setState(() => _currentStep += 1) : null;
      } else if (_currentStep == 2) {
        print(jsonEncode({
          "user_idx": Provider.of<SignInModel>(context, listen: false).userIdx,
          "project_name": titleController.text,
          "project_exp": expController.text,
          "start_date": startDate.toIso8601String(),
          "end_date": endDate.toIso8601String(),
          "professionality": ProjectEnumFormat(projectLevel),
          "project_type": ProjectEnumFormat(projectType),
          "tag_num": projectTag.length,
          "tag_name": projectCategory,
          "detail_name": projectTag
        }));
        var code = await togetherPostAPI(
            "/project/createProject",
            jsonEncode({
              "user_idx":
                  Provider.of<SignInModel>(context, listen: false).userIdx,
              "project_name": titleController.text,
              "project_exp": expController.text,
              "start_date": startDate.toIso8601String(),
              "end_date": endDate.toIso8601String(),
              "professionality": ProjectEnumFormat(projectLevel),
              "project_type": ProjectEnumFormat(projectType),
              "tag_num": projectTag.length,
              "tag_name": projectCategory,
              "detail_name": projectTag
            }));
        if (code.toString() == "success") Navigator.of(context).pop();
      }
    }

    cancel() {
      print("cancel");
      _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
    }

    tapped(int step) {
      setState(() => _currentStep = step);
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: titleColor,
          title: Text('프로젝트 생성'),
        ),
        body: Container(
          child: Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepTapped: (step) => tapped(step),
              onStepContinue: continued,
              onStepCancel: cancel,
              controlsBuilder: (BuildContext context,
                  {VoidCallback? onStepContinue, VoidCallback? onStepCancel}) {
                return _currentStep == 0
                    ? Center(
                        child: Container(
                          width: width * 0.3,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: titleColor, shadowColor: titleColor),
                            onPressed: onStepContinue,
                            child: Text('다음'),
                          ),
                        ),
                      )
                    : _currentStep == 1
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: width * 0.3,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.red[200],
                                      shadowColor: Colors.red[200]),
                                  onPressed: onStepCancel,
                                  child: Text('이전'),
                                ),
                              ),
                              Container(
                                width: width * 0.3,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: titleColor,
                                      shadowColor: titleColor),
                                  onPressed: onStepContinue,
                                  child: Text('다음'),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: width * 0.3,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.red[200],
                                      shadowColor: Colors.red[200]),
                                  onPressed: onStepCancel,
                                  child: Text('이전'),
                                ),
                              ),
                              Container(
                                width: width * 0.3,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: titleColor,
                                      shadowColor: titleColor),
                                  onPressed: onStepContinue,
                                  child: Text('생성하기'),
                                ),
                              ),
                            ],
                          );
              },
              steps: [
                Step(
                  title: Text("프로젝트 생성"),
                  content: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade400.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Form(
                          key: makeStep1,
                          child: TextFormFieldWidget(
                              header: Text("프로젝트 제목"),
                              body: TextFormField(
                                controller: titleController,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    prefixIcon: Icon(Icons.title_outlined)),
                                validator: (value) {
                                  if (value!.isEmpty) return "프로젝트 제목을 입력하세요";
                                },
                              ),
                              footer: null,
                              heightPadding: height * 0.02),
                        ),
                        TextFormFieldWidget(
                            header: Text("프로젝트 설명"),
                            body: TextFormField(
                              maxLines: 8,
                              controller: expController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  prefixIcon: Icon(Icons.description_outlined)),
                            ),
                            footer: null,
                            heightPadding: height * 0.02)
                      ],
                    ),
                  ),
                  isActive: _currentStep >= 0,
                  state: _currentStep >= 0
                      ? StepState.complete
                      : StepState.disabled,
                ),
                Step(
                  title: Text('세부 설정1'),
                  content: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade400.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        TextFormFieldWidget(
                            header: Text("프로젝트 난이도"),
                            body: GroupButton(
                                groupingType: GroupingType.wrap,
                                selectedColor: titleColor,
                                isRadio: true,
                                spacing: width * 0.01,
                                buttons: levelList,
                                selectedButton: levelList.indexOf(projectLevel),
                                onSelected: (index, isSelected) {
                                  setState(() {
                                    projectLevel = levelList[index];
                                    print(projectLevel);
                                  });
                                }),
                            footer: null,
                            heightPadding: height * 0.02),
                        TextFormFieldWidget(
                            header: Text("프로젝트 유형"),
                            body: GroupButton(
                                selectedColor: titleColor,
                                mainGroupAlignment: MainGroupAlignment.start,
                                buttonWidth: width * 0.25,
                                isRadio: true,
                                spacing: width * 0.02,
                                buttons: typeList,
                                selectedButton: typeList.indexOf(projectType),
                                onSelected: (index, isSelected) {
                                  setState(() {
                                    projectType = typeList[index];
                                    print(projectType);
                                  });
                                }),
                            footer: null,
                            heightPadding: height * 0.02),
                        TextFormFieldWidget(
                            header: Text("프로젝트 시작 날짜"),
                            body: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: width * 0.02,
                                  horizontal: width * 0.04),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(width: 1, color: Colors.grey)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(toDate(startDate)),
                                  IconButton(
                                      onPressed: () async {
                                        await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime(2025),
                                        ).then((value) {
                                          if (value != null) {
                                            setState(() {
                                              startDate = value;
                                              if (startDate.isAfter(endDate)) {
                                                endDate = DateTime(
                                                  startDate.year,
                                                  startDate.month,
                                                  startDate.day,
                                                  // hour이 더 늦을경우에는?
                                                );
                                              }
                                            });
                                          }
                                        });
                                      },
                                      icon: Icon(Icons.arrow_drop_down_outlined,
                                          size: 32))
                                ],
                              ),
                            ),
                            footer: null,
                            heightPadding: height * 0.02),
                        TextFormFieldWidget(
                            header: Text("프로젝트 종료 날짜"),
                            body: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: width * 0.02,
                                  horizontal: width * 0.04),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(width: 1, color: Colors.grey)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(toDate(endDate)),
                                  IconButton(
                                      onPressed: () async {
                                        await showDatePicker(
                                          context: context,
                                          initialDate: startDate,
                                          firstDate: startDate,
                                          lastDate: DateTime(2025),
                                        ).then((value) {
                                          if (value != null) {
                                            setState(() {
                                              endDate = value;
                                            });
                                          }
                                        });
                                      },
                                      icon: Icon(Icons.arrow_drop_down_outlined,
                                          size: 32))
                                ],
                              ),
                            ),
                            footer: null,
                            heightPadding: height * 0.02),
                      ],
                    ),
                  ),
                  isActive: _currentStep >= 1,
                  state: _currentStep >= 1
                      ? StepState.complete
                      : StepState.disabled,
                ),
                Step(
                  title: Text('세부 설정2'),
                  content: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade400.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        TextFormFieldWidget(
                            header: Text("프로젝트 초대 멤버"),
                            body: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: width * 0.02,
                                    horizontal: width * 0.04),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        width: 1, color: Colors.grey)),
                                child: Row(
                                  children: [
                                    member.length == 0
                                        ? Expanded(child: Text(""))
                                        : Expanded(
                                            child: Wrap(
                                            children: member.map((e) {
                                              return Chip(label: Text(e));
                                            }).toList(),
                                          )),
                                    IconButton(
                                        onPressed: () {
                                          showSearch(
                                              context: context,
                                              delegate: SearchPage(
                                                  showItemsOnEmpty: true,
                                                  barTheme: ThemeData(
                                                      appBarTheme: AppBarTheme(
                                                          color: titleColor)),
                                                  builder: (person) => Card(
                                                        child: ListTile(
                                                          onTap: () async {
                                                            UserProfile
                                                                userProfile =
                                                                await togetherGetAPI(
                                                                    "/project/UserInfo",
                                                                    "/$person");

                                                            Navigator.of(
                                                                    context)
                                                                .push(
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            ShowUserDetailPage(
                                                                              userProfile: userProfile,
                                                                              members: member,
                                                                            )))
                                                                .then(
                                                                    (newMember) {
                                                              setState(() {
                                                                print(
                                                                    newMember);
                                                                if (member.contains(
                                                                            newMember) ==
                                                                        false &&
                                                                    newMember !=
                                                                        null)
                                                                  member.add(
                                                                      newMember);
                                                              });
                                                            });
                                                          },
                                                          trailing:
                                                              member.contains(
                                                                      person)
                                                                  ? Icon(
                                                                      Icons
                                                                          .check_circle_outline_outlined,
                                                                      color:
                                                                          titleColor,
                                                                    )
                                                                  : null,
                                                          title: Text(person
                                                              .toString()),
                                                        ),
                                                      ),
                                                  filter: (person) {
                                                    List<String> a = [];
                                                    userList.forEach((element) {
                                                      if (element.contains(
                                                          person.toString()))
                                                        a.add(element);
                                                    });

                                                    return a;
                                                  },
                                                  failure: Center(
                                                    child:
                                                        Text('No person found'),
                                                  ),
                                                  items: userList));
                                        },
                                        icon: Icon(
                                          Icons.person_add_alt_1_outlined,
                                        ))
                                  ],
                                )),
                            footer: null,
                            heightPadding: height * 0.06),
                        TextFormFieldWidget(
                            header: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("프로젝트 태그"),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: titleColor),
                                    onPressed: () {
                                      showModalBottomSheet(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          isScrollControlled: true,
                                          context: context,
                                          builder: (context) {
                                            print(
                                                "showModalBottomSheet builder 실행");
                                            containTag = [];
                                            // selectedCategory = category[0];
                                            mappingTag.keys.forEach((element) {
                                              if (mappingTag[element] ==
                                                  selectedCategory)
                                                containTag.add(element);
                                              print(containTag);
                                            });
                                            if (containTag.contains("기타") ==
                                                false) containTag.add("기타");
                                            return StatefulBuilder(
                                                builder: (context, setState) {
                                              print(selectedCategory);
                                              print(selectedTag);
                                              print(
                                                  "StatefulBuilder builder 실행");
                                              // print(selectedCategory);
                                              // print(selectedTag);
                                              return Padding(
                                                padding: MediaQuery.of(context)
                                                    .viewInsets,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: width * 0.1,
                                                      horizontal: width * 0.1),
                                                  child: Wrap(
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Text("카테고리 선택"),
                                                          DropdownButton(
                                                            value:
                                                                selectedCategory,
                                                            items: category
                                                                .map((value) {
                                                              return DropdownMenuItem(
                                                                  value: value,
                                                                  child: Text(
                                                                      value));
                                                            }).toList(),
                                                            onChanged: (value) {
                                                              setState(() {
                                                                selectedCategory =
                                                                    value
                                                                        .toString();

                                                                if (value ==
                                                                    "기타") {
                                                                  selectedTag =
                                                                      "기타";
                                                                } else {
                                                                  containTag =
                                                                      [];
                                                                  mappingTag
                                                                      .keys
                                                                      .forEach(
                                                                          (element) {
                                                                    if (mappingTag[
                                                                            element] ==
                                                                        selectedCategory)
                                                                      containTag
                                                                          .add(
                                                                              element);
                                                                  });
                                                                  containTag
                                                                      .add(
                                                                          "기타");
                                                                  selectedTag =
                                                                      containTag[
                                                                          0];
                                                                }

                                                                print(
                                                                    containTag);
                                                              });
                                                            },
                                                          )
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        width: width * 0.2,
                                                      ),
                                                      Column(
                                                        children: [
                                                          Text("태그 선택"),
                                                          // Text(selectedTag),
                                                          // Text(containTag
                                                          //     .toString()),
                                                          DropdownButton(
                                                            value: selectedTag,
                                                            items: selectedCategory !=
                                                                    "기타"
                                                                ? containTag.map(
                                                                    (value) {
                                                                    return DropdownMenuItem(
                                                                        value:
                                                                            value,
                                                                        child: Text(
                                                                            value));
                                                                  }).toList()
                                                                : ['기타'].map(
                                                                    (value) {
                                                                    return DropdownMenuItem(
                                                                        value:
                                                                            value,
                                                                        child: Text(
                                                                            value));
                                                                  }).toList(),
                                                            onChanged: (value) {
                                                              setState(() {
                                                                selectedTag = value
                                                                    .toString();
                                                                print(
                                                                    selectedTag);
                                                              });
                                                            },
                                                          )
                                                        ],
                                                      ),
                                                      Visibility(
                                                          visible:
                                                              selectedCategory ==
                                                                  "기타",
                                                          child:
                                                              TextFormFieldWidget(
                                                                  header: Text(
                                                                      "카테고리 입력"),
                                                                  body:
                                                                      TextFormField(
                                                                    controller:
                                                                        categoryController,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      hintText:
                                                                          "카테고리를 입력하세요..",
                                                                      border:
                                                                          OutlineInputBorder(),
                                                                    ),
                                                                  ),
                                                                  footer: null,
                                                                  heightPadding:
                                                                      height *
                                                                          0.02)),
                                                      Visibility(
                                                          visible:
                                                              selectedCategory ==
                                                                      "기타" ||
                                                                  selectedTag ==
                                                                      "기타",
                                                          child:
                                                              TextFormFieldWidget(
                                                                  header: Text(
                                                                      "태그 입력"),
                                                                  body:
                                                                      TextFormField(
                                                                    controller:
                                                                        tagController,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      hintText:
                                                                          "태그를 입력하세요..",
                                                                      border:
                                                                          OutlineInputBorder(),
                                                                    ),
                                                                  ),
                                                                  footer: null,
                                                                  heightPadding:
                                                                      height *
                                                                          0.02)),
                                                      Container(
                                                          width: width,
                                                          child: ElevatedButton(
                                                              style: ElevatedButton
                                                                  .styleFrom(
                                                                      primary:
                                                                          titleColor),
                                                              onPressed: () {
                                                                setState(() {
                                                                  if (selectedCategory ==
                                                                          "기타" &&
                                                                      selectedTag ==
                                                                          "기타") {
                                                                    projectTag.add(
                                                                        tagController
                                                                            .text);
                                                                    projectCategory.add(
                                                                        categoryController
                                                                            .text);
                                                                  } else if (selectedCategory !=
                                                                          "기타" &&
                                                                      selectedTag ==
                                                                          "기타") {
                                                                    projectTag.add(
                                                                        tagController
                                                                            .text);
                                                                    projectCategory
                                                                        .add(
                                                                            selectedCategory);
                                                                  } else {
                                                                    projectCategory
                                                                        .add(
                                                                            selectedCategory);
                                                                    projectTag.add(
                                                                        selectedTag);
                                                                  }
                                                                });
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child:
                                                                  Text("추가하기")))
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                          }).then((value) {
                                        setState(() {});
                                        containTag = [];
                                        tagController.clear();
                                        categoryController.clear();
                                      });
                                    },
                                    child: Text("태그 설정하기"))
                              ],
                            ),
                            body: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: width * 0.02,
                                    horizontal: width * 0.04),
                                decoration: projectTag.length == 0
                                    ? BoxDecoration()
                                    : BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            width: 1, color: Colors.grey)),
                                child: projectTag.length == 0
                                    ? Text("")
                                    : Wrap(
                                        spacing: width * 0.01,
                                        children: projectTag.map((e) {
                                          return Chip(
                                              backgroundColor: titleColor,
                                              deleteIconColor: Colors.red[300],
                                              onDeleted: () {
                                                setState(() {
                                                  var index =
                                                      projectTag.indexOf(e);
                                                  projectTag.removeAt(index);
                                                  projectCategory
                                                      .removeAt(index);
                                                });
                                              },
                                              label: Text(e.toString()));
                                        }).toList(),
                                      )),
                            footer: null,
                            heightPadding: height * 0.02),
                      ],
                    ),
                  ),
                  isActive: _currentStep >= 2,
                  state: _currentStep >= 2
                      ? StepState.complete
                      : StepState.disabled,
                ),
              ]),
        ));
  }
}
