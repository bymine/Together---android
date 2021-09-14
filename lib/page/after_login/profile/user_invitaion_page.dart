import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/invitaion_model.dart';
import 'package:together_android/model/sign_in_model.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

class UserInviationPage extends StatefulWidget {
  List<Invitaion> invitaion;
  UserInviationPage({required this.invitaion});

  @override
  _UserInviationPageState createState() => _UserInviationPageState();
}

class _UserInviationPageState extends State<UserInviationPage> {
  @override
  Widget build(BuildContext context) {
    var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop(widget.invitaion);
            },
            icon: Icon(Icons.arrow_back)),
        title: Text("초대 현황"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
            vertical: height * 0.02, horizontal: width * 0.02),
        child: ListView.builder(
            itemCount: widget.invitaion.length,
            itemBuilder: (context, index) {
              Invitaion invitaion = widget.invitaion[index];
              return Card(
                child: ListTile(
                  title: Text(invitaion.projectName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("프로젝트 소개: " + invitaion.projectExp),
                      Text("프로젝트 인원: " + invitaion.members.toString()),
                      Text("초대일자 " +
                          toDate(DateTime.parse(invitaion.inviteTime))),
                    ],
                  ),
                  trailing: Container(
                    width: width * 0.4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(primary: titleColor),
                            onPressed: () async {
                              await togetherPostAPI(
                                "/user/decideJoin",
                                jsonEncode(
                                  {
                                    "project_idx": invitaion.projectIdx,
                                    "user_idx": userIdx,
                                    "accept": "Y"
                                  },
                                ),
                              );
                              setState(() {
                                widget.invitaion.remove(invitaion);
                              });
                            },
                            child: Text("수락")),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.red.withOpacity(0.5)),
                            onPressed: () async {
                              await togetherPostAPI(
                                "/user/decideJoin",
                                jsonEncode(
                                  {
                                    "project_idx": invitaion.projectIdx,
                                    "user_idx": userIdx,
                                    "accept": "Y"
                                  },
                                ),
                              );
                              setState(() {
                                widget.invitaion.remove(invitaion);
                              });
                            },
                            child: Text("거절")),
                      ],
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
