class ProjectSetting {
  String projectName;
  String projectExp;
  String startDate;
  String endDate;
  String level;
  String type;
  List<String> category;
  List<String> tag;
  List<int> tagIdxs;
  List<String> members;

  ProjectSetting(
      {required this.projectName,
      required this.projectExp,
      required this.startDate,
      required this.endDate,
      required this.level,
      required this.type,
      required this.category,
      required this.tag,
      required this.tagIdxs,
      required this.members});

  factory ProjectSetting.fromJson(Map<String, dynamic> json) {
    return ProjectSetting(
        projectName: json['project_name'],
        projectExp: json['project_exp'],
        startDate: json['start_date'],
        endDate: json['end_date'],
        level: json['professionality'],
        type: json['project_type'],
        category: List<String>.from(json['tag_names']),
        tag: List<String>.from(json['tag_detail_names']),
        tagIdxs: List<int>.from(json['tag_list_idxes']),
        members: List<String>.from(json['member_names']));
  }
}
