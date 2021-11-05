import 'package:dotted_border/dotted_border.dart';
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
import 'package:together_android/utils.dart';

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
              FutureBuilder(
                  future: future,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<ProjectResume> resumes =
                          snapshot.data as List<ProjectResume>;

                      return _searchMain(resumes, map, name, width, height);
                    } else if (snapshot.hasError) {
                      print('${snapshot.error}');
                      return Text('${snapshot.error}');
                    } else if (snapshot.hasData == false &&
                        snapshot.connectionState == ConnectionState.done) {
                      return _searchMain(null, map, name, width, height);
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }

  _searchMain(List<ProjectResume>? resumes, Map<String, int> map, String name,
      double width, double height) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header(name),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "내 프로젝트",
                style: editTitleStyle,
              ),
              Visibility(
                visible: resumes != null,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ShowProjectCard(
                              map: map,
                            )));
                  },
                  child: Text(
                    "추가하기",
                    style: editTitleStyle,
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          if (resumes != null)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: resumes.map((card) {
                  var index = resumes.indexOf(card);
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => ShowProjectCard(
                                    card: card,
                                    map: map,
                                  )))
                          .then((value) => setState(() {
                                future = fetchTeamMatchData();
                              }));
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 8),
                      padding: EdgeInsets.symmetric(
                          vertical: height * 0.04, horizontal: width * 0.04),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: BasicColor.basicColor[index]),
                      width: width * 0.6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.projectName,
                            style: editTitleStyle.copyWith(color: Colors.white),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Icon(Icons.border_color,
                                  color: Colors.white, size: 16),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                card.comment,
                                style: editSubTitleStyle.copyWith(
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 16, color: Colors.white),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                schdeuleDateFormat(
                                    card.startDate, card.endDate, false),
                                style: editSubTitleStyle.copyWith(
                                    color: Colors.white),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
          else
            DottedBorder(
                strokeWidth: 2,
                radius: Radius.circular(16),
                padding: EdgeInsets.all(0),
                color: Colors.blueGrey,
                strokeCap: StrokeCap.butt,
                borderType: BorderType.RRect,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ShowProjectCard(map: map)));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.blueGrey),
                    width: width / 2,
                    height: width / 3,
                    child: Center(
                      child: Text(
                        "+  등록하기",
                        style: editTitleStyle.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )),
          SizedBox(
            height: 20,
          ),
          Text(
            "추천 리스트",
            style: editTitleStyle,
          ),
        ],
      ),
    );
  }

  Column header(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "프로젝트 찾기",
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
