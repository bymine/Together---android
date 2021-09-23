import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:group_button/group_button.dart';
import 'package:provider/provider.dart';
import 'package:timelines/timelines.dart';
import 'package:together_android/componet/bottom_sheet_top_bar.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/live_project_model.dart';
import 'package:together_android/model/after_project_model/project_file_simple_model.dart';
import 'package:together_android/model/after_project_model/project_file_version_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/page/after_project/project_file/project_file_page.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';
import 'package:path/path.dart';

class FileMainPage extends StatefulWidget {
  final List<SimpleFile>? files;

  FileMainPage({required this.files});

  @override
  _FileMainPageState createState() => _FileMainPageState();
}

class _FileMainPageState extends State<FileMainPage> {
  var fileType = ["Read", "All"];
  String selectedType = "All";
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    File? _file;
    Dio dio = new Dio();

    return Scaffold(
        body: ListView.builder(
            itemCount: widget.files!.length,
            itemBuilder: (context, index) {
              return Card(
                color: Colors.green[50],
                child: ListTile(
                  onTap: () {
                    print(widget.files![index].fileIdx);
                  },
                  leading: Container(
                      width: width * 0.12,
                      height: width * 0.12,
                      decoration: BoxDecoration(
                          border: Border(
                              right: BorderSide(width: 1, color: Colors.grey))),
                      child: SvgPicture.asset(
                        SvgIconAsset(widget.files![index].fileExt),
                        // color: titleColor,
                        fit: BoxFit.fill,
                        width: 48,
                        height: 48,
                      )),
                  title: Text(
                    widget.files![index].fileName +
                        "." +
                        widget.files![index].fileExt,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                      onPressed: () async {
                        var version = await togetherGetAPI("/file/version",
                            "/${widget.files![index].fileIdx}");
                        version as List<VersionFile>;
                        int vLength = version.length;
                        showModalBottomSheet(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16))),
                            isScrollControlled: true,
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                  builder: (context, setState) {
                                return Container(
                                  height: height * 0.7,
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    width: 1,
                                                    color: Colors.grey))),
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
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            Container(
                                              width: 40,
                                            )
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                          child: Timeline.tileBuilder(
                                        theme: TimelineTheme.of(context)
                                            .copyWith(
                                                color: titleColor,
                                                nodePosition: 0,
                                                indicatorPosition: 0.5),
                                        padding: EdgeInsets.symmetric(
                                            vertical: width * 0.02,
                                            horizontal: width * 0.02),
                                        shrinkWrap: true,

                                        builder: TimelineTileBuilder.fromStyle(
                                          connectorStyle:
                                              ConnectorStyle.solidLine,
                                          contentsAlign: ContentsAlign.basic,
                                          nodePositionBuilder: (context, i) =>
                                              0,
                                          indicatorPositionBuilder:
                                              (context, i) => 0.5,
                                          contentsBuilder: (context, i) => Card(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: width * 0.008),
                                              child: ListTile(
                                                isThreeLine: true,
                                                title: Text(
                                                  widget.files![index]
                                                          .fileName +
                                                      "." +
                                                      widget.files![index]
                                                          .fileExt +
                                                      " V${vLength - i}",
                                                  maxLines: 1,
                                                ),
                                                subtitle: Visibility(
                                                  visible:
                                                      version[i].showDetail,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text("설명 " +
                                                          version[vLength -
                                                                  i -
                                                                  1]
                                                              .content),
                                                      Text("작성자 " +
                                                          version[vLength -
                                                                  i -
                                                                  1]
                                                              .user),
                                                      Text("날짜 " +
                                                          toDateTime(DateTime
                                                                  .parse(version[
                                                                          vLength -
                                                                              i -
                                                                              1]
                                                                      .time)
                                                              .add(Duration(
                                                                  hours: 9)))),
                                                      Visibility(
                                                        visible: version[i]
                                                                .showDetail &&
                                                            i != 0,
                                                        child: Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Container(
                                                            width: width,
                                                            child:
                                                                ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(
                                                                        primary:
                                                                            titleColor),
                                                                    onPressed:
                                                                        () async {
                                                                      print(
                                                                          vLength -
                                                                              i);
                                                                      var user = Provider.of<
                                                                              SignInModel>(
                                                                          context,
                                                                          listen:
                                                                              false);

                                                                      await togetherGetAPI(
                                                                          "/file/detail/return",
                                                                          "?file_idx=${widget.files![index].fileIdx}&file_version_idx=${vLength - i}&user_idx=${user.userIdx}");

                                                                      setState(
                                                                          () {
                                                                        version.add(VersionFile(
                                                                            user: user
                                                                                .userName,
                                                                            content:
                                                                                "v${vLength - i} 되돌림",
                                                                            time:
                                                                                DateTime.now().toIso8601String()));
                                                                        version[i].showDetail =
                                                                            false;

                                                                        vLength++;

                                                                        version[0].showDetail =
                                                                            true;
                                                                      });
                                                                    },
                                                                    child: Text(
                                                                        "되돌리기")),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                trailing: IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        if (version[i]
                                                            .showDetail)
                                                          version[i]
                                                                  .showDetail =
                                                              false;
                                                        else {
                                                          for (var item
                                                              in version) {
                                                            item.showDetail =
                                                                false;
                                                          }

                                                          version[i]
                                                                  .showDetail =
                                                              !version[i]
                                                                  .showDetail;
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
                            }).then((value) => setState(() {}));
                      },
                      icon: Icon(Icons.history)),
                ),
              );
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            ValueNotifier<String> fileName =
                ValueNotifier<String>("No File Selected");

            showModalBottomSheet(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16))),
                isScrollControlled: true,
                context: context,
                builder: (context) {
                  return Container(
                    height: height * 0.5,
                    child: Column(
                      children: [
                        BottomSheetTopBar(
                            title: "파일 업로드",
                            onPressed: () async {
                              var userIdx = Provider.of<SignInModel>(context,
                                      listen: false)
                                  .userIdx;
                              var projectIdx = Provider.of<LiveProject>(context,
                                      listen: false)
                                  .projectIdx;
                              String fileOriginName =
                                  fileName.value.split('.').first;
                              String fileExtenstion =
                                  fileName.value.split('.').last;

                              FormData formdata = FormData.fromMap({
                                "multipartfile": await MultipartFile.fromFile(
                                  _file!.path,
                                  filename: fileName.value,
                                ),
                                "project_idx": projectIdx,
                                "file_origin_name": fileOriginName,
                                "file_extension": fileExtenstion,
                                "file_type": selectedType,
                                'user_idx': userIdx,
                              });

                              String url =
                                  "http://101.101.216.93:8080/file/uploadNew";
                              final response = await dio.post(url,
                                  data: formdata,
                                  options: Options(headers: {
                                    "Content-Type": "multipart/form-data"
                                  }));

                              print(response.statusCode);
                              print(response.data);

                              if (response.toString() == "success") {
                                setState(() {
                                  widget.files!.add(SimpleFile(
                                      fileIdx: 0,
                                      fileName: fileOriginName,
                                      fileExt: fileExtenstion,
                                      fileType: selectedType,
                                      fileFlag: ""));
                                });
                                Navigator.pop(context, true);
                                print(response.toString());
                                //print response from server
                              } else {
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   const SnackBar(
                                //     content: Text(
                                //       '파일이름이 중복되어서는 안됩니다.',
                                //       style: TextStyle(fontSize: 16),
                                //     ),
                                //   ),
                                // );
                                print("Error during connection to server.");
                              }
                            }),
                        FileButton(
                            icon: Icons.attach_file,
                            text: "파일 선택",
                            onClicked: () async {
                              final result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.any,
                                allowMultiple: false,
                                //     allowedExtensions: [
                                //   'doc',
                                //   'docx',
                                //   'pptx',
                                //   'xlm',
                                //   'xlsm',
                                //   'xlsx',
                                //   'ppt',
                                //   'hwp',
                                //   'hwpx',
                                //   'png',
                                //   'jpg'
                                // ],
                              );

                              if (result == null) return;
                              final path = result.files.single.path!;

                              setState(() {
                                _file = File(path);
                                fileName.value = _file != null
                                    ? basename(_file!.path)
                                    : 'No File Selected';
                              });
                            }),
                        ValueListenableBuilder(
                            valueListenable: fileName,
                            builder: (context, filename, child) {
                              return Text(fileName.value);
                            }),
                        GroupButton(
                            groupingType: GroupingType.wrap,
                            buttons: fileType,
                            isRadio: true,
                            selectedColor: titleColor,
                            spacing: width * 0.01,
                            selectedButton: fileType.indexOf(selectedType),
                            onSelected: (index, isSelected) {
                              setState(() {
                                selectedType = fileType[index];
                              });
                            })
                      ],
                    ),
                  );
                }).then((value) => setState(() {}));
          },
          child: Icon(Icons.file_upload),
        ));
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
