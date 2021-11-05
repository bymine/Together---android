class ProjectApplyMember {
  int applyIdx;
  int userIdx;
  int projectIdx;
  String userName;
  String userNickName;
  String userMbti;
  int userAge;

  ProjectApplyMember(
      {required this.applyIdx,
      required this.userAge,
      required this.projectIdx,
      required this.userIdx,
      required this.userName,
      required this.userNickName,
      required this.userMbti});

  factory ProjectApplyMember.fromJson(Map<String, dynamic> json) {
    return ProjectApplyMember(
        applyIdx: json['team_application_idx'],
        userAge: json['user_age'],
        projectIdx: json['project_idx'],
        userIdx: json['user_idx'],
        userName: json['user_name'],
        userNickName: json['user_nickname'],
        userMbti: json['user_mbti'] == "NULL" ? "설정 안함" : json['user_mbti']);
  }
}
