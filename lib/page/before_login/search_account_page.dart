import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown.dart';
import 'package:flutter_countdown_timer/countdown_controller.dart';
import 'package:together_android/componet/showDialog.dart';
import 'package:together_android/componet/textfield_widget.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/page/before_login/search_email_result_page.dart';
import 'package:together_android/page/before_login/sign_in_page.dart';
import 'package:together_android/reg.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

// ignore: must_be_immutable
class SearchAccountPage extends StatefulWidget {
  String type;
  SearchAccountPage({required this.type});

  @override
  _SearchAccountPageState createState() => _SearchAccountPageState();
}

class _SearchAccountPageState extends State<SearchAccountPage> {
  TextEditingController findEmailController = TextEditingController();

  TextEditingController findCodeController = TextEditingController();
  TextEditingController findPhoneController =
      TextEditingController(text: "01011112222");
  TextEditingController findNameController = TextEditingController(text: "김용만");

  TextEditingController changePwController1 = TextEditingController();
  TextEditingController changePwController2 = TextEditingController();

  // TextEditingController findPPhoneController = TextEditingController();
  // TextEditingController findPNameController = TextEditingController();

  final findEmailKey = GlobalKey<FormState>();
  final findPwKey = GlobalKey<FormState>();
  final authEmailKey = GlobalKey<FormState>();
  final authPwKey = GlobalKey<FormState>();
  final changePwKey = GlobalKey<FormState>();
  // String findEmail = "";
  String findPhone = "not yet";
  String changePw = "";

  ValueNotifier<String> findCode = ValueNotifier<String>("not yet");

  bool showNewPw1 = true;
  bool showNewPw2 = true;

