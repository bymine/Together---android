class UserInfo {
  int userIdx;
  String userNickname;
  String userPhoto;

  UserInfo(
      {required this.userIdx,
      required this.userNickname,
      required this.userPhoto});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
        userIdx: json['user_idx'],
        userNickname: json['user_nickname'],
        userPhoto: json['user_profile']);
  }
}
