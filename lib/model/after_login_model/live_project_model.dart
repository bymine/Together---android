import 'package:flutter/cupertino.dart';

class LiveProject extends ChangeNotifier {
  int projectIdx;
  int memberCount;
  int files;
  String projectName;
  String projectExp;
  String startDate;
  String endDate;
  List<String> photoes;

  LiveProject(
      {required this.projectIdx,
      required this.memberCount,
      required this.files,
      required this.projectName,
      required this.projectExp,
      required this.startDate,
      required this.endDate,
      required this.photoes});

  factory LiveProject.fromJson(Map<String, dynamic> json) {
    List<String> photoes = [];

    List.from(json['user_profile_photoes']).forEach((element) {
      if (element.runtimeType == Null) {
        photoes.add("assets/sample.png");
      } else
        photoes.add(element);
    });

    return LiveProject(
        projectIdx: json['project_idx'],
        memberCount: json['count'],
        files: json['file_num'],
        projectName: json['project_name'],
        projectExp: json['project_exp'],
        startDate: json['start_date'],
        endDate: json['end_date'],
        photoes: photoes);
  }

  void enterProject(LiveProject project) {
    this.projectIdx = project.projectIdx;
    this.memberCount = project.memberCount;
    this.files = project.files;
    this.projectName = project.projectName;
    this.projectExp = project.projectExp;
    this.startDate = project.startDate;
    this.endDate = project.endDate;
    this.photoes = project.photoes;

    notifyListeners();
  }
}
