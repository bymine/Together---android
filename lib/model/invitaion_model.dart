class Invitaion {
  int projectIdx;
  String projectName;
  String projectExp;
  int members;
  String inviteTime;

  Invitaion(
      {required this.projectIdx,
      required this.projectName,
      required this.projectExp,
      required this.members,
      required this.inviteTime});

  factory Invitaion.fromJson(Map<String, dynamic> json) {
    return Invitaion(
        projectIdx: json['project_idx'],
        projectName: json['project_name'],
        projectExp:
            json['project_exp'] == null ? "프로젝트 소개가 없습니다" : json['project_exp'],
        members: json['member_num'],
        inviteTime: json['invite_time']);
  }
}
