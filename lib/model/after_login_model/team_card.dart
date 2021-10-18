class ProjectCard {
  String projectName;
  String projectExp;
  String startDate;
  String endDate;
  String professionality;
  String projectType;
  String memberNum;
  String intro;

  ProjectCard(
      {required this.projectName,
      required this.projectExp,
      required this.startDate,
      required this.endDate,
      required this.professionality,
      required this.projectType,
      required this.memberNum,
      required this.intro});

  factory ProjectCard.fromJson(Map<String, dynamic> json) {
    return ProjectCard(
        projectName: json['project_name'],
        projectExp: json['project_exp'],
        startDate: json['start_date'],
        endDate: json['end_date'],
        professionality: json['professionality'],
        projectType: json['project_type'],
        memberNum: json['member_num'],
        intro: json['comment']);
  }
}
