import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:group_button/group_button.dart';
import 'package:provider/provider.dart';
import 'package:timelines/timelines.dart';
import 'package:together_android/componet/bottom_sheet_top_bar.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/live_project_model.dart';
import 'package:together_android/model/after_project_model/project_file_simple_model.dart';
import 'package:together_android/model/after_project_model/project_file_version_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/page/after_login/main_page.dart';
import 'package:together_android/page/after_project/project_file/file_upload_page.dart';
import 'package:together_android/page/after_project/project_file/project_file_detail_page.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';
import 'package:path/path.dart' as Path;

class ProjectFilePage extends StatefulWidget {
  const ProjectFilePage({Key? key}) : super(key: key);

  @override
  _ProjectFilePageState createState() => _ProjectFilePageState();
}

class _ProjectFilePageState extends State<ProjectFilePage> {
  ValueNotifier<bool> showFloating = ValueNotifier<bool>(false);

  Future<List<SimpleFile>> fetchFileSimpleDetail() async {
    var projectIdx =
        Provider.of<LiveProject>(context, listen: false).projectIdx;
    return await togetherGetAPI("/file/main", "?project_idx=$projectIdx");
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String photo = Provider.of<SignInModel>(context, listen: false).userPhoto;
    String projectName =
        Provider.of<LiveProject>(context, listen: false).projectName;

    File? _file;
    Dio dio = new Dio();

    var fileType = ["Read", "All"];
    String selectedType = "All";

    return Scaffold(
      appBar: _appBar(context, photo),
      body: FutureBuilder<List<SimpleFile>>(
          future: fetchFileSimpleDetail(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(
                      left: width * 0.04,
                      right: width * 0.04,
                      top: height * 0.02,
                      bottom: height * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                projectName,
                                style: subHeadingStyle,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Shared Files",
                                style: headingStyle,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                          MyButton(
                              label: "+ Upload File",
                              width: width * 0.4,
                              height: 50,
                              onTap: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (context) => FileUploadPage()))
                                    .then((value) {
                                  setState(() {
                                    //fetchFileSimpleDetail();
                                  });
                                });
                              }),
                        ],
                      ),
                      Container(
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Card(
                                color: Colors.green[50],
                                child: ListTile(
                                  onTap: () {
                                    Provider.of<SimpleFile>(context,
                                            listen: false)
                                        .setFileService(snapshot.data![index]);

                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) =>
                                                FileDetailPage(
                                                  fileName: snapshot
                                                          .data![index]
                                                          .fileName +
                                                      "." +
                                                      snapshot
                                                          .data![index].fileExt,
                                                )))
                                        .then((value) => setState(() {}));
                                  },
                                  leading: svgFileIcon(width, snapshot, index),
                                  title: Text(
                                      snapshot.data![index].fileName +
                                          "." +
                                          snapshot.data![index].fileExt,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: editTitleStyle),
                                  subtitle: Text(
                                    snapshot.data![index].fileType == "Read"
                                        ? "읽기 전용"
                                        : "수정 가능",
                                    style: editSubTitleStyle,
                                  ),
                                  trailing: IconButton(
                                      onPressed: () async {
                                        var version = await togetherGetAPI(
                                            "/file/version",
                                            "/${snapshot.data![index].fileIdx}");
                                        version as List<VersionFile>;
                                        int vLength = version.length;
                                        versionSheet(
                                                context,
                                                height,
                                                width,
                                                snapshot,
                                                index,
                                                vLength,
                                                version)
                                            .then((value) => setState(() {}));
                                      },
                                      icon: Icon(Icons.history)),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasData == false &&
                snapshot.connectionState == ConnectionState.done) {
              return Container(
                width: width,
                height: height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "진행 중인 프로젝트가 없습니다.",
                      style: headingStyle.copyWith(fontSize: 18),
                    ),
                    Text(
                      "새로운 프로젝트를 생성 하세요",
                      style: subHeadingStyle.copyWith(fontSize: 14),
                    ),
                    SizedBox(
                      height: height * 0.08,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            minimumSize: Size(width * 0.6, height * 0.1),
                            primary: Colors.green.withOpacity(0.5)),
                        onPressed: () async {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => FileUploadPage()))
                              .then((value) {
                            setState(() {
                              fetchFileSimpleDetail();
                            });
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_upload),
                            SizedBox(
                              width: 5,
                            ),
                            Text("파일 업로드 하기"),
                          ],
                        ))
                  ],
                ),
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }

  versionSheet(
      BuildContext context,
      double height,
      double width,
      AsyncSnapshot<List<SimpleFile>> snapshot,
      int index,
      int vLength,
      List<VersionFile> version) async {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16))),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              height: height * 0.7,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(width: 1, color: Colors.grey))),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          child: IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(Icons.close)),
                        ),
                        Expanded(
                          child: Text("버전 보기",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          width: 40,
                        )
                      ],
                    ),
                  ),
                  Expanded(
                      child: Timeline.tileBuilder(
                    theme: TimelineTheme.of(context).copyWith(
                        color: titleColor,
                        nodePosition: 0,
                        indicatorPosition: 0.5),
                    padding: EdgeInsets.symmetric(
                        vertical: width * 0.02, horizontal: width * 0.02),
                    shrinkWrap: true,

                    builder: TimelineTileBuilder.fromStyle(
                      connectorStyle: ConnectorStyle.solidLine,
                      contentsAlign: ContentsAlign.basic,
                      nodePositionBuilder: (context, i) => 0,
                      indicatorPositionBuilder: (context, i) => 0.5,
                      contentsBuilder: (context, i) => Card(
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: width * 0.008),
                          child: ListTile(
                            isThreeLine: true,
                            title: Text(
                              snapshot.data![index].fileName +
                                  "." +
                                  snapshot.data![index].fileExt +
                                  " V${vLength - i}",
                              maxLines: 1,
                              style: editTitleStyle,
                            ),
                            subtitle: Visibility(
                              visible: version[i].showDetail,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "설명: " + version[vLength - i - 1].content,
                                    style: editSubTitleStyle,
                                  ),
                                  Text(
                                    "작성자: " + version[vLength - i - 1].user,
                                    style: editSubTitleStyle,
                                  ),
                                  Text(
                                    "날짜: " +
                                        toDateTime(DateTime.parse(
                                                version[vLength - i - 1].time)
                                            .add(Duration(hours: 9))),
                                    style: editSubTitleStyle,
                                  ),
                                  Visibility(
                                      visible: version[i].showDetail && i != 0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: MyButton(
                                          label: "되돌리기",
                                          width: 100,
                                          height: 40,
                                          onTap: () async {
                                            print(vLength - i);
                                            var user = Provider.of<SignInModel>(
                                                context,
                                                listen: false);

                                            await togetherGetAPI(
                                                "/file/detail/return",
                                                "?file_idx=${snapshot.data![index].fileIdx}&file_version_idx=${vLength - i}&user_idx=${user.userIdx}");

                                            setState(() {
                                              version.add(VersionFile(
                                                  user: user.userName,
                                                  content:
                                                      "v${vLength - i} 되돌림",
                                                  time: DateTime.now()
                                                      .toIso8601String()));
                                              version[i].showDetail = false;

                                              vLength++;

                                              version[0].showDetail = true;
                                            });
                                          },
                                        ),
                                      )),
                                ],
                              ),
                            ),
                            trailing: IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (version[i].showDetail)
                                      version[i].showDetail = false;
                                    else {
                                      for (var item in version) {
                                        item.showDetail = false;
                                      }

                                      version[i].showDetail =
                                          !version[i].showDetail;
                                    }
                                  });
                                },
                                icon: Icon(
                                  version[i].showDetail
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  size: 32,
                                )),
                          ),
                        ),
                      ),
                      itemCount: version.length,
                    ),
                    // )
                  ))
                ],
              ),
            );
          });
        });
  }

  Container svgFileIcon(
      double width, AsyncSnapshot<List<SimpleFile>> snapshot, int index) {
    return Container(
        width: width * 0.12,
        height: width * 0.12,
        decoration: BoxDecoration(
            border: Border(right: BorderSide(width: 1, color: Colors.grey))),
        child: SvgPicture.asset(
          svgIconAsset(snapshot.data![index].fileExt),
          fit: BoxFit.fill,
          // width: 48,
          // height: 48,
        ));
  }

  _appBar(BuildContext context, String photo) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MainPage()));
        },
        icon: Icon(Icons.home_outlined, color: Colors.grey),
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
}

class FileButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onClicked;
  FileButton({required this.icon, required this.text, required this.onClicked});
  Widget buildContext() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          SizedBox(
            width: 16,
          ),
          Text(
            text,
            style: TextStyle(fontSize: 22, color: Colors.white),
          )
        ],
      );
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: titleColor,
        minimumSize: Size(width * 0.8, height * 0.06),
      ),
      child: buildContext(),
      onPressed: onClicked,
    );
  }
}
