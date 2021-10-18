import 'package:flutter/cupertino.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class SimpleFile extends ChangeNotifier {
  int fileIdx;
  String fileName;
  String fileExt;
  String fileType;
  String fileFlag;

  String link =
      'http://barbra-coco.dyndns.org/student/learning_android_studio.pdf';

  String? taskId;
  int? progress = 0;
  DownloadTaskStatus? status = DownloadTaskStatus.undefined;

  SimpleFile(
      {required this.fileIdx,
      required this.fileName,
      required this.fileExt,
      required this.fileType,
      required this.fileFlag});

  factory SimpleFile.fromJson(Map<String, dynamic> json) {
    return SimpleFile(
        fileIdx: json['file_idx'],
        fileName: json['file_origin_name'],
        fileExt: json['file_extension'],
        fileType: json['file_type'],
        fileFlag: json['file_sema_flag']);
  }

  void setFileService(SimpleFile simpleFile) {
    this.fileIdx = simpleFile.fileIdx;
    this.fileName = simpleFile.fileName;
    this.fileExt = simpleFile.fileExt;
    this.fileType = simpleFile.fileType;

    notifyListeners();
  }
}
