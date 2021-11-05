import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown.dart';
import 'package:flutter_countdown_timer/countdown_controller.dart';
import 'package:get/get.dart' as GET;
import 'package:image_picker/image_picker.dart';
import 'package:juso/juso.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together_android/componet/bottom_sheet_top_bar.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/componet/input_field.dart';
import 'package:together_android/componet/listTile.dart';
import 'package:together_android/componet/showDialog.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/hobby_model.dart';
import 'package:together_android/model/after_login_model/invitaion_model.dart';
import 'package:together_android/model/after_login_model/my_profile_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/page/after_login/main_page.dart';
import 'package:together_android/page/after_login/profile/edit_private_user_info_page.dart';
import 'package:together_android/page/after_login/profile/user_address_page.dart';
import 'package:together_android/page/after_login/profile/user_invitaion_page.dart';
import 'package:together_android/page/after_login/profile/user_schedule_page.dart';
import 'package:together_android/page/before_login/sign_in_page.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

class UserDetailProfilePage extends StatefulWidget {
  const UserDetailProfilePage({Key? key}) : super(key: key);

  @override
  _UserDetailProfilePageState createState() => _UserDetailProfilePageState();
}

class _UserDetailProfilePageState extends State<UserDetailProfilePage> {
  late Future future;
  TextEditingController nickNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController emailAuthController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController phoneAuthController = TextEditingController();

  TextEditingController license1Controller = TextEditingController();
  TextEditingController license2Controller = TextEditingController();
  TextEditingController license3Controller = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController tagController = TextEditingController();

  Juso? myJuso;

  final nickNameFormkey = GlobalKey<FormState>();
  final phoneFormKey = GlobalKey<FormState>();
  final emailFormKey = GlobalKey<FormState>();

  String emailFlag = "";
  String phoneFlag = "";

  String licenseString = "";

  ValueNotifier<String> emailAuthFlag = ValueNotifier<String>("");
  ValueNotifier<String> phoneAuthFlag = ValueNotifier<String>("");

  CountdownController emailTimerController =
      CountdownController(duration: Duration(seconds: 180), onEnd: () {});
  CountdownController phoneTimerController =
      CountdownController(duration: Duration(seconds: 180), onEnd: () {});

  late File _image;
  Dio dio = new Dio();
  final picker = ImagePicker();
  var pickedFile;

  List<FetchHobby> mapHobby = [];

  List<FetchHobby> hobbyList = [];

  List<String> tagName = [];
  List<String> categoryName = [];
  List<String> categoryIdx = [];
  List<String> tagIdx = [];
  List<String> containTag = [];

  List<String> myTag = [];
  List<String> postTagIdx = [];

  Map mappingIdx = Map<String, String>();
  Map mappingName = Map<String, String>();
  Map mappingTag = Map<String, String>();

  Map mappingCategory = Map<String, String>();
  String selectedCategory = "게임";
  String selectedTag = "롤";

  List<Invitaion> invitaions = [];

  _fetchData() {
    var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;
    print("info");
    return togetherGetAPI("/user/detail_profile", "?user_idx=$userIdx");
  }

  Future changePhoto() async {
    pickedFile = (await picker.pickImage(source: ImageSource.gallery));

    if (pickedFile != null) {
      print(pickedFile.path);
      _image = File(pickedFile.path);
      int userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;
      FormData formData = FormData.fromMap({
        "photo": await MultipartFile.fromFile(
          _image.path,
          filename: _image.path,
        ),
        "user_idx": userIdx,
      });

      String url = "http://101.101.216.93:8080/user/changePhoto";
      final response = await dio.post(url,
          data: formData,
          options: Options(headers: {"Content-Type": "multipart/form-data"}));

      if (response.statusCode == 200) {
        setState(() {});
      }
    } else {
      print('No image selected.');
    }
  }

  @override
  void initState() {
    super.initState();
    future = _fetchData();
    _fetchInvitaion();
    fetchHobbyData();
  }

