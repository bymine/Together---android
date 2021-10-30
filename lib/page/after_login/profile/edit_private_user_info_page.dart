import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown.dart';
import 'package:flutter_countdown_timer/countdown_controller.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/componet/input_field.dart';
import 'package:together_android/componet/showDialog.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

// ignore: must_be_immutable
class EditPrivateUserPage extends StatefulWidget {
  String type;
  String value;
  EditPrivateUserPage({Key? key, required this.type, required this.value})
      : super(key: key);

  @override
  _EditPrivateUserPageState createState() => _EditPrivateUserPageState();
}

class _EditPrivateUserPageState extends State<EditPrivateUserPage> {
  TextEditingController infoController = TextEditingController();
  TextEditingController authController = TextEditingController();

  final formkey = GlobalKey<FormState>();
  var code;
  var authCode;
  CountdownController timerController =
      CountdownController(duration: Duration(seconds: 180), onEnd: () {});
  @override
  void initState() {
    super.initState();
    infoController.text = widget.value;
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
              left: width * 0.08,
              right: width * 0.08,
              bottom: height * 0.02,
              top: height * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("개인 정보 수정", style: headingStyle),
              SizedBox(
                height: 30,
              ),
              if (widget.type == "NickName")
                nicknameWidget(user)
              else if (widget.type == "Email")
                emailWidget(width, user, context)
              else if (widget.type == "Phone")
                phoneWidget(width, user, context)
            ],
          ),
        ),
      ),
    );
  }

  phoneWidget(double width, SignInModel user, BuildContext context) {
    return Column(
      children: [
        Form(
          key: formkey,
          child: MyInputField(
            title: "휴대전화 변경",
            hint: "-없이 입력하세요",
            controller: infoController,
            onChanged: (value) {
              setState(() {
                code = "";
                authCode = "";
              });
            },
            validator: (value) {
              if (value!.isEmpty)
                return "휴대전화 번호를 입력하세여";
              else if (value == widget.value)
                return "현재 내가 사용중인 휴대전화 번호 입니다";
              else if (code == "duplication") return "이미 존재하는 휴대전화 입니다";
            },
            titleButton: ElevatedButton(
              onPressed: () async {
                var phone = phoneNumerFormat(infoController.text);

                if (formkey.currentState!.validate()) {
                  code = await togetherGetAPI(
                      "/user/validationPhone", "?user_phone=$phone");
                  setState(() {});
                  print(code);
                  if (code == "permit") {
                    authController.clear();
                    authCode = "";
                    timerController.stop();
                    timerController = CountdownController(
                        duration: Duration(seconds: 180),
                        onEnd: () {
                          setState(() {
                            authCode = "time over";
                          });
                        });
                    timerController.start();
                  }
                }
              },
              style: ElevatedButton.styleFrom(primary: titleColor),
              child: Text("중복확인"),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Visibility(
          visible: code == "permit" && authCode != "permit",
          child: Container(
            child: Row(
              children: [
                Expanded(
                    child: TextFormField(
                  controller: authController,
                  style: editSubTitleStyle,
                  keyboardType: TextInputType.number,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.isEmpty)
                      return "Code 입력하세요";
                    else if (authCode == "error")
                      return "인증번호가 올바르지 않습니다";
                    else if (authCode == "time over") return "인증 시간이 지났습니다";
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 14),
                    hintText: "Code",
                    hintStyle: editSubTitleStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey, width: 1)),
                  ),
                )),
                SizedBox(
                  width: width * 0.1,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        print(authController.text);
                        var phone = phoneNumerFormat(infoController.text);

                        authCode = await togetherGetAPI(
                            '/user/checkDeviceValidation',
                            "?validation_code=${authController.text}&code_type=P&user_device=$phone");
                        setState(() {});
                        print(authCode);
                        if (authCode == "permit") {
                          if (timerController.isRunning) timerController.stop();
                        }
                      },
                      style: elevatedStyle,
                      child: Text("인증 확인"),
                    ),
                    Visibility(
                      visible: timerController.isRunning,
                      child: Countdown(
                        countdownController: timerController,
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
        ),
        SizedBox(
          height: 30,
        ),
        MyButton(
            label: "변경하기",
            color: authCode == "permit" ? Colors.green[200] : Colors.grey[400],
            onTap: () async {
              if (authCode == "permit") {
                await togetherPostAPI(
                  "/user/editEmailPhone",
                  jsonEncode(
                    {
                      "user_idx": user.userIdx,
                      "value": phoneNumerFormat(infoController.text),
                      "type": "P",
                      "code": "true"
                    },
                  ),
                );
                Navigator.of(context).pop();
              }
            })
      ],
    );
  }

  emailWidget(double width, SignInModel user, BuildContext context) {
    return Column(
      children: [
        Form(
          key: formkey,
          child: MyInputField(
            title: "이메일 변경",
            hint: "Input Email",
            controller: infoController,
            onChanged: (value) {
              setState(() {
                code = "";
                authCode = "";
              });
            },
            validator: (value) {
              if (value!.isEmpty)
                return "이메일을 입력하세여";
              else if (value == widget.value)
                return "현재 내가 사용중인 이메일 입니다";
              else if (code == "duplication") return "이미 존재하는 이메일 입니다";
            },
            titleButton: ElevatedButton(
              onPressed: () async {
                if (formkey.currentState!.validate()) {
                  code = await togetherGetAPI("/user/validationEmail",
                      "?user_email=${infoController.text}");
                  setState(() {});
                  print(code);
                  if (code == "permit") {
                    authController.clear();
                    authCode = "";
                    timerController.stop();
                    timerController = CountdownController(
                        duration: Duration(seconds: 180),
                        onEnd: () {
                          setState(() {
                            authCode = "time over";
                          });
                        });
                    timerController.start();
                  }
                }
              },
              style: ElevatedButton.styleFrom(primary: titleColor),
              child: Text("중복확인"),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Visibility(
          visible: code == "permit" && authCode != "permit",
          child: Container(
            child: Row(
              children: [
                Expanded(
                    child: TextFormField(
                  controller: authController,
                  style: editSubTitleStyle,
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.isEmpty)
                      return "Code 입력하세요";
                    else if (authCode == "error")
                      return "인증번호가 올바르지 않습니다";
                    else if (authCode == "time over") return "인증 시간이 지났습니다";
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 14),
                    hintText: "Code",
                    hintStyle: editSubTitleStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey, width: 1)),
                  ),
                )),
                SizedBox(
                  width: width * 0.1,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        print(authController.text);

                        authCode = await togetherGetAPI(
                            '/user/checkDeviceValidation',
                            "?validation_code=${authController.text}&code_type=E&user_device=${infoController.text}");
                        setState(() {});
                        print(authCode);
                        if (authCode == "permit") {
                          if (timerController.isRunning) timerController.stop();
                        }
                      },
                      style: elevatedStyle,
                      child: Text("인증 확인"),
                    ),
                    Visibility(
                      visible: timerController.isRunning,
                      child: Countdown(
                        countdownController: timerController,
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
        ),
        SizedBox(
          height: 30,
        ),
        MyButton(
            label: "변경하기",
            color: authCode == "permit" ? Colors.green[200] : Colors.grey[400],
            onTap: () async {
              if (authCode == "permit") {
                await togetherPostAPI(
                  "/user/editEmailPhone",
                  jsonEncode(
                    {
                      "user_idx": user.userIdx,
                      "value": infoController.text,
                      "type": "E",
                      "code": "true"
                    },
                  ),
                );
                Navigator.of(context).pop();
              }
            })
      ],
    );
  }

  nicknameWidget(var user) {
    return Column(
      children: [
        Form(
          key: formkey,
          child: MyInputField(
            title: "닉네임 변경",
            hint: "Input nickname",
            controller: infoController,
            titleButton: ElevatedButton(
              onPressed: () async {
                if (formkey.currentState!.validate()) {
                  code = await togetherGetAPI("/user/validationNickname",
                      "?user_nickname=${infoController.text}");

                  print(code);
                  setState(() {});
                }
              },
              style: ElevatedButton.styleFrom(primary: titleColor),
              child: Text("중복확인"),
            ),
            onChanged: (value) {
              setState(() {
                code = "";
              });
            },
            validator: (value) {
              if (value!.isEmpty)
                return "사용할 닉네임을 입력하세요";
              else if (value == widget.value)
                return "현재 내가 사용중인 닉네임으로 변경할 수 없습니다.";
              else if (code == "duplication") return "이미 사용중인 닉네임 입니다.";
            },
            auth: Visibility(
              visible: code == "permit",
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "사용 가능한 닉네임 입니다.",
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        MyButton(
            label: "변경하기",
            color: code == "permit" ? Colors.green[200] : Colors.grey[400],
            onTap: () async {
              if (code == "permit") {
                await togetherPostAPI(
                  "/user/editNickname",
                  jsonEncode(
                    {
                      "user_idx": user.userIdx,
                      "user_nickname": infoController.text,
                    },
                  ),
                );
                Navigator.of(context).pop();
              }
            })
      ],
    );
  }

  _appBar(BuildContext context, String photo) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(
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
