class MyProfileDetail {
  String userName;
  String userNickName;
  String userPhoto;
  String userEmail;
  String userPhone;
  String userBirth;
  int userAge;
  String license1;
  String license2;
  String license3;
  String mainAddr;
  String referenceAddr;
  String detailAddr;
  String postNum;
  String userMbti;
  List<String> userHobby;
  List<int> userHobbyIdx;

  List<int> hobbyIdx;
  List<int> searcgIdx;

  MyProfileDetail(
      {required this.userName,
      required this.userNickName,
      required this.userPhoto,
      required this.userEmail,
      required this.userPhone,
      required this.userBirth,
      required this.userAge,
      required this.license1,
      required this.license2,
      required this.license3,
      required this.mainAddr,
      required this.referenceAddr,
      required this.detailAddr,
      required this.postNum,
      required this.userMbti,
      required this.userHobby,
      required this.userHobbyIdx,
      required this.hobbyIdx,
      required this.searcgIdx});

  factory MyProfileDetail.fromJson(Map<String, dynamic> json) {
    List hobby = [];
    List searchIdx = [];

    List.from(json['hobby_idxes']).forEach((element) {
      if (element.runtimeType == Null) {
        hobby.add(0);
      } else
        hobby.add(element);
    });

    List.from(json['hobby_search_idxes']).forEach((element) {
      if (element.runtimeType == Null) {
        searchIdx.add(0);
      } else
        searchIdx.add(element);
    });
    return MyProfileDetail(
      userName: json['user_name'],
      userNickName: json['user_nickname'],
      userPhoto: json['user_profile_photo'],
      userEmail: json['user_email'],
      userPhone: json['user_phone'],
      userBirth: json['user_birth'],
      userAge: json['user_age'],
      license1: json['license1'] ?? "",
      license2: json['license2'] ?? "",
      license3: json['license3'] ?? "",
      mainAddr: json['main_addr'] == null ? "" : json['main_addr'],
      referenceAddr:
          json['reference_addr'] == null ? "" : json['reference_addr'],
      detailAddr: json['detail_addr'] == null ? "" : json['detail_addr'],
      postNum: json['post_num'] == null ? "" : json['post_num'],
      userMbti: json['user_mbti_name'],
      userHobby: List<String>.from(json['user_hobbies']),
      userHobbyIdx: List<int>.from(json['user_hobby_idxes']),
      hobbyIdx: List<int>.from(hobby),
      searcgIdx: List<int>.from(searchIdx),
    );
  }
}
