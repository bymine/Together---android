import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/componet/input_field.dart';
import 'package:together_android/componet/showDialog.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/team_card.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/service/api.dart';

// ignore: must_be_immutable
class ShowProjectCard extends StatefulWidget {
  ProjectResume? card;
  Map<String, int> map;
  ShowProjectCard({Key? key, this.card, required this.map}) : super(key: key);

  @override
  _ShowProjectCardState createState() => _ShowProjectCardState();
}

class _ShowProjectCardState extends State<ShowProjectCard> {
  String _selectProject = "";
  TextEditingController commentController = TextEditingController();
  List<ProjectResume>? newResume = [];
  Map<String, ProjectResume> myProject = Map<String, ProjectResume>();
  void fetchMyProject() async {
    var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;
    newResume =
        await togetherGetAPI("/teamMatching/projectList", "?user_idx=$userIdx");
    if (newResume != null) {
      newResume!.forEach((element) {
        myProject[element.projectName] = element;
      });
      setState(() {
        _selectProject = myProject.keys.first;
        print(_selectProject);
      });
    } else
      setState(() {
        _selectProject = "생성 가능한 프로젝트가 없습니다";
      });
  }

  @override
  void initState() {
    super.initState();
    if (widget.card != null)
      commentController.text = widget.card!.comment;
    else {
      fetchMyProject();
    }
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
                      widget.card == null ? "카드 추가하기" : "카드 수정하기",
                      style: headingStyle,
                    ),
                    MyButton(
                        label:
                            widget.card == null ? "+ Add Card" : "Update Card",
                        onTap: () async {
                          loadingAlert(context);
                          var code = await togetherPostAPI(
                              "/teamMatching/projectList/card/build",
                              jsonEncode({
                                "project_idx": widget.card == null
                                    ? myProject[_selectProject]!.projectIdx
                                    : widget.card!.projectIdx,
                                "comment": commentController.text
                              }));
                          print(code);
                          if (code != null) Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        })
                  ],
                ),
                Visibility(
                  visible: widget.card == null,
                  child: MyInputField(
                    title: "Select Project",
                    hint: _selectProject,
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: DropdownButton(
                        iconDisabledColor: Colors.white,
                        dropdownColor: Colors.blueGrey,
                        value: _selectProject,
                        underline: Container(),
                        items: myProject.keys.toList().map((value) {
                          return DropdownMenuItem(
                              value: value,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(value,
                                    style: editSubTitleStyle.copyWith(
                                        color: Colors.white)),
                              ));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectProject = value.toString();
                            print(_selectProject);
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                if (widget.card != null)
                  myProjectCard(widget.card)
                else
                  myProjectCard(myProject[_selectProject]),
                // MyInputField(
                //     title: "Project Info",
                //     hint: "이름\n 설명\n 시작날짜\n 종료날짜\n 타입\n 레벨\n 표시 구간"),
                MyInputField(
                    title: "Comment",
                    hint: "Input Comment",
                    controller: commentController,
                    maxLine: 3)
              ],
            ),
          ),
        ));
  }

  myProjectCard(ProjectResume? card) {
    if (card != null)
      return Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          padding: EdgeInsets.only(left: 12, top: 16, right: 8, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(card.projectName),
              Row(
                children: [
                  Icon(Icons.note, size: 16, color: Colors.grey),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    card.projectExp,
                    style: tileSubTitleStyle,
                  )
                ],
              ),
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
                        card.projectType,
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
                        card.professionality,
                        style: tileSubTitleStyle,
                      )
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.note, size: 16, color: Colors.grey),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    card.startDate,
                    style: tileSubTitleStyle,
                  )
                ],
              ),
            ],
          ),
        ),
      );
    else
      return Container();
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
