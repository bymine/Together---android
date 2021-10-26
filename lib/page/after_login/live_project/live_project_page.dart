import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/componet/circle_avator_widget.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/main.dart';
import 'package:together_android/model/after_login_model/live_project_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/model/mappingProject_model.dart';
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
  Map<String, int> map = Map<String, int>();

  var _changed;

  var isAlreadyMap = false;

  @override
  void initState() {
    future = getDeviceUserIdx();

    Provider.of<MappingProject>(context, listen: false).map = map;

    super.initState();
  }

  Future getDeviceUserIdx() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var idx = prefs.getInt('idx');

    if (idx != null) {
      await togetherGetAPI("/user/mypage", "?user_idx=$idx").then((value) {
        Provider.of<SignInModel>(context, listen: false).userName =
            value['user_name'];
        Provider.of<SignInModel>(context, listen: false).userPhoto =
            value['user_profile_photo'];
      });
      Provider.of<SignInModel>(context, listen: false).userIdx = idx;
      return togetherGetAPI('/main', '?user_idx=$idx');
    } else {
      var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;
      return togetherGetAPI('/main', '?user_idx=$userIdx');
    }
  }

  @override
  Widget build(BuildContext context) {
    var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;
    var userName = Provider.of<SignInModel>(context, listen: false).userName;

    var photo = Provider.of<SignInModel>(context, listen: false).userPhoto;

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    if (_changed == true) {
      print("updated");
      future = togetherGetAPI('/main', '?user_idx=$userIdx');
      _changed = false;
      isAlreadyMap = false;
    }

    return Scaffold(
      appBar: _appBar(context, photo),
      body: FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            showFloating.value = true;
            snapshot.data as List<LiveProject>;

            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    left: width * 0.04,
                    right: width * 0.04,
                    top: height * 0.02,
                    bottom: height * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "진행중인 프로젝트",
                              style: subHeadingStyle,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              userName,
                              style: headingStyle,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                        MyButton(
                            label: "+ 생성하기",
                            width: width * 0.3,
                            height: 50,
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) => MakeProjectBody()))
                                  .then((value) => setState(() {
                                        if (value != null) {
                                          _changed = value;
                                        }
                                      }));
                            }),
                      ],
                    ),
                    Container(
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            LiveProject project = snapshot.data[index];

                            if (isAlreadyMap == false) {
                              for (int i = 0; i < snapshot.data.length; i++) {
                                LiveProject mapProject = snapshot.data[i];

                                Provider.of<MappingProject>(context,
                                            listen: false)
                                        .map[mapProject.projectName] =
                                    mapProject.projectIdx;
                              }
                              print("project mapping !!");
                              isAlreadyMap = true;
                            }

                            var gradientColor = GradientTemplate
                                .gradientTemplate[index % 5].colors;
                            return GestureDetector(
                              onTap: () {
                                chatRoom = project.projectIdx;
                                Provider.of<LiveProject>(context, listen: false)
                                    .enterProject(project);
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (context) =>
                                            ProjectMainPage()))
                                    .then((value) => setState(() {
                                          _changed = true;
                                        }));
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
                                          color: gradientColor.last
                                              .withOpacity(0.5),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                          offset: Offset(4, 4),
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(24)),
                                  margin: EdgeInsets.only(top: 10),
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
                  ],
                ),
              ),
            );
          }
          if (snapshot.hasData == false &&
              snapshot.connectionState == ConnectionState.done) {
            showFloating.value = false;
            return Container(
              width: width,
              height: height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Container(
                  //   width: width,
                  //   height: height * 0.5,
                  //   child: Image.asset('assets/empty.png'),
                  // ),
                  Text(
                    "진행 중인 프로젝트가 없습니다.",
                    style: headingStyle.copyWith(fontSize: 18),
                  ),
                  Text(
                    "새로운 프로젝트를 생성 하세요",
                    style: subHeadingStyle.copyWith(fontSize: 14),
                  ),
                  SizedBox(
                    height: height * 0.08,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          minimumSize: Size(width * 0.6, height * 0.1),
                          primary: Colors.green.withOpacity(0.5)),
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (context) => MakeProjectBody()))
                            .then((value) => setState(() {
                                  if (value != null) {
                                    _changed = value;
                                  }
                                }));
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add),
                          Text("프로젝트 생성하기"),
                        ],
                      ))
                ],
              ),
            );
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

  hortCirclePhotos(LiveProject project) {
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

  _appBar(BuildContext context, String photo) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.help_outline,
              color: Colors.grey,
              size: 24,
            )),
        SizedBox(
          width: 20,
        )
      ],
    );
  }
}
