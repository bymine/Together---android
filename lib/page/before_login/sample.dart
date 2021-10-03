import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown.dart';
import 'package:flutter_countdown_timer/countdown_controller.dart';
import 'package:together_android/componet/showDialog.dart';
import 'package:together_android/componet/textfield_widget.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/page/before_login/search_account_page.dart';
import 'package:together_android/page/before_login/sign_up_result_page.dart';
import 'package:together_android/reg.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController signUpEmail = TextEditingController();
  TextEditingController signUpPassword1 = TextEditingController();
  TextEditingController signUpPassword2 = TextEditingController();
  TextEditingController signUpName = TextEditingController();
  TextEditingController signUpNickName = TextEditingController();
  TextEditingController signUpPhone = TextEditingController();
  TextEditingController signUpBirth = TextEditingController();

  TextEditingController emailAuthController = TextEditingController();
  TextEditingController phoneAuthController = TextEditingController();

  final emailCodeKey = GlobalKey<FormState>();
  final phoneCodeKey = GlobalKey<FormState>();

  final signupStep1 = GlobalKey<FormState>();
  final signupStep2 = GlobalKey<FormState>();
  final signupStep3 = GlobalKey<FormState>();

  String emailFlag = "not yet";
  String phoneFlag = "not yet";
  String nicknameFlag = "not yet";

  bool showPw1 = true;
  bool showPw2 = true;

  ValueNotifier<String> emailCode = ValueNotifier<String>("not yet");
  ValueNotifier<String> phoneCode = ValueNotifier<String>("not yet");

  CountdownController emailCodeController =
      CountdownController(duration: Duration(seconds: 60));
  CountdownController phoneCodeController =
      CountdownController(duration: Duration(seconds: 60));
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    continued() async {
      if (_currentStep == 0) {
        if (signupStep1.currentState!.validate()) {
          print("이메일 플레그: " + emailFlag);
          print("이메일 인증 상태: " + emailCode.value);
          //_currentStep < 2 ? setState(() => _currentStep += 1) :null ;
          if (_currentStep < 2)
            setState(() {
              _currentStep += 1;
            });
        }
      } else if (_currentStep == 1) {
        if (signupStep2.currentState!.validate()) {
          print("휴대폰 플레그: " + phoneFlag);
          print("이메일 인증 상태: " + phoneCode.value);
          // _currentStep < 2 ? setState(() => _currentStep += 1) : null;
          if (_currentStep < 2)
            setState(() {
              _currentStep += 1;
            });
        }
      } else if (_currentStep == 2) {
        if (signupStep3.currentState!.validate()) {
          print(jsonEncode({
            "user_email": signUpEmail.text,
            "user_pw": signUpPassword1.text,
            "user_name": signUpName.text,
            "user_phone": phoneNumerFormat(signUpPhone.text),
            "user_nickname": signUpNickName.text,
            "user_birth": DateTime.parse(signUpBirth.text).toIso8601String(),
            "user_age":
                DateTime.now().year - DateTime.parse(signUpBirth.text).year + 1
          }));

          var statusCode = await togetherPostAPI(
              "/user/join",
              jsonEncode({
                "user_email": signUpEmail.text,
                "user_pw": signUpPassword1.text,
                "user_name": signUpName.text,
                "user_phone": phoneNumerFormat(signUpPhone.text),
                "user_nickname": signUpNickName.text,
                "user_birth":
                    DateTime.parse(signUpBirth.text).toIso8601String(),
                "user_age": DateTime.now().year -
                    DateTime.parse(signUpBirth.text).year +
                    1
              }));

          if (statusCode == 200) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => SignUpResultPage()));
          }
        }
      }
    }

    cancel() {
      print("cancel");
      // _currentStep > 0 ? setState(() => _currentStep -= 1) : null;

      if (_currentStep > 0)
        setState(() {
          _currentStep -= 1;
        });
    }

    tapped(int step) {
      setState(() => _currentStep = step);
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: titleColor,
          title: Text("회원가입"),
          centerTitle: true,
        ),
        body: Container(
          child: Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepTapped: (step) => tapped(step),
              onStepContinue: continued,
              onStepCancel: cancel,
              controlsBuilder: (BuildContext context,
                  {VoidCallback? onStepContinue, VoidCallback? onStepCancel}) {
                return _currentStep == 0
                    ? Center(
                        child: Container(
                          width: width * 0.3,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: titleColor, shadowColor: titleColor),
                            onPressed: onStepContinue,
                            child: Text('다음'),
                          ),
                        ),
                      )
                    : _currentStep == 1
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: width * 0.3,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.red[200],
                                      shadowColor: Colors.red[200]),
                                  onPressed: onStepCancel,
                                  child: Text('이전'),
                                ),
                              ),
                              Container(
                                width: width * 0.3,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: titleColor,
                                      shadowColor: titleColor),
                                  onPressed: onStepContinue,
                                  child: Text('다음'),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: width * 0.3,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.red[200],
                                      shadowColor: Colors.red[200]),
                                  onPressed: onStepCancel,
                                  child: Text('이전'),
                                ),
                              ),
                              Container(
                                width: width * 0.3,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: titleColor,
                                      shadowColor: titleColor),
                                  onPressed: onStepContinue,
                                  child: Text('회원가입'),
                                ),
                              ),
                            ],
                          );
              },
              steps: [
                Step(
                  title: Text("계정 생성"),
                  content: Form(
                    key: signupStep1,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade400.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          Container(
                            child: TextFormFieldWidget(
                                header: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("이메일"),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: titleColor,
                                            shadowColor: titleColor),
                                        onPressed: () async {
                                          if (signUpEmail.text.isNotEmpty) {
                                            print("인증번호 받기 버튼 클릭");
                                            emailAuthController.clear();
                                            emailCode.value = "not yet";

                                            var email = signUpEmail.text;
                                            var code = await togetherGetAPI(
                                                "/user/validationEmail",
                                                "?user_email=$email");

                                            setState(() {
                                              emailFlag = code.toString();
                                            });
                                            if (emailFlag == "fail") {
                                              showAlertDialog(
                                                  context,
                                                  Text("이메일 인증 실패"),
                                                  Text("입력하신 이메일이 올바르지 않습니다"), [
                                                Center(
                                                  child: TextButton(
                                                      style:
                                                          TextButton.styleFrom(
                                                              primary:
                                                                  Colors.black),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text("확인",
                                                          style: TextStyle(
                                                              fontSize: width *
                                                                  0.048))),
                                                )
                                              ]);
                                            } else if (emailFlag == "permit") {
                                              emailCodeController =
                                                  CountdownController(
                                                      duration:
                                                          Duration(seconds: 30),
                                                      onEnd: () {
                                                        emailCode.value =
                                                            "time over";
                                                      });
                                              emailCodeController.start();
                                            } else if (emailFlag ==
                                                "duplication") {
                                              showAlertDialog(
                                                  context,
                                                  Text("이메일 인증 실패"),
                                                  Text(
                                                      "입력하신 이메일이 이미 존재하는 이메일입니다"),
                                                  [
                                                    TextButton(
                                                        style: TextButton
                                                            .styleFrom(
                                                                primary: Colors
                                                                    .black),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context).pushReplacement(
                                                              (MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      SearchAccountPage(
                                                                          type:
                                                                              "pw"))));
                                                        },
                                                        child: Text("비밀번호 찾기",
                                                            style: TextStyle(
                                                                fontSize: width *
                                                                    0.048))),
                                                    TextButton(
                                                        style: TextButton
                                                            .styleFrom(
                                                                primary: Colors
                                                                    .black),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text("확인",
                                                            style: TextStyle(
                                                                fontSize:
                                                                    width *
                                                                        0.048)))
                                                  ]);
                                            }
                                          }
                                        },
                                        child: Text(emailFlag != "permit"
                                            ? "인증번호 받기"
                                            : emailCode.value == "permit"
                                                ? "인증 완료"
                                                : "재전송"))
                                  ],
                                ),
                                body: Container(
                                  child: TextFormField(
                                    controller: signUpEmail,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        hintText: "Email",
                                        prefixIcon: Icon(Icons.email_outlined,
                                            color: (emailFlag == "permit" &&
                                                    emailCode.value == "permit")
                                                ? titleColor
                                                : Colors.grey)),
                                    onChanged: (value) {
                                      setState(() {
                                        emailFlag = "not yet";
                                        emailCode.value = "not yet";
                                      });
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value!.isEmpty)
                                        return "이메일을 입력하세여";
                                      else if (emailCode.value == "not yet")
                                        return "인증을 진행하세요";
                                    },
                                  ),
                                ),
                                footer: Visibility(
                                  visible: emailFlag == "permit" &&
                                      emailCode.value != "permit",
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Form(
                                        key: emailCodeKey,
                                        child: Container(
                                          width: width * 0.5,
                                          child: TextFormField(
                                            controller: emailAuthController,
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16)),
                                                hintText: "인증 코드",
                                                prefixIcon: Icon(
                                                  Icons.vpn_key_outlined,
                                                )),
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            validator: (value) {
                                              if (value!.isEmpty)
                                                return "인증 코드를 입력하세요";
                                              if (emailCode.value ==
                                                  "time over")
                                                return "인증번호 입력 시간이 초과하였습니다.\n다시 시도해 주세요.";
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.08,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  primary: titleColor,
                                                  shadowColor: titleColor),
                                              onPressed: () async {
                                                if (emailCodeKey.currentState!
                                                    .validate()) {
                                                  var authCode =
                                                      emailAuthController.text;
                                                  var email = signUpEmail.text;

                                                  var code = await togetherGetAPI(
                                                      '/user/checkDeviceValidation',
                                                      "?validation_code=$authCode&code_type=E&user_device=$email");

                                                  emailCode.value =
                                                      code.toString();
                                                  print(emailCode.value);
                                                  if (emailCode.value ==
                                                      "permit") {
                                                    if (emailCodeController
                                                        .isRunning)
                                                      emailCodeController
                                                          .stop();
                                                  } else if (emailCode.value ==
                                                      "error") {
                                                    showAlertDialog(
                                                        context,
                                                        Text("이메일 인증 실패"),
                                                        Text(
                                                            "입력하신 코드가 올바르지 않습니다"),
                                                        []);
                                                  }
                                                  setState(() {});
                                                }
                                              },
                                              child: Text("인증 확인")),
                                          Countdown(
                                            countdownController:
                                                emailCodeController,
                                            builder: (context, Duration time) {
                                              return Text(
                                                  durationFormatTime(time));
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                heightPadding: height * 0.02),
                          ),
                          TextFormFieldWidget(
                              header: Text("비밀번호"),
                              body: TextFormField(
                                controller: signUpPassword1,
                                obscureText: showPw1,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    hintText: "비밀번호를 입력하세요",
                                    prefixIcon: Icon(Icons.vpn_key_outlined),
                                    suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            showPw1 = !showPw1;
                                          });
                                        },
                                        icon: Icon(Icons.visibility_outlined))),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "비밀번호를 입력하세요";
                                  }
                                },
                              ),
                              footer: null,
                              heightPadding: height * 0.02),
                          TextFormFieldWidget(
                              header: Text("비밀번호 확인"),
                              body: TextFormField(
                                controller: signUpPassword2,
                                obscureText: showPw2,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    hintText: "비밀번호를 입력하세요",
                                    prefixIcon: Icon(
                                      Icons.vpn_key_outlined,
                                    ),
                                    suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            showPw2 = !showPw2;
                                          });
                                        },
                                        icon: Icon(Icons.visibility_outlined))),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "비밀번호를 입력하세요";
                                  }
                                  if (signUpPassword1.text !=
                                      signUpPassword2.text)
                                    return "비밀번호가 일치하지 않습니다.";
                                },
                              ),
                              footer: null,
                              heightPadding: height * 0.02),
                        ],
                      ),
                    ),
                  ),
                  isActive: _currentStep >= 0,
                  state: _currentStep >= 1
                      ? StepState.complete
                      : StepState.disabled,
                ),
                Step(
                  title: Text("개인 인증"),
                  content: Form(
                      key: signupStep2,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade400.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            TextFormFieldWidget(
                                header: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("휴대전화"),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: titleColor,
                                            shadowColor: titleColor),
                                        onPressed: () async {
                                          if (signUpPhone.text.isNotEmpty) {
                                            print("인증번호 받기 버튼 클릭");
                                            phoneAuthController.clear();
                                            phoneCode.value = "not yet";

                                            var phone = phoneNumerFormat(
                                                signUpPhone.text);

                                            var code = await togetherGetAPI(
                                                "/user/validationPhone",
                                                "?user_phone=$phone");

                                            setState(() {
                                              phoneFlag = code.toString();
                                            });
                                            if (phoneFlag == "error") {
                                              showAlertDialog(
                                                  context,
                                                  Text("휴대폰 인증 실패"),
                                                  Text("입력하신 휴대폰번호가 올바르지 않습니다"),
                                                  [
                                                    Center(
                                                      child: TextButton(
                                                          style: TextButton
                                                              .styleFrom(
                                                                  primary: Colors
                                                                      .black),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Text("확인",
                                                              style: TextStyle(
                                                                  fontSize: width *
                                                                      0.048))),
                                                    )
                                                  ]);
                                            } else if (phoneFlag == "permit") {
                                              phoneCodeController =
                                                  CountdownController(
                                                      duration:
                                                          Duration(seconds: 30),
                                                      onEnd: () {
                                                        phoneCode.value =
                                                            "time over";
                                                      });
                                              phoneCodeController.start();
                                            } else if (phoneFlag ==
                                                "duplication") {
                                              showAlertDialog(
                                                  context,
                                                  Text("휴대전화 인증 실패"),
                                                  Text(
                                                      "입력하신 휴대전화 번호는 이미 존재하는 번호입니다"),
                                                  [
                                                    TextButton(
                                                        style: TextButton
                                                            .styleFrom(
                                                                primary: Colors
                                                                    .black),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context).pushReplacement(
                                                              (MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      SearchAccountPage(
                                                                          type:
                                                                              "pw"))));
                                                        },
                                                        child: Text("비밀번호 찾기",
                                                            style: TextStyle(
                                                                fontSize: width *
                                                                    0.048))),
                                                    TextButton(
                                                        style: TextButton
                                                            .styleFrom(
                                                                primary: Colors
                                                                    .black),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text("확인",
                                                            style: TextStyle(
                                                                fontSize:
                                                                    width *
                                                                        0.048)))
                                                  ]);
                                            }
                                          }
                                        },
                                        child: Text(phoneFlag != "permit"
                                            ? "인증번호 받기"
                                            : phoneCode.value == "permit"
                                                ? "인증 완료"
                                                : "재전송"))
                                  ],
                                ),
                                body: Container(
                                  child: TextFormField(
                                    controller: signUpPhone,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        hintText: "휴대전화 번호 - 제외하고 입력하세요",
                                        prefixIcon: Icon(
                                            Icons.smartphone_outlined,
                                            color: (phoneFlag == "permit" &&
                                                    phoneCode.value == "permit")
                                                ? titleColor
                                                : Colors.grey)),
                                    onChanged: (value) {
                                      setState(() {
                                        phoneFlag = "not yet";
                                        phoneCode.value = "not yet";
                                      });
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value!.isEmpty)
                                        return "휴대전화번호를 입력하세여";
                                      else if (phoneCode.value == "not yet")
                                        return "인증을 진행하세요";
                                    },
                                  ),
                                ),
                                footer: Visibility(
                                  visible: phoneFlag == "permit" &&
                                      phoneCode.value != "permit",
                                  child: Row(
                                    children: [
                                      Form(
                                        key: phoneCodeKey,
                                        child: Container(
                                          width: width * 0.5,
                                          child: TextFormField(
                                            controller: phoneAuthController,
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16)),
                                                hintText: "인증 코드",
                                                prefixIcon: Icon(
                                                  Icons.vpn_key_outlined,
                                                )),
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            validator: (value) {
                                              if (value!.isEmpty)
                                                return "인증 코드를 입력하세요";
                                              if (phoneCode.value ==
                                                  "time over")
                                                return "인증번호 입력 시간이 초과하였습니다.\n다시 시도해 주세요.";
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.08,
                                      ),
                                      Column(
                                        children: [
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  primary: titleColor,
                                                  shadowColor: titleColor),
                                              onPressed: () async {
                                                if (phoneCodeKey.currentState!
                                                    .validate()) {
                                                  var authCode =
                                                      phoneAuthController.text;
                                                  var phone = phoneNumerFormat(
                                                      signUpPhone.text);

                                                  var code = await togetherGetAPI(
                                                      '/user/checkDeviceValidation',
                                                      "?validation_code=$authCode&code_type=P&user_device=$phone");

                                                  phoneCode.value =
                                                      code.toString();
                                                  print(phoneCode.value);
                                                  if (phoneCode.value ==
                                                      "permit") {
                                                    if (phoneCodeController
                                                        .isRunning)
                                                      phoneCodeController
                                                          .stop();
                                                  } else if (phoneCode.value ==
                                                      "fail") {
                                                    showAlertDialog(
                                                        context,
                                                        Text("휴대전화 인증 실패"),
                                                        Text(
                                                            "입력하신 코드가 올바르지 않습니다"),
                                                        []);
                                                  }
                                                  setState(() {});
                                                }
                                              },
                                              child: Text("인증 확인")),
                                          Countdown(
                                            countdownController:
                                                phoneCodeController,
                                            builder: (context, Duration time) {
                                              return Text(
                                                  durationFormatTime(time));
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                heightPadding: height * 0.01),
                            TextFormFieldWidget(
                                header: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("닉네임"),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: titleColor,
                                            shadowColor: titleColor),
                                        onPressed: () async {
                                          if (signUpNickName.text.isNotEmpty) {
                                            print(signUpNickName.text);
                                            var code = await togetherGetAPI(
                                                "/user/validationNickname",
                                                "?user_nickname=${signUpNickName.text}");

                                            setState(() {
                                              nicknameFlag = code.toString();
                                            });
                                            print(nicknameFlag);
                                            if (nicknameFlag == "duplication") {
                                              showAlertDialog(
                                                  context,
                                                  Text("닉네임 중복검사 실패"),
                                                  Text(
                                                      "입력하신 닉네임은 이미 존재하는 닉네임입니다"),
                                                  [
                                                    TextButton(
                                                        style: TextButton
                                                            .styleFrom(
                                                                primary: Colors
                                                                    .black),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context).pushReplacement(
                                                              (MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      SearchAccountPage(
                                                                          type:
                                                                              "pw"))));
                                                        },
                                                        child: Text("비밀번호 찾기",
                                                            style: TextStyle(
                                                                fontSize: width *
                                                                    0.048))),
                                                    TextButton(
                                                        style: TextButton
                                                            .styleFrom(
                                                                primary: Colors
                                                                    .black),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text("확인",
                                                            style: TextStyle(
                                                                fontSize:
                                                                    width *
                                                                        0.048)))
                                                  ]);
                                            }
                                          }
                                        },
                                        child: Text("중복확인"))
                                  ],
                                ),
                                body: TextFormField(
                                    controller: signUpNickName,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        hintText: "닉네임",
                                        prefixIcon: Icon(
                                          Icons.person_outline_outlined,
                                        )),
                                    onChanged: (value) {
                                      setState(() {
                                        nicknameFlag = "not yet";
                                      });
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value!.isEmpty) return "닉네임을 입력하세요";
                                      if (nicknameFlag == "not yet")
                                        return "중복확인 버튼을 누르세요";
                                      if (nicknameFlag == "permit") return null;
                                    }),
                                footer: null,
                                heightPadding: height * 0.01),
                            TextFormFieldWidget(
                                header: Text("이름"),
                                body: TextFormField(
                                  controller: signUpName,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      hintText: "2~10자리 한글로 입력하세요",
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
                                heightPadding: height * 0.01),
                          ],
                        ),
                      )),
                  isActive: _currentStep >= 0,
                  state: _currentStep >= 2
                      ? StepState.complete
                      : StepState.disabled,
                ),
                Step(
                  title: Text("개인 정보"),
                  content: Form(
                      key: signupStep3,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade400.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            TextFormFieldWidget(
                                header: Text("생년월일"),
                                body: TextFormField(
                                  controller: signUpBirth,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      hintText: " 예시) 19970723",
                                      prefixIcon:
                                          Icon(Icons.calendar_today_outlined)),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "생년월일을 입력하세요";
                                    } else if (value.length != 8) {
                                      return "8자리 숫자로 생년월일을 입력하세요";
                                    }
                                  },
                                ),
                                footer: null,
                                heightPadding: height * 0.01),
                          ],
                        ),
                      )),
                  isActive: _currentStep >= 0,
                  state: _currentStep >= 3
                      ? StepState.complete
                      : StepState.disabled,
                )
              ]),
        ));
  }
}
