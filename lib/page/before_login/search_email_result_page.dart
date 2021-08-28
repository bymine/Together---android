import 'package:flutter/material.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/page/before_login/sign_in_page.dart';

class SearchResultPage extends StatefulWidget {
  final String name;
  final String email;
  SearchResultPage({required this.name, required this.email});

  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: titleColor,
        title: Text("이메일 찾기"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: height * 0.2,
          ),
          Container(
            width: width * 0.8,
            height: height * 0.5,
            child: Text("${widget.name}님의 이메일은 ${widget.email}입니다."),
          ),
          SizedBox(
            height: height * 0.05,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => SignInPage()));
              },
              child: Text("로그인"))
        ],
      ),
    );
  }
}
