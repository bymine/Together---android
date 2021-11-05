import 'dart:convert';

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
import 'package:together_android/page/after_login/match_member/condition_search_page.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

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

  String _selectProject = "";

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
    var map = Provider.of<MappingProject>(context, listen: false).map;
    String photo = Provider.of<SignInModel>(context, listen: false).userPhoto;
    if (isCondition == true) {
      future = togetherPostSpecialAPI(
          "/member/search/do", conditionDetail, "/$userIdx");
      print("updated");
      //isCondition = false;
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
                      Visibility(
                        visible: isCondition,
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  isCondition = false;
                                });
                                future = fetchCardList();
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
                      ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount:
                              isInput ? cards.length : containCard.length,
                          itemBuilder: (context, index) {
                            print("index: " + index.toString());
                            MemberResume card =
                                isInput ? cards[index] : containCard[index];
                            return GestureDetector(
                              onTap: () {
                                MemberResume detailCard =
                                    isInput ? cards[index] : containCard[index];

                                detailCardBottomsheet(
                                    context, width, height, detailCard, map);
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
                                              color: darkBlue,
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
                                              color: darkBlue,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              addressToString(
                                                  false,
                                                  card.mainAddr,
                                                  card.referenceAddr,
                                                  card.detailAddr),
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
                                          color: darkBlue,
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
      MemberResume detailCard, Map<String, int> map) {
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
                            title: "Select Project",
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
                          Column(
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
                                    Icons.psychology,
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
                                            .substring(1,
                                                detailCard.hobbys.length - 1),
                                    style: editSubTitleStyle,
                                  ),
                                ],
                              ),
                            ],
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
                                label: "Invite",
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
                          print(conditionDetail);
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
          backgroundImage: NetworkImage(photo),
        ),
        SizedBox(
          width: 20,
        )
      ],
    );
  }
}