  fetchHobbyData() async {
    mapHobby = await togetherGetAPI("/user/edit_hobby", "");
    mapHobby.forEach((element) {
      if (categoryName.contains(element.hobbyName.keys.first) == false) {
        categoryName.add(element.hobbyName.keys.first.toString());
        categoryIdx.add(element.hobbyIdx.keys.first);
      }
      if (tagName.contains(element.hobbyName.values.first) == false) {
        tagName.add(element.hobbyName.values.first.toString());
        tagIdx.add(element.hobbyIdx.values.first);
      }

      element.hobbyIdx.forEach((key, value) {
        mappingIdx[value] = key;
      });

      element.hobbyName.forEach((key, value) {
        mappingName[value] = key;
      });
    });
    if (categoryName.contains('기타') == false) {
      categoryName.insert(categoryName.length, '기타');
      categoryIdx.insert(categoryIdx.length, '0');
    }

    categoryIdx.forEach((element) {
      int i = categoryIdx.indexOf(element);
      mappingCategory[categoryName[i]] = element;
    });

    tagIdx.forEach((element) {
      int i = tagIdx.indexOf(element);
      mappingTag[tagName[i]] = element;
    });
    selectedCategory = categoryName[0];
    selectedTag = tagName[0];
  }

  _fetchInvitaion() async {
    var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;
    invitaions =
        await togetherGetAPI("/user/invitationList", "?user_idx=$userIdx");
    print(invitaions.length);
  }

