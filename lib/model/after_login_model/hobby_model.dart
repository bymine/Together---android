class FetchHobby {
  Map<String, String> hobbyIdx;
  Map<String, String> hobbyName;

  FetchHobby({required this.hobbyIdx, required this.hobbyName});

  factory FetchHobby.fromJson(Map<String, dynamic> json) {
    return FetchHobby(
        hobbyIdx: Map<String, String>.from(json['hobby_idx']),
        hobbyName: Map<String, String>.from(json['hobby_name']));
  }
}

class HobbyData {
  Map<String, String> hobbyIdx;
  Map<String, String> hobbyName;

  HobbyData({required this.hobbyIdx, required this.hobbyName});

  factory HobbyData.fromJson(Map<String, dynamic> json) {
    return HobbyData(
        hobbyIdx: Map<String, String>.from(json['hobby_idx']),
        hobbyName: Map<String, String>.from(json['hobby_name']));
  }
}
