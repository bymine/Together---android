import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together_android/componet/showDialog.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/page/after_login/main_page.dart';
import 'package:together_android/page/before_login/search_account_page.dart';
import 'package:together_android/page/before_login/sign_up_page.dart';
import 'package:together_android/service/api.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController pwController = TextEditingController();

  final signInFromKey = GlobalKey<FormState>();

  bool isHidePw = true;
  bool isAutoLogin = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
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
        //resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Form(
            key: signInFromKey,
            child: Container(
              margin: EdgeInsets.symmetric(
                  vertical: height * 0.084, horizontal: width * 0.064),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Together",
                      style: headingStyle.copyWith(
                          fontSize: 48, color: Colors.black)),
                  SizedBox(
                    height: height * 0.1,
                  ),
                  _signInField(
                      hint: "E-mail",
                      icon: Icons.email,
                      type: TextInputType.emailAddress,
                      controller: emailController,
                      validator: (value) {
                        if (value!.isEmpty) return "E-mail을 입력하세요";
                      }),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  _signInField(
                    hint: "Password",
                    icon: Icons.lock,
                    controller: pwController,
                    validator: (value) {
                      if (value!.isEmpty) return "PassWord를 입력하세요";
                    },
                    bool: isHidePw,
                    widget: IconButton(
                      onPressed: () {
                        setState(() {
                          isHidePw = !isHidePw;
                        });
                      },
                      icon: Icon(Icons.visibility),
                    ),
                  ),
                  _autoLoginBox(),
                  SizedBox(
                    height: height * 0.1,
                  ),
                  _singInButton(width, height, context),
                  SizedBox(
                    height: height * 0.1,
                  ),
                  _supportFunction(width, context)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextFormField _signInField(
      {required String hint,
      required IconData icon,
      required TextEditingController controller,
      required String? Function(String?)? validator,
      TextInputType? type,
      bool? bool,
      Widget? widget}) {
    return TextFormField(
        autofocus: false,
        controller: controller,
        obscureText: bool ?? false,
        keyboardType: type,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          filled: true,
          fillColor: Color(0xffF7F8F9),
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixIcon: widget,
        ),
        validator: validator);
  }

  _signInFunction(double width) async {
    if (signInFromKey.currentState!.validate()) {
      var signInModel = await togetherPostAPI(
          '/user/login',
          jsonEncode({
            "user_email": emailController.text,
            "user_pw": pwController.text
          })) as SignInModel;
      if (signInModel.signInCode == "success") {
        Provider.of<SignInModel>(context, listen: false)
            .setSignInSuccess(signInModel);

        if (isAutoLogin) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setInt('idx', signInModel.userIdx);
          prefs.setString('photo', signInModel.userPhoto);
          prefs.setString('name', signInModel.userName);
        }

        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainPage()));
      } else {
        showAlertDialog(
            context,
            Container(
              child: Text(
                "로그인 실패",
              ),
            ),
            Container(
              padding: EdgeInsets.all(width * 0.04),
              child: Text(
                signInModel.signInCode == "wrong_pw"
                    ? "비밀번호가 올바르지 않습니다"
                    : "이메일이 올바르지 않습니다",
                textAlign: TextAlign.center,
              ),
            ),
            []);
      }
    }
  }

  _singInButton(double width, double height, BuildContext context) {
    return Container(
      width: width,
      height: height * 0.08,
      child: ElevatedButton(
        style: elevatedStyle,
        onPressed: () async {
          _signInFunction(width);
        },
        child: Text(
          '로그인',
          style: TextStyle(fontSize: width * 0.064),
        ),
      ),
    );
  }

  _autoLoginBox() {
    return Row(
      children: [
        Container(
          child: Checkbox(
            value: isAutoLogin,
            onChanged: (bool? value) {
              setState(() {
                isAutoLogin = value!;
              });
            },
          ),
        ),
        Text("Auto Login")
      ],
    );
  }

  _supportFunction(double width, BuildContext context) {
    return Container(
      width: width,
      child: Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SearchAccountPage(
                          type: "email",
                        )));
              },
              child: Text(
                "이메일 찾기",
                style: TextStyle(color: Colors.black),
              )),
          Container(
            height: 30,
            child: VerticalDivider(
              width: 3,
              thickness: 1,
              color: Colors.grey,
            ),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SearchAccountPage(
                          type: "pw",
                        )));
              },
              child: Text(
                "비밀번호 찾기",
                style: TextStyle(color: Colors.black),
              )),
          Container(
            height: 30,
            child: VerticalDivider(
              width: 3,
              thickness: 1,
              color: Colors.grey,
            ),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SignUpPage()));
              },
              child: Text(
                "회원 가입",
                style: TextStyle(color: Colors.black),
              ))
        ],
      ),
    );
  }
}