  CountdownController emailCodeController =
      CountdownController(duration: Duration(seconds: 30));
  CountdownController pwCodeController =
      CountdownController(duration: Duration(seconds: 30));

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: titleColor,
        centerTitle: true,
        title: Text("이메일/비밀번호 찾기"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                findTypeContianer(width, height, "email"),
                findTypeContianer(width, height, "pw"),
              ],
            ),
            Form(
              key: widget.type == "pw" ? findPwKey : findEmailKey,
              child: Container(
                padding: EdgeInsets.symmetric(
                    vertical:
                        widget.type == "pw" ? height * 0.02 : height * 0.08,
                    horizontal: width * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Form(
                      key: widget.type == "pw" ? authPwKey : authEmailKey,
                      child: Column(
                        children: [
                          TextFormFieldWidget(
                            header: Text("이름"),
                            body: TextFormField(
                              controller: findNameController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  hintText: "이름",
                                  prefixIcon: Icon(
                                    Icons.face_outlined,
                                  )),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "이름을 입력하세요";
                                } else if (value.length < 2 ||
                                    value.length > 10 ||
                                    !regName.hasMatch(value)) {
                                  return "2 ~ 10자리 한글로 이름을 입력하세요";
                                }
                              },
                            ),
                            footer: null,
                            heightPadding: widget.type == "pw"
                                ? height * 0.02
                                : height * 0.08,
                          ),
                          Visibility(
                              visible: widget.type == "pw",
                              child: TextFormFieldWidget(
                                header: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("이메일"),
                                  ],
                                ),
                                body: TextFormField(
                                  controller: findEmailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      hintText: "이메일",
                                      prefixIcon: Icon(Icons.email_outlined)),
                                  validator: (value) {
                                    if (value!.isEmpty) return "이메일을 입력하세여";
                                  },
                                ),
                                footer: null,
                                heightPadding: widget.type == "pw"
                                    ? height * 0.02
                                    : height * 0.08,
                              )),
                          TextFormFieldWidget(
                              header: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("휴대전화"),
                                  ValueListenableBuilder(
                                      valueListenable: findCode,
                                      builder: (context, value, child) {
                                        return ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                primary: titleColor,
                                                shadowColor: titleColor),
                                            onPressed: () async {
                                              if (widget.type != "pw") {
                                                if (authEmailKey.currentState!
                                                    .validate()) {
                                                  // 재발송을 위한 코드
                                                  if (findPhone == "success") {
                                                    findCodeController.clear();
                                                    findCode.value = "not yet";
                                                  }

                                                  var code = await togetherPostAPI(
                                                      '/user/checkInfoForFindId',
                                                      jsonEncode({
                                                        "user_name":
                                                            findNameController
                                                                .text,
                                                        "user_phone":
                                                            phoneNumerFormat(
                                                                findPhoneController
                                                                    .text)
                                                      }));
                                                  print(
                                                      findNameController.text);
                                                  setState(() {
                                                    findPhone = code;
                                                    print(findPhone);
                                                  });

                                                  if (findPhone == "fail") {
                                                    showAlertDialog(
                                                        context,
                                                        null,
                                                        Container(
                                                          height: height * 0.2,
                                                          child: Wrap(
                                                            children: [
                                                              Text(
                                                                  "입력하신 정보가 올바르지 않습니다",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          width *
                                                                              0.048)),
                                                              SizedBox(
                                                                height: height *
                                                                    0.02,
                                                              ),
                                                              Divider(),
                                                            ],
                                                          ),
                                                        ),
                                                        [
                                                          Center(
                                                            child: TextButton(
                                                                style: TextButton
                                                                    .styleFrom(
                                                                        primary:
                                                                            Colors
                                                                                .black),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: Text(
                                                                    "확인",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            width *
                                                                                0.048))),
                                                          )
                                                        ]);
                                                  } else {
                                                    emailCodeController =
                                                        CountdownController(
                                                            duration: Duration(
                                                                seconds: 90),
                                                            onEnd: () {
                                                              findCode.value =
                                                                  "time over";
                                                            });
                                                    emailCodeController.start();
                                                  }
                                                }
                                              } else {
                                                if (authPwKey.currentState!
                                                    .validate()) {
                                                  findCodeController.clear();
                                                  findCode.value = "not yet";

                                                  var code = await togetherPostAPI(
                                                      '/user/checkInfoForChangePw',
                                                      jsonEncode({
                                                        "user_name":
                                                            findNameController
                                                                .text,
                                                        "user_email":
                                                            findEmailController
                                                                .text,
                                                        "user_phone":
                                                            phoneNumerFormat(
                                                                findPhoneController
                                                                    .text)
                                                      }));
                                                  print(code);
                                                  setState(() {
                                                    findPhone = code;
                                                  });
                                                  if (findPhone == "fail") {
                                                    showAlertDialog(
                                                        context,
                                                        Text("비밀번호 찾기 실패"),
                                                        Text(
                                                            "입력하신 정보가 올바르지 않습니다"),
                                                        []);
                                                  } else {
                                                    pwCodeController =
                                                        CountdownController(
                                                            duration: Duration(
                                                                seconds: 90),
                                                            onEnd: () {
                                                              findCode.value =
                                                                  "time over";
                                                            });
                                                    pwCodeController.start();
                                                  }
                                                }
                                              }
                                            },
                                            child: Text(findPhone == "success"
                                                ? "재발송"
                                                : "인증번호 받기"));
                                      })
                                ],
                              ),
                              body: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: findPhoneController,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    hintText: " - 없이 입력하세요",
                                    prefixIcon: Icon(
                                      Icons.smartphone_outlined,
                                    )),
                                onChanged: (value) {
                                  setState(() {
                                    findPhone = "not yet";
                                  });
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "휴대전화번호를 입력하세요";
                                  } else if (value.length < 10 ||
                                      value.length > 11 ||
                                      !regPhone.hasMatch(value)) {
                                    return "10 ~ 11 자리 숫자를 입력하세요";
                                  }
                                },
                              ),
                              footer: null,
                              heightPadding: height * 0.01),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: findPhone == "success",
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ValueListenableBuilder(
                              valueListenable: findCode,
                              builder: (BuildContext context, String value,
                                  Widget? child) {
                                return TextFormField(
                                  controller: findCodeController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      hintText: "인증번호",
                                      prefixIcon: Icon(Icons.vpn_key_outlined)),
                                  onChanged: (value) {},
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (value!.isEmpty) return "인증번호를 입력하세요";
                                    if (findCode.value == "time over") {
                                      print(findCode.value);
                                      return "인증번호 입력 시간이 초과하였습니다.\n다시 시도해 주세요.";
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            width: width * 0.02,
                          ),
                          Visibility(
                            visible: findPhone == "success" &&
                                findCode.value != "permit",
                            child: Countdown(
                              countdownController: widget.type == "email"
                                  ? emailCodeController
                                  : pwCodeController,
                              builder: (context, Duration time) {
                                return Text(durationFormatTime(time));
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * 0.04,
                    ),
                    Visibility(
                      visible: findPhone == "success",
                      child: Container(
                        width: width,
                        height: height * 0.08,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: titleColor,
                            ),
                            onPressed: () async {
                              String phone =
                                  phoneNumerFormat(findPhoneController.text);
                              String authCode = findCodeController.text;
                              if (widget.type != "pw") {
                                if (findEmailKey.currentState!.validate()) {
                                  print("이메일 찾기 버튼 클릭");
                                  // api 연결할것!!!

                                  var code = await togetherGetAPI(
                                      '/user/checkDeviceValidation',
                                      "?validation_code=$authCode&code_type=P&user_device=$phone");

                                  findCode.value =
                                      code.toString(); //서버 repsonse.body 값
                                  print(findCode.value);
                                  if (findCode.value == "permit") {
                                    if (emailCodeController.isRunning) {
                                      emailCodeController.stop();
                                    }
                                    String founEmail = await togetherPostAPI(
                                        '/user/findUserId',
                                        jsonEncode({
                                          "user_name": findNameController.text,
                                          "user_email":
                                              findEmailController.text,
                                          "user_phone": phoneNumerFormat(
                                              findPhoneController.text)
                                        }));
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SearchResultPage(
                                                    name:
                                                        findNameController.text,
                                                    email: founEmail)));
                                  } else if (findCode.value == "fail") {
                                    showAlertDialog(context, Text("이메일 찾기 실패"),
                                        Text("입력하신 코드가 올바르지 않습니다"), []);
                                  } else {
                                    showAlertDialog(context, Text("이메일 찾기 실패"),
                                        Text("인증과정을 진행하세요"), []);
                                  }
                                }
                              } else {
                                if (findPwKey.currentState!.validate()) {
                                  var code = await togetherGetAPI(
                                      '/user/checkDeviceValidation',
                                      "?validation_code=$authCode&code_type=P&user_device=$phone");
                                  findCode.value = code; //서버 repsonse.body 값

                                  if (findCode.value == "permit") {
                                    if (pwCodeController.isRunning) {
                                      pwCodeController.stop();
                                    }
                                    showModalBottomSheet(
                                        context: context,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        isScrollControlled: true,
                                        builder: (context) {
                                          return SingleChildScrollView(
                                            child: StatefulBuilder(
                                                builder: (context, setState) {
                                              return Padding(
                                                padding: MediaQuery.of(context)
                                                    .viewInsets,
                                                child: Form(
                                                  key: changePwKey,
                                                  child: Container(
                                                    padding: EdgeInsets.all(20),
                                                    child: Column(
                                                      children: [
                                                        TextFormFieldWidget(
                                                          header:
                                                              Text("비밀번호 변경"),
                                                          body: TextFormField(
                                                            controller:
                                                                changePwController1,
                                                            obscureText:
                                                                showNewPw1,
                                                            decoration:
                                                                InputDecoration(
                                                                    border: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                16)),
                                                                    hintText:
                                                                        "새 비밀번호 확인",
                                                                    prefixIcon:
                                                                        Icon(
                                                                      Icons
                                                                          .lock_outline,
                                                                    ),
                                                                    suffixIcon:
                                                                        IconButton(
                                                                      icon: Icon(
                                                                          Icons
                                                                              .visibility),
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          showNewPw1 =
                                                                              !showNewPw1;
                                                                        });
                                                                      },
                                                                    )),
                                                            validator: (value) {
                                                              if (value!
                                                                  .isEmpty) {
                                                                return "비밀번호를 입력하세요";
                                                              }
                                                            },
                                                          ),
                                                          footer: null,
                                                          heightPadding: widget
                                                                      .type ==
                                                                  "pw"
                                                              ? height * 0.02
                                                              : height * 0.08,
                                                        ),
                                                        TextFormFieldWidget(
                                                          header: Text(
                                                              "비밀번호 변경 확인"),
                                                          body: TextFormField(
                                                            controller:
                                                                changePwController2,
                                                            obscureText:
                                                                showNewPw2,
                                                            decoration:
                                                                InputDecoration(
                                                                    border: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                16)),
                                                                    hintText:
                                                                        "새 비밀번호 확인",
                                                                    prefixIcon:
                                                                        Icon(
                                                                      Icons
                                                                          .lock_outline,
                                                                    ),
                                                                    suffixIcon:
                                                                        IconButton(
                                                                      icon: Icon(
                                                                          Icons
                                                                              .visibility),
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          showNewPw2 =
                                                                              !showNewPw2;
                                                                        });
                                                                      },
                                                                    )),
                                                            validator: (value) {
                                                              if (value!
                                                                  .isEmpty) {
                                                                return "비밀번호를 입력하세요";
                                                              }
                                                              if (changePwController1
                                                                      .text !=
                                                                  changePwController2
                                                                      .text)
                                                                return "비밀번호가 일치하지 않습니다.";
                                                            },
                                                          ),
                                                          footer: null,
                                                          heightPadding: widget
                                                                      .type ==
                                                                  "pw"
                                                              ? height * 0.02
                                                              : height * 0.08,
                                                        ),
                                                        Container(
                                                          width: width,
                                                          height: height * 0.08,
                                                          child: ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              primary:
                                                                  titleColor,
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              if (changePwKey
                                                                  .currentState!
                                                                  .validate()) {
                                                                var code = await togetherPostAPI(
                                                                    '/user/changePw',
                                                                    jsonEncode({
                                                                      "user_name":
                                                                          findNameController
                                                                              .text,
                                                                      "user_email":
                                                                          findEmailController
                                                                              .text,
                                                                      "user_phone":
                                                                          phoneNumerFormat(
                                                                              findPhoneController.text),
                                                                      "user_pw":
                                                                          changePwController1
                                                                              .text,
                                                                      "user_pw2":
                                                                          changePwController2
                                                                              .text
                                                                    }));
                                                                print(code);
                                                                if (code.toString() ==
                                                                    "success") {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pushReplacement(MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              SignInPage()));
                                                                }
                                                              }
                                                            },
                                                            child:
                                                                Text("비밀번호 변경"),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          );
                                        });
                                  } else if (findCode.value == "fail") {
                                    showAlertDialog(context, Text("비밀번호 찾기 실패"),
                                        Text("입력하신 코드가 올바르지 않습니다"), []);
                                  } else {
                                    showAlertDialog(context, Text("비밀번호 찾기 실패"),
                                        Text("인증과정을 진행하세요"), []);
                                  }
                                }
                              }
                            },
                            child: Text(
                                widget.type == "pw" ? "비밀번호 찾기" : "이메일 찾기")),
                      ),
                    ),
                    Text(findCode.value)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector findTypeContianer(double width, double height, String type) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (widget.type == "email") {
            setState(() {
              widget.type = "pw";
            });
          } else {
            setState(() {
              widget.type = "email";
            });
          }

          findPhone = "";

          findCodeController.clear();
          findEmailController.clear();
          findNameController.clear();
          findPhoneController.clear();
        });
      },
      child: Container(
          color:
              widget.type == type ? Colors.grey.shade300 : Colors.grey.shade500,
          width: width * 0.5,
          height: height * 0.08,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              type == "email" ? "이메일 찾기" : "비밀번호 찾기",
              style: TextStyle(
                  fontSize: widget.type == type ? width * 0.06 : width * 0.04),
              textAlign: TextAlign.center,
            ),
          )),
    );
  }
}
