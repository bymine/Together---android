import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown.dart';
import 'package:flutter_countdown_timer/countdown_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together_android/componet/bottom_sheet_top_bar.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/my_profile_model.dart';
import 'package:together_android/model/sign_in_model.dart';
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

  final nickNameFormkey = GlobalKey<FormState>();
  final phoneFormKey = GlobalKey<FormState>();
  final emailFormKey = GlobalKey<FormState>();
  final licenseFormKey = GlobalKey<FormState>();

  String emailFlag = "";
  String phoneFlag = "";
  String nickNameFlag = "";

  ValueNotifier<String> emailAuthFlag = ValueNotifier<String>("");
  ValueNotifier<String> phoneAuthFlag = ValueNotifier<String>("");

  CountdownController emailCodeController =
      CountdownController(duration: Duration(seconds: 30));

  _fetchData() {
    return this._memoizer.runOnce(() async {
      var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;
      return togetherGetAPI("/user/detail_profile", "?user_idx=$userIdx");
    });
  }
  // _fetchData() {
  //   var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;
  //   return togetherGetAPI("/user/detail_profile", "?user_idx=$userIdx");
  // }

  late File _image;
  Dio dio = new Dio();
  final picker = ImagePicker();
  var pickedFile;
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
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("마이 페이지"),
      ),
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
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.local_post_office_outlined,
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
                              buildProfileEditForm(Icons.phone,
                                  profile.userPhone, "휴대전화", () {}),
                              buildProfileEditForm(Icons.calendar_today,
                                  profile.userBirth, "생년월일", () {}),
                              buildProfileEditForm(
                                  Icons.book, "", "자격증", () {}),
                              buildProfileEditForm(Icons.psychology,
                                  profile.userMbti, "MBTI", () {}),
                              buildProfileEditForm(Icons.location_city,
                                  profile.postNum, "주소", () {}),
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

                                final code = await togetherPostAPI(
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
                                    child: Text("중복검사"))
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

                                final code = await togetherPostAPI(
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

                                      if (emailCodeController.isRunning)
                                        emailCodeController.stop();
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
                                        emailCodeController =
                                            CountdownController(
                                                duration: Duration(seconds: 90),
                                                onEnd: () {
                                                  emailAuthFlag.value =
                                                      "time over";
                                                });
                                        emailCodeController.start();
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
                                              emailCodeController.stop();

                                              var code = await togetherGetAPI(
                                                  "/user/checkDeviceValidation",
                                                  "?validation_code=${emailAuthController.text}&code_type=E&user_device=${emailController.text}");
                                              print(code);
                                              emailAuthFlag.value = code;
                                              if (emailAuthFlag.value ==
                                                  "permit") {
                                                if (emailCodeController
                                                    .isRunning)
                                                  emailCodeController.stop();
                                              } else {
                                                if (emailCodeController
                                                        .isRunning ==
                                                    false)
                                                  emailCodeController.start();
                                              }
                                            },
                                            child: Text("인증번호 확인")),
                                        Countdown(
                                          countdownController:
                                              emailCodeController,
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
                        // ValueListenableBuilder(
                        //   valueListenable: emailAuthFlag,
                        //   builder:
                        //       (BuildContext context, value, Widget? child) {
                        //     return Padding(
                        //       padding: EdgeInsets.symmetric(
                        //           vertical: width * 0.02),
                        //       child: AnimatedOpacity(
                        //         duration: const Duration(milliseconds: 500),
                        //         opacity: emailFlag == "permit"
                        //             ? (emailAuthFlag == "permit")
                        //                 ? 1.0
                        //                 : 1.0
                        //             : 0.0,
                        //         child: Text(
                        //             emailFlag == "permit"
                        //                 ? (emailAuthFlag.value == "permit")
                        //                     ? "사용가능한 이메일 입니다."
                        //                     : "인증번호를 인증하세요"
                        //                 : "",
                        //             textAlign: TextAlign.start,
                        //             style:
                        //                 TextStyle(color: Colors.blueAccent)),
                        //       ),
                        //     );
                        //   },
                        // )
                      ],
                    ),
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
