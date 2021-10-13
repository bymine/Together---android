import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
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
import 'package:together_android/componet/input_field.dart';
import 'package:together_android/componet/listTile.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/hobby_model.dart';
import 'package:together_android/model/after_login_model/invitaion_model.dart';
import 'package:together_android/model/after_login_model/my_profile_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/page/after_login/live_project/live_project_page.dart';
import 'package:together_android/page/after_login/main_page.dart';
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
  final AsyncMemoizer _memoizer = AsyncMemoizer();
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
  final licenseFormKey = GlobalKey<FormState>();

  String emailFlag = "";
  String phoneFlag = "";

  String licenseString = "";

  ValueNotifier<String> emailAuthFlag = ValueNotifier<String>("");
  ValueNotifier<String> phoneAuthFlag = ValueNotifier<String>("");

  CountdownController codeController =
      CountdownController(duration: Duration(seconds: 30));

  late File _image;
  Dio dio = new Dio();
  final picker = ImagePicker();
  var pickedFile;

  List<Invitaion> invitaions = [];
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

  String selectedMBTI = "";

  _fetchData() {
    return this._memoizer.runOnce(() async {
      var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;
      return togetherGetAPI("/user/detail_profile", "?user_idx=$userIdx");
    });
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
    _fetchInvitaion().then((value) => setState(() {
          invitaions = value;
        }));

    Future<List<FetchHobby>> future = fetchHobbyData();

    future.then((value) {
      value.forEach((element) {
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
    });
  }

  Future<List<FetchHobby>> fetchHobbyData() async {
    return await togetherGetAPI("/user/edit_hobby", "");
  }

  Future<List<Invitaion>> _fetchInvitaion() async {
    var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;
    var list =
        await togetherGetAPI("/user/invitationList", "?user_idx=$userIdx");

    return list as List<Invitaion>;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: _appBar(context, Icons.logout),
      body: SingleChildScrollView(
        child: FutureBuilder(
            future: _fetchData(),
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  iconButton(
                                      width, 'Photo', Icons.camera_alt_outlined,
                                      () {
                                    changePhoto();
                                  }),
                                  iconButton(width, 'Calendar',
                                      Icons.calendar_today_outlined, () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PrivateSchedulePage()));
                                  }),
                                  iconButton(width, 'Message',
                                      Icons.mail_outline_outlined, () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) =>
                                                UserInviationPage(
                                                    invitaion: invitaions)))
                                        .then((value) {
                                      if (value != null) {
                                        setState(() {
                                          invitaions = value as List<Invitaion>;
                                          print(invitaions.length);
                                        });
                                      }
                                    });
                                  })
                                ],
                              ),
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
                                title: Text('NickName'),
                                subTitle: Text(profile.userNickName),
                                trailing: IconButton(
                                    onPressed: () async {
                                      nickNameController.text =
                                          profile.userNickName;
                                      await nickNameSheet(
                                          width, height, context, profile);
                                    },
                                    icon: Icon(Icons.chevron_right_outlined)),
                              ),
                              MyListTile(
                                leading: CircleAvatar(
                                    backgroundColor: Colors.orange[300],
                                    child: Icon(Icons.email_outlined,
                                        color: Colors.white)),
                                title: Text('Email'),
                                subTitle: Text(profile.userEmail),
                                trailing: IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.chevron_right_outlined)),
                              ),
                              MyListTile(
                                leading: CircleAvatar(
                                    backgroundColor: Colors.blue[300],
                                    child: Icon(Icons.phone_outlined,
                                        color: Colors.white)),
                                title: Text('Phone'),
                                subTitle: Text(profile.userPhone),
                                trailing: IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.chevron_right_outlined)),
                              ),
                              MyListTile(
                                leading: CircleAvatar(
                                    backgroundColor: Colors.brown[300],
                                    child: Icon(Icons.psychology_outlined,
                                        color: Colors.white)),
                                title: Text('MBTI'),
                                subTitle: Text(profile.userMbti),
                                trailing: IconButton(
                                    onPressed: () {
                                      mbtiSheet(profile, width, height);
                                    },
                                    icon: Icon(Icons.chevron_right_outlined)),
                              ),
                              MyListTile(
                                leading: CircleAvatar(
                                    backgroundColor: Colors.green[300],
                                    child: Icon(Icons.celebration_outlined,
                                        color: Colors.white)),
                                title: Text('Birth'),
                                subTitle: Text(profile.userBirth),
                                trailing: IconButton(
                                    onPressed: () {
                                      birthSheet(
                                          width, height, context, profile);
                                    },
                                    icon: Icon(Icons.chevron_right_outlined)),
                              ),
                              MyListTile(
                                leading: CircleAvatar(
                                    backgroundColor: Colors.grey[300],
                                    child: Icon(Icons.location_city_outlined,
                                        color: Colors.white)),
                                title: Text('Address'),
                                subTitle: Text(addressToString(
                                    true,
                                    profile.mainAddr,
                                    profile.referenceAddr,
                                    profile.detailAddr)),
                                trailing: IconButton(
                                    onPressed: () async {
                                      var userIdx = Provider.of<SignInModel>(
                                              context,
                                              listen: false)
                                          .userIdx;

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
                                title: Text('Certification'),
                                subTitle: Text(
                                  licenseToString(profile.license1,
                                      profile.license2, profile.license3),
                                ),
                                trailing: IconButton(
                                    onPressed: () {
                                      license1Controller.text =
                                          profile.license1;
                                      license2Controller.text =
                                          profile.license2;
                                      license3Controller.text =
                                          profile.license3;
                                      licenseSheet(profile);
                                    },
                                    icon: Icon(Icons.chevron_right_outlined)),
                              ),
                              MyListTile(
                                leading: CircleAvatar(
                                    backgroundColor: Colors.red[300],
                                    child:
                                        Icon(Icons.tag, color: Colors.white)),
                                title: Text(
                                    'Hobby (${profile.userHobby.length}/4)'),
                                subTitle: Container(
                                  child: Wrap(
                                    spacing: 0.5,
                                    children: profile.userHobby.map((hobby) {
                                      return Chip(
                                        label: Text(hobby),
                                        labelStyle: TextStyle(fontSize: 16),
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
                                      containTag = [];
                                      mappingName.keys.forEach((element) {
                                        if (mappingName[element] ==
                                            selectedCategory)
                                          containTag.add(element);
                                      });
                                      containTag.insert(
                                          containTag.length, '기타');

                                      selectedTag = containTag[0];
                                      if (profile.userHobby.length >= 4) {
                                        GET.Get.snackbar(
                                          "Add Hobby Failed",
                                          "You can register up to 4",
                                          margin: EdgeInsets.only(bottom: 50),
                                          icon: Icon(
                                            Icons.warning,
                                            color: Colors.red,
                                          ),
                                          snackPosition:
                                              GET.SnackPosition.BOTTOM,
                                        );
                                      } else {
                                        tagSheet(
                                                context, width, height, profile)
                                            .then((value) => setState(() {}));
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

  jusoToFormat(Juso juso, MyProfileDetail profile) {
    profile.mainAddr = mainAdressFormat(juso.sido);

    profile.referenceAddr = juso.sigungu;
    profile.detailAddr = juso.address.split(juso.sigungu).last;
    profile.postNum = juso.zonecode;

    print("detail_addr: " + juso.sido);
    print("reference_addr: " + juso.sigungu);
    print("main_addr: " + juso.address.split(juso.sigungu).last);
  }

  tagSheet(BuildContext context, double width, double height,
      MyProfileDetail profile) {
    return showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16))),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  padding: EdgeInsets.only(
                      left: width * 0.08,
                      right: width * 0.08,
                      top: height * 0.02,
                      bottom: height * 0.02),
                  child: Wrap(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Add Hobby",
                                style: headingStyle,
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    var bigIdx;
                                    var smallIdx;
                                    var bigName;
                                    var smallName;
                                    var userIdx = Provider.of<SignInModel>(
                                            context,
                                            listen: false)
                                        .userIdx;

                                    if (selectedCategory == "기타") {
                                      if (selectedTag == "기타") {
                                        bigIdx = -1;
                                        smallIdx = -1;
                                        bigName = categoryController.text;
                                        smallName = tagController.text;
                                      }
                                    } else {
                                      if (selectedTag == "기타") {
                                        bigIdx =
                                            mappingCategory[selectedCategory];
                                        bigName = selectedCategory;
                                        smallIdx = -1;
                                        smallName = tagController.text;
                                      } else {
                                        bigIdx =
                                            mappingCategory[selectedCategory];
                                        bigName = selectedCategory;
                                        smallIdx = mappingTag[selectedTag];
                                        smallName = selectedTag;
                                      }
                                    }

                                    print(bigIdx);
                                    print(bigName);
                                    print(smallIdx);
                                    print(smallName);
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
                                      if (profile.userHobby
                                              .contains(selectedTag) ==
                                          false)
                                        profile.userHobby.add(selectedTag);
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  style: elevatedStyle,
                                  child: Text("+ Add"))
                            ],
                          ),
                          MyInputField(
                            title: "Select Category",
                            hint: selectedCategory,
                            suffixIcon: DropdownButton(
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
                                          style: editSubTitleStyle.copyWith(
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
                          MyInputField(
                            title: "Select Tag",
                            hint: selectedTag,
                            suffixIcon: DropdownButton(
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
                                          style: editSubTitleStyle.copyWith(
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
                          Visibility(
                              visible: selectedCategory == "기타",
                              child: MyInputField(
                                controller: categoryController,
                                title: "Category",
                                hint: "Input Category",
                              )),
                          Visibility(
                              visible: selectedCategory == "기타" ||
                                  selectedTag == "기타",
                              child: MyInputField(
                                controller: tagController,
                                title: "Tag",
                                hint: "Input Tag",
                              )),
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

  birthSheet(double width, double height, BuildContext context,
      MyProfileDetail profile) {
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
                var userIdx =
                    Provider.of<SignInModel>(context, listen: false).userIdx;

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
    GET.Get.bottomSheet(Wrap(
      children: [
        Form(
          key: nickNameFormkey,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                      left: width * 0.04,
                      right: width * 0.04,
                      bottom: height * 0.04),
                  child: MyInputField(
                    title: "Nickname",
                    hint: "Input Nickname",
                    controller: nickNameController,
                    titleButton: ElevatedButton(
                        onPressed: () async {
                          if (nickNameFormkey.currentState!.validate()) {
                            await togetherGetAPI("/user/validationNickname",
                                    "?user_nickname=${nickNameController.text}")
                                .then((value) async {
                              if (value != null)
                                setState(() {
                                  print(nickNameFlag);
                                  nickNameFlag = value.toString();
                                  print(nickNameFlag);
                                  setState(() {});
                                });

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
                            });
                          }
                        },
                        style: elevatedStyle,
                        child: Text(
                          "변경 하기",
                        )),
                    onChanged: (value) {
                      setState(() {
                        nickNameFlag = "not yet";
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) return "사용할 닉네임을 입력해 주세요.";
                      if (value == profile.userNickName)
                        return "현재 내가 사용중인 닉네임으로 변경할 수 없습니다.";
                      else if (nickNameFlag == "duplication")
                        return "사용중인 닉네임 입니다. 닉네임을 다시 입력하세요";
                      else if (nickNameFlag == "length_error")
                        return "닉네임은 2 ~ 10자리로 입력하세여";
                      else if (nickNameFlag == "not_nickname")
                        return "닉네임 형식을 다시 확인해 주세요.";
                      else if (nickNameFlag == "not check") return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    ));
  }

  Row profileHeader(MyProfileDetail profile) {
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
                  'My Profile',
                  style: subHeadingStyle,
                ),
                SizedBox(
                  height: 15,
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

  void showPhoneSheet(MyProfileDetail profile) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16))),
        context: context,
        isScrollControlled: true,
        builder: (context) {
          double width = MediaQuery.of(context).size.width;
          return SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Container(
                    padding: EdgeInsets.only(top: width * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        Form(
                          key: phoneFormKey,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: width * 0.04,
                                horizontal: width * 0.02),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: 1, color: Colors.grey))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: width * 0.6,
                                  child: TextFormField(
                                    controller: phoneController,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        hintText: "휴대전화",
                                        prefixIcon: Icon(Icons.smartphone)),
                                    onChanged: (value) {
                                      setState(() {
                                        phoneFlag = "not check";
                                        phoneAuthFlag.value = "not yet auth";
                                      });
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty)
                                        return "사용할 휴대전화를 입력해 주세요.";
                                      if (value ==
                                          toPhoneString(profile.userPhone))
                                        return "현재 내가 사용중인 휴대전화로는\n변경할 수 없습니다.";
                                      if (phoneFlag == "duplication")
                                        return "사용중인 휴대전화 입니다.\n휴대전화번호를 다시 입력하세요";
                                      if (phoneFlag == "not_phone")
                                        return "휴대전화 형식을 다시 확인해 주세요.";
                                      if (phoneFlag == "not check") return null;
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: titleColor),
                                  onPressed: () async {
                                    if (phoneFormKey.currentState!.validate()) {
                                      var userIdx = Provider.of<SignInModel>(
                                              context,
                                              listen: false)
                                          .userIdx;

                                      if (codeController.isRunning)
                                        codeController.stop();
                                      phoneFlag = "";
                                      phoneAuthController.clear();
                                      phoneAuthFlag.value = "not yet";

                                      var code = await togetherPostAPI(
                                        "/user/validationEditPhone",
                                        jsonEncode(
                                          {
                                            "user_idx": userIdx,
                                            "user_phone": phoneNumerFormat(
                                                phoneController.text),
                                          },
                                        ),
                                      );
                                      print(code);
                                      setState(() {
                                        phoneFlag = code.toString();
                                      });
                                      if (phoneFlag == "permit") {
                                        print("카운트 시작");
                                        codeController = CountdownController(
                                            duration: Duration(seconds: 90),
                                            onEnd: () {
                                              phoneAuthFlag.value = "time over";
                                            });
                                        codeController.start();
                                      }
                                    }
                                  },
                                  child: Text(phoneFlag != "permit"
                                      ? "인증번호 요청"
                                      : phoneAuthFlag.value == "permit"
                                          ? "인증완료"
                                          : "재발송"),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ValueListenableBuilder(
                          builder:
                              (BuildContext context, value, Widget? child) {
                            return Visibility(
                              visible: phoneFlag == "permit" &&
                                  phoneAuthFlag.value != "permit",
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: width * 0.04,
                                    horizontal: width * 0.02),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: width * 0.6,
                                      child: TextFormField(
                                        controller: phoneAuthController,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16)),
                                            hintText: "인증번호",
                                            prefixIcon: Icon(Icons.vpn_key)),
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        validator: (value) {
                                          if (value!.isEmpty)
                                            return "인증번호를 입력하세요";
                                          if (phoneAuthFlag.value == "error")
                                            return "인증번호가 다시 한번 확인 후 입력해 주세요";
                                          if (phoneAuthFlag.value ==
                                              "time over")
                                            return "인증번호 입력 시간이 초과하였습니다.\n다시 시도해 주세요";
                                        },
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                primary: titleColor),
                                            onPressed: () async {
                                              codeController.stop();
                                              var phone = phoneNumerFormat(
                                                  phoneController.text);
                                              var code = await togetherGetAPI(
                                                  "/user/checkDeviceValidation",
                                                  "?validation_code=${phoneAuthController.text}&code_type=P&user_device=$phone");
                                              print(code);
                                              phoneAuthFlag.value = code;
                                              if (phoneAuthFlag.value ==
                                                  "permit") {
                                                if (codeController.isRunning)
                                                  codeController.stop();
                                              } else {
                                                if (codeController.isRunning ==
                                                    false)
                                                  codeController.start();
                                              }
                                            },
                                            child: Text("인증번호 확인")),
                                        Countdown(
                                          countdownController: codeController,
                                          builder: (context, Duration time) {
                                            print("카운트 다운 빌드 실행");
                                            return Text(
                                                durationFormatTime(time));
                                          },
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                          valueListenable: phoneAuthFlag,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }).then((value) => setState(() {
          if (codeController.isRunning) codeController.stop();
        }));
  }

  void licenseSheet(MyProfileDetail profile) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16))),
        context: context,
        isScrollControlled: true,
        builder: (context) {
          double width = MediaQuery.of(context).size.width;
          double height = MediaQuery.of(context).size.height;

          return SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: width * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        BottomSheetTopBar(
                            title: "자격증 변경",
                            onPressed: () async {
                              var userIdx = Provider.of<SignInModel>(context,
                                      listen: false)
                                  .userIdx;
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
                                title: "Certification1",
                                hint: "Input Certification",
                                controller: license1Controller,
                              ),
                              MyInputField(
                                maxLine: 1,
                                title: "Certification2",
                                hint: "Input Certification",
                                controller: license2Controller,
                              ),
                              MyInputField(
                                maxLine: 1,
                                title: "certification3",
                                hint: "Input Certification",
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

  void mbtiSheet(MyProfileDetail profile, double width, double height) {
    selectedMBTI = profile.userMbti;

    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16))),
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
                            var userIdx =
                                Provider.of<SignInModel>(context, listen: false)
                                    .userIdx;

                            await togetherPostAPI(
                              "/user/edit_detail_profile",
                              jsonEncode(
                                {
                                  "user_idx": userIdx,
                                  "flag": 'mbti',
                                  "value":
                                      mbtiList.indexOf(profile.userMbti) + 1
                                },
                              ),
                            );
                            setState(() {});
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
                          hint: profile.userMbti,
                          suffixIcon: DropdownButton(
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
                                profile.userMbti = value.toString();
                              });
                            },
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
