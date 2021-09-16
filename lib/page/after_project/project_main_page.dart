import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:together_android/page/after_project/project_file/project_file_page.dart';
import 'package:together_android/page/after_project/project_schedule/project_schedule_page.dart';
import 'package:together_android/page/after_project/project_setting/project_setting_page.dart';

class ProjectMainPage extends StatefulWidget {
  const ProjectMainPage({Key? key}) : super(key: key);

  @override
  _ProjectMainPageState createState() => _ProjectMainPageState();
}

class _ProjectMainPageState extends State<ProjectMainPage> {
  int _selectedMenuIndex = 0;

  List<Widget> _children = [
    ProjectSchedulePage(),
    ProjectFilePage(),
    ProjectSchedulePage(),
    ProjectSchedulePage(),
  ];
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
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
              icon: Icons.event,
              text: 'Schedule',
            ),
            GButton(
              icon: Icons.text_snippet_outlined,
              text: 'File',
            ),
            GButton(
              icon: Icons.message_outlined,
              text: 'Chat',
            ),
            GButton(
              icon: Icons.settings,
              text: 'Setting',
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
    );
  }
}
