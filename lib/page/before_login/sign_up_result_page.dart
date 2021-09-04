import 'package:flutter/material.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/page/before_login/sign_in_page.dart';

class SignUpResultPage extends StatefulWidget {
  const SignUpResultPage({Key? key}) : super(key: key);

  @override
  _SignUpResultPageState createState() => _SignUpResultPageState();
}

class _SignUpResultPageState extends State<SignUpResultPage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: titleColor,
        title: Text("회원가입"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
            vertical: height * 0.16, horizontal: width * 0.08),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: height * 0.02,
            ),
            Container(
              width: width * 0.8,
              padding: EdgeInsets.symmetric(
                  vertical: height * 0.08, horizontal: width * 0.04),
              decoration: BoxDecoration(color: Color(0xffF5F5F5)),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    text: "회원가입이 되었습니다.\n",
                    style:
                        TextStyle(fontSize: width * 0.054, color: Colors.black),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: height * 0.05,
            ),
            Container(
              width: width,
              height: height * 0.08,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: titleColor, shadowColor: titleColor),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => SignInPage()));
                  },
                  child: Text("로그인")),
            )
          ],
        ),
      ),
    );
  }
}
