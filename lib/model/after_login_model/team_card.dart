class ProjectResume {
  int projectIdx;
  String projectName;
  String projectExp;
  String startDate;
  String endDate;
  String professionality;
  String projectType;
  List<String> categoryName;
  List<String> tagName;
  int memberNum;
  String comment;
  int myFlag;

  ProjectResume(
      {required this.projectIdx,
      required this.projectName,
      required this.projectExp,
      required this.startDate,
      required this.endDate,
      required this.professionality,
      required this.projectType,
      required this.categoryName,
      required this.tagName,
      required this.memberNum,
      required this.comment,
      required this.myFlag});

  factory ProjectResume.fromJson(Map<String, dynamic> json) {
    return ProjectResume(
        projectIdx: json['project_idx'],
        projectName: json['project_name'],
        projectExp: json['project_exp'],
        startDate: json['start_date'],
        endDate: json['end_date'],
        professionality: json['professionality'],
        projectType: json['project_type'],
        memberNum: json['member_num'],
        categoryName: List<String>.from(json['tag']),
        tagName: List<String>.from(json['tag_detail']),
        comment: json['comment'],
        myFlag: json['my_flag']);
  }
}
