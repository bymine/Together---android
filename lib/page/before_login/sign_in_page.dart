import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together_android/componet/showDialog.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/sign_in_model.dart';
import 'package:together_android/page/after_login/main_page.dart';
import 'package:together_android/service/api.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController signInEmail = TextEditingController();
  TextEditingController signInPassword = TextEditingController();

  final signInFromKey = GlobalKey<FormState>();

  bool clickEye = true;
  bool saveLogin = false;
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
              // padding: EdgeInsets.symmetric(
              //     vertical: height * 0.02, horizontal: width * 0.03),
              // decoration: BoxDecoration(
              //   border: Border.all(width: 1, color: Colors.red),
              // ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      "Together",
                      style: appBarStyle.copyWith(fontSize: width * 0.12),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.1,
                  ),
                  TextFormField(
                    controller: signInEmail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                        filled: true,
                        fillColor: Color(0xFFF7F8F9),
                        hintText: "E-mail",
                        prefixIcon: Icon(
                          Icons.email,
                        )),
                    validator: (value) {
                      if (value!.isEmpty) return "E-mail을 입력하세요";
                    },
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  TextFormField(
                    controller: signInPassword,
                    obscureText: clickEye,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: Color(0xffF7F8F9),
                      hintText: "Password",
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.visibility),
                        onPressed: () {
                          setState(() {
                            clickEye = !clickEye;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return "Password을 입력하세요";
                    },
                  ),
                  Row(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Checkbox(
                          value: saveLogin,
                          onChanged: (bool? value) {
                            setState(() {
                              saveLogin = value!;
                            });
                          },
                        ),
                      ),
                      Text("Auto Login")
                    ],
                  ),
                  SizedBox(
                    height: height * 0.1,
                  ),
                  Container(
                    width: width,
                    height: height * 0.08,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: kButtonColor,
                      ),
                      onPressed: () async {
                        if (signInFromKey.currentState!.validate()) {
                          var signInModel = await beforeLoginPostAPI(
                              '/user/login',
                              jsonEncode({
                                "user_email": signInEmail.text,
                                "user_pw": signInPassword.text
                              })) as SignInModel;
                          if (signInModel.signInCode == "success") {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            if (saveLogin) {
                              prefs.setBool("auto", true);
                              prefs.setString('email', signInEmail.text);
                              prefs.setString('pw', signInPassword.text);
                            } else {
                              prefs.setBool("auto", false);
                              Provider.of<SignInModel>(context, listen: false)
                                  .setSignInSuccess(signInModel);
                            }

                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => MainPage()));
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
                      },
                      child: Text(
                        '로그인',
                        style: TextStyle(fontSize: width * 0.064),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.14,
                  ),
                  Container(
                    width: width,
                    child: Wrap(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: () {},
                            child: Text(
                              "아이디 찾기",
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
                            onPressed: () {},
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
                            onPressed: () {},
                            child: Text(
                              "회원 가입",
                              style: TextStyle(color: Colors.black),
                            ))
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
