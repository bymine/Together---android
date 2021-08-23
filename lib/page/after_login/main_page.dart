import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together_android/componet/showDialog.dart';
import 'package:together_android/model/sign_in_model.dart';
import 'package:together_android/page/before_login/sign_in_page.dart';
import 'package:together_android/service/api.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    getLoginData();
  }

  void getLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString('email');
    var pw = prefs.getString('pw');
    var auto = prefs.getBool('auto');
    if (auto == true) {
      print("auto login");
      var signInModel = await beforeLoginPostAPI(
              '/user/login', jsonEncode({"user_email": email, "user_pw": pw}))
          as SignInModel;
      Provider.of<SignInModel>(context, listen: false)
          .setSignInSuccess(signInModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var user = Provider.of<SignInModel>(context);
    return WillPopScope(
      onWillPop: () async {
        showAlertDialog(
            context,
            Container(
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey))),
                width: width,
                height: height * 0.4,
                child: Image.asset("assets/exit.png")),
            SizedBox(
              height: 1,
            ),
            [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Together 앱을 종료하시겠습니까?",
                    style: TextStyle(fontSize: width * 0.048),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          width: width * 0.3,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.white),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("취소",
                                  style: TextStyle(color: Colors.black))),
                        ),
                        Container(
                            width: width * 0.3,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.white),
                              onPressed: () {
                                SystemNavigator.pop();
                              },
                              child: Text("확인",
                                  style: TextStyle(color: Colors.black)),
                            )),
                      ],
                    ),
                  )
                ],
              ),
            ]);
        return false;
      },
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("진행 중인 프로젝트"),
            SizedBox(
              height: 200,
            ),
            Text(user.signInCode),
            Text(user.userEmail),
            Text(user.userName),
            Text(user.userPassword),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                  color: Colors.grey[350],
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: NetworkImage("http://101.101.216.93:8080/images/" +
                          user.userPhoto))),
            ),
            Text(user.userIdx.toString()),
            IconButton(
                onPressed: () async {
                  // 추가적으로 로그인 정보를 갖고있는 providere 초기화 하기 !!!
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove('email');
                  prefs.remove('pw');

                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => SignInPage()));
                },
                icon: Icon(Icons.logout_outlined))
          ],
        ),
      ),
    );
  }
}
