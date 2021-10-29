import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/listTile.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/live_project_model.dart';
import 'package:together_android/model/after_project_model/project_file_detail_model.dart';
import 'package:together_android/model/after_project_model/project_file_simple_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/page/after_project/project_file/file_version_page.dart';
import 'package:together_android/page/after_project/project_file/file_version_upload_page.dart';
import 'package:together_android/page/after_project/project_file/reservation_main.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/service/notification_serivice.dart';
import 'package:together_android/utils.dart';

class FileDetailPage extends StatefulWidget {
  final String fileName;
  FileDetailPage({required this.fileName});

  @override
  _FileDetailPageState createState() => _FileDetailPageState();
}

class _FileDetailPageState extends State<FileDetailPage> {
  //late Future future;

  StreamController _streamController = StreamController.broadcast();
  var notifyHelper;

  @override
  void initState() {
    /// aaa();
    notifyHelper = NotifiyHelper();
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();
    super.initState();
  }

  aaa() async {
    await FlutterDownloader.initialize(
        debug: true // optional: set false to disable printing logs to console
        );
  }

  Future fetchFileDetail() async {
    var fileIdx = Provider.of<SimpleFile>(context, listen: false).fileIdx;

    var list = togetherGetAPI("/file/detail", "/$fileIdx");
    return list;
  }

