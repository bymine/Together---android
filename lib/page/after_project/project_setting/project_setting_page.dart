import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:search_page/search_page.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/componet/input_field.dart';
import 'package:together_android/componet/listTile.dart';
import 'package:together_android/componet/showDialog.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/live_project_model.dart';
import 'package:together_android/model/after_login_model/user_profile_model.dart';
import 'package:together_android/model/after_project_model/project_apply_member_model.dart';
import 'package:together_android/model/after_project_model/project_setting_model.dart';
import 'package:together_android/model/after_project_model/show_user_list_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/page/after_login/main_page.dart';
import 'package:together_android/page/after_login/make_project/show_user_detail_page.dart';
import 'package:together_android/page/after_project/project_setting/edit_project_info_page.dart';
import 'package:together_android/page/after_project/project_setting/edit_project_member_page.dart';
import 'package:together_android/page/after_project/project_setting/show_apply_List_page.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';
import 'package:async/async.dart';

class ProjectSettingPage extends StatefulWidget {
  const ProjectSettingPage({Key? key}) : super(key: key);

  @override
  _ProjectSettingPageState createState() => _ProjectSettingPageState();
}

class _ProjectSettingPageState extends State<ProjectSettingPage> {
  late Future future;
  List<String> userList = [];
  List<UserInfo> userInfoList = [];
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  List<String> category = [];
  List<String> tag = [];
  List<String> containTag = [];
  TextEditingController categoryController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  Map mappingTag = Map<String, String>();
  Map mappingIdx = Map<String, String>();
  String selectedCategory = "";
  String selectedTag = "";

  List<ProjectApplyMember> applyList = [];
  fetchSetting() async {
    var projectIdx =
        Provider.of<LiveProject>(context, listen: false).projectIdx;
    print("info");

    return togetherGetAPI("/project/getInfo", "/$projectIdx");
  }

  fetchUserList() async {
    _memoizer.runOnce(() async {
      var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;

      var projectIdx =
          Provider.of<LiveProject>(context, listen: false).projectIdx;

      try {
        userInfoList = await togetherPostSpecialAPI(
            "/user/getUsers", "", "/$userIdx/$projectIdx");
        userInfoList.forEach((element) {
          userList.add(element.userNickname);
        });
      } catch (e) {
        userInfoList = [];
      }
    });
    print("user");
  }

  _fetchApplyList() async {
    var projectIdx =
        Provider.of<LiveProject>(context, listen: false).projectIdx;
    applyList = await togetherGetAPI(
        "/project/applicationList", '?project_idx=$projectIdx');
    print(applyList.length);
  }

  void fetchTagList() async {
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
    if (category.contains("기타") == false) category.add('기타');
    selectedCategory = category.first;
    selectedTag = tag.first;
  }

  @override
  void initState() {
    super.initState();
    _fetchApplyList();

    fetchUserList();
    fetchTagList();
    future = fetchSetting();
  }

