import 'package:flutter/material.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/user_profile_model.dart';
import 'package:together_android/service/api.dart';

class ShowUserDetailPage extends StatelessWidget {
  final UserProfile userProfile;
  final List<String> members;

  ShowUserDetailPage({required this.userProfile, required this.members});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("프로필 조회"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(
              vertical: height * 0.02, horizontal: width * 0.08),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ]),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(5),
                height: width * 0.25,
                width: width * 0.25,
                decoration: BoxDecoration(
                    border: Border.all(width: 5, color: Colors.grey),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.fill,
                        image: NetworkImage(
                            "http://101.101.216.93:8080/images/" +
                                userProfile.photo))),
              ),
              buildUserDetail(Icons.face, userProfile.nickname, "닉네임"),
              buildUserDetail(Icons.calendar_today, userProfile.age, "나이"),
              buildUserDetail(Icons.book, userProfile.license1, "자격증"),
              buildUserDetail(Icons.psychology, userProfile.mbti, "MBTI"),
              buildUserDetail(Icons.location_city, userProfile.address, "주소"),
              Container(
                width: width * 0.7,
                height: height * 0.08,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: members.contains(userProfile.nickname)
                          ? Colors.grey.shade500
                          : titleColor),
                  onPressed: () async {
                    if (members.contains(userProfile.nickname) == false) {
                      final code = await togetherGetAPI(
                          '/project/inviteMember', '/${userProfile.nickname}');
                      print(code);
                      Navigator.of(context)
                          .pop(userProfile.nickname.toString());
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(members.contains(userProfile.nickname)
                      ? "이미 초대 하였습니다"
                      : "초대하기"),
                ),
              )
            ],
          ),
        ),
      ),
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
