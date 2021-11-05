import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/componet/input_field.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/MemberResume.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

class MyMemberCard extends StatefulWidget {
  final MemberResume? resume;

  const MyMemberCard({this.resume, Key? key}) : super(key: key);

  @override
  _MyMemberCardState createState() => _MyMemberCardState();
}

class _MyMemberCardState extends State<MyMemberCard> {
  TextEditingController experienceController = TextEditingController();
  TextEditingController introController = TextEditingController();
  MemberResume? newResume;

  @override
  void initState() {
    super.initState();
    if (widget.resume != null) {
      experienceController.text = widget.resume!.resume ?? "";
      introController.text = widget.resume!.comment ?? "";
    } else {
      fetchNewCardData().then((value) {
        setState(() {
          newResume = value as MemberResume;
        });
      });
    }
  }

  Future fetchNewCardData() async {
    var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;

    var data = togetherGetAPI("/member/search/register", "/$userIdx");
    return data;
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
                left: width * 0.08,
                right: width * 0.08,
                bottom: height * 0.02,
                top: height * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.resume == null ? "Add Card" : "My Card",
                      style: headingStyle,
                    ),
                    MyButton(
                        label: widget.resume == null
                            ? "+ Add Card"
                            : "Update Card",
                        onTap: () async {
                          var userIdx =
                              Provider.of<SignInModel>(context, listen: false)
                                  .userIdx;

                          await togetherPostSpecialAPI(
                              "/member/search/register",
                              jsonEncode({
                                "resume": experienceController.text,
                                "comment": introController.text,
                              }),
                              "/$userIdx");
                          Navigator.of(context).pop(true);
                        })
                  ],
                ),
                // MyInputField(
                //   title: "My Info",
                //   hint: myInfoString(widget.resume ?? newResume),
                //   maxLine: 7,
                //   suffixIcon: Text(""),
                // ),
                SizedBox(
                  height: 15,
                ),
                if (widget.resume == null)
                  cardWidget(newResume)
                else
                  cardWidget(widget.resume),

                Container(
                  child: MyInputField(
                    title: "소개",
                    hint: "Input Introduce about me",
                    controller: introController,
                    maxLine: 5,
                  ),
                ),
                MyInputField(
                  title: "경험",
                  hint: "Input Experience",
                  controller: experienceController,
                  maxLine: 5,
                ),
              ],
            ),
          ),
        ));
  }

  cardWidget(MemberResume? resume) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Color(0xffFED97F),
      child: Container(
        padding: EdgeInsets.only(left: 12, top: 16, right: 8, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(resume!.photo),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        resume.name,
                        style: headingStyle.copyWith(color: darkBlue),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        resume.nickName,
                        style: editTitleStyle.copyWith(color: darkBlue),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.face,
                            size: 16,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            resume.age.toString(),
                            style: tileSubTitleStyle,
                          )
                        ],
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Row(
                        children: [
                          Icon(Icons.psychology, size: 16, color: Colors.grey),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            resume.mbti,
                            style: tileSubTitleStyle,
                          )
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_city, size: 16, color: Colors.grey),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        addressToString(false, resume.mainAddr,
                            resume.referenceAddr, resume.detailAddr),
                        maxLines: 1,
                        style: tileSubTitleStyle,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Icon(Icons.book, size: 16, color: Colors.grey),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        formatLicense(resume),
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
                      Icon(Icons.tag, size: 16, color: Colors.grey),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        formatHobby(resume),
                        maxLines: 2,
                        style: tileSubTitleStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatLicense(MemberResume? resume) {
    String license;
    if (resume!.licens.isEmpty)
      license = "";
    else
      license = resume.licens
          .toString()
          .substring(1, resume.licens.toString().length - 1);

    return license;
  }

  String formatHobby(MemberResume? resume) {
    String hobby;
    if (resume!.hobbys.isEmpty)
      hobby = "";
    else {
      hobby = resume.hobbys
          .toString()
          .substring(1, resume.hobbys.toString().length - 1);
    }
    return hobby;
  }

  String myInfoString(MemberResume? resume) {
    if (resume == null)
      return "";
    else {
      String license;
      String hobby;
      String address = addressToString(
          false, resume.mainAddr, resume.referenceAddr, resume.detailAddr);

      if (resume.licens.isEmpty)
        license = "";
      else
        license = resume.licens
            .toString()
            .substring(1, resume.licens.toString().length - 1);

      if (resume.hobbys.isEmpty)
        hobby = "";
      else {
        hobby = resume.hobbys
            .toString()
            .substring(1, resume.hobbys.toString().length - 1);
      }

      return "Name: ${resume.name}\n" +
          "NickName: ${resume.nickName}\n" +
          "Age: ${resume.age}\n" +
          "MBTI: ${resume.mbti}\n" +
          "Address: $address\n"
              "license: $license\n" +
          "hobby: $hobby\n";
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
