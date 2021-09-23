import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:together_android/model/after_project_model/project_file_detail_model.dart';
import 'package:together_android/model/after_project_model/project_file_simple_model.dart';
import 'package:together_android/page/after_project/project_file/file_reservation_page.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

class FileDetailPage extends StatefulWidget {
  final String fileName;
  FileDetailPage({required this.fileName});

  @override
  _FileDetailPageState createState() => _FileDetailPageState();
}

class _FileDetailPageState extends State<FileDetailPage> {
  late Future future;

  @override
  void initState() {
    super.initState();
    future = fetchFileDetail();
  }

  Future fetchFileDetail() async {
    var fileIdx = Provider.of<SimpleFile>(context, listen: false).fileIdx;

    var list = togetherGetAPI("/file/detail", "/$fileIdx");

    return list;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var fileIdx = Provider.of<SimpleFile>(context, listen: false).fileIdx;
    print(fileIdx);
    return Scaffold(
      appBar: AppBar(
        title: Text("파일 세부 사항"),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var detialFile = snapshot.data as DetailFile;
                return Container(
                  padding: EdgeInsets.symmetric(
                      vertical: height * 0.05, horizontal: width * 0.05),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: width * 0.05, horizontal: width * 0.05),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ]),
                        child: Row(
                          mainAxisAlignment: detialFile.fileType == "All"
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.orange.withOpacity(0.4)),
                                child: Icon(
                                  Icons.download,
                                  color: Colors.orange,
                                  size: 32,
                                )),
                            detialFile.fileType == "All"
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  FileReservation()));
                                    },
                                    child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color:
                                                Colors.purple.withOpacity(0.4)),
                                        child: Icon(
                                          Icons.event,
                                          color: Colors.purple,
                                          size: 32,
                                        )),
                                  )
                                : Container(),
                            detialFile.fileType == "All"
                                ? Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.pink.withOpacity(0.4)),
                                    child: Icon(
                                      Icons.upload_file,
                                      color: Colors.pink,
                                      size: 32,
                                    ))
                                : Container(),
                            Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.blue.withOpacity(0.4)),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.blue,
                                  size: 32,
                                )),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: height * 0.03,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: width * 0.05, horizontal: width * 0.05),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ]),
                        child: Column(
                          children: [
                            buildProfileEditForm(
                                Icons.description, "파일 이름", widget.fileName),
                            buildProfileEditForm(
                                Icons.face, "최근 수정자", detialFile.modifyUser),
                            buildProfileEditForm(
                                Icons.history,
                                "최근 수정시간",
                                toDateTime(
                                    DateTime.parse(detialFile.modifyDateTime))),
                            buildProfileEditForm(Icons.border_color_outlined,
                                "수정 내역", detialFile.modifyComment),
                            Card(
                              child: ListTile(
                                leading: Icon(Icons.delete_outline_outlined),
                                title: Text(
                                  "임시 삭제 여부 " + detialFile.tempDeleteFlag,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: detialFile.tempDeleteFlag == "Y"
                                          ? Colors.red
                                          : Colors.grey),
                                ),
                                subtitle: detialFile.tempDeleteMemberName == ""
                                    ? Text(
                                        '임시 삭제 요청자가 없습니다.',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey),
                                      )
                                    : Text(
                                        '임시 삭제 요청자: ' +
                                            detialFile.tempDeleteMemberName,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                detialFile.tempDeleteFlag == "Y"
                                                    ? Colors.red
                                                    : Colors.grey),
                                      ),
                              ),
                            ),
                            detialFile.fileType == "All"
                                ? Column(
                                    children: [
                                      buildProfileEditForm(
                                        Icons.schedule_outlined,
                                        detialFile.reserveName ==
                                                "예약된 수정자가 없습니다"
                                            ? ""
                                            : (toDateTime(DateTime.parse(
                                                    detialFile.reserveStart)) +
                                                "  ~  " +
                                                toTime(DateTime.parse(
                                                    detialFile.reserveEnd))),
                                        detialFile.reserveName ==
                                                "예약된 수정자가 없습니다"
                                            ? "예약된 시작 시간이 없습니다."
                                            : detialFile.currentNextFlag == 0
                                                ? "다음 예약된 수정 시간"
                                                : "현재 예약된 수정 시간",
                                      ),
                                      buildProfileEditForm(
                                        Icons.person,
                                        detialFile.reserveName ==
                                                "예약된 수정자가 없습니다"
                                            ? ""
                                            : detialFile.reserveName,
                                        detialFile.reserveName ==
                                                "예약된 수정자가 없습니다"
                                            ? "예약된 수정자가 없습니다"
                                            : detialFile.currentNextFlag == 0
                                                ? "다음 수정자"
                                                : "현재 수정자",
                                      )
                                    ],
                                  )
                                : Container()
                          ],
                        ),
                      )
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                print(snapshot.error);
              }

              return CircularProgressIndicator();
            }),
      ),
    );
  }

  Widget buildProfileEditForm(IconData data, String title, String subtitle) =>
      Container(
        child: Card(
          child: ListTile(
            leading: Icon(data),
            title: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
}
