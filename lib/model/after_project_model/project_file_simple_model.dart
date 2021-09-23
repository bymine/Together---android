import 'package:flutter/cupertino.dart';

class SimpleFile extends ChangeNotifier {
  int fileIdx;
  String fileName;
  String fileExt;
  String fileType;
  String fileFlag;

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
