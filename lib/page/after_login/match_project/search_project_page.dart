import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/team_card.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/page/after_login/match_project/condition_team_page.dart';
import 'package:together_android/service/api.dart';

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
                              onTap: () {},
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
                                  children: [Text(card.projectName)],
                                ),
                              ),
                            );
                          })
                    ],
                  );
                } else if (snapshot.hasError) return Text('${snapshot.error}');

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
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ConditionTeamPage()));
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