  @override
  Widget build(BuildContext context) {
    var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: _appBar(context, Icons.logout),
      body: SingleChildScrollView(
        child: FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());
                default:
                  var profile = snapshot.data as MyProfileDetail;
                  return Container(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20)),
                              color: Color(0xffD0EBFF)),
                          padding: EdgeInsets.only(
                              left: width * 0.08,
                              right: width * 0.08,
                              bottom: height * 0.02),
                          child: Column(
                            children: [
                              profileHeader(profile),
                              SizedBox(
                                height: height * 0.04,
                              ),
                              myButtons(width, context),
                              SizedBox(
                                height: height * 0.03,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              left: width * 0.04,
                              right: width * 0.04,
                              top: height * 0.04),
                          child: Column(
                            children: [
                              MyListTile(
                                leading: CircleAvatar(
                                    child: Icon(Icons.face_outlined,
                                        color: Colors.white),
                                    backgroundColor: Colors.red[300]),
                                title: Text(
                                  '닉네임',
                                  style: tileTitleStyle,
                                ),
                                subTitle: Text(
                                  profile.userNickName,
                                  style: tileSubTitleStyle,
                                ),
                                trailing: IconButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  EditPrivateUserPage(
                                                    type: "NickName",
                                                    value: profile.userNickName,
                                                  )))
                                          .then((value) {
                                        setState(() {
                                          future = _fetchData();
                                        });
                                      });
                                    },
                                    icon: Icon(Icons.chevron_right_outlined)),
                              ),
                              MyListTile(
                                leading: CircleAvatar(
                                    backgroundColor: Colors.orange[300],
                                    child: Icon(Icons.email_outlined,
                                        color: Colors.white)),
                                title: Text(
                                  '이메일',
                                  style: tileTitleStyle,
                                ),
                                subTitle: Text(
                                  profile.userEmail,
                                  style: tileSubTitleStyle,
                                ),
                                trailing: IconButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  EditPrivateUserPage(
                                                    type: "Email",
                                                    value: profile.userEmail,
                                                  )))
                                          .then((value) => setState(() {
                                                future = _fetchData();
                                              }));
                                    },
                                    icon: Icon(Icons.chevron_right_outlined)),
                              ),
                              MyListTile(
                                leading: CircleAvatar(
                                    backgroundColor: Colors.blue[300],
                                    child: Icon(Icons.phone_outlined,
                                        color: Colors.white)),
                                title: Text(
                                  '휴대폰',
                                  style: tileTitleStyle,
                                ),
                                subTitle: Text(
                                  profile.userPhone,
                                  style: tileSubTitleStyle,
                                ),
                                trailing: IconButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  EditPrivateUserPage(
                                                    type: "Phone",
                                                    value: toPhoneString(
                                                        profile.userPhone),
                                                  )))
                                          .then((value) => setState(() {
                                                future = _fetchData();
                                              }));
                                    },
                                    icon: Icon(Icons.chevron_right_outlined)),
                              ),
                              MyListTile(
                                leading: CircleAvatar(
                                    backgroundColor: Colors.brown[300],
                                    child: Icon(Icons.psychology_outlined,
                                        color: Colors.white)),
                                title: Text(
                                  'MBTI',
                                  style: tileTitleStyle,
                                ),
                                subTitle: Text(
                                  profile.userMbti,
                                  style: tileSubTitleStyle,
                                ),
                                trailing: IconButton(
                                    onPressed: () {
                                      mbtiSheet(
                                          profile, width, height, userIdx);
                                    },
                                    icon: Icon(Icons.chevron_right_outlined)),
                              ),
                              MyListTile(
                                leading: CircleAvatar(
                                    backgroundColor: Colors.green[300],
                                    child: Icon(Icons.celebration_outlined,
                                        color: Colors.white)),
                                title: Text(
                                  '생일',
                                  style: tileTitleStyle,
                                ),
                                subTitle: Text(
                                  profile.userBirth,
                                  style: tileSubTitleStyle,
                                ),
                                trailing: IconButton(
                                    onPressed: () {
                                      birthSheet(context, profile, userIdx);
                                    },
                                    icon: Icon(Icons.chevron_right_outlined)),
                              ),
                              MyListTile(
                                leading: CircleAvatar(
                                    backgroundColor: Colors.grey[300],
                                    child: Icon(Icons.location_city_outlined,
                                        color: Colors.white)),
                                title: Text(
                                  '주소',
                                  style: tileTitleStyle,
                                ),
                                subTitle: Text(
                                  addressToString(
                                      true,
                                      profile.mainAddr,
                                      profile.referenceAddr,
                                      profile.detailAddr),
                                  style: tileSubTitleStyle,
                                ),
                                trailing: IconButton(
                                    onPressed: () async {
                                      final juso = await Navigator.push<Juso?>(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const JusoScreen()),
                                      );
                                      if (juso != null) {
                                        setState(() {
                                          myJuso = juso;
                                          jusoToFormat(myJuso!, profile);
                                        });
                                        await togetherPostSpecialAPI(
                                            "/user/edit_address",
                                            jsonEncode({
                                              "main_addr": profile.mainAddr,
                                              "reference_addr":
                                                  profile.referenceAddr,
                                              "detail_addr": profile.detailAddr,
                                              "post_num": profile.postNum
                                            }),
                                            "/$userIdx");
                                      }
                                    },
                                    icon: Icon(Icons.chevron_right_outlined)),
                              ),
                              MyListTile(
                                leading: CircleAvatar(
                                    backgroundColor: Colors.purple[300],
                                    child: Icon(Icons.book_outlined,
                                        color: Colors.white)),
                                title: Text(
                                  '자격증',
                                  style: tileTitleStyle,
                                ),
                                subTitle: Text(
                                  licenseToString(profile.license1,
                                      profile.license2, profile.license3),
                                  style: tileSubTitleStyle,
                                ),
                                trailing: IconButton(
                                    onPressed: () {
                                      licenseSheet(
                                          width, height, profile, userIdx);
                                    },
                                    icon: Icon(Icons.chevron_right_outlined)),
                              ),
                              MyListTile(
                                leading: CircleAvatar(
                                    backgroundColor: Colors.red[300],
                                    child:
                                        Icon(Icons.tag, color: Colors.white)),
                                title: Text(
                                  '취미 (${profile.userHobby.length}/3)',
                                  style: tileTitleStyle,
                                ),
                                subTitle: Container(
                                  child: Wrap(
                                    spacing: 0.5,
                                    children: profile.userHobby.map((hobby) {
                                      return Chip(
                                        label: Text(
                                          hobby,
                                          style: tileSubTitleStyle.copyWith(
                                              color: Colors.black),
                                        ),
                                        backgroundColor: titleColor,
                                        deleteIconColor: Colors.red[300],
                                        onDeleted: () async {
                                          int userHobby =
                                              profile.userHobby.indexOf(hobby);
                                          int userHobbyIdx =
                                              profile.userHobbyIdx[userHobby];

                                          await togetherGetAPI(
                                              "/user/delete_hobby",
                                              "?user_hobby_idxes=$userHobbyIdx");
                                          setState(() {
                                            profile.userHobby.remove(hobby);
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                                trailing: IconButton(
                                    onPressed: () async {
                                      if (profile.userHobby.length >= 3) {
                                        GET.Get.snackbar(
                                          "취미 추가 실패",
                                          "최대 3개까지 설정 할 수 있습니다",
                                          icon: Icon(
                                            Icons.warning_amber_rounded,
                                            color: Colors.redAccent,
                                          ),
                                        );
                                      } else {
                                        hobbySheet(context, width, height,
                                                profile, userIdx)
                                            .then((value) => setState(() {
                                                  if (value != null)
                                                    future = _fetchData();
                                                }));
                                      }
                                    },
                                    icon: Icon(Icons.chevron_right_outlined)),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  );
              }
            }),
      ),
    );
  }

  myButtons(double width, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        iconButton(width, '사진', Icons.camera_alt_outlined, () {
          changePhoto();
        }),
        iconButton(width, '일정', Icons.calendar_today_outlined, () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => PrivateSchedulePage()));
        }),
        messageButton(width, () {
          Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (context) =>
                      UserInviationPage(invitaion: invitaions)))
              .then((value) {
            setState(() {
              _fetchInvitaion();
            });
          });
        })
      ],
    );
  }

  jusoToFormat(Juso juso, MyProfileDetail profile) {
    profile.mainAddr = mainAdressFormat(juso.sido);

    profile.referenceAddr = juso.sigungu;
    profile.detailAddr = juso.address.split(juso.sigungu).last;
    profile.postNum = juso.zonecode;

    print("detail_addr: " + juso.sido);
    print("reference_addr: " + juso.sigungu);
    print("main_addr: " + juso.address.split(juso.sigungu).last);
  }

  hobbySheet(BuildContext context, double width, double height,
      MyProfileDetail profile, int userIdx) {
    containTag = [];
    mappingName.keys.forEach((element) {
      if (mappingName[element] == selectedCategory) containTag.add(element);
    });
    containTag.insert(containTag.length, '기타');

    selectedTag = containTag[0];

    return showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  child: Wrap(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BottomSheetTopBar(
                              title: "취미 추가",
                              onPressed: () async {
                                var bigIdx;
                                var smallIdx;
                                var bigName;
                                var smallName;

                                if (selectedCategory == "기타") {
                                  if (selectedTag == "기타") {
                                    bigIdx = -1;
                                    smallIdx = -1;
                                    bigName = categoryController.text;
                                    smallName = tagController.text;
                                  }
                                } else {
                                  if (selectedTag == "기타") {
                                    bigIdx = mappingCategory[selectedCategory];
                                    bigName = selectedCategory;
                                    smallIdx = -1;
                                    smallName = tagController.text;
                                  } else {
                                    bigIdx = mappingCategory[selectedCategory];
                                    bigName = selectedCategory;
                                    smallIdx = mappingTag[selectedTag];
                                    smallName = selectedTag;
                                  }
                                }
                                await togetherPostAPI(
                                    "/user/add_hobby",
                                    jsonEncode({
                                      "user_idx": userIdx,
                                      "big_idx": bigIdx,
                                      "small_idx": smallIdx,
                                      "big_name": bigName,
                                      "small_name": smallName
                                    }));
                                setState(() {
                                  if (profile.userHobby.contains(selectedTag) ==
                                      false) profile.userHobby.add(selectedTag);
                                });
                                Navigator.of(context).pop(true);
                              }),
                          Container(
                            padding: EdgeInsets.only(
                                left: width * 0.04,
                                right: width * 0.04,
                                bottom: height * 0.02),
                            child: Column(
                              children: [
                                MyInputField(
                                  title: "카테고리 선택",
                                  hint: selectedCategory,
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: DropdownButton(
                                      dropdownColor: Colors.blueGrey,
                                      underline: Container(),
                                      value: selectedCategory,
                                      items: categoryName.map((value) {
                                        return DropdownMenuItem(
                                            value: value,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 14,
                                              ),
                                              child: Text(value,
                                                  style: editSubTitleStyle
                                                      .copyWith(
                                                          color: Colors.white)),
                                            ));
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedCategory = value.toString();
                                          containTag = [];
                                          mappingName.keys.forEach((element) {
                                            if (mappingName[element] ==
                                                selectedCategory)
                                              containTag.add(element);
                                          });
                                          containTag.add('기타');
                                          selectedTag = containTag[0];

                                          print(selectedTag);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                MyInputField(
                                  title: "태그 선택",
                                  hint: selectedTag,
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: DropdownButton(
                                      dropdownColor: Colors.blueGrey,
                                      underline: Container(),
                                      value: selectedTag,
                                      items: containTag.map((value) {
                                        return DropdownMenuItem(
                                            value: value,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 14,
                                              ),
                                              child: Text(value,
                                                  style: editSubTitleStyle
                                                      .copyWith(
                                                          color: Colors.white)),
                                            ));
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedTag = value.toString();
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Visibility(
                                    visible: selectedCategory == "기타",
                                    child: MyInputField(
                                      controller: categoryController,
                                      title: "카테고리 입력",
                                      hint: "카테고리를 입력하세요",
                                    )),
                                Visibility(
                                    visible: selectedCategory == "기타" ||
                                        selectedTag == "기타",
                                    child: MyInputField(
                                      controller: tagController,
                                      title: "태그 입력",
                                      hint: "태그를 입력하세요",
                                    )),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  birthSheet(BuildContext context, MyProfileDetail profile, userIdx) {
    String year = profile.userBirth.split('-').first;
    String month = profile.userBirth.split('-').last.split('-').first;
    String day = profile.userBirth.split('-').last.split('-').last;

    DateTime initalDate =
        DateTime(int.parse(year), int.parse(month), int.parse(day));

    GET.Get.bottomSheet(Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Wrap(
        children: [
          BottomSheetTopBar(
              title: "생일 변경",
              onPressed: () async {
                await togetherPostAPI(
                  "/user/edit_detail_profile",
                  jsonEncode(
                    {
                      "user_idx": userIdx,
                      "flag": 'birth',
                      "value": initalDate.toIso8601String().substring(0, 10)
                    },
                  ),
                );
                setState(() {
                  profile.userBirth =
                      initalDate.toIso8601String().substring(0, 10);
                });
                Navigator.of(context).pop();
              }),
          Container(
            height: 300,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: initalDate,
              onDateTimeChanged: (DateTime value) {
                initalDate = value;
              },
            ),
          ),
        ],
      ),
    ));
  }

  nickNameSheet(double width, double height, BuildContext context,
      MyProfileDetail profile) async {
    var nickNameFlag = "not yet";
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: StatefulBuilder(builder: (context, setState) {
              return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Form(
                  key: nickNameFormkey,
                  child: Container(
                    child: Column(
                      children: [
                        BottomSheetTopBar(
                            title: "닉네임 변경",
                            onPressed: () async {
                              if (nickNameFlag == "permit") {
                                var userIdx = Provider.of<SignInModel>(context,
                                        listen: false)
                                    .userIdx;

                                await togetherPostAPI(
                                  "/user/editNickname",
                                  jsonEncode(
                                    {
                                      "user_idx": userIdx,
                                      "user_nickname": nickNameController.text,
                                    },
                                  ),
                                );
                                setState(() {
                                  profile.userNickName =
                                      nickNameController.text;
                                });
                                Navigator.of(context).pop();
                              }
                            }),
                        Container(
                          padding: EdgeInsets.only(
                              left: width * 0.04,
                              right: width * 0.04,
                              bottom: height * 0.04),
                          child: MyInputField(
                            title: "Nickname",
                            hint: "Input Nickname",
                            controller: nickNameController,
                            titleButton: Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: MyButton(
                                  label: "중복 확인",
                                  onTap: () async {
                                    if (nickNameFormkey.currentState!
                                        .validate()) {
                                      await togetherGetAPI(
                                              "/user/validationNickname",
                                              "?user_nickname=${nickNameController.text}")
                                          .then((value) async {
                                        if (value != null)
                                          setState(() {
                                            print(nickNameFlag);
                                            nickNameFlag = value.toString();
                                            print(nickNameFlag);
                                            setState(() {});
                                          });
                                      });
                                    }
                                  }),
                            ),
                            onChanged: (value) {
                              setState(() {
                                nickNameFlag = "not yet";
                              });
                            },
                            validator: (value) {
                              print(nickNameFlag);
                              if (value!.isEmpty) return "사용할 닉네임을 입력해 주세요.";
                              if (value == profile.userNickName)
                                return "현재 내가 사용중인 닉네임으로 변경할 수 없습니다.";
                              else if (nickNameFlag == "duplication")
                                return "사용중인 닉네임 입니다. 닉네임을 다시 입력하세요";
                              else if (nickNameFlag == "length_error")
                                return "닉네임은 2 ~ 10자리로 입력하세여";
                              else if (nickNameFlag == "not_nickname")
                                return "닉네임 형식을 다시 확인해 주세요.";
                              else if (nickNameFlag == "not yet") return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        }).then((value) => setState(() {}));
  }

  profileHeader(MyProfileDetail profile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            height: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '내 프로필',
                  style: subHeadingStyle,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  profile.userName,
                  style: headingStyle.copyWith(color: darkBlue),
                ),
              ],
            ),
          ),
        ),
        pickedFile == null
            ? Container(
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey[300],
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(profile.userPhoto),
                  ),
                ),
              )
            : Container(
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey[300],
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: FileImage(_image),
                  ),
                ),
              ),
      ],
    );
  }

  iconButton(double width, String name, IconData icon, Function()? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width * 0.2,
        height: width * 0.2,
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Color(0xffffe0e0e0),
                spreadRadius: 2,
                blurRadius: 2,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: pinkClr,
              size: 40,
            ),
            Text(
              name,
              style: editSubTitleStyle,
            )
          ],
        ),
      ),
    );
  }

  messageButton(double width, Function()? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width * 0.2,
        height: width * 0.2,
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Color(0xffffe0e0e0),
                spreadRadius: 2,
                blurRadius: 2,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ]),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mail_outline_outlined,
                  color: pinkClr,
                  size: 40,
                ),
                Text(
                  "메세지",
                  style: editSubTitleStyle,
                )
              ],
            ),
            invitaions.length != 0
                ? Positioned(
                    right: 8,
                    top: 2,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      width: 16,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.redAccent),
                      child: Text(
                        invitaions.length.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  void phoneSheet(double width, double height, BuildContext context,
      MyProfileDetail profile) {
    phoneController.text = toPhoneString(profile.userPhone);
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: StatefulBuilder(builder: (context, setState) {
              return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Form(
                  key: phoneFormKey,
                  child: Container(
                    child: Column(
                      children: [
                        BottomSheetTopBar(
                            title: "휴대전화 변경",
                            onPressed: () async {
                              if (phoneFormKey.currentState!.validate() &&
                                  phoneFlag == "permit" &&
                                  phoneAuthFlag.value == "permit") {
                                var userIdx = Provider.of<SignInModel>(context,
                                        listen: false)
                                    .userIdx;

                                await togetherPostAPI(
                                  "/user/editEmailPhone",
                                  jsonEncode(
                                    {
                                      "user_idx": userIdx,
                                      "value": phoneNumerFormat(
                                          phoneController.text),
                                      "type": "P",
                                      "code": "true"
                                    },
                                  ),
                                );
                                setState(() {
                                  profile.userPhone = phoneController.text;
                                });
                                Navigator.of(context).pop();
                              }
                            }),
                        Container(
                          padding: EdgeInsets.only(
                              left: width * 0.04,
                              right: width * 0.04,
                              bottom: height * 0.04),
                          child: MyInputField(
                            title: "Phone",
                            hint: "- 없이 입력하세요",
                            type: TextInputType.number,
                            controller: phoneController,
                            titleButton: Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: MyButton(
                                  label: "인증 받기",
                                  onTap: () async {
                                    phoneAuthController.clear();
                                    phoneAuthFlag.value = "not yet";
                                    phoneTimerController.stop();
                                    var phone =
                                        phoneNumerFormat(phoneController.text);

                                    var code = await togetherGetAPI(
                                        "/user/validationPhone",
                                        "?user_phone=$phone");

                                    setState(() {
                                      phoneFlag = code.toString();
                                      print(phoneFlag);
                                    });

                                    if (phoneFlag == "permit") {
                                      phoneTimerController =
                                          CountdownController(
                                              duration: Duration(seconds: 180),
                                              onEnd: () {
                                                phoneAuthFlag.value =
                                                    "time over";
                                              });
                                      phoneTimerController.start();
                                    }
                                  }),
                            ),
                            onChanged: (value) {
                              setState(() {
                                phoneFlag = "changed";
                                phoneAuthFlag.value = "not yet";
                                phoneTimerController.stop();
                              });
                            },
                            validator: (value) {
                              if (value!.isEmpty)
                                return "휴대전화 번호를 입력하세여";
                              else if (value ==
                                  toPhoneString(profile.userPhone))
                                return "현재 내가 사용중인 휴대전화 번호 입니다";
                              else if (phoneFlag == "duplication")
                                return "이미 존재하는 휴대전화 입니다";
                            },
                            auth: Visibility(
                                visible: phoneFlag == "permit" &&
                                    phoneAuthFlag.value != "permit",
                                child: Container(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: phoneAuthController,
                                          style: editSubTitleStyle,
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value!.isEmpty)
                                              return "Code 입력하세요";
                                          },
                                          decoration: InputDecoration(
                                            hintText: "Code",
                                            hintStyle: editSubTitleStyle,
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                    color: Colors.grey,
                                                    width: 1)),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.1,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              print(phoneAuthController.text);
                                              var phone = phoneNumerFormat(
                                                  phoneController.text);

                                              var code = await togetherGetAPI(
                                                  '/user/checkDeviceValidation',
                                                  "?validation_code=${phoneAuthController.text}&code_type=P&user_device=$phone");

                                              phoneAuthFlag.value =
                                                  code.toString();
                                              print(phoneAuthFlag.value);
                                              if (phoneAuthFlag.value ==
                                                  "permit") {
                                                if (phoneTimerController
                                                    .isRunning)
                                                  phoneTimerController.stop();
                                              } else if (phoneAuthFlag.value ==
                                                  "error") {
                                                showAlertDialog(
                                                    context,
                                                    Text("휴대폰 인증 실패"),
                                                    Text("입력하신 코드가 올바르지 않습니다"),
                                                    []);
                                              }
                                              setState(() {});
                                            },
                                            style: elevatedStyle,
                                            child: Text("인증 확인"),
                                          ),
                                          Visibility(
                                            visible:
                                                phoneTimerController.isRunning,
                                            child: Countdown(
                                              countdownController:
                                                  phoneTimerController,
                                              builder: (_, Duration time) {
                                                return Text(
                                                    durationFormatTime(time));
                                              },
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        }).then((value) => setState(() {}));
  }

  void licenseSheet(
      double width, double height, MyProfileDetail profile, int userIdx) {
    license1Controller.text = profile.license1;
    license2Controller.text = profile.license2;
    license3Controller.text = profile.license3;
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        BottomSheetTopBar(
                            title: "자격증 변경",
                            onPressed: () async {
                              String value = licenseToString(
                                  license1Controller.text,
                                  license2Controller.text,
                                  license3Controller.text);

                              await togetherPostAPI(
                                "/user/edit_detail_profile",
                                jsonEncode(
                                  {
                                    "user_idx": userIdx,
                                    "flag": 'license',
                                    "value": value
                                  },
                                ),
                              );
                              setState(() {
                                profile.license1 = license1Controller.text;
                                profile.license2 = license2Controller.text;
                                profile.license3 = license3Controller.text;
                              });
                              Navigator.of(context).pop();
                            }),
                        Container(
                          padding: EdgeInsets.only(
                              left: width * 0.04,
                              right: width * 0.04,
                              bottom: height * 0.04),
                          child: Column(
                            children: [
                              MyInputField(
                                maxLine: 1,
                                title: "자격증 1",
                                hint: "첫번째 자격증을 입력하세요",
                                controller: license1Controller,
                              ),
                              MyInputField(
                                maxLine: 1,
                                title: "자격증 2",
                                hint: "두번째 자격증을 입력하세요",
                                controller: license2Controller,
                              ),
                              MyInputField(
                                maxLine: 1,
                                title: "자격증 3",
                                hint: "세번째 자격증을 입력하세요",
                                controller: license3Controller,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }).then((value) => setState(() {}));
  }

  void mbtiSheet(
      MyProfileDetail profile, double width, double height, int userIdx) {
    var selectedMBTI = profile.userMbti;

    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              child: Wrap(
                children: [
                  Column(
                    children: [
                      BottomSheetTopBar(
                          title: "MBTI 변경",
                          onPressed: () async {
                            await togetherPostAPI(
                              "/user/edit_detail_profile",
                              jsonEncode(
                                {
                                  "user_idx": userIdx,
                                  "flag": 'mbti',
                                  "value": mbtiList.indexOf(selectedMBTI) + 1
                                },
                              ),
                            );
                            setState(() {
                              profile.userMbti = selectedMBTI;
                            });
                            Navigator.of(context).pop();
                          }),
                      Container(
                        padding: EdgeInsets.only(
                            left: width * 0.08,
                            right: width * 0.08,
                            top: height * 0.02,
                            bottom: height * 0.02),
                        child: MyInputField(
                          title: "MBTI",
                          hint: selectedMBTI,
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: DropdownButton(
                              dropdownColor: Colors.blueGrey,
                              underline: Container(),
                              value: profile.userMbti,
                              items: mbtiList.map((value) {
                                return DropdownMenuItem(
                                    value: value,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(value,
                                          style: editSubTitleStyle.copyWith(
                                              color: Colors.white)),
                                    ));
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedMBTI = value.toString();
                                });
                              },
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            );
          });
        }).then((value) => setState(() {}));
  }

  logOutFunction() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('idx');
    prefs.remove('name');
    prefs.remove('photo');
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => SignInPage()));
  }

  _appBar(BuildContext context, IconData icon) {
    return AppBar(
      backgroundColor: Color(0xffD0EBFF),
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MainPage()));
        },
        icon: Icon(Icons.home_outlined, color: Colors.grey),
      ),
      actions: [
        IconButton(
          onPressed: () {
            logOutFunction();
          },
          icon: Icon(icon, color: Colors.grey),
        ),
      ],
    );
  }
}
