import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/componet/listTile.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/live_project_model.dart';
import 'package:together_android/model/after_login_model/user_profile_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

class ShowUserDetailPage extends StatelessWidget {
  final UserProfile userProfile;
  final List<String> members;
  final bool isInsidePjt;
  final int? userIdx;

  ShowUserDetailPage(
      {required this.userProfile,
      required this.members,
      required this.isInsidePjt,
      this.userIdx});

  @override
  Widget build(BuildContext context) {
    String photo = Provider.of<SignInModel>(context, listen: false).userPhoto;

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: _appBar(context, photo),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                    left: width * 0.08,
                    right: width * 0.08,
                    bottom: height * 0.02),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20)),
                    color: Color(0xffD0EBFF)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "멤버 초대하기",
                          style: subHeadingStyle,
                        ),
                        Text(
                          userProfile.nickname + " 님의 프로필",
                          style: headingStyle,
                          maxLines: 1,
                        )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.all(5),
                      height: width * 0.15,
                      width: width * 0.15,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage(
                                  "http://101.101.216.93:8080/images/" +
                                      userProfile.photo))),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: height * 0.03,
              ),
              Container(
                padding: EdgeInsets.only(
                    left: width * 0.08,
                    right: width * 0.08,
                    bottom: height * 0.02),
                child: Column(
                  children: [
                    MyListTile(
                      leading: CircleAvatar(
                          backgroundColor: Colors.red[300],
                          child: Icon(Icons.face, color: Colors.white)),
                      title: Text(
                        "나이",
                        style: tileTitleStyle,
                      ),
                      subTitle: Text(
                        userProfile.age,
                        style: tileSubTitleStyle,
                      ),
                    ),
                    MyListTile(
                      leading: CircleAvatar(
                          backgroundColor: Colors.brown[300],
                          child: Icon(Icons.book, color: Colors.white)),
                      title: Text(
                        "자격증",
                        style: tileTitleStyle,
                      ),
                      subTitle: Text(
                        licenseToString(
                                    userProfile.license1,
                                    userProfile.license2,
                                    userProfile.license3) ==
                                ""
                            ? "설정 안함"
                            : licenseToString(userProfile.license1,
                                userProfile.license2, userProfile.license3),
                        style: tileSubTitleStyle,
                      ),
                    ),
                    MyListTile(
                      leading: CircleAvatar(
                          backgroundColor: Colors.purple[300],
                          child: Icon(Icons.psychology, color: Colors.white)),
                      title: Text(
                        "MBTI",
                        style: tileTitleStyle,
                      ),
                      subTitle: Text(
                        userProfile.mbti,
                        style: tileSubTitleStyle,
                      ),
                    ),
                    MyListTile(
                      leading: CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          child:
                              Icon(Icons.location_city, color: Colors.white)),
                      title: Text(
                        "주소",
                        style: tileTitleStyle,
                      ),
                      subTitle: Text(
                        userProfile.address,
                        style: tileSubTitleStyle,
                      ),
                    ),
                    MyButton(
                        color: members.contains(userProfile.nickname)
                            ? Colors.grey.shade500
                            : titleColor,
                        label: members.contains(userProfile.nickname)
                            ? "이미 초대 하였습니다"
                            : "초대하기",
                        onTap: () async {
                          int projectIdx =
                              Provider.of<LiveProject>(context, listen: false)
                                  .projectIdx;
                          if (isInsidePjt) {
                            // 프로젝트 내부 초대
                            final code = await togetherGetAPI(
                                "/project/inviteUser",
                                '?project_idx=$projectIdx&user_idx=$userIdx');
                            print(code);
                            if (code == "success") {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              Get.snackbar("멤버 초대 성공",
                                  "${userProfile.nickname}님에게 초대 메세지를 보냈습니다.");
                            } else {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              Get.snackbar("멤버 초대 실패",
                                  "${userProfile.nickname}님은 이미 프로젝트 멤버입니다.");
                            }
                          } else {
                            print('프로젝트 생성 초대');

                            if (members.contains(userProfile.nickname) ==
                                false) {
                              final code = await togetherGetAPI(
                                  '/project/inviteMember',
                                  '/${userProfile.nickname}');
                              print(code);
                              if (code == "success") {
                                Navigator.of(context)
                                    .pop(userProfile.nickname.toString());
                                Navigator.of(context)
                                    .pop(userProfile.nickname.toString());
                              }
                            }
                          }
                        }),
                  ],
                ),
              ),

              // buildUserDetail(Icons.face, userProfile.nickname, "닉네임"),
              // buildUserDetail(Icons.calendar_today, userProfile.age, "나이"),
              // buildUserDetail(Icons.book, userProfile.license1, "자격증"),
              // buildUserDetail(Icons.psychology, userProfile.mbti, "MBTI"),
              // buildUserDetail(Icons.location_city, userProfile.address, "주소"),

              // Container(
              //   width: width * 0.7,
              //   height: height * 0.08,
              //   child: ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //         primary: members.contains(userProfile.nickname)
              //             ? Colors.grey.shade500
              //             : titleColor),
              //     onPressed: () async {
              //       if (members.contains(userProfile.nickname) == false) {
              //         final code = await togetherGetAPI(
              //             '/project/inviteMember', '/${userProfile.nickname}');
              //         print(code);
              //         Navigator.of(context)
              //             .pop(userProfile.nickname.toString());
              //         Navigator.of(context).pop();
              //       } else {
              //         Navigator.of(context).pop();
              //         Navigator.of(context).pop();
              //       }
              //     },
              //     child: Text(members.contains(userProfile.nickname)
              //         ? "이미 초대 하였습니다"
              //         : "초대하기"),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }

  _appBar(BuildContext context, String photo) {
    return AppBar(
      backgroundColor: Color(0xffD0EBFF),
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

  Widget buildUserDetail(IconData data, String title, String name) => Container(
        child: Card(
          child: ListTile(
            leading: Icon(data),
            title: Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
}
