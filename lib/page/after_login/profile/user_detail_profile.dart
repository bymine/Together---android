import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown.dart';
import 'package:flutter_countdown_timer/countdown_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together_android/componet/bottom_sheet_top_bar.dart';
import 'package:together_android/componet/textfield_widget.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/hobby_model.dart';
import 'package:together_android/model/after_login_model/invitaion_model.dart';
import 'package:together_android/model/after_login_model/my_profile_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
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
  // TextEditingController ee = TextEditingController();
  TextEditingController nickNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController emailAuthController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController phoneAuthController = TextEditingController();
  TextEditingController license1Controller = TextEditingController();
  TextEditingController license2Controller = TextEditingController();
  TextEditingController license3Controller = TextEditingController();

  final nickNameFormkey = GlobalKey<FormState>();
  final phoneFormKey = GlobalKey<FormState>();
  final emailFormKey = GlobalKey<FormState>();
  final licenseFormKey = GlobalKey<FormState>();

  String emailFlag = "";
  String phoneFlag = "";
  String nickNameFlag = "";

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

  String selectedCategory = "운동";
  String selectedTag = "축구";

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
      appBar: AppBar(
          title: Text(
            "My Profile",
          ),
          actions: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue.withOpacity(0.4)),
              child: IconButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.remove('idx');
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => SignInPage()));
                  },
                  icon: Icon(
                    Icons.power_settings_new,
                    color: Colors.blue,
                    size: 32,
                  )),
            ),
          ]),
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
                    padding: EdgeInsets.symmetric(
                        vertical: height * 0.05, horizontal: width * 0.05),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: width * 0.05, horizontal: width * 0.05),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ]),
                          width: width,
                          height: height * 0.4,
                          child: pickedFile == null
                              ? Container(
                                  margin: EdgeInsets.only(right: width * 0.02),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        width: 3, color: Colors.grey),
                                    shape: BoxShape.rectangle,
                                    image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: NetworkImage(profile.userPhoto)),
                                  ),
                                )
                              : Container(
                                  margin: EdgeInsets.only(right: width * 0.02),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        width: 3, color: Colors.grey),
                                    shape: BoxShape.rectangle,
                                    image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: FileImage(_image)),
                                  ),
                                ),
                        ),
                        SizedBox(
                          height: height * 0.03,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: width * 0.05, horizontal: width * 0.05),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ]),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.pink.withOpacity(0.4)),
                                child: IconButton(
                                    onPressed: changePhoto,
                                    icon: Icon(
                                      Icons.camera_alt,
                                      color: Colors.pink,
                                      size: 32,
                                    )),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.orange.withOpacity(0.4)),
                                child: IconButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PrivateSchedulePage()));
                                    },
                                    icon: Icon(
                                      Icons.today,
                                      color: Colors.orange,
                                      size: 32,
                                    )),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.red.withOpacity(0.4)),
                                child: IconButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  UserInviationPage(
                                                      invitaion: invitaions)))
                                          .then((value) {
                                        if (value != null) {
                                          setState(() {
                                            invitaions =
                                                value as List<Invitaion>;
                                            print(invitaions.length);
                                          });
                                        }
                                      });
                                    },
                                    icon: Icon(
                                      invitaions.length == 0
                                          ? Icons.local_post_office_outlined
                                          : Icons.mark_email_unread_outlined,
                                      color: Colors.red,
                                      size: 32,
                                    )),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.blue.withOpacity(0.4)),
                                child: IconButton(
                                    onPressed: () async {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.setString('email', "");
                                      prefs.setString('pw', "");
                                      prefs.setInt('idx', 0);

                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SignInPage()));
                                    },
                                    icon: Icon(
                                      Icons.power_settings_new,
                                      color: Colors.blue,
                                      size: 32,
                                    )),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: height * 0.03,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: width * 0.05, horizontal: width * 0.05),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ]),
                          child: Column(
                            children: [
                              Container(
                                child: Card(
                                  child: ListTile(
                                    leading: Icon(Icons.person),
                                    title: Text(
                                      "이름",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      profile.userName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              buildProfileEditForm(Icons.face_outlined,
                                  profile.userNickName, "닉네임", () {
                                nickNameController.text = profile.userNickName;
                                nickNameFlag = "not check";
                                showNickNameSheet(profile);
                              }),
                              buildProfileEditForm(
                                  Icons.email, profile.userEmail, "이메일", () {
                                emailController.text = profile.userEmail;
                                emailAuthController.text = "";
                                emailFlag = "";
                                emailAuthFlag.value = "";
                                showEmailSheet(profile);
                              }),
                              buildProfileEditForm(
                                  Icons.phone, profile.userPhone, "휴대전화", () {
                                phoneController.text =
                                    toPhoneString(profile.userPhone);
                                phoneAuthController.text = "";
                                emailFlag = "";
                                emailAuthFlag.value = "";
                                showPhoneSheet(profile);
                              }),
                              buildProfileEditForm(Icons.calendar_today,
                                  profile.userBirth, "생년월일", () {
                                showBirthSheet(profile);
                              }),
                              buildProfileEditForm(
                                  Icons.book,
                                  licenseToString(profile.license1,
                                      profile.license2, profile.license3),
                                  "자격증", () {
                                license1Controller.text = profile.license1;
                                license2Controller.text = profile.license2;
                                license3Controller.text = profile.license3;
                                showLicenseSheet(profile);
                              }),
                              buildProfileEditForm(
                                  Icons.psychology, profile.userMbti, "MBTI",
                                  () {
                                showMbtiSheet(profile);
                              }),
                              buildProfileEditForm(Icons.location_city,
                                  profile.postNum, "주소", () {}),
                              buildHobbyForm(profile: profile),
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

  Widget buildHobbyForm({required MyProfileDetail profile}) => Container(
        child: Card(
          child: ListTile(
              leading: Icon(Icons.star),
              title: Text(
                "관심사",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Container(
                child: Wrap(
                  spacing: 0.5,
                  children: profile.userHobby.map((hobby) {
                    return Chip(
                      label: Text(hobby),
                      labelStyle: TextStyle(fontSize: 16),
                      backgroundColor: titleColor,
                      deleteIconColor: Colors.red[300],
                      onDeleted: () async {
                        int userHobby = profile.userHobby.indexOf(hobby);
                        int userHobbyIdx = profile.userHobbyIdx[userHobby];

                        await togetherGetAPI("/user/delete_hobby",
                            "?user_hobby_idxes=$userHobbyIdx");
                        setState(() {
                          profile.userHobby.remove(hobby);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              trailing: TextButton(
                  onPressed: () async {
                    await togetherGetAPI("/user/edit_hobby", "").then((value) {
                      setState(() {
                        value as List<FetchHobby>;
                        hobbyList = value;
                      });
                    });

                    List<String> fetchCategoryName = [];
                    List<String> fetchTagName = [];
                    List<String> fetchCategoryIdx = [];
                    List<String> fetchTagIdx = [];

                    Map mappingIdx = Map<String, String>();
                    Map mappingName = Map<String, String>();

                    hobbyList.forEach((element) {
                      if (fetchCategoryName
                              .contains(element.hobbyName.keys.first) ==
                          false) {
                        fetchCategoryName.add(element.hobbyName.keys.first);
                        fetchCategoryIdx.add(element.hobbyIdx.keys.first);
                      }
                      if (fetchTagName
                              .contains(element.hobbyName.values.first) ==
                          false) {
                        fetchTagName.add(element.hobbyName.values.first);
                        fetchTagIdx.add(element.hobbyIdx.values.first);
                      }

                      element.hobbyIdx.forEach((key, value) {
                        mappingIdx[value] = key;
                      });

                      element.hobbyName.forEach((key, value) {
                        mappingName[value] = key;
                      });
                    });

                    if (fetchCategoryName.contains("기타") == false) {
                      fetchCategoryIdx.insert(fetchCategoryIdx.length, "0");
                      fetchCategoryName.insert(fetchCategoryName.length, "기타");
                    }

                    Map mappingCategory = Map<String, String>();
                    Map mappingTag = Map<String, String>();

                    fetchCategoryIdx.forEach((element) {
                      var index = fetchCategoryIdx.indexOf(element);

                      mappingCategory[fetchCategoryIdx[index]] =
                          fetchCategoryName[index];
                    });

                    fetchTagIdx.forEach((element) {
                      var index = fetchTagIdx.indexOf(element);

                      mappingTag[fetchTagIdx[index]] = fetchTagName[index];
                    });

                    print(mappingCategory);
                    print(mappingTag);

                    selectedCategory = fetchCategoryName[0];

                    if (profile.userHobby.length >= 4) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("관심사는 최대 4개까지 설정할수 있습니다.")));
                    } else {
                      showModalBottomSheet(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16))),
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            double width = MediaQuery.of(context).size.width;

                            return SingleChildScrollView(
                              child:
                                  StatefulBuilder(builder: (context, setState) {
                                return Padding(
                                  padding: MediaQuery.of(context).viewInsets,
                                  child: Container(
                                    child: Column(
                                      children: [
                                        BottomSheetTopBar(
                                            title: "관심사 변경",
                                            onPressed: () async {
                                              // var userIdx =
                                              //     Provider.of<SignInModel>(
                                              //             context,
                                              //             listen: false)
                                              //         .userIdx;

                                              //Navigator.of(context).pop();
                                            }),
                                        Container(
                                          padding: EdgeInsets.all(width * 0.02),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Column(
                                                children: [
                                                  Text("카테고리 선택",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize:
                                                              width * 0.048)),
                                                  DropdownButton(
                                                    value: selectedTag,
                                                    items: fetchCategoryName
                                                        .map((value) {
                                                      print(value);
                                                      return DropdownMenuItem(
                                                          // value: value,
                                                          child: Text(value));
                                                    }).toList(),
                                                  )
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Text("태그 선택",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize:
                                                              width * 0.048)),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            );
                          });
                    }
                  },
                  child: Text("Edit"))),
        ),
      );

  void showNickNameSheet(MyProfileDetail profile) {
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
                  child: Form(
                    key: nickNameFormkey,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: width * 0.02,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          BottomSheetTopBar(
                              title: "닉네임 변경",
                              onPressed: () async {
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
                              }),
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: width * 0.04,
                            ),
                            // decoration: BoxDecoration(
                            //     border: Border(
                            //         bottom: BorderSide(
                            //             width: 1, color: Colors.grey))),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  width: width * 0.6,
                                  child: TextFormField(
                                    controller: nickNameController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        nickNameFlag = "not check";
                                      });
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty)
                                        return "사용할 닉네임을 입력해 주세요.";
                                      if (value == profile.userNickName)
                                        return "현재 내가 사용중인 닉네임으로\n변경할 수 없습니다.";
                                      if (nickNameFlag == "duplication")
                                        return "사용중인 닉네임 입니다.\n닉네임을 다시 입력하세요";
                                      if (nickNameFlag == "length_error")
                                        return "닉네임은 2 ~ 10자리로 입력하세여";
                                      if (nickNameFlag == "not_nickname")
                                        return "닉네임 형식을 다시 확인해 주세요.";
                                      if (nickNameFlag == "not check")
                                        return null;
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                  ),
                                ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: titleColor),
                                    onPressed: () async {
                                      if (nickNameFormkey.currentState!
                                          .validate()) {
                                        var code = await togetherGetAPI(
                                            "/user/validationNickname",
                                            "?user_nickname=${nickNameController.text}");
                                        print(code);
                                        setState(() {
                                          nickNameFlag = code.toString();
                                        });
                                      }
                                    },
                                    child: Text("중복확인"))
                              ],
                            ),
                          ),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 500),
                            opacity: nickNameFlag == "permit" ? 1.0 : 0.0,
                            child: Text("사용할수 있는 닉네임 입니다.",
                                textAlign: TextAlign.start,
                                style: TextStyle(color: Colors.blueAccent)),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }).then((value) => setState(() {
          nickNameController.clear();
        }));
  }

  void showEmailSheet(MyProfileDetail profile) {
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
                            title: "이메일 변경",
                            onPressed: () async {
                              if (emailFormKey.currentState!.validate() &&
                                  emailFlag == "permit" &&
                                  emailAuthFlag.value == "permit") {
                                var userIdx = Provider.of<SignInModel>(context,
                                        listen: false)
                                    .userIdx;

                                await togetherPostAPI(
                                  "/user/editEmailPhone",
                                  jsonEncode(
                                    {
                                      "user_idx": userIdx,
                                      "value": emailController.text,
                                      "type": "E",
                                      "code": "true"
                                    },
                                  ),
                                );
                                setState(() {
                                  profile.userEmail = emailController.text;
                                });
                                Navigator.of(context).pop();
                              }
                            }),
                        Form(
                          key: emailFormKey,
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
                                    controller: emailController,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        hintText: "이메일",
                                        prefixIcon: Icon(Icons.email_outlined)),
                                    onChanged: (value) {
                                      setState(() {
                                        emailFlag = "not check";
                                        emailAuthFlag.value = "not yet auth";
                                      });
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty)
                                        return "사용할 이메일을 입력해 주세요.";
                                      if (value == profile.userEmail)
                                        return "현재 내가 사용중인 Email로는\n변경할 수 없습니다.";
                                      if (emailFlag == "duplication")
                                        return "사용중인 이메일 입니다.\n이메일을 다시 입력하세요";
                                      if (emailFlag == "not_email")
                                        return "이메일 형식을 다시 확인해 주세요.";
                                      if (emailFlag == "not check") return null;
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: titleColor),
                                  onPressed: () async {
                                    if (emailFormKey.currentState!.validate()) {
                                      var userIdx = Provider.of<SignInModel>(
                                              context,
                                              listen: false)
                                          .userIdx;

                                      if (codeController.isRunning)
                                        codeController.stop();
                                      emailFlag = "";
                                      emailAuthController.clear();
                                      emailAuthFlag.value = "not yet";

                                      var code = await togetherPostAPI(
                                        "/user/validationEditEmail",
                                        jsonEncode(
                                          {
                                            "user_idx": userIdx,
                                            "user_email": emailController.text,
                                          },
                                        ),
                                      );
                                      print(code);
                                      setState(() {
                                        emailFlag = code.toString();
                                      });
                                      if (emailFlag == "permit") {
                                        print("카운트 시작");
                                        codeController = CountdownController(
                                            duration: Duration(seconds: 90),
                                            onEnd: () {
                                              emailAuthFlag.value = "time over";
                                            });
                                        codeController.start();
                                      }
                                    }
                                  },
                                  child: Text(emailFlag != "permit"
                                      ? "인증번호 요청"
                                      : emailAuthFlag.value == "permit"
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
                              visible: emailFlag == "permit" &&
                                  emailAuthFlag.value != "permit",
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
                                        controller: emailAuthController,
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
                                          if (emailAuthFlag.value == "error")
                                            return "인증번호가 다시 한번 확인 후 입력해 주세요";
                                          if (emailAuthFlag.value ==
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

                                              var code = await togetherGetAPI(
                                                  "/user/checkDeviceValidation",
                                                  "?validation_code=${emailAuthController.text}&code_type=E&user_device=${emailController.text}");
                                              print(code);
                                              emailAuthFlag.value = code;
                                              if (emailAuthFlag.value ==
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
                          valueListenable: emailAuthFlag,
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

  void showBirthSheet(MyProfileDetail profile) {
    String year = profile.userBirth.split('-').first;
    String month = profile.userBirth.split('-').last.split('-').first;
    String day = profile.userBirth.split('-').last.split('-').last;

    DateTime initalDate =
        DateTime(int.parse(year), int.parse(month), int.parse(day));

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
                    padding: EdgeInsets.symmetric(
                      vertical: width * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        BottomSheetTopBar(
                            title: "생일 변경",
                            onPressed: () async {
                              var userIdx = Provider.of<SignInModel>(context,
                                      listen: false)
                                  .userIdx;

                              await togetherPostAPI(
                                "/user/edit_detail_profile",
                                jsonEncode(
                                  {
                                    "user_idx": userIdx,
                                    "flag": 'birth',
                                    "value": initalDate
                                        .toIso8601String()
                                        .substring(0, 10)
                                  },
                                ),
                              );
                              setState(() {
                                profile.userBirth = initalDate
                                    .toIso8601String()
                                    .substring(0, 10);
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
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }).then((value) => setState(() {}));
  }

  void showLicenseSheet(MyProfileDetail profile) {
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
                          margin: EdgeInsets.symmetric(
                              vertical: width * 0.01, horizontal: width * 0.04),
                          child: TextFormFieldWidget(
                              header: Text("자격증 1"),
                              body: Container(
                                width: width * 0.8,
                                child: TextFormField(
                                  controller: license1Controller,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              footer: null,
                              heightPadding: 0),
                        ),
                        Divider(color: Colors.grey),
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: width * 0.01, horizontal: width * 0.04),
                          child: TextFormFieldWidget(
                              header: Text("자격증 2"),
                              body: Container(
                                width: width * 0.8,
                                child: TextFormField(
                                  controller: license2Controller,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              footer: null,
                              heightPadding: 0),
                        ),
                        Divider(color: Colors.grey),
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: width * 0.01, horizontal: width * 0.04),
                          child: TextFormFieldWidget(
                              header: Text("자격증 3"),
                              body: Container(
                                width: width * 0.8,
                                child: TextFormField(
                                  controller: license3Controller,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              footer: null,
                              heightPadding: 0),
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

  void showMbtiSheet(MyProfileDetail profile) {
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
                return Container(
                  padding: EdgeInsets.symmetric(
                    vertical: width * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                      GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 4,
                          children: mbtiList.map((mbti) {
                            int index = mbtiList.indexOf(mbti);

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  profile.userMbti = mbti;
                                });
                              },
                              child: Container(
                                child: Card(
                                  color: profile.userMbti == mbti
                                      ? titleColor
                                      : Colors.grey[100],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        mbti,
                                        style: TextStyle(
                                            fontWeight: profile.userMbti == mbti
                                                ? FontWeight.bold
                                                : FontWeight.normal),
                                      ),
                                      Text(
                                        mbtiType[index],
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontWeight: profile.userMbti == mbti
                                                ? FontWeight.bold
                                                : FontWeight.normal),
                                      ),
                                      Text(
                                        mbtiType2[index],
                                        style: TextStyle(
                                            fontWeight: profile.userMbti == mbti
                                                ? FontWeight.bold
                                                : FontWeight.normal),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList())
                    ],
                  ),
                );
              },
            ),
          );
        }).then((value) => setState(() {}));
  }

  Widget buildProfileEditForm(
          IconData data, String title, String name, VoidCallback onPressed) =>
      Container(
        child: Card(
          child: ListTile(
            leading: Icon(data),
            title: Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: TextButton(onPressed: onPressed, child: Text("Edit")),
          ),
        ),
      );
}
