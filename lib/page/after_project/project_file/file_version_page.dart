import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelines/timelines.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_project_model/project_file_simple_model.dart';
import 'package:together_android/model/after_project_model/project_file_version_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

class FileVersionPage extends StatefulWidget {
  const FileVersionPage({Key? key}) : super(key: key);

  @override
  _FileVersionPageState createState() => _FileVersionPageState();
}

class _FileVersionPageState extends State<FileVersionPage> {
  late Future future;

  fetchVersion() async {
    var fileIdx = Provider.of<SimpleFile>(context, listen: false).fileIdx;
    var version = await togetherGetAPI('/file/version', '/$fileIdx');

    return version;
  }

  @override
  void initState() {
    super.initState();
    future = fetchVersion();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var file = Provider.of<SimpleFile>(context, listen: false);

    return Scaffold(
      appBar: _appBar(context),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            left: width * 0.04,
            right: width * 0.04,
            bottom: height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("파일 버전", style: subHeadingStyle),
              SizedBox(
                height: 5,
              ),
              Text('${file.fileName}.${file.fileExt}',
                  style: headingStyle.copyWith(color: darkBlue, fontSize: 20)),
              SizedBox(
                height: 5,
              ),
              FutureBuilder(
                  future: future,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var data = snapshot.data as List<VersionFile>;

                      return Timeline.tileBuilder(
                        physics: NeverScrollableScrollPhysics(),
                        theme: TimelineTheme.of(context).copyWith(
                            color: titleColor,
                            nodePosition: 0,
                            indicatorPosition: 0.5),
                        // padding: EdgeInsets.symmetric(
                        //     vertical: width * 0.02, horizontal: width * 0.02),
                        shrinkWrap: true,
                        builder: TimelineTileBuilder.fromStyle(
                          itemCount: data.length,
                          connectorStyle: ConnectorStyle.solidLine,
                          contentsAlign: ContentsAlign.basic,
                          nodePositionBuilder: (context, i) => 0,
                          indicatorPositionBuilder: (context, i) => 0.5,
                          contentsBuilder: (context, i) => Card(
                            child: Container(
                              child: ListTile(
                                isThreeLine: true,
                                title: Text(
                                  " Ver.${data.length - i}",
                                  maxLines: 1,
                                  style: tileTitleStyle,
                                ),
                                subtitle: Visibility(
                                    visible: data[i].showDetail,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.border_color,
                                              color: Colors.grey,
                                              size: 16,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              data[data.length - i - 1].content,
                                              style: tileSubTitleStyle,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.person,
                                              color: Colors.grey,
                                              size: 16,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              data[data.length - i - 1].user,
                                              style: tileSubTitleStyle,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.today,
                                              color: Colors.grey,
                                              size: 16,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              toDateTime(DateTime.parse(
                                                      data[data.length - i - 1]
                                                          .time)
                                                  .add(Duration(hours: 9))),
                                              style: tileSubTitleStyle,
                                            ),
                                          ],
                                        ),
                                        Visibility(
                                            visible:
                                                data[i].showDetail && i != 0,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: MyButton(
                                                  label: "되돌리기",
                                                  onTap: () async {
                                                    var user = Provider.of<
                                                            SignInModel>(
                                                        context,
                                                        listen: false);
                                                    await togetherGetAPI(
                                                        "/file/detail/return",
                                                        "?file_idx=${file.fileIdx}&file_version_idx=${data.length - i}&user_idx=${user.userIdx}");

                                                    setState(() {
                                                      future = fetchVersion();
                                                    });
                                                  }),
                                            ))
                                      ],
                                    )),
                                trailing: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (data[i].showDetail)
                                          data[i].showDetail = false;
                                        else {
                                          for (var item in data) {
                                            item.showDetail = false;
                                          }

                                          data[i].showDetail =
                                              !data[i].showDetail;
                                        }
                                      });
                                    },
                                    icon: Icon(
                                      data[i].showDetail
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: Colors.grey,
                                      size: 32,
                                    )),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text("error");
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
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
        Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.help_outline,
              color: Colors.grey,
              size: 24,
            )),
        SizedBox(
          width: 20,
        )
      ],
    );
  }
}
