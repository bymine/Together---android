class VersionFile {
  String user;
  String content;
  String time;
  bool showDetail;

  VersionFile(
      {required this.user,
      required this.content,
      required this.time,
      this.showDetail = false});

  factory VersionFile.fromJson(List json) {
    return VersionFile(user: json[1], content: json[2], time: json[0]);
  }
}
