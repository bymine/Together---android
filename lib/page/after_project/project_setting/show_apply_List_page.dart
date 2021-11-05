import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_project_model/project_apply_member_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/service/api.dart';

// ignore: must_be_immutable
class ShowApplyListPage extends StatefulWidget {
  List<ProjectApplyMember> applyList;
  ShowApplyListPage({Key? key, required this.applyList}) : super(key: key);

  @override
  _ShowApplyListPageState createState() => _ShowApplyListPageState();
}

class _ShowApplyListPageState extends State<ShowApplyListPage> {
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
            Navigator.of(context).pop();
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
              if (widget.applyList.isEmpty)
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
                    itemCount: widget.applyList.length,
                    itemBuilder: (context, index) {
                      ProjectApplyMember apply = widget.applyList[index];

                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        color: Colors.grey[100],
                        child: ListTile(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          title: Text(
                            apply.userName,
                            style: tileTitleStyle,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.face,
                                        color: Colors.grey,
                                        size: 16,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        apply.userAge.toString(),
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
                                        Icons.psychology,
                                        color: Colors.grey,
                                        size: 16,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        apply.userMbti,
                                        style: tileSubTitleStyle,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      MyButton(
                                          label: "수락",
                                          onTap: () async {
                                            var applyIdx = apply.applyIdx;
                                            var userIdx = apply.userIdx;
                                            var projectIdx = apply.projectIdx;

                                            await togetherGetAPI(
                                                "/project/applicationList/process",
                                                "?team_application_idx=$applyIdx&user_idx=$userIdx&project_idx=$projectIdx&flag=Y");
                                            setState(() {
                                              widget.applyList.remove(apply);
                                            });
                                          }),
                                      MyButton(
                                          color: Colors.red[200],
                                          label: "거절",
                                          onTap: () async {
                                            await togetherGetAPI(
                                                "/project/applicationList/process",
                                                "?team_application_idx=${apply.applyIdx}&user_idx=${apply.userIdx}&project_idx=${apply.projectIdx}&flag=N");
                                            setState(() {
                                              widget.applyList.remove(apply);
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
                    })
            ],
          ),
        ),
      ),
    );
  }
}
