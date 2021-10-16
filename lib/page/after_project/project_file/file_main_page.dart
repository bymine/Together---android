import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/live_project_model.dart';
import 'package:together_android/model/after_project_model/project_file_simple_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/page/after_login/main_page.dart';
import 'package:together_android/page/after_project/project_file/file_upload_page.dart';
import 'package:together_android/page/after_project/project_file/file_detail_page.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

class ProjectFilePage extends StatefulWidget with WidgetsBindingObserver {
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
                                  setState(() {});
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
                                        : "읽기 쓰기",
                                    style: editSubTitleStyle,
                                  ),
                                  trailing: IconButton(
                                      onPressed: () async {},
                                      icon: Icon(Icons.download)),
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

  Container svgFileIcon(
      double width, AsyncSnapshot<List<SimpleFile>> snapshot, int index) {
    return Container(
        width: width * 0.12,
        height: width * 0.12,
        decoration: BoxDecoration(
            border: Border(right: BorderSide(width: 0.5, color: Colors.grey))),
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
