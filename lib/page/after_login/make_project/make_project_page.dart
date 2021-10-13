import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:search_page/search_page.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/componet/input_field.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/user_profile_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/page/after_login/make_project/show_user_detail_page.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

class MakeProjectBody extends StatefulWidget {
  @override
  _MakeProjectBodyState createState() => _MakeProjectBodyState();
}

class _MakeProjectBodyState extends State<MakeProjectBody> {
  String projectLevel = "상";
  String projectType = "스터디";
  var levelList = ["상", "중", "하", "설정 안함"];
  var typeList = ["스터디", "대외활동", "교내활동", "설정안함"];
  TextEditingController titleController = TextEditingController();
  TextEditingController expController = TextEditingController();

  TextEditingController categoryController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  List<String> member = [];
  List<String> userList = [];

  List<String> category = [];
  List<String> tag = [];
  List<String> containTag = [];
  List<String> projectCategory = [];
  List<String> projectTag = [];

  String selectedCategory = "게임";
  String selectedTag = "롤";
  Map mappingTag = Map<String, String>();

  DateTime _selectedStart = DateTime.now();
  DateTime _selectedEnd = DateTime.now().add(Duration(days: 7));

  @override
  void initState() {
    fetchUserList();
    fetchTagList();
    super.initState();
  }

  void fetchUserList() async {
    var parsedNickName = await togetherPostAPI(
        '/project/searchMember',
        jsonEncode({
          "user_idx": Provider.of<SignInModel>(context, listen: false).userIdx
        }));
    parsedNickName.map((element) {
      element as String;
      if (userList.contains(element) == false) {
        userList.add(element);
      }
    }).toList();
  }

  void fetchTagList() async {
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
    category.removeAt(0);
    tag.removeAt(0);
    if (category.contains("기타") == false) category.add('기타');

    print(category);
    print(tag);
    print(mappingTag);
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
              left: width * 0.08, right: width * 0.08, bottom: height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Create Team Proejct", style: headingStyle),
              MyInputField(
                  title: "Title",
                  hint: "Input Project Title",
                  controller: titleController),
              MyInputField(
                title: "Description",
                hint: "Input Project Description",
                controller: expController,
                maxLine: 5,
              ),
              projectGroypButton(
                  title: "Project Type",
                  buttons: typeList,
                  selected: projectType),
              projectGroypButton(
                  title: "Project Level",
                  buttons: levelList,
                  selected: projectLevel),
              MyInputField(
                title: "Start Date",
                hint: DateFormat.yMd().format(_selectedStart),
                suffixIcon: IconButton(
                  onPressed: () async {
                    _getDateFromUser(true);
                  },
                  icon: Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),
              MyInputField(
                title: "End Date",
                hint: DateFormat.yMd().format(_selectedEnd),
                suffixIcon: IconButton(
                  onPressed: () async {
                    _getDateFromUser(false);
                  },
                  icon: Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),
              MyInputField(
                title: "Project Member",
                hint: member
                    .toString()
                    .substring(1, member.toString().length - 1),
                suffixIcon: IconButton(
                  onPressed: () {
                    openUserList(context);
                  },
                  icon: Icon(
                    Icons.person_add,
                    color: Colors.grey,
                  ),
                ),
              ),
              MyInputField(
                title: "Project Tag",
                hint: projectTag
                    .toString()
                    .substring(1, projectTag.toString().length - 1),
                suffixIcon: IconButton(
                  onPressed: () {
                    showTagBottomSheet(context, width, height).then((value) {
                      setState(() {});
                      containTag = [];
                      tagController.clear();
                      categoryController.clear();
                    });
                  },
                  icon: Icon(
                    Icons.tag,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              createProjectButton(width, height, context)
            ],
          ),
        ),
      ),
    );
  }

  createProjectButton(double width, double height, BuildContext context) {
    return Container(
        width: width,
        height: height * 0.08,
        child: MyButton(
            label: "Create Project",
            onTap: () async {
              var code = await togetherPostAPI(
                  "/project/createProject",
                  jsonEncode({
                    "user_idx": Provider.of<SignInModel>(context, listen: false)
                        .userIdx,
                    "project_name": titleController.text,
                    "project_exp": expController.text,
                    "start_date": _selectedStart.toIso8601String(),
                    "end_date": _selectedEnd.toIso8601String(),
                    "professionality": projectEnumFormat(projectLevel),
                    "project_type": projectEnumFormat(projectType),
                    "tag_num": projectTag.length,
                    "tag_name": projectCategory,
                    "detail_name": projectTag
                  }));
              if (code.toString() == "success") Navigator.of(context).pop(true);
            }));
  }

