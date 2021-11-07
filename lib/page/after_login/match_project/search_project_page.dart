import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/componet/showDialog.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/team_card.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/page/after_login/match_project/condition_team_page.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

class SearchTeamPage extends StatefulWidget {
  const SearchTeamPage({Key? key}) : super(key: key);

  @override
  _SearchTeamPageState createState() => _SearchTeamPageState();
}

class _SearchTeamPageState extends State<SearchTeamPage> {
  late Future future;
  TextEditingController searchController = TextEditingController();

  List<ProjectResume> containCard = [];
  bool isInput = true;

  fetchProjectCardList() async {
    var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;

    return togetherGetAPI("/teamMatching/projectList/card", "?$userIdx");
  }

  conditionProjcetCardList(var body) async {
    print(body);
    return togetherPostAPI("/teamMatching/team/condition/table", body);
  }

  @override
  void initState() {
    super.initState();
    future = fetchProjectCardList();
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<SignInModel>(context, listen: false);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: _appBar(context, user.userPhoto),
      body: SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.only(
                left: width * 0.08, right: width * 0.08, bottom: height * 0.02),
            child: FutureBuilder(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<ProjectResume> cards =
                      snapshot.data as List<ProjectResume>;
                  return Column(
                    children: [
                      _seachBar(cards),
                      ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount:
                              isInput ? cards.length : containCard.length,
                          itemBuilder: (context, index) {
                            ProjectResume card =
                                isInput ? cards[index] : containCard[index];
                            return GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16))),
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (context) {
                                      return SingleChildScrollView(
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              left: width * 0.08,
                                              right: width * 0.08,
                                              top: height * 0.02,
                                              bottom: height * 0.02),
                                          child: Wrap(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      card.projectName +
                                                          " 프로젝트 상세 정보",
                                                      style: tileTitleStyle),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.description,
                                                          size: 16,
                                                          color: Colors.grey),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        card.projectExp,
                                                        style: editSubTitleStyle
                                                            .copyWith(
                                                                fontSize: 14),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(Icons.school,
                                                              size: 16,
                                                              color:
                                                                  Colors.grey),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            projectEnumFromServer(
                                                                card.professionality),
                                                            style:
                                                                editSubTitleStyle
                                                                    .copyWith(
                                                                        fontSize:
                                                                            14),
                                                          )
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        width: 20,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Icon(Icons.info,
                                                              size: 16,
                                                              color:
                                                                  Colors.grey),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            projectEnumFromServer(
                                                                card.projectType),
                                                            style:
                                                                editSubTitleStyle
                                                                    .copyWith(
                                                                        fontSize:
                                                                            14),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.calendar_today,
                                                          size: 16,
                                                          color: Colors.grey),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        schdeuleDateFormat(
                                                            card.startDate,
                                                            card.endDate,
                                                            false),
                                                        style: editSubTitleStyle
                                                            .copyWith(
                                                                fontSize: 14),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.person,
                                                          size: 16,
                                                          color: Colors.grey),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        card.memberNum
                                                            .toString(),
                                                        style: editSubTitleStyle
                                                            .copyWith(
                                                                fontSize: 14),
                                                      )
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.tag,
                                                          size: 16,
                                                          color: Colors.grey),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        card.tagName
                                                            .toString()
                                                            .substring(
                                                                1,
                                                                card.tagName
                                                                        .toString()
                                                                        .length -
                                                                    1),
                                                        style: editSubTitleStyle
                                                            .copyWith(
                                                                fontSize: 14),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    "소개",
                                                    style: tileTitleStyle,
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    card.comment,
                                                    style: editSubTitleStyle,
                                                  ),
                                                  SizedBox(
                                                    height: 16,
                                                  ),
                                                  Center(
                                                    child: MyButton(
                                                        label: "Apply",
                                                        onTap: () async {
                                                          loadingAlert(context);
                                                          var code = await togetherGetAPI(
                                                              "/teamMatching/team/application",
                                                              '?user_idx=${user.userIdx}&project_idx=${card.projectIdx}');

                                                          print(code);
                                                          if (code != null)
                                                            Navigator.of(
                                                                    context)
                                                                .pop();

                                                          Navigator.of(context)
                                                              .pop();
                                                        }),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              },
                              child: Container(
                                margin: EdgeInsets.only(top: 12),
                                padding: EdgeInsets.symmetric(
                                    vertical: height * 0.02,
                                    horizontal: width * 0.06),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.blueGrey[400]),
                                width: width * 0.8,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      card.projectName,
                                      style: editTitleStyle.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.school,
                                                size: 16, color: Colors.white),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              projectEnumFromServer(
                                                  card.professionality),
                                              style: editTitleStyle.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 14),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.info,
                                                size: 16, color: Colors.white),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              projectEnumFromServer(
                                                  card.projectType),
                                              style: editTitleStyle.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 14),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            size: 16, color: Colors.white),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          schdeuleDateFormat(card.startDate,
                                              card.endDate, false),
                                          style: editTitleStyle.copyWith(
                                              color: Colors.white,
                                              fontSize: 14),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.person,
                                            size: 16, color: Colors.white),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          card.memberNum.toString(),
                                          style: editTitleStyle.copyWith(
                                              color: Colors.white,
                                              fontSize: 14),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          })
                    ],
                  );
                } else if (snapshot.hasError)
                  return Text('${snapshot.error}');
                else if (snapshot.hasData == false &&
                    snapshot.connectionState == ConnectionState.done) {
                  return Column(
                    children: [
                      _seachBar([]),
                      Visibility(
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  future = fetchProjectCardList();
                                });
                              },
                              style: TextButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.zero),
                              child: Text(
                                "See All",
                                style: editTitleStyle,
                              ),
                            )),
                      ),
                      Container(
                          height: 500,
                          child: Center(child: Text("Not found!"))),
                    ],
                  );
                }
                return CircularProgressIndicator();
              },
            )),
      ),
    );
  }

  _seachBar(List<ProjectResume> cards) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none),
                fillColor: Colors.grey[200],
                filled: true,
                hintText: "Input Proejct Name",
                hintStyle: editSubTitleStyle,
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey,
                )),
            onChanged: (value) {
              setState(() {
                isInput = false;
                containCard = [];
                cards.forEach((element) {
                  if (element.projectName.contains(value))
                    containCard.add(element);
                });
              });
            },
          ),
        ),
        IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => ConditionTeamPage()))
                  .then((value) {
                if (value != null)
                  setState(() {
                    future = conditionProjcetCardList(value);
                  });
              });
            },
            icon: Icon(Icons.tune))
      ],
    );
  }

  _appBar(BuildContext context, String photo) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Icon(
          Icons.arrow_back_ios,
          size: 20,
          color: Colors.black,
        ),
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
