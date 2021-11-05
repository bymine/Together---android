import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/componet/input_field.dart';
import 'package:together_android/componet/showDialog.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/MemberResume.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/model/mappingProject_model.dart';
import 'package:together_android/page/after_login/main_page.dart';
import 'package:together_android/page/after_login/match_member/condition_search_page.dart';
import 'package:together_android/page/after_login/match_member/show_my_resume_page.dart';
import 'package:together_android/page/after_login/match_member/search_resume_page.dart';
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
    var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;
    String photo = Provider.of<SignInModel>(context, listen: false).userPhoto;
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
                      List<MemberResume> resume =
                          snapshot.data as List<MemberResume>;
                      var myCard;
                      List<MemberResume> recCards = [];
                      resume.forEach((element) {
                        if (element.idx == userIdx)
                          myCard = element;
                        else
                          recCards.add(element);
                      });

                      return _serachMain(myCard, recCards, width, height);
                    } else if (snapshot.hasError) {
                      print("$snapshot.error");
                      return Text("$snapshot.error");
                    } else if (snapshot.hasData == false &&
                        snapshot.connectionState == ConnectionState.done) {
                      return _serachMain(null, null, width, height);
                    }
                    return Center(child: CircularProgressIndicator());
                  })
            ],
          ),
        ),
      ),
    );
  }

  _serachMain(MemberResume? resume, List<MemberResume>? recCards, double width,
      double height) {
    if (resume != null)
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "프로젝트 멤버 찾기",
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
                  "내 명함",
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
                    "보기",
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
              "추천 리스트",
              style: editTitleStyle,
            ),
            SizedBox(
              height: 10,
            ),
            recCards!.isEmpty
                ? Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ConditionSearchPage()));
                      },
                      child: Text(
                        "조건검색을 등록하세요",
                        style: editSubTitleStyle,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: recCards.map<Widget>((e) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: recResumeCard(
                              height, width, e, recCards.indexOf(e)),
                        );
                      }).toList(),
                    ),
                  )
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
              "프로젝트 멤버 찾기",
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
              "내 명함",
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
                        "+ 등록하기",
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
            SizedBox(
              height: 10,
            ),
          ],
        ),
      );
    }
  }

  detailCardBottomsheet(BuildContext context, double width, double height,
      MemberResume detailCard, Map<String, int> map) {
    String _selectProject = "";

    if (map.isNotEmpty) _selectProject = map.keys.first;

    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16))),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    left: width * 0.08,
                    right: width * 0.08,
                    top: height * 0.02,
                    bottom: height * 0.02),
                child: Wrap(
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(detailCard.photo),
                            ),
                          ),
                          MyInputField(
                            title: "초대할 프로젝트 선택",
                            hint: _selectProject.isEmpty
                                ? "First Create a Project!!"
                                : _selectProject,
                            suffixIcon: _selectProject == ""
                                ? SizedBox(
                                    width: 1,
                                  )
                                : DropdownButton(
                                    dropdownColor: Colors.blueGrey,
                                    value: _selectProject,
                                    underline: Container(),
                                    items: Provider.of<MappingProject>(context,
                                            listen: false)
                                        .map
                                        .keys
                                        .toList()
                                        .map((value) {
                                      return DropdownMenuItem(
                                          value: value,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(value,
                                                style:
                                                    editSubTitleStyle.copyWith(
                                                        color: Colors.white)),
                                          ));
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectProject = value.toString();
                                      });
                                    },
                                  ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "프로필",
                            style: editTitleStyle,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      detailCard.name,
                                      style: editSubTitleStyle,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.psychology_outlined,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      detailCard.mbti,
                                      style: editSubTitleStyle,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.face,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      detailCard.age.toString() + "살",
                                      style: editSubTitleStyle,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.place,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      addressToString(
                                          false,
                                          detailCard.mainAddr,
                                          detailCard.referenceAddr,
                                          detailCard.detailAddr), // 수정 필요
                                      style: editSubTitleStyle,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.book,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      detailCard.licens.isEmpty
                                          ? "no comment"
                                          : detailCard.licens
                                              .toString()
                                              .substring(1,
                                                  detailCard.licens.length - 1),
                                      style: editSubTitleStyle,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.tag,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      detailCard.hobbys.isEmpty
                                          ? "no comment"
                                          : detailCard.hobbys
                                              .toString()
                                              .substring(
                                                  1,
                                                  detailCard.hobbys
                                                          .toString()
                                                          .length -
                                                      1),
                                      style: editSubTitleStyle,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            "소개",
                            style: editTitleStyle,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              detailCard.comment ?? "no comment",
                              style: editSubTitleStyle,
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            "경험",
                            style: editTitleStyle,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(detailCard.resume ?? "no comment",
                                style: editSubTitleStyle),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Center(
                            child: MyButton(
                                label: "초대하기",
                                onTap: () async {
                                  loadingAlert(context);
                                  var code = await togetherPostAPI(
                                      "/member/search/invite",
                                      jsonEncode({
                                        "user_idx": Provider.of<SignInModel>(
                                                context,
                                                listen: false)
                                            .userIdx,
                                        "member_idx": detailCard.idx,
                                        "project_idx": map[_selectProject]
                                      }));
                                  if (code != null) Navigator.of(context).pop();
                                  Navigator.of(context).pop();

                                  inviteSnackbar(code.toString());
                                }),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  inviteSnackbar(code) {
    return Get.snackbar(
      code == "success" ? "프로젝트 초대 성공" : '프로젝트 초대 실패',
      invitteMessage(code.toString()),
      icon: code == "success"
          ? Icon(
              Icons.check_circle,
              color: Colors.greenAccent,
            )
          : Icon(
              Icons.warning,
              color: Colors.redAccent,
            ),
      duration: Duration(seconds: 4),
      animationDuration: Duration(milliseconds: 800),
      snackPosition: SnackPosition.TOP,
    );
  }

  recResumeCard(double height, double width, MemberResume resume, int index) {
    return GestureDetector(
      onTap: () {
        var map = Provider.of<MappingProject>(context, listen: false).map;
        detailCardBottomsheet(context, width, height, resume, map);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: height * 0.02, horizontal: width * 0.06),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: BasicColor.basicColor[index]),
        width: width * 0.35,
        height: width * 0.4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: CircleAvatar(
                backgroundImage: NetworkImage(resume.photo),
              ),
            ),
            SizedBox(
              height: 5,
            ),
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
              children: [
                Icon(
                  Icons.face,
                  size: 20,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  resume.age.toString() + "살",
                  style: editTitleStyle.copyWith(
                      color: Colors.white, fontSize: 14),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Icon(
                  Icons.psychology_outlined,
                  size: 20,
                  color: Colors.white,
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
          ],
        ),
      ),
    );
  }

  Container myResumeCard(double height, double width, MemberResume resume) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: height * 0.02, horizontal: width * 0.06),
      decoration: BoxDecoration(
          color: Color(0xFF61A3FE), borderRadius: BorderRadius.circular(16)),
      width: width * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            resume.name,
            style: editTitleStyle.copyWith(color: Colors.white),
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
                    Icons.psychology_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    resume.mbti,
                    style: editSubTitleStyle.copyWith(color: Colors.white),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.place,
                    size: 20,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    addressToString(false, resume.mainAddr,
                        resume.referenceAddr, resume.detailAddr),
                    style: editSubTitleStyle.copyWith(color: Colors.white),
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
                color: Colors.white,
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Text(resume.comment ?? "나의 소개글이 없습니다.",
                    style: editSubTitleStyle.copyWith(color: Colors.white)),
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
            .push(MaterialPageRoute(builder: (context) => MemberSearchPage()))
            .then((value) => setState(() {
                  future = fetchMemberMainData();
                }));
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
