import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/team_card.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/model/mappingProject_model.dart';
import 'package:together_android/page/after_login/main_page.dart';
import 'package:together_android/page/after_login/match_project/search_project_page.dart';
import 'package:together_android/page/after_login/match_project/show_my_project_card_page.dart';
import 'package:together_android/service/api.dart';

class MatchProjectBody extends StatefulWidget {
  const MatchProjectBody({Key? key}) : super(key: key);

  @override
  _MatchProjectBodyState createState() => _MatchProjectBodyState();
}

class _MatchProjectBodyState extends State<MatchProjectBody> {
  late Future future;
  fetchTeamMatchData() async {
    var idx = Provider.of<SignInModel>(context, listen: false).userIdx;

    return togetherGetAPI("/teamMatching", "?user_idx=$idx");
  }

  @override
  void initState() {
    super.initState();
    future = fetchTeamMatchData();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var name = Provider.of<SignInModel>(context, listen: false).userName;
    var map = Provider.of<MappingProject>(context, listen: false).map;

    String photo = Provider.of<SignInModel>(context, listen: false).userPhoto;
    return Scaffold(
      appBar: _appBar(context, photo),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
              left: width * 0.08, right: width * 0.08, bottom: height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header(name),
              FutureBuilder(
                  future: future,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text("12");
                    } else if (snapshot.hasError) {
                      print('${snapshot.error}');
                      return Text('${snapshot.error}');
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "My Project Cards",
                    style: editTitleStyle,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ShowProjectCard(
                                map: map,
                              )));
                    },
                    child: Text(
                      "Add Card",
                      style: editTitleStyle,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: myPorjectCard
                      .map((card) => GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ShowProjectCard(
                                        card: card,
                                        map: map,
                                      )));
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 8),
                              padding: EdgeInsets.symmetric(
                                  vertical: height * 0.04,
                                  horizontal: width * 0.06),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.blueGrey[400]),
                              width: width * 0.6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    card.projectName,
                                  ),
                                  Text(card.intro),
                                  Text(card.professionality)
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              // DottedBorder(
              //     strokeWidth: 2,
              //     radius: Radius.circular(16),
              //     padding: EdgeInsets.all(0),
              //     color: Colors.blueGrey,
              //     strokeCap: StrokeCap.butt,
              //     borderType: BorderType.RRect,
              //     child: GestureDetector(
              //       onTap: () {
              //         Navigator.of(context).push(MaterialPageRoute(
              //             builder: (context) => ShowProjectCard(map: map)));
              //       },
              //       child: Container(
              //         decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(16),
              //             color: Colors.blueGrey),
              //         width: width / 3,
              //         height: width / 3,
              //         child: Center(
              //           child: Text(
              //             "+ Add Card",
              //             style: editTitleStyle.copyWith(
              //                 color: Colors.white, fontWeight: FontWeight.bold),
              //           ),
              //         ),
              //       ),
              //     )),
              SizedBox(
                height: 20,
              ),
              Text(
                "Recommend List",
                style: editTitleStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column header(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Search Team",
          style: subHeadingStyle,
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          name,
          style: headingStyle,
        ),
        SizedBox(
          height: 20,
        ),
        _searchBar(),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  _searchBar() {
    return TextField(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => SearchTeamPage()));
      },
      readOnly: true,
      decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none),
          fillColor: Colors.grey[200],
          filled: true,
          hintText: "Search",
          hintStyle: editSubTitleStyle,
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey,
          )),
    );
  }

  _appBar(BuildContext context, String photo) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MainPage()));
        },
        icon: Icon(Icons.home_outlined, color: Colors.grey),
      ),
      actions: [
        CircleAvatar(
          backgroundImage: NetworkImage(photo),
        ),
        SizedBox(
          width: 20,
        )
      ],
    );
  }
}

List<ProjectResume> myPorjectCard = [
  ProjectResume(
      projectName: "1",
      projectExp: "sadasd",
      startDate: "d",
      endDate: "",
      professionality: "a",
      projectType: "s",
      memberNum: "2",
      intro: "intro intro intro intro"),
  ProjectResume(
      projectName: "1",
      projectExp: "sadasd",
      startDate: "d",
      endDate: "",
      professionality: "a",
      projectType: "s",
      memberNum: "2",
      intro: "intro"),
  ProjectResume(
      projectName: "1",
      projectExp: "sadasd",
      startDate: "d",
      endDate: "",
      professionality: "a",
      projectType: "s",
      memberNum: "2",
      intro: "intro")
];
