import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown.dart';
import 'package:flutter_countdown_timer/countdown_controller.dart';
import 'package:together_android/componet/input_field.dart';
import 'package:together_android/componet/showDialog.dart';
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
  TextEditingController findPhoneController = TextEditingController();
  TextEditingController findNameController = TextEditingController();

  TextEditingController changePwController1 = TextEditingController();
  TextEditingController changePwController2 = TextEditingController();

  final findEmailKey = GlobalKey<FormState>();
  final findPwKey = GlobalKey<FormState>();
  final changePwKey = GlobalKey<FormState>();
  String findPhoneFlag = "not yet";
  String changePw = "";

  ValueNotifier<String> findCode = ValueNotifier<String>("not yet");

  bool isHidePw1 = true;
  bool isHidePw2 = true;

  CountdownController emailTimerCodeController =
      CountdownController(duration: Duration(seconds: 180), onEnd: () {});
  CountdownController pwTimerCodeController =
      CountdownController(duration: Duration(seconds: 180), onEnd: () {});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: _appBar(context),
      body: Form(
        key: widget.type == "pw" ? findPwKey : findEmailKey,
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    findTypeContianer(width, height, "email"),
                    findTypeContianer(width, height, "pw"),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(
                      left: width * 0.08,
                      right: width * 0.08,
                      bottom: height * 0.02),
                  child: Column(
                    children: [
                      MyInputField(
                        title: "Name",
                        controller: findNameController,
                        hint: "",
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
                      Visibility(
                        visible: widget.type == "pw",
                        child: MyInputField(
                          title: "Email",
                          hint: "toghet@naver.com",
                          controller: findEmailController,
                          type: TextInputType.emailAddress,
                        ),
                      ),
                      MyInputField(
                          title: "Phone",
                          hint: "-없이 입력하세요",
                          type: TextInputType.number,
                          controller: findPhoneController,
                          onChanged: (value) {
                            setState(() {
                              findPhoneFlag = "changed";
                              findCode.value = "not yet";
                            });
                            if (widget.type == "email") {
                              emailTimerCodeController.stop();
                            } else
                              pwTimerCodeController.stop();
                          },
                          validator: (value) {
                            if (value!.isEmpty)
                              return "휴대전화 번호를 입력하세여";
                            else if (findPhoneController.text == "changed")
                              return "인증번호 받기 버튼을 눌러주세요";
                          },
                          titleButton: ElevatedButton(
                            onPressed: () async {
                              findEmailProcedure(width, height);
                              findPwProcedure(width, height);
                            },
                            style: elevatedStyle,
                            child: Text(findPhoneFlag != "success"
                                ? "인증번호 받기"
                                : findCode.value == "permit"
                                    ? "인증 완료"
                                    : "재전송"),
                          ),
                          auth: authPhoneField(
                              width, context, findPhoneFlag, findCode.value)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  findPwProcedure(double width, double height) async {
    if (widget.type == "pw") {
      print(findEmailController.text);
      if (findPwKey.currentState!.validate()) {
        var code = await togetherPostAPI(
            '/user/checkInfoForChangePw',
            jsonEncode({
              "user_name": findNameController.text,
              "user_email": findEmailController.text,
              "user_phone": phoneNumerFormat(findPhoneController.text)
            }));
        setState(() {
          findPhoneFlag = code;
        });

        if (findPhoneFlag == "fail") {
          showAlertDialog(
              context, Text("비밀번호 찾기 실패"), Text("입력하신 정보가 올바르지 않습니다"), []);
        } else {
          pwTimerCodeController = CountdownController(
              duration: Duration(seconds: 90), onEnd: () {});
          pwTimerCodeController.start();
        }
      }
    }
  }

  findEmailProcedure(double width, double height) async {
    if (widget.type == "email") {
      if (findEmailKey.currentState!.validate()) {
        var code = await togetherPostAPI(
            '/user/checkInfoForFindId',
            jsonEncode({
              "user_name": findNameController.text,
              "user_phone": phoneNumerFormat(findPhoneController.text)
            }));
        setState(() {
          findPhoneFlag = code;
          print(findPhoneFlag);
        });
        if (findPhoneFlag == "fail") {
          showAlertDialog(
              context,
              null,
              Container(
                height: height * 0.2,
                child: Wrap(
                  children: [
                    Text("입력하신 정보가 올바르지 않습니다",
                        style: TextStyle(fontSize: width * 0.048)),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Divider(),
                  ],
                ),
              ),
              [
                Center(
                  child: TextButton(
                      style: TextButton.styleFrom(primary: Colors.black),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("확인",
                          style: TextStyle(fontSize: width * 0.048))),
                )
              ]);
        } else {
          emailTimerCodeController = CountdownController(
              duration: Duration(seconds: 90), onEnd: () {});

          emailTimerCodeController.start();
        }
      }
    }
  }

  codeCheckForEmail() async {
    if (widget.type == "email") {
      if (findCode.value == "permit") {
        if (emailTimerCodeController.isRunning) emailTimerCodeController.stop();

        String founEmail = await togetherPostAPI(
            '/user/findUserId',
            jsonEncode({
              "user_name": findNameController.text,
              "user_email": findEmailController.text,
              "user_phone": phoneNumerFormat(findPhoneController.text)
            }));
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => SearchResultPage(
                name: findNameController.text, email: founEmail)));
      } else if (findCode.value == "fail") {
        showAlertDialog(
            context, Text("이메일 찾기 실패"), Text("입력하신 코드가 올바르지 않습니다"), []);
      } else {
        showAlertDialog(context, Text("이메일 찾기 실패"), Text("인증과정을 진행하세요"), []);
      }
    }
  }

  changePwFunction() async {
    var code = await togetherPostAPI(
        '/user/changePw',
        jsonEncode({
          "user_name": findNameController.text,
          "user_email": findEmailController.text,
          "user_phone": phoneNumerFormat(findPhoneController.text),
          "user_pw": changePwController1.text,
          "user_pw2": changePwController2.text
        }));
    if (code.toString() == "success") {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SignInPage()));
    }
  }

  codeCheckForPw() async {
    if (widget.type == "pw") {
      if (findCode.value == "permit") {
        if (pwTimerCodeController.isRunning) {
          pwTimerCodeController.stop();
          showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              isScrollControlled: true,
              builder: (context) {
                return SingleChildScrollView(
                  child: StatefulBuilder(builder: (context, setState) {
                    return Padding(
                      padding: MediaQuery.of(context).viewInsets,
                      child: Form(
                        key: changePwKey,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              MyInputField(
                                  title: "Password",
                                  hint: "",
                                  controller: changePwController1,
                                  isHidePw: isHidePw1,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isHidePw1 = !isHidePw1;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "비밀번호를 입력하세요";
                                    }
                                  }),
                              MyInputField(
                                  title: "Re Password",
                                  hint: "",
                                  isHidePw: isHidePw2,
                                  controller: changePwController2,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isHidePw2 = !isHidePw2;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "비밀번호를 입력하세요";
                                    }
                                    if (changePwController1.text !=
                                        changePwController2.text)
                                      return "비밀번호가 일치하지 않습니다.";
                                  }),
                              SizedBox(height: 20),
                              Container(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton(
                                    onPressed: () {
                                      changePwFunction();
                                    },
                                    style: elevatedStyle,
                                    child: Text("변경하기")),
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
          showAlertDialog(
              context, Text("비밀번호 찾기 실패"), Text("입력하신 코드가 올바르지 않습니다"), []);
        } else {
          showAlertDialog(context, Text("비밀번호 찾기 실패"), Text("인증과정을 진행하세요"), []);
        }
      }
    }
  }

  authPhoneField(
      double width, BuildContext context, String value, String authValue) {
    return Visibility(
      visible: value == "success" && authValue != "permit",
      child: Container(
        padding: EdgeInsets.only(top: 10),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: findCodeController,
                keyboardType: TextInputType.number,
                style: editSubTitleStyle,
                validator: (value) {
                  if (value!.isEmpty) return "Code 입력하세요";
                },
                decoration: InputDecoration(
                  hintText: "Code",
                  hintStyle: editSubTitleStyle,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey, width: 1)),
                ),
              ),
            ),
            SizedBox(
              width: width * 0.1,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    var phone = phoneNumerFormat(findPhoneController.text);

                    var code = await togetherGetAPI(
                        '/user/checkDeviceValidation',
                        "?validation_code=${findCodeController.text}&code_type=P&user_device=$phone");

                    findCode.value = code.toString();

                    codeCheckForEmail();
                    codeCheckForPw();
                    setState(() {});
                  },
                  style: elevatedStyle,
                  child: Text("인증 확인"),
                ),
                Visibility(
                  visible: widget.type == "email"
                      ? emailTimerCodeController.isRunning
                      : pwTimerCodeController.isRunning,
                  child: Countdown(
                    countdownController: widget.type == "email"
                        ? emailTimerCodeController
                        : pwTimerCodeController,
                    builder: (_, Duration time) {
                      return Text(durationFormatTime(time));
                    },
                  ),
                ),
              ],
            )
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
            if (type != "email")
              setState(() {
                widget.type = "pw";
              });
          } else {
            if (type != "pw")
              setState(() {
                widget.type = "email";
              });
          }

          findPhoneFlag = "not yet";

          findCodeController.clear();
          findEmailController.clear();
          findNameController.clear();
          findPhoneController.clear();
        });
      },
      child: Container(
          color: widget.type == type ? titleColor : Colors.grey[200],
          width: width * 0.5,
          height: height * 0.08,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              type == "email" ? "Find Email" : "Find Password",
              style: headingStyle.copyWith(
                  fontSize: widget.type == type ? 20 : 14),
              textAlign: TextAlign.center,
            ),
          )),
    );
  }

  AppBar _appBar(BuildContext context) {
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
        Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 2, color: Colors.grey),
            ),
            child: Icon(
              Icons.person,
              color: Colors.grey,
              size: 20,
            )),
        SizedBox(
          width: 20,
        )
      ],
    );
  }
}
