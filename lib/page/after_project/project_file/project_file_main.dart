import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:timelines/timelines.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_project_model/project_file_simple_model.dart';
import 'package:together_android/model/after_project_model/project_file_version_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/page/after_project/project_file/project_file_page.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

class FileMainPage extends StatefulWidget {
  final List<SimpleFile>? files;

  FileMainPage({required this.files});

  @override
  _FileMainPageState createState() => _FileMainPageState();
}

class _FileMainPageState extends State<FileMainPage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        body: ListView.builder(
            itemCount: widget.files!.length,
            itemBuilder: (context, index) {
              return Card(
                color: Colors.green[50],
                child: ListTile(
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
                                                  vertical: width * 0.005),
                                              child: ListTile(
                                                title: Text(widget.files![index]
                                                        .fileName +
                                                    "." +
                                                    widget
                                                        .files![index].fileExt +
                                                    " V${vLength - i}"),
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
          onPressed: () {},
          child: Icon(Icons.file_upload),
        ));
  }
}
