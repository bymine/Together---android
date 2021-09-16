class Schedule {
  int writedIdx;
  int scheduleIdx;
  int projectIdx;
  String title;
  String content;
  String startTime;
  String endTime;

  Schedule(
      {required this.writedIdx,
      required this.projectIdx,
      this.scheduleIdx = 0,
      required this.title,
      required this.content,
      required this.startTime,
      required this.endTime});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (scheduleIdx == 0) {
      // 스케줄 추가
      data['project_idx'] = this.projectIdx;
      data['schedule_name'] = this.title;
      data['schedule_content'] = this.content;
      data['schedule_start_datetime'] = this.startTime;
      data['schedule_end_datetime'] = this.endTime;
      data['writer_idx'] = this.writedIdx;
    } else {
      // 데이터 불러오기
      data['project_idx'] = this.projectIdx;
      data['schedule_idx'] = this.scheduleIdx;
      data['schedule_name'] = this.title;
      data['schedule_content'] = this.content;
      data['schedule_start_datetime'] = this.startTime;
      data['schedule_end_datetime'] = this.endTime;
      data['writer_idx'] = this.writedIdx;
    }
    return data;
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
        projectIdx: json['project_idx'],
        scheduleIdx: json['schedule_idx'],
        title: json['schedule_name'],
        content: json['schedule_content'],
        startTime: json['schedule_start_datetime'],
        endTime: json['schedule_end_datetime'],
        writedIdx: json['writer_idx']);
  }
}