  @override
  Widget build(BuildContext context) {
    var photo = Provider.of<SignInModel>(context, listen: false).userPhoto;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var projectIdx =
        Provider.of<LiveProject>(context, listen: false).projectIdx;
    var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;

    return Scaffold(
      appBar: _appBar(context, photo),
      body: SingleChildScrollView(
        child: FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                ProjectSetting setting = snapshot.data as ProjectSetting;
                return Container(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20)),
                            color: Color(0xffD0EBFF)),
                        padding: EdgeInsets.only(
                            left: width * 0.08,
                            right: width * 0.08,
                            bottom: height * 0.02),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "프로젝트 설정",
                                      style: subHeadingStyle,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      setting.projectName,
                                      style: headingStyle,
                                    ),
                                  ],
                                ),
                                // MyButton(label: "수정하기", onTap: () {})
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                messageButton(width, () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) =>
                                              ShowApplyListPage(
                                                applyList: applyList,
                                              )))
                                      .then((value) {
                                    setState(() {
                                      _fetchApplyList();
                                      future = fetchSetting();
                                    });
                                  });
                                }),
                                iconButton(
                                    width,
                                    "편집",
                                    Icons.edit,
                                    () => Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) =>
                                                    EditProjectInfo(
                                                      setting: setting,
                                                    )))
                                            .then((value) {
                                          setState(() {
                                            future = fetchSetting();
                                            print("updated setting");
                                          });
                                        })),
                                iconButton(width, "멤버 초대", Icons.group_add, () {
                                  if (mounted) {
                                    if (userInfoList.isEmpty) {
                                      Get.snackbar("멤버를 초대할 수 없습니다",
                                          "팀장만이 멤버초대를 할 수 있습니다.",
                                          icon: Icon(
                                            Icons.warning_amber_rounded,
                                            color: Colors.redAccent,
                                          ));
                                    } else
                                      showSearch(
                                          context: context,
                                          delegate: SearchPage(
                                              searchStyle: editTitleStyle,
                                              barTheme: ThemeData(
                                                  appBarTheme: AppBarTheme(
                                                      elevation: 0,
                                                      backgroundColor:
                                                          Color(0xffD0EBFF))),
                                              showItemsOnEmpty: true,
                                              builder: (person) {
                                                var info = userInfoList
                                                    .firstWhere((element) =>
                                                        element.userNickname ==
                                                        person);

                                                return Card(
                                                  elevation: 0,
                                                  child: ListTile(
                                                    onTap: () async {
                                                      UserProfile userProfile =
                                                          await togetherGetAPI(
                                                              "/project/UserInfo",
                                                              "/$person");
                                                      Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ShowUserDetailPage(
                                                                    userProfile:
                                                                        userProfile,
                                                                    members: setting
                                                                        .members,
                                                                    isInsidePjt:
                                                                        true,
                                                                    userIdx: info
                                                                        .userIdx,
                                                                  )));
                                                    },
                                                    leading: CircleAvatar(
                                                      backgroundImage:
                                                          NetworkImage(
                                                              info.userPhoto),
                                                    ),
                                                    title: Text(
                                                      person.toString(),
                                                      style: tileTitleStyle,
                                                    ),
                                                  ),
                                                );
                                              },
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
                                                child: Text('No person found'),
                                              ),
                                              items: userList));
                                  }
                                })
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            left: width * 0.04,
                            right: width * 0.04,
                            top: height * 0.04),
                        child: Column(
                          children: [
                            MyListTile(
                              title: Text(
                                '설명',
                                style: tileTitleStyle,
                              ),
                              subTitle: Text(
                                setting.projectExp,
                                style: tileSubTitleStyle,
                              ),
                            ),
                            MyListTile(
                              title: Text(
                                '시작날짜',
                                style: tileTitleStyle,
                              ),
                              subTitle: Text(
                                toDateISO(setting.startDate),
                                style: tileSubTitleStyle,
                              ),
                            ),
                            MyListTile(
                              title: Text(
                                '종료날짜',
                                style: tileTitleStyle,
                              ),
                              subTitle: Text(
                                toDateISO(setting.endDate),
                                style: tileSubTitleStyle,
                              ),
                            ),
                            MyListTile(
                              title: Text(
                                '전문성',
                                style: tileTitleStyle,
                              ),
                              subTitle: Text(
                                projectEnumFromServer(setting.level),
                                style: tileSubTitleStyle,
                              ),
                            ),
                            MyListTile(
                              title: Text(
                                '유형',
                                style: tileTitleStyle,
                              ),
                              subTitle: Text(
                                projectEnumFromServer(setting.type),
                                style: tileSubTitleStyle,
                              ),
                            ),
                            MyListTile(
                              leading: CircleAvatar(
                                  child: Icon(Icons.tag, color: Colors.white),
                                  backgroundColor: Colors.red[300]),
                              title: Text(
                                '태그 (${setting.tag.length}/3)',
                                style: tileTitleStyle,
                              ),
                              subTitle: Container(
                                child: Wrap(
                                  spacing: 0.5,
                                  children: setting.tag
                                      .map((element) => Chip(
                                            label: Text(element,
                                                style:
                                                    tileSubTitleStyle.copyWith(
                                                        color: Colors.black)),
                                            backgroundColor: titleColor,
                                            deleteIconColor: Colors.red[300],
                                            onDeleted: () async {
                                              var index =
                                                  setting.tag.indexOf(element);
                                              var code = await togetherPostSpecialAPI(
                                                  "/project/deleteProjectTag",
                                                  "",
                                                  "/$projectIdx/$userIdx/${setting.tagIdxs[index]}");
                                              if (code == "not_leader") {
                                                Get.snackbar("태그 삭제 실패",
                                                    "팀장만이 태그를 삭제 할 수 있습니다",
                                                    icon: Icon(
                                                      Icons
                                                          .warning_amber_rounded,
                                                      color: Colors.redAccent,
                                                    ));
                                              } else
                                                setState(() {
                                                  setting.tag.remove(element);
                                                });
                                            },
                                          ))
                                      .toList(),
                                ),
                              ),
                              trailing: IconButton(
                                  onPressed: () async {
                                    if (setting.tag.length >= 3) {
                                      Get.snackbar(
                                        "태그 추가 실패",
                                        "태그는 최대 3개까지 설정 할 수 있습니다",
                                        icon: Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.redAccent,
                                        ),
                                      );
                                    } else
                                      tagSheet(context, width, height,
                                          projectIdx, userIdx);
                                  },
                                  icon: Icon(Icons.add)),
                            ),
                            MyListTile(
                              leading: CircleAvatar(
                                  child: Icon(Icons.manage_accounts,
                                      color: Colors.white),
                                  backgroundColor: Colors.purple[300]),
                              title: Text(
                                '멤버',
                                style: tileTitleStyle,
                              ),
                              subTitle: Text(
                                setting.members.toString().substring(
                                    1, setting.members.toString().length - 1),
                                style: tileSubTitleStyle,
                              ),
                              trailing: IconButton(
                                  onPressed: () async {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) =>
                                                EditMemberPage()))
                                        .then((value) => setState(() {
                                              future = fetchSetting();
                                              print("updated setting");
                                            }));
                                  },
                                  icon: Icon(Icons.chevron_right_outlined)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            }),
      ),
    );
  }

  messageButton(double width, Function()? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width * 0.2,
        height: width * 0.2,
        padding: EdgeInsets.all(4),
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
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mail_outline_outlined,
                  color: pinkClr,
                  size: 40,
                ),
                Text(
                  "메세지",
                  style: editSubTitleStyle,
                )
              ],
            ),
            applyList.length != 0
                ? Positioned(
                    right: 8,
                    top: 2,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      width: 16,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.redAccent),
                      child: Text(
                        applyList.length.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  tagSheet(BuildContext context, double width, double height, int projectIdx,
      int userIdx) {
    containTag = [];
    mappingTag.keys.forEach((element) {
      if (mappingTag[element] == selectedCategory) containTag.add(element);
    });
    containTag.insert(containTag.length, '기타');

    selectedTag = containTag[0];
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16))),
        isScrollControlled: true,
        context: context,
        builder: (context) {
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "태그 추가",
                              style: headingStyle,
                            ),
                            MyButton(
                                width: width * 0.3,
                                height: 40,
                                label: "+ 추가",
                                onTap: () async {
                                  loadingAlert(context);
                                  var tagIdx;
                                  var tagName;
                                  var detailName;
                                  if (selectedCategory == "기타" &&
                                      selectedTag == "기타") {
                                    tagIdx = 0;
                                    tagName = categoryController.text;
                                    detailName = tagController.text;
                                  } else if (selectedCategory != "기타" &&
                                      selectedTag == "기타") {
                                    tagIdx = 0;
                                    tagName = selectedCategory;
                                    detailName = tagController.text;
                                  } else {
                                    tagIdx = mappingIdx[selectedTag];
                                    tagName = selectedCategory;
                                    detailName = selectedTag;
                                  }

                                  var code = await togetherPostSpecialAPI(
                                      "/project/addProjectTag",
                                      jsonEncode({
                                        "tag_idx": tagIdx,
                                        "tag_name": tagName,
                                        "tag_detail_name": detailName
                                      }),
                                      "/$projectIdx/$userIdx");
                                  if (code != null) Navigator.pop(context);
                                  if (code == "not_leader") {
                                    Navigator.of(context).pop();
                                    Get.snackbar(
                                        "태그 추가 실패", "팀장만이 태그를 추가 할 수 있습니다",
                                        icon: Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.redAccent,
                                        ));
                                  } else {
                                    Navigator.of(context).pop();
                                  }
                                })
                          ],
                        ),
                        MyInputField(
                          title: "카테고리 선택",
                          hint: selectedCategory,
                          suffixIcon: DropdownButton(
                            dropdownColor: Colors.blueGrey,
                            underline: Container(),
                            value: selectedCategory,
                            items: category.map((value) {
                              return DropdownMenuItem(
                                  value: value,
                                  child: Text(value,
                                      style: editSubTitleStyle.copyWith(
                                          color: Colors.white)));
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value.toString();

                                containTag = [];
                                mappingTag.keys.forEach((element) {
                                  if (mappingTag[element] == selectedCategory)
                                    containTag.add(element);
                                });
                                containTag.add("기타");
                                selectedTag = containTag.first;
                              });
                            },
                          ),
                        ),
                        MyInputField(
                          title: "태그 선택",
                          hint: selectedTag,
                          suffixIcon: DropdownButton(
                            dropdownColor: Colors.blueGrey,
                            underline: Container(),
                            value: selectedTag,
                            items: containTag.map((value) {
                              return DropdownMenuItem(
                                  value: value,
                                  child: Text(value,
                                      style: editSubTitleStyle.copyWith(
                                          color: Colors.white)));
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedTag = value.toString();
                              });
                            },
                          ),
                        ),
                        Visibility(
                            visible: selectedCategory == "기타",
                            child: MyInputField(
                              controller: categoryController,
                              title: "카테고리 입력",
                              hint: "Input Category",
                            )),
                        Visibility(
                            visible:
                                selectedCategory == "기타" || selectedTag == "기타",
                            child: MyInputField(
                              controller: tagController,
                              title: "태그 입력",
                              hint: "Input Tag",
                            )),
                      ],
                    )
                  ],
                ),
              ),
            );
          });
        }).then((value) => setState(() {
          future = fetchSetting();
        }));
  }

  iconButton(double width, String name, IconData icon, Function()? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width * 0.2,
        height: width * 0.2,
        padding: EdgeInsets.all(4),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: pinkClr,
              size: 32,
            ),
            Text(
              name,
              style: editSubTitleStyle,
            )
          ],
        ),
      ),
    );
  }

  _appBar(BuildContext context, String photo) {
    return AppBar(
      backgroundColor: Color(0xffD0EBFF),
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MainPage()));
        },
        icon: Icon(Icons.home_outlined, color: Colors.grey),
      ),
      actions: [
        CircleAvatar(
          backgroundImage: NetworkImage(photo),
        ),
        SizedBox(
          width: 20,
        )
      ],
    );
  }
}
