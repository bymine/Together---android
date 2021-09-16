import 'package:flutter/material.dart';

class SignInModel extends ChangeNotifier {
  int userIdx;
  String userName;
  String userPhoto;
  String signInCode;

  SignInModel(
      {required this.userIdx,
      required this.userName,
      required this.userPhoto,
      required this.signInCode});

  factory SignInModel.fromJson(Map<String, dynamic> json) {
    return SignInModel(
        userIdx: json['user_idx'],
        userName: json['user_name'] ?? "",
        userPhoto: json['user_profile_photo'] ?? "",
        signInCode: json['code']);
  }

  void setSignInSuccess(SignInModel signInModel) {
    this.userIdx = signInModel.userIdx;
    this.userName = signInModel.userName;
    this.userPhoto = signInModel.userPhoto;
    this.signInCode = signInModel.signInCode;

    notifyListeners();
  }
}
