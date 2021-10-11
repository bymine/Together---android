import 'package:flutter/cupertino.dart';
import 'package:together_android/model/after_login_model/live_project_model.dart';

class MappingProject extends ChangeNotifier {
  Map<String, int> map;

  MappingProject({required this.map});

  void mappingProject(List<LiveProject> project) {
    // this.map[project.projectName] = project.projectIdx;

    notifyListeners();
    print(map);
  }
}
