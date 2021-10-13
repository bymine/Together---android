import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/MemberResume.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/page/after_login/main_page.dart';
import 'package:together_android/page/after_login/match_member/member_card_page.dart';
import 'package:together_android/page/after_login/match_member/member_search_page.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

class MatchMemberBody extends StatefulWidget {
  const MatchMemberBody({Key? key}) : super(key: key);

  @override
  _MatchMemberBodyState createState() => _MatchMemberBodyState();
}

class _MatchMemberBodyState extends State<MatchMemberBody> {
  late Future future;
  @override
  void initState() {
    future = fetchMemberMainData();
    super.initState();
  }

  fetchMemberMainData() async {
    var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;
    var data = togetherGetAPI("/member/search/main", "/$userIdx");
    return data;
  }

  bool isChanged = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String photo = Provider.of<SignInModel>(context, listen: false).userPhoto;
    // print(Provider.of<MappingProject>(context, listen: false).map);
    if (isChanged) {
      future = fetchMemberMainData();
      print("updated main page");
      isChanged = false;
    }
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
                      MemberResume resume = snapshot.data as MemberResume;
                      return _serachMain(resume, width, height);
                    } else if (snapshot.hasError) {
                      print("$snapshot.error");
                      return Text("$snapshot.error");
                    } else if (snapshot.hasData == false &&
                        snapshot.connectionState == ConnectionState.done) {
                      return _serachMain(null, width, height);
                    }
                    return Center(child: CircularProgressIndicator());
                  })
            ],
          ),
        ),
      ),
    );
  }

  _serachMain(MemberResume? resume, double width, double height) {
    if (resume != null)
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Search Member",
              style: subHeadingStyle,
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              resume.name,
              style: headingStyle,
            ),
            SizedBox(
              height: 20,
            ),
            _searchBar(),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "My Card",
                  style: editTitleStyle,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (context) => MyMemberCard(
                          resume: resume,
                        ),
                      ),
                    )
                        .then((value) {
                      setState(() {
                        if (value != null) isChanged = value;
                      });
                    });
                  },
                  child: Text(
                    "See All",
                    style: editTitleStyle,
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            myResumeCard(height, width, resume),
            SizedBox(
              height: 20,
            ),
            Text(
              "Recommend List",
              style: editTitleStyle,
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      );
    else {
      String name = Provider.of<SignInModel>(context, listen: false).userName;

      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Search Member",
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
            Text(
              "My Card",
              style: editTitleStyle,
            ),
            SizedBox(
              height: 10,
            ),
            DottedBorder(
                strokeWidth: 2,
                radius: Radius.circular(16),
                padding: EdgeInsets.all(0),
                color: Colors.blueGrey,
                strokeCap: StrokeCap.butt,
                borderType: BorderType.RRect,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (context) => MyMemberCard(),
                      ),
                    )
                        .then((value) {
                      setState(() {
                        if (value != null) isChanged = value;
                      });
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.blueGrey),
                    width: width / 3,
                    height: width / 3,
                    child: Center(
                      child: Text(
                        "+ Add Card",
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
              "Recommend List",
              style: editTitleStyle,
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      );
    }
  }

  Container myResumeCard(double height, double width, MemberResume resume) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: height * 0.02, horizontal: width * 0.06),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), color: Colors.blueGrey[400]),
      width: width * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            resume.name,
            style: editTitleStyle.copyWith(
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.psychology,
                    size: 20,
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    resume.mbti,
                    style: editTitleStyle.copyWith(
                        color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.place,
                    size: 20,
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    addressToString(false, resume.mainAddr,
                        resume.referenceAddr, resume.detailAddr),
                    style: editTitleStyle.copyWith(
                        color: Colors.white, fontSize: 14),
                    maxLines: 1,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.rate_review,
                size: 20,
                color: Colors.black,
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Text(
                  resume.comment ?? "나의 소개글이 없습니다.",
                  style: editTitleStyle.copyWith(
                      color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _searchBar() {
    return TextField(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => MemberSearchPage()));
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
