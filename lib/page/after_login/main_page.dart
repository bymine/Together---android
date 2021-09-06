import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/showDialog.dart';
import 'package:together_android/model/my_profile_model.dart';
import 'package:together_android/model/sign_in_model.dart';
import 'package:together_android/page/after_login/live_project/live_project_page.dart';
import 'package:together_android/page/after_login/match_member/match_member_page.dart';
import 'package:together_android/page/after_login/match_project/match_project_page.dart';
import 'package:together_android/page/after_login/profile/user_profile.dart';
import 'package:together_android/service/api.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedMenuIndex = 0;
  List<GButton> tabs = [];
  List<Color> colors = [
    Colors.purple,
    Colors.pink,
    Colors.amber[600]!,
    Colors.teal,
    Colors.green,
  ];
  List<Widget> _children = [
    LiveProjectBody(),
    MatchProjectBody(),
    MatchMemberBody(),
    UserProfileBody()
  ];

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
                child: Image.asset(
                  "assets/exit.png",
                )),
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
        body: _children[_selectedMenuIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          width: width,
          height: 70,
          child: GNav(
            color: Colors.grey[800],
            activeColor: Colors.purple,
            iconSize: 24,
            tabBackgroundColor: Colors.green.withOpacity(0.1),
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            duration: Duration(milliseconds: 1000),
            tabs: [
              GButton(
                icon: Icons.home_outlined,
                text: 'Home',
              ),
              GButton(
                icon: Icons.manage_search_outlined,
                text: 'Search project',
              ),
              GButton(
                icon: Icons.person_search_outlined,
                text: 'Search member',
              ),
              GButton(
                icon: Icons.person_outline_outlined,
                text: 'Profile',
              )
            ],
            selectedIndex: _selectedMenuIndex,
            onTabChange: (index) {
              setState(() {
                _selectedMenuIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
