import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/circle_avator_widget.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/live_project_model.dart';
import 'package:together_android/page/after_login/make_project/make_project_page.dart';
import 'package:together_android/page/after_project/project_main_page.dart';

class LiveProjectCards extends StatefulWidget {
  final List<LiveProject> projects;
  LiveProjectCards({required this.projects});

  @override
  _LiveProjectCardsState createState() => _LiveProjectCardsState();
}

class _LiveProjectCardsState extends State<LiveProjectCards> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        child: ListView.builder(
            itemCount: widget.projects.length,
            itemBuilder: (context, index) {
              var project = widget.projects[index];
              var gradientColor =
                  GradientTemplate.gradientTemplate[index % 5].colors;
              return GestureDetector(
                onTap: () {
                  Provider.of<LiveProject>(context, listen: false)
                      .enterProject(project);
                  print("선택한 프로젝트 idx: " +
                      Provider.of<LiveProject>(context, listen: false)
                          .projectIdx
                          .toString());
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ProjectMainPage()));
                },
                child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColor,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColor.last.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: Offset(4, 4),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(24)),
                    margin: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        ListTile(
                            // minVerticalPadding: 8,
                            title: Padding(
                              padding: EdgeInsets.only(
                                left: width * 0.04,
                                top: width * 0.04,
                              ),
                              child: Text(project.projectName,
                                  style: TextStyle(
                                      fontSize: width * 0.056,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                            subtitle: Padding(
                              padding: EdgeInsets.only(
                                  left: width * 0.04,
                                  top: width * 0.04,
                                  bottom: width * 0.04),
                              child: Text(project.projectExp,
                                  style: TextStyle(
                                      fontSize: width * 0.048,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500)),
                            ),
                            trailing: PopupMenuButton(
                              icon: Icon(Icons.more_vert_outlined),
                              onSelected: (newValue) {
                                // add this property
                                setState(() {
                                  // _value =
                                  //     newValue; // it gives the value which is selected
                                });
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: Text("Settings"),
                                  value: 0,
                                ),
                                PopupMenuItem(
                                  child: Text("Color"),
                                  value: 1,
                                ),
                              ],
                            )),
                        Column(
                          children: [
                            Column(
                              children: [
                                Text(
                                  "참여 인원 " +
                                      project.memberCount.toString() +
                                      "명",
                                  style: TextStyle(color: Colors.white),
                                ),
                                hortCirclePhotos(project)
                              ],
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "보관중인 파일",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      project.files.toString() + "개",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "기간",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      project.startDate +
                                          "~ " +
                                          project.endDate,
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: height * 0.02,
                            )
                          ],
                        )
                      ],
                    )),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.withOpacity(0.5),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => MakeProjectBody()))
              .then((value) => setState(() {
                    if (value != null) {
                      value as LiveProject;
                      widget.projects.add(value);
                    }
                  }));
        },
        child: Icon(
          Icons.post_add,
          size: 32,
        ),
      ),
    );
  }

  Row hortCirclePhotos(LiveProject project) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: project.photoes.map((e) {
        return CircleAvatorComponent(width: 60, height: 60, serverImage: e);
      }).toList(),
    );
  }
}