  showTagBottomSheet(BuildContext context, double width, double height) {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          containTag = [];
          mappingTag.keys.forEach((element) {
            if (mappingTag[element] == selectedCategory)
              containTag.add(element);
          });
          if (containTag.contains("기타") == false) containTag.add("기타");
          return StatefulBuilder(builder: (context, setState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                padding: EdgeInsets.only(
                    left: width * 0.08,
                    right: width * 0.08,
                    top: height * 0.02,
                    bottom: height * 0.02),
                child: Wrap(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Add Proejct Tag", style: headingStyle),
                        MyInputField(
                          title: "Select Category",
                          hint: selectedCategory,
                          suffixIcon: DropdownButton(
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

                                if (value == "기타") {
                                  selectedTag = "기타";
                                } else {
                                  containTag = [];
                                  mappingTag.keys.forEach((element) {
                                    if (mappingTag[element] == selectedCategory)
                                      containTag.add(element);
                                  });
                                  containTag.add("기타");
                                  selectedTag = containTag[0];
                                }

                                print(containTag);
                              });
                            },
                          ),
                        ),
                        MyInputField(
                          title: "Select Tag",
                          hint: selectedTag,
                          suffixIcon: DropdownButton(
                            dropdownColor: Colors.blueGrey,
                            underline: Container(),
                            value: selectedTag,
                            items: selectedCategory != "기타"
                                ? containTag.map((value) {
                                    return DropdownMenuItem(
                                        value: value,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 14),
                                          child: Text(
                                            value,
                                            style: editSubTitleStyle.copyWith(
                                                color: Colors.white),
                                          ),
                                        ));
                                  }).toList()
                                : ['기타'].map((value) {
                                    return DropdownMenuItem(
                                        value: value,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
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
                                print(selectedTag);
                              });
                            },
                          ),
                        ),
                        Visibility(
                            visible: selectedCategory == "기타",
                            child: MyInputField(
                                title: "Category",
                                hint: "Input Category",
                                controller: categoryController)),
                        Visibility(
                            visible:
                                selectedCategory == "기타" || selectedTag == "기타",
                            child: MyInputField(
                                title: "Tag",
                                hint: "Input Tag",
                                controller: tagController)),
                        SizedBox(
                          height: 20,
                        ),
                        MyButton(
                            label: "+ Add Tag",
                            onTap: () {
                              setState(() {
                                if (selectedCategory == "기타" &&
                                    selectedTag == "기타") {
                                  projectTag.add(tagController.text);
                                  projectCategory.add(categoryController.text);
                                } else if (selectedCategory != "기타" &&
                                    selectedTag == "기타") {
                                  projectTag.add(tagController.text);
                                  projectCategory.add(selectedCategory);
                                } else {
                                  projectCategory.add(selectedCategory);
                                  projectTag.add(selectedTag);
                                }
                              });
                              Navigator.of(context).pop();
                            })
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  openUserList(BuildContext context) {
    return showSearch(
        context: context,
        delegate: SearchPage(
            showItemsOnEmpty: true,
            barTheme: ThemeData(appBarTheme: AppBarTheme(color: titleColor)),
            builder: (person) => Card(
                  child: ListTile(
                    onTap: () {
                      _showUserDetailFunction(person);
                    },
                    trailing: member.contains(person)
                        ? Icon(
                            Icons.check_circle_outline_outlined,
                            color: titleColor,
                          )
                        : null,
                    title: Text(person.toString()),
                  ),
                ),
            filter: (person) {
              List<String> a = [];
              userList.forEach((element) {
                if (element.contains(person.toString())) a.add(element);
              });

              return a;
            },
            failure: Center(
              child: Text('No person found'),
            ),
            items: userList));
  }

  _showUserDetailFunction(var person) async {
    UserProfile userProfile =
        await togetherGetAPI("/project/UserInfo", "/$person");

    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => ShowUserDetailPage(
                  userProfile: userProfile,
                  members: member,
                )))
        .then((newMember) {
      setState(() {
        print(newMember);
        if (member.contains(newMember) == false && newMember != null)
          member.add(newMember);
      });
    });
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
            selectedButton: typeList.indexOf(projectType),
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
