class Event {
  String title;
  String content;
  String startTime;
  String endTime;
  Event(
      {required this.title,
      required this.content,
      required this.startTime,
      required this.endTime});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['body'] = this.content;
    data['start_datetime'] = this.startTime;
    data['end_datetime'] = this.endTime;

    return data;
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
        title: json['title'],
        content: json['body'] ?? "",
        startTime: json['start_datetime'],
        endTime: json['end_datetime']);
  }
}
