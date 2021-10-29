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
      backgroundColor: Color(0xffD0EBFF),
      appBar: AppBar(
        backgroundColor: Color(0xffD0EBFF),
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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
              left: width * 0.04, right: width * 0.04, bottom: height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "초대 메세지",
                style: headingStyle,
              ),
              SizedBox(
                height: 10,
              ),
              if (widget.invitaion.isEmpty)
                Center(
                  child: Container(
                    height: 500,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mail_outline,
                          color: Colors.green.withOpacity(0.5),
                          size: 90,
                        ),
                        // SvgPicture.asset(
                        //   "assets/task.svg",
                        //   color: Colors.green.withOpacity(0.5),
                        //   height: 90,
                        //   semanticsLabel: 'Task',
                        // ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          child: Text(
                            "초대 메세지가 없습니다!",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.invitaion.length,
                    itemBuilder: (context, index) {
                      Invitaion invitaion = widget.invitaion[index];

                      if (index == 0)
                        return Column(
                          children: [
                            buildTimeline(date: invitaion.inviteTime),
                            invitaionMessage(invitaion, userIdx)
                          ],
                        );
                      else if (index != 0 &&
                          getHashCode(DateTime.parse(invitaion.inviteTime)) !=
                              getHashCode(DateTime.parse(
                                  widget.invitaion[index - 1].inviteTime)))
                        return Column(
                          children: [
                            buildTimeline(date: invitaion.inviteTime),
                            invitaionMessage(invitaion, userIdx)
                          ],
                        );
                      else
                        return invitaionMessage(invitaion, userIdx);
                    }),
            ],
          ),
        ),
      ),
    );
  }

  buildTimeline({required String date}) => Container(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              toDateDaysISO(date),
              style: editSubTitleStyle.copyWith(color: Colors.black),
            ),
          ),
        ),
      );

  invitaionMessage(Invitaion invitaion, int userIdx) {
    return Column(
      children: [
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.grey[100],
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            title: Text(
              invitaion.projectName,
              style: tileTitleStyle,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.border_color,
                      color: Colors.grey,
                      size: 16,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      invitaion.projectExp,
                      maxLines: 2,
                      style: tileSubTitleStyle,
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.group,
                          color: Colors.grey,
                          size: 16,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          invitaion.members.toString(),
                          style: tileSubTitleStyle,
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: Colors.grey,
                          size: 16,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          toTime(DateTime.parse(invitaion.inviteTime)),
                          style: tileSubTitleStyle,
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MyButton(
                            label: "수락",
                            onTap: () async {
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
                            }),
                        MyButton(
                            color: Colors.red[200],
                            label: "거절",
                            onTap: () async {
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
                            })
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