  @override
  Widget build(BuildContext context) {
    fetchFileDetail().then((value) => _streamController.add(value));

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;

    var photo = Provider.of<SignInModel>(context, listen: false).userPhoto;
    var projectIdx =
        Provider.of<LiveProject>(context, listen: false).projectIdx;
    var fileIdx = Provider.of<SimpleFile>(context, listen: false).fileIdx;
    print(fileIdx);
    return Scaffold(
      appBar: _appBar(context, photo),
      body: SingleChildScrollView(
        child: StreamBuilder(
            stream: _streamController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var detialFile = snapshot.data as DetailFile;

                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          left: width * 0.08,
                          right: width * 0.08,
                          bottom: height * 0.02),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20)),
                          color: Color(0xffD0EBFF)),
                      child: Column(
                        children: [
                          detailHeader(width, detialFile),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              fileIconButton(width * 0.16, "버전", Icons.history,
                                  () async {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => FileVersionPage()));
                                // var bytes = await togetherGetAPI(
                                //     "/file/detail/download/read", "/$fileIdx");

                                // final ext = await getExternalStorageDirectory();

                                // File("${ext!.path}/${widget.fileName}")
                                //     .writeAsBytes(bytes)
                                //     .then((value) => null);

                                // notifyHelper.displayNotification(
                                //     title: "File Download",
                                //     body: "download ${widget.fileName}",
                                //     payload: "${ext.path}/${widget.fileName}");
                              }),
                              Visibility(
                                  visible: detialFile.fileType == "All",
                                  child: fileIconButton(
                                      width * 0.16, "예약", Icons.today_outlined,
                                      () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) =>
                                                FileReservation()))
                                        .then((value) => setState(() {}));
                                  })),
                              fileIconButton(
                                  width * 0.16, "삭제", Icons.delete_outline, () {
                                deleteFunction(userIdx, projectIdx, fileIdx);
                              }),
                              Visibility(
                                  visible: detialFile.fileType == "All" &&
                                      detialFile.currentNextFlag == 1 &&
                                      detialFile.reserveIdx == userIdx,
                                  child: fileIconButton(
                                      width * 0.16, "업로드", Icons.upload_file,
                                      () async {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FileVersionUpload(
                                                  name: widget.fileName,
                                                )));
                                  }))
                            ],
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: width * 0.04,
                          right: width * 0.04,
                          top: height * 0.04),
                      child: Column(
                        children: [
                          MyListTile(
                              leading: CircleAvatar(
                                  child: Icon(Icons.face_outlined,
                                      color: Colors.white),
                                  backgroundColor: Colors.orange[300]),
                              title: Text(
                                '최근 수정자',
                                style: tileTitleStyle,
                              ),
                              subTitle: Text(
                                detialFile.modifyUser,
                                style: tileSubTitleStyle,
                              ),
                              trailing: null),
                          MyListTile(
                              leading: CircleAvatar(
                                  child:
                                      Icon(Icons.history, color: Colors.white),
                                  backgroundColor: Colors.red[300]),
                              title: Text(
                                '최근 수정시간',
                                style: tileTitleStyle,
                              ),
                              subTitle: Text(
                                toDateTimeISO(detialFile.modifyDateTime),
                                style: tileSubTitleStyle,
                              ),
                              trailing: null),
                          MyListTile(
                              leading: CircleAvatar(
                                  child: Icon(Icons.border_color_outlined,
                                      color: Colors.white),
                                  backgroundColor: Colors.brown[300]),
                              title: Text(
                                '수정 내용',
                                style: tileTitleStyle,
                              ),
                              subTitle: Text(
                                toDateTimeISO(detialFile.modifyDateTime),
                                style: tileSubTitleStyle,
                              ),
                              trailing: null),
                          MyListTile(
                              leading: CircleAvatar(
                                  child: Icon(Icons.delete_outline_outlined,
                                      color: Colors.white),
                                  backgroundColor: Colors.blue[300]),
                              title: Text(
                                "임시 삭제 여부 " + detialFile.tempDeleteFlag,
                                style: tileTitleStyle,
                              ),
                              subTitle: detialFile.tempDeleteMemberName == ""
                                  ? Text(
                                      '임시 삭제 요청자가 없습니다.',
                                      style: tileSubTitleStyle,
                                    )
                                  : Text(
                                      '임시 삭제 요청자: ' +
                                          detialFile.tempDeleteMemberName,
                                      style: tileSubTitleStyle,
                                    ),
                              trailing: null),
                          detialFile.fileType == "All"
                              ? Column(
                                  children: [
                                    MyListTile(
                                        leading: CircleAvatar(
                                            child: Icon(Icons.person,
                                                color: Colors.white),
                                            backgroundColor: Colors.green[300]),
                                        title:
                                            detialFile.tempDeleteMemberName ==
                                                    ""
                                                ? Text(
                                                    detialFile.reserveName ==
                                                            "예약된 수정자가 없습니다"
                                                        ? "예약된 수정자가 없습니다"
                                                        : detialFile.currentNextFlag ==
                                                                0
                                                            ? "다음 수정자"
                                                            : "현재 수정자",
                                                    style: tileTitleStyle,
                                                  )
                                                : Text(
                                                    '임시 삭제 요청자: ' +
                                                        detialFile
                                                            .tempDeleteMemberName,
                                                    style: tileTitleStyle,
                                                  ),
                                        subTitle: Text(
                                          detialFile.reserveName ==
                                                  "예약된 수정자가 없습니다"
                                              ? ""
                                              : detialFile.reserveName,
                                          style: tileSubTitleStyle,
                                        ),
                                        trailing: null),
                                    MyListTile(
                                        leading: CircleAvatar(
                                            child: Icon(Icons.schedule_outlined,
                                                color: Colors.white),
                                            backgroundColor: Colors.green[300]),
                                        title: detialFile.reserveName ==
                                                "예약된 수정자가 없습니다"
                                            ? Text(
                                                "예약된 시작 시간이 없습니다.",
                                                style: tileTitleStyle,
                                              )
                                            : detialFile.currentNextFlag == 0
                                                ? Text(
                                                    "다음 예약된 수정 시간",
                                                    style: tileTitleStyle,
                                                  )
                                                : Text(
                                                    "현재 예약된 수정 시간",
                                                    style: tileTitleStyle,
                                                  ),
                                        subTitle: Text(
                                          detialFile.reserveName ==
                                                  "예약된 수정자가 없습니다"
                                              ? ""
                                              : (toDateTime(DateTime.parse(
                                                      detialFile
                                                          .reserveStart)) +
                                                  "  ~  " +
                                                  toTime(DateTime.parse(
                                                      detialFile.reserveEnd))),
                                          style: tileSubTitleStyle,
                                        ),
                                        trailing: null),
                                  ],
                                )
                              : Container()
                        ],
                      ),
                    )
                  ],
                );
              } else if (snapshot.hasError) {
                print(snapshot.error);
              }

              return Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }

  deleteFunction(int userIdx, int projectIdx, int fileIdx) async {
    var code = await togetherPostAPI(
        "/file/detail/deleteFile",
        jsonEncode({
          'user_idx': userIdx,
          'project_idx': projectIdx,
          'file_idx': fileIdx
        }));
    print(code.toString());
    if (code.toString() == "Leader") {
      Navigator.of(context).pop();
    } else if (code.toString() == "Member") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '팀장이 최종 삭제하여야합니다.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
      setState(() {});
    }
  }

  fileIconButton(double width, String name, IconData icon, Function()? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: width,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Color(0xffffe0e0e0),
                spreadRadius: 2,
                blurRadius: 2,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: pinkClr,
              size: 24,
            ),
            Text(
              name,
              style: editSubTitleStyle.copyWith(fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  Row detailHeader(double width, DetailFile detailFile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "FileDetail",
                style: subHeadingStyle,
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                detailFile.fileType == "All"
                    ? widget.fileName
                    : widget.fileName + " (읽기 전용)",
                style: headingStyle.copyWith(color: darkBlue, fontSize: 20),
                maxLines: 2,
              ),
            ],
          ),
        ),
        svgFileIcon(width, widget.fileName)
      ],
    );
  }

  _appBar(BuildContext context, String photo) {
    return AppBar(
      backgroundColor: Color(0xffD0EBFF),
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Icon(
          Icons.arrow_back_ios,
          size: 20,
          color: Colors.black,
        ),
      ),
      actions: [
        CircleAvatar(
          backgroundImage: NetworkImage(photo),
        ),
        SizedBox(
          width: 20,
        )
      ],
    );
  }

  buildProfileEditForm(IconData data, String title, String subtitle) =>
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

  svgFileIcon(
    double width,
    String fileName,
  ) {
    return CircleAvatar(
      radius: 50,
      child: SvgPicture.asset(
        svgIconAsset(fileName.split('.').last),
        width: 80,
        height: 80,
      ),
      backgroundColor: Color(0xffD0EBFF),
    );
  }
}
