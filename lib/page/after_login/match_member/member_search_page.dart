import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/MemberResume.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/page/after_login/match_member/condition_search_page.dart';
import 'package:together_android/service/api.dart';

class MemberSearchPage extends StatefulWidget {
  const MemberSearchPage({Key? key}) : super(key: key);

  @override
  _MemberSearchPageState createState() => _MemberSearchPageState();
}

class _MemberSearchPageState extends State<MemberSearchPage> {
  late Future future;
  TextEditingController searchController = TextEditingController();

  List<MemberResume> containCard = [];
  bool isInput = true;

  bool isCondition = false;
  String conditionDetail = "";
  @override
  void initState() {
    future = fetchCardList();
    super.initState();
  }

  fetchCardList() async {
    var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;
    var data = togetherGetAPI("/member/search/cards", "/$userIdx");

    return data;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;

    String photo = Provider.of<SignInModel>(context, listen: false).userPhoto;
    if (isCondition == true) {
      future = togetherPostSpecialAPI(
          "/member/search/do", conditionDetail, "/$userIdx");
      print("updated");
      isCondition = false;
    }
    return Scaffold(
      appBar: _appBar(context, photo),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
              left: width * 0.08, right: width * 0.08, bottom: height * 0.02),
          child: FutureBuilder(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<MemberResume> cards =
                      snapshot.data as List<MemberResume>;
                  return Column(
                    children: [
                      _seachBar(cards),
                      ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount:
                              isInput ? cards.length : containCard.length,
                          itemBuilder: (context, index) {
                            MemberResume card =
                                isInput ? cards[index] : containCard[index];
                            return GestureDetector(
                              onTap: () {
                                MemberResume detailCard =
                                    isInput ? cards[index] : containCard[index];

                                detailCardBottomsheet(
                                    context, width, height, detailCard);
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
                                      card.name,
                                      style: editTitleStyle.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                              card.mbti,
                                              style: editTitleStyle.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 14),
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
                                              card.mainAddr + "경기도 화성시 봉담읍",
                                              style: editTitleStyle.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 14),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            cards[index].comment ??
                                                "나의 소개글이 없습니다.",
                                            style: editTitleStyle.copyWith(
                                                color: Colors.white,
                                                fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          })
                    ],
                  );
                } else if (snapshot.hasError) {
                  print("$snapshot.error");
                  return Text("$snapshot.error");
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              }),
        ),
      ),
    );
  }

  detailCardBottomsheet(BuildContext context, double width, double height,
      MemberResume detailCard) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
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
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          detailCard.name,
                          style: headingStyle,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.psychology,
                              size: 20,
                              color: Colors.grey,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              detailCard.mbti,
                              style: editTitleStyle.copyWith(
                                  color: Colors.grey, fontSize: 14),
                            ),
                          ],
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
                              style: editTitleStyle.copyWith(
                                  color: Colors.grey, fontSize: 14),
                            ),
                          ],
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
                              detailCard.mainAddr + "경기도 화성시 봉담읍",
                              style: editTitleStyle.copyWith(
                                  color: Colors.grey, fontSize: 14),
                              maxLines: 1,
                            ),
                          ],
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
                              detailCard.licens.toString(),
                              style: editTitleStyle.copyWith(
                                  color: Colors.grey, fontSize: 14),
                            ),
                          ],
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
                              detailCard.hobbys.toString(),
                              style: editTitleStyle.copyWith(
                                  color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          "Introduce",
                          style: headingStyle,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(
                            detailCard.comment ?? "no comment",
                            style: editSubTitleStyle,
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          "Experience",
                          style: headingStyle,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(detailCard.resume ?? "no comment",
                              style: editSubTitleStyle),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: elevatedStyle,
                          child: Text("Project Invitaion"),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          });
        });
  }

  Row _seachBar(List<MemberResume> cards) {
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
                hintText: "Input Name",
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
                  if (element.name.contains(value)) containCard.add(element);
                });
              });
            },
          ),
        ),
        IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => ConditionSearchPage()))
                  .then((value) => setState(() {
                        if (value != null) {
                          isCondition = true;
                          conditionDetail = value;
                        }
                      }));
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
          backgroundImage:
              NetworkImage("http://101.101.216.93:8080/images/" + photo),
        ),
        SizedBox(
          width: 20,
        )
      ],
    );
  }
}
