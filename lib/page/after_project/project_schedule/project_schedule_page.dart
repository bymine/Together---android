import 'package:flutter/material.dart';

class ProjectSchedulePage extends StatefulWidget {
  const ProjectSchedulePage({Key? key}) : super(key: key);

  @override
  _ProjectSchedulePageState createState() => _ProjectSchedulePageState();
}

class _ProjectSchedulePageState extends State<ProjectSchedulePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("프로젝트 일정"),
      ),
    );
  }
}
