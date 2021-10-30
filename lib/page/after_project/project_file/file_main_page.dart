import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
import 'package:async/async.dart';

class ProjectFilePage extends StatefulWidget with WidgetsBindingObserver {
  const ProjectFilePage({Key? key}) : super(key: key);

  @override
  _ProjectFilePageState createState() => _ProjectFilePageState();
}

class _ProjectFilePageState extends State<ProjectFilePage> {
  late Future future;
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  List<SimpleFile>? _tasks;
  late bool _isLoading;
  late bool _permissionReady;
  late String _localPath;
  ReceivePort _port = ReceivePort();

  fetchFileSimpleDetail() async {
    var projectIdx =
        Provider.of<LiveProject>(context, listen: false).projectIdx;
    return await togetherGetAPI("/file/main", "?project_idx=$projectIdx");
  }

  @override
  void initState() {
    super.initState();
    future = fetchFileSimpleDetail();

    _bindBackgroundIsolate();

    FlutterDownloader.registerCallback(downloadCallback);

    _isLoading = true;
    _permissionReady = false;

    _prepare();
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      if (true) {
        print('UI Isolate Callback: $data');
      }
      String? id = data[0];
      DownloadTaskStatus? status = data[1];
      int? progress = data[2];

      if (_tasks != null && _tasks!.isNotEmpty) {
        final task = _tasks!.firstWhere((task) => task.taskId == id);
        setState(() {
          task.status = status;
          task.progress = progress;
        });
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    if (true) {
      print(
          'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    }
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  Future<bool> _checkPermission() async {
    final status = await Permission.storage.status;
    if (status != PermissionStatus.granted) {
      final result = await Permission.storage.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    } else {
      return true;
    }

    return false;
  }

  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath())!;
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String?> _findLocalPath() async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        externalStorageDirPath = await AndroidPathProvider.downloadsPath;
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath;
  }

  _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();

    tasks!.forEach((element) {});

    _permissionReady = await _checkPermission();
    if (_permissionReady) {
      await _prepareSaveDir();
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _requestDownload(SimpleFile task, bool isReadMode) async {
    var name = isReadMode
        ? task.fileName + ".pdf"
        : task.fileName + "." + task.fileExt;
    print(await File(_localPath + "/" + name).exists());
    task.taskId = await FlutterDownloader.enqueue(
      url: isReadMode ? task.readLink : task.writeLink,
      fileName: name,
      savedDir: _localPath,
      showNotification: true,
      openFileFromNotification: true,
      saveInPublicStorage: true,
    );
    setState(() {
      print("aaaaaaaaaaaaaa" + task.status.toString());
      print("aaaaaaaaaaaaaa" + task.taskId.toString());
      print("aaaaaaaaaaaaaa" + task.progress.toString());
    });
  }

  void _delete(SimpleFile task) async {
    await FlutterDownloader.remove(
        taskId: task.taskId!, shouldDeleteContent: true);
    await _prepare();
    setState(() {});
  }

  void _cancelDownload(SimpleFile task) async {
    await FlutterDownloader.cancel(taskId: task.taskId!);
  }

  void _pauseDownload(SimpleFile task) async {
    await FlutterDownloader.pause(taskId: task.taskId!);
  }

  void _resumeDownload(SimpleFile task) async {
    String? newTaskId = await FlutterDownloader.resume(taskId: task.taskId!);
    task.taskId = newTaskId;
  }

  void _retryDownload(SimpleFile task) async {
    String? newTaskId = await FlutterDownloader.retry(taskId: task.taskId!);
    task.taskId = newTaskId;
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
      body: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var files = snapshot.data as List<SimpleFile>;
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
                                "공유 파일",
                                style: subHeadingStyle,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                projectName,
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
                                    future = fetchFileSimpleDetail();
                                  });
                                });
                              }),
                        ],
                      ),
                      Container(
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: files.length,
                            itemBuilder: (context, index) {
                              return Card(
                                color: Colors.green[50],
                                child: ListTile(
                                  onTap: () {
                                    Provider.of<SimpleFile>(context,
                                            listen: false)
                                        .setFileService(files[index]);

                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) =>
                                                FileDetailPage(
                                                  fileName:
                                                      files[index].fileName +
                                                          "." +
                                                          files[index].fileExt,
                                                )))
                                        .then((value) => setState(() {}));
                                  },
                                  leading: svgFileIcon(
                                      width, files[index].fileExt, index),
                                  title: Text(
                                      files[index].fileName +
                                          "." +
                                          files[index].fileExt,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: tileTitleStyle),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        files[index].fileType == "Read"
                                            ? "읽기 전용"
                                            : "읽기 쓰기",
                                        style: tileSubTitleStyle,
                                      ),
                                      files[index].status ==
                                                  DownloadTaskStatus.running ||
                                              files[index].status ==
                                                  DownloadTaskStatus.paused
                                          ? LinearProgressIndicator(
                                              value:
                                                  files[index].progress! / 100,
                                            )
                                          : Container(),
                                      Text(files[index].status.toString())
                                    ],
                                  ),
                                  trailing: IconButton(
                                      onPressed: () async {
                                        if (files[index].fileType == "All") {
                                          showModalBottomSheet(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  20),
                                                          topRight:
                                                              Radius.circular(
                                                                  20))),
                                              context: context,
                                              builder: (context) {
                                                return Container(
                                                  child: Wrap(
                                                    alignment:
                                                        WrapAlignment.center,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        8),
                                                            child: Text(
                                                              "파일 다운로드",
                                                              style: editTitleStyle
                                                                  .copyWith(
                                                                      fontSize:
                                                                          18),
                                                            ),
                                                          ),
                                                          Divider(
                                                            thickness: 1,
                                                          ),
                                                          TextButton(
                                                              onPressed: () {
                                                                _requestDownload(
                                                                    files[
                                                                        index],
                                                                    true);

                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                  "읽기 전용 다운로드")),
                                                          Divider(
                                                            thickness: 1,
                                                          ),
                                                          TextButton(
                                                              onPressed: () {
                                                                _requestDownload(
                                                                    files[
                                                                        index],
                                                                    false);
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                "수정 전용 다운로드",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .redAccent),
                                                              )),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              });
                                        }
                                      },
                                      icon: Icon(Icons.file_download)),
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
                              future = fetchFileSimpleDetail();
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

  // Icon trailingIcon(SimpleFile file) {
  //   if (file.status == DownloadTaskStatus.undefined)
  //     return Icon(Icons.file_download);
  //   else if (file.status == DownloadTaskStatus.running)
  //     return Icon(Icons.pause);
  //   else if (file.status == DownloadTaskStatus.paused)
  //     return Icon(Icons.play_arrow);
  //   else if (file.status == DownloadTaskStatus.complete)
  //     return Icon(Icons.delete_forever);
  //   else if (file.status == DownloadTaskStatus.canceled)
  //     return Icon(Icons.cancel);
  //   else if (file.status == DownloadTaskStatus.failed)
  //     return Icon(Icons.refresh);
  //   else if (file.status == DownloadTaskStatus.enqueued)
  //     return Icon(Icons.equalizer_rounded);
  //   else
  //     return Icon(Icons.check_box);
  // }

  Container svgFileIcon(double width, String ext, int index) {
    return Container(
        width: width * 0.1,
        height: width * 0.1,
        decoration: BoxDecoration(
            border: Border(right: BorderSide(width: 0.5, color: Colors.grey))),
        child: SvgPicture.asset(
          svgIconAsset(ext),
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
