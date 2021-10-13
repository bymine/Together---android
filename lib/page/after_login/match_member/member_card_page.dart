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
                MyInputField(
                  title: "My Info",
                  hint: myInfoString(widget.resume ?? newResume),
                  maxLine: 7,
                  suffixIcon: Text(""),
                ),
                MyInputField(
                  title: "Introduce",
                  hint: "Input Introduce about me",
                  controller: introController,
                  maxLine: 5,
                ),
                MyInputField(
                  title: "Experience",
                  hint: "Input Experience",
                  controller: experienceController,
                  maxLine: 5,
                ),
              ],
            ),
          ),
        ));
  }

  String myInfoString(MemberResume? resume) {
    String license;
    String hobby;
    String address = addressToString(
        false, resume!.mainAddr, resume.referenceAddr, resume.detailAddr);
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
