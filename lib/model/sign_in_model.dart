import 'package:flutter/material.dart';

class SignInModel extends ChangeNotifier {
  int userIdx;
  String userEmail;
  String userPassword;
  String userName;
  String userPhoto;

  String signInCode;

  SignInModel(
      {required this.userIdx,
      required this.userEmail,
      required this.userPassword,
      required this.userName,
      required this.userPhoto,
      required this.signInCode});

  factory SignInModel.fromJson(Map<String, dynamic> json) {
    return SignInModel(
        userIdx: json['user_idx'],
        userEmail: json['user_email'] ?? "",
        userPassword: json['user_pw'] ?? "",
        userName: json['user_name'] ?? "",
        userPhoto: json['user_profile_photo'] ?? "",
        signInCode: json['code']);
  }

  void setSignInSuccess(SignInModel signInModel) {
    this.userIdx = signInModel.userIdx;
    this.userEmail = signInModel.userEmail;
    this.userPassword = signInModel.userPassword;
    this.userName = signInModel.userName;
    this.userPhoto = signInModel.userPhoto;
    this.signInCode = signInModel.signInCode;

    notifyListeners();
  }
}
