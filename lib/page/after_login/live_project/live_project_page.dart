import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together_android/componet/circle_avator_widget.dart';
import 'package:together_android/componet/empty_data_display.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/main.dart';
import 'package:together_android/model/after_login_model/live_project_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/page/after_login/make_project/make_project_page.dart';
import 'package:together_android/page/after_project/project_main_page.dart';
import 'package:together_android/service/api.dart';

class LiveProjectBody extends StatefulWidget {
  const LiveProjectBody({Key? key}) : super(key: key);

  @override
  _LiveProjectBodyState createState() => _LiveProjectBodyState();
}

class _LiveProjectBodyState extends State<LiveProjectBody> {
  late Future future;
  ValueNotifier<bool> showFloating = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    future = getDeviceUserIdx();
  }

  Future getDeviceUserIdx() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var idx = prefs.getInt('idx');

    if (idx != null) {
      Provider.of<SignInModel>(context, listen: false).userIdx = idx;
      return togetherGetAPI('/main', '?user_idx=$idx');
    } else {
      var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;
      return togetherGetAPI('/main', '?user_idx=$userIdx');
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: titleColor,
        title: Text(
          "My Projects",
          style: appBarTitleStlye,
        ),
      ),
      body: FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data as List;
            if (data.isEmpty) {
              showFloating.value = false;
              return EmptyDataDisplay();
            } else {
              showFloating.value = true;
              snapshot.data as List<LiveProject>;
              return Stack(
                children: [
                  Container(
                    child: ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          LiveProject project = snapshot.data[index];
                          var gradientColor = GradientTemplate
                              .gradientTemplate[index % 5].colors;
                          return GestureDetector(
                            onTap: () {
                              chatRoom = project.projectIdx;
                              Provider.of<LiveProject>(context, listen: false)
                                  .enterProject(project);
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
                                        color:
                                            gradientColor.last.withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                        offset: Offset(4, 4),
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(24)),
                                margin: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    projectIntro(width, project),
                                    SizedBox(
                                      height: height * 0.01,
                                    ),
                                    projectMember(project),
                                    SizedBox(
                                      height: height * 0.01,
                                    ),
                                    projectData(project),
                                    SizedBox(
                                      height: height * 0.02,
                                    )
                                  ],
                                )),
                          );
                        }),
                  ),
                  makeProjectButton(width, context)
                ],
              );
            }
          } else if (snapshot.hasError) {
            print("error");
            return Text("$snapshot.error");
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  ListTile projectIntro(double width, LiveProject project) {
    return ListTile(
      contentPadding: EdgeInsets.only(
        left: width * 0.04,
        top: width * 0.04,
      ),
      title: Text(project.projectName,
          style: GoogleFonts.lato(
              textStyle: TextStyle(
                  fontSize: width * 0.052,
                  color: Colors.white,
                  fontWeight: FontWeight.bold))),
      subtitle: Padding(
        padding: EdgeInsets.only(
          left: width * 0.04,
          top: width * 0.04,
        ),
        child: Text(
          project.projectExp,
          style: GoogleFonts.lato(
              textStyle: TextStyle(
                  fontSize: width * 0.052,
                  color: Colors.white,
                  fontWeight: FontWeight.w400)),
          maxLines: 3,
        ),
      ),
      //trailing: cardPopupButton(),
    );
  }

  Row projectData(LiveProject project) {
    return Row(
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
        Container(
          width: 1,
          height: 30,
          decoration: BoxDecoration(color: Colors.grey),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "기간",
              style: TextStyle(color: Colors.white),
            ),
            Text(
              project.startDate + "~ " + project.endDate,
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ],
    );
  }

  Column projectMember(LiveProject project) {
    return Column(
      children: [
        Text(
          "참여 인원 " + project.memberCount.toString() + "명",
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        hortCirclePhotos(project)
      ],
    );
  }

  PopupMenuButton<int> cardPopupButton() {
    return PopupMenuButton(
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
    );
  }

  makeProjectButton(double width, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: width * 0.03, right: width * 0.03),
      child: Visibility(
        visible: showFloating.value,
        child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              backgroundColor: titleColor,
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => MakeProjectBody()))
                    .then((value) => setState(() {}));
              },
              child: Icon(
                Icons.post_add,
                size: 32,
              ),
            )),
      ),
    );
  }

  hortCirclePhotos(LiveProject project) {
    // return ListView(
    //   shrinkWrap: true,
    //   scrollDirection: Axis.horizontal,
    //   children: project.photoes.map<Widget>((e) {
    //     return CircleAvatorComponent(width: 60, height: 60, serverImage: e);
    //   }).toList(),
    // );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: project.photoes.map<Widget>((e) {
            return Padding(
              padding: const EdgeInsets.only(right: 5),
              child:
                  CircleAvatorComponent(width: 60, height: 60, serverImage: e),
            );
          }).toList(),
        ),
      ),
    );
  }
}
