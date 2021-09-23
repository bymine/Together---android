class DetailFile {
  String modifyUser;
  String modifyComment;
  String modifyDateTime;
  String tempDeleteFlag;
  String tempDeleteMemberName;
  String reserveStart;
  String reserveEnd;
  String reserveName;
  int reserveIdx;
  int currentNextFlag;
  String fileType;
  // userIDx, 현재시간 사용중인지 플래그 0,1
  DetailFile({
    required this.modifyUser,
    required this.modifyComment,
    required this.modifyDateTime,
    required this.tempDeleteFlag,
    required this.tempDeleteMemberName,
    required this.reserveStart,
    required this.reserveEnd,
    required this.reserveName,
    required this.reserveIdx,
    required this.currentNextFlag,
    required this.fileType,
  });

  factory DetailFile.fromJson(Map<String, dynamic> json) {
    return DetailFile(
        modifyUser: json["version_user_name"],
        modifyComment: json["file_modified_comment"] == ""
            ? "첫 업로드 입니다"
            : json["file_modified_comment"],
        fileType: json['file_type'],
        modifyDateTime: json["file_modified_datetime"],
        tempDeleteFlag: json["temp_delete_flag"],
        tempDeleteMemberName: json["temp_delete_member_name"],
        reserveStart: json['reserve_start_datetime'],
        // reserveStart: reserveName == "예약된 수정자가 없습니다"?"예약된 시간이 없습니다":json["reserve_start_datetime"],
        reserveEnd: json["reserve_end_datetime"],
        reserveName: json["reserve_user_name"] == ""
            ? "예약된 수정자가 없습니다"
            : json["reserve_user_name"],
        reserveIdx: json["reserve_user_idx"],
        currentNextFlag: json["file_reservation_flag"]);
    //1이 현재 0이 다음
  }
}
