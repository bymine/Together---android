import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/page/before_login/sign_in_page.dart';

class UserProfileBody extends StatefulWidget {
  const UserProfileBody({Key? key}) : super(key: key);

  @override
  _UserProfileBodyState createState() => _UserProfileBodyState();
}

class _UserProfileBodyState extends State<UserProfileBody> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: titleColor,
        title: Text("프로필"),
        actions: [
          IconButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('email', "");
                prefs.setString('pw', "");
                prefs.setInt('idx', 0);

                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => SignInPage()));
              },
              icon: Icon(Icons.logout_outlined))
        ],
      ),
    );
  }
}
