import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/live_project_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/service/api.dart';

class EditMemberPage extends StatefulWidget {
  const EditMemberPage({Key? key}) : super(key: key);

  @override
  _EditMemberPageState createState() => _EditMemberPageState();
}

class _EditMemberPageState extends State<EditMemberPage> {
  late Future future;
  int managerIdx = 0;
  fetchMembersInfo() async {
    var projectIdx =
        Provider.of<LiveProject>(context, listen: false).projectIdx;
    return togetherGetAPI('/project/members', '/$projectIdx');
  }

  @override
  void initState() {
    super.initState();
    future = fetchMembersInfo();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;
    var photo = Provider.of<SignInModel>(context, listen: false).userPhoto;
    var project = Provider.of<LiveProject>(context, listen: false);
    var positionList = ["팀장", "부팀장", "팀원"];

    return Scaffold(
      appBar: _appBar(context, photo),
      body: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var members = snapshot.data as List<MemberInfo>;
              members.forEach((element) {
                if (element.position == "팀장") managerIdx = element.userIdx;
              });
              return SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(
                      left: width * 0.04,
                      right: width * 0.04,
                      bottom: height * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              Text(
                                "Edit Members",
                                style: subHeadingStyle,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        project.projectName,
                        style: headingStyle,
                      ),
                      Column(
                        children: members.map((user) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            margin: EdgeInsets.only(top: 16),
                            width: width,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.green[100]),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 32,
                                      backgroundImage: NetworkImage(
                                        user.userPhoto,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.name,
                                            style: editTitleStyle,
                                          ),
                                          DropdownButton(
                                            isExpanded: true,
                                            elevation: 0,
                                            iconEnabledColor: Colors.black,
                                            underline: Container(),
                                            value: user.position,
                                            items: positionList
                                                .map((pos) => DropdownMenuItem(
                                                    value: pos,
                                                    child: Text(
                                                      pos,
                                                      style: editTitleStyle,
                                                    )))
                                                .toList(),
                                            onChanged: managerIdx == userIdx
                                                ? (value) {
                                                    setState(() {
                                                      user.position =
                                                          value.toString();
                                                    });
                                                  }
                                                : null,
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Visibility(
                                      visible: managerIdx == userIdx,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          MyButton(
                                              label: "변경",
                                              onTap: () async {
                                                var code = await togetherPostSpecialAPI(
                                                    "/project/modifyMember",
                                                    jsonEncode({
                                                      "member_right":
                                                          positionToScreen(
                                                              user.position)
                                                      // 권한 수정
                                                      //  'Leader','Sub','Member'
                                                    }), // not_leader & fail & success signal
                                                    "/$userIdx/${user.userIdx}/${project.projectIdx}");

                                                print(code.toString());
                                              }),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          MyButton(
                                            label: "추방",
                                            onTap: () async {
                                              var code =
                                                  await togetherPostSpecialAPI(
                                                      "/project/removeMember",
                                                      "",
                                                      "/$userIdx/${user.userIdx}/${project.projectIdx}");

                                              print(code.toString());

                                              setState(() {
                                                future = fetchMembersInfo();
                                              });
                                            },
                                            color: Colors.red[200],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) return Text('${snapshot.error}');
            return Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }

  _appBar(BuildContext context, String photo) {
    return AppBar(
      backgroundColor: Colors.white, //Color(0xffD0EBFF),
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

class MemberInfo {
  int userIdx;
  String name;
  String nickName;
  String userPhoto;
  String position;

  MemberInfo(
      {required this.userIdx,
      required this.name,
      required this.nickName,
      required this.userPhoto,
      required this.position});
  factory MemberInfo.fromJson(Map<String, dynamic> json) {
    return MemberInfo(
        userIdx: json['user_idx'],
        name: json['user_name'],
        nickName: json['user_nickname'],
        userPhoto: json['user_photo'],
        position: positionToScreen(json['user_position']));
  }
}

String positionToScreen(String position) {
  switch (position) {
    case "Leader":
      return "팀장";
    case "Sub":
      return "부팀장";
    case "Member":
      return "팀원";
    case "팀장":
      return "Leader";
    case "부팀장":
      return "Sub";
    case "팀원":
      return "Member";
    default:
      return "";
  }
}
