import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/invitaion_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

// ignore: must_be_immutable
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
    var photo = Provider.of<SignInModel>(context, listen: false).userPhoto;

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop(widget.invitaion);
          },
          icon: Icon(
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
      ),
      body: Container(
        padding: EdgeInsets.only(
            left: width * 0.04, right: width * 0.04, bottom: height * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Project Invite",
              style: headingStyle,
            ),
            SizedBox(
              height: 5,
            ),
            ListView.builder(
                shrinkWrap: true,
                itemCount: widget.invitaion.length,
                itemBuilder: (context, index) {
                  Invitaion invitaion = widget.invitaion[index];
                  return Card(
                    color: Colors.grey[100],
                    child: ListTile(
                      title: Text(
                        invitaion.projectName,
                        style: editTitleStyle,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Project Intro: " + invitaion.projectExp,
                            maxLines: 2,
                            style: editSubTitleStyle,
                          ),
                          Text(
                            "Members: " + invitaion.members.toString(),
                            style: editSubTitleStyle,
                          ),
                          Text(
                            "Invitation Date: " +
                                toDate(DateTime.parse(invitaion.inviteTime)),
                            style: editSubTitleStyle,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  MyButton(
                                      label: "Accept",
                                      onTap: () async {
                                        await togetherPostAPI(
                                          "/user/decideJoin",
                                          jsonEncode(
                                            {
                                              "project_idx":
                                                  invitaion.projectIdx,
                                              "user_idx": userIdx,
                                              "accept": "Y"
                                            },
                                          ),
                                        );
                                        setState(() {
                                          widget.invitaion.remove(invitaion);
                                        });
                                      }),
                                  MyButton(
                                      label: "Refuse",
                                      onTap: () async {
                                        await togetherPostAPI(
                                          "/user/decideJoin",
                                          jsonEncode(
                                            {
                                              "project_idx":
                                                  invitaion.projectIdx,
                                              "user_idx": userIdx,
                                              "accept": "Y"
                                            },
                                          ),
                                        );
                                        setState(() {
                                          widget.invitaion.remove(invitaion);
                                        });
                                      })
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
