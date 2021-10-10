class MemberResume {
  String name;
  String nickName;
  int age;
  String mainAddr;
  String referenceAddr;
  String detailAddr;
  String mbti;
  List<String> licens;
  List<String> hobbys;
  String? resume;
  String? comment;
  String photo;

  MemberResume({
    required this.name,
    required this.nickName,
    required this.age,
    required this.mainAddr,
    required this.referenceAddr,
    required this.detailAddr,
    required this.mbti,
    required this.licens,
    required this.hobbys,
    this.resume,
    this.comment,
    required this.photo,
  });

  factory MemberResume.fromJson(Map<String, dynamic> json) {
    return MemberResume(
      name: json['user_name'],
      nickName: json['user_nickname'],
      age: json['age'],
      mainAddr: json['main_addr'] ?? "",
      referenceAddr: json['reference_addr'] ?? "",
      detailAddr: json['detail_addr'] ?? "",
      mbti: json['mbti_name'] == "NULL" ? "설정 안함" : json['mbti_name'],
      licens: List<String>.from(json['license']),
      hobbys: List<String>.from(json['hobby_names']),
      photo: json['user_profile_photo'],
      resume: json['resume'] ?? "no comment",
      comment: json['comment'] ?? "no comment",
    );
  }
}
