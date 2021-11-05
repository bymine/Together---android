import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
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

  List<SimpleFile>? _tasks = [];
  late bool _isLoading;
  late bool _permissionReady;
  late String _localPath;
  ReceivePort _port = ReceivePort();

  fetchFileSimpleDetail() async {
    print("File main futurebuilder ");
    var projectIdx =
        Provider.of<LiveProject>(context, listen: false).projectIdx;
    _tasks = await togetherGetAPI("/file/main", "?project_idx=$projectIdx");
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchFileSimpleDetail();

    _bindBackgroundIsolate();

    FlutterDownloader.registerCallback(downloadCallback);
    _prepare();
    _isLoading = true;
    _permissionReady = false;
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
    var project = Provider.of<LiveProject>(context, listen: false).projectName;
    _localPath = (await _findLocalPath())! + "/$project";
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
    _permissionReady = await _checkPermission();
    if (_permissionReady) {
      await _prepareSaveDir();
    }

    // final tasks = await FlutterDownloader.loadTasksWithRawQuery(
    //     query: 'SELECT * FROM task WHERE progress = 100');

    // tasks!.forEach((element) {
    //   if (element.savedDir == _localPath) print(element.filename);
    // });

    // print(_localPath);
    // String query = 'SELECT * FROM task WHERE progress = 100 ';

    // try {
    //   final tasks = await FlutterDownloader.loadTasksWithRawQuery(query: query);
    // tasks!.forEach((element) {
    //   print(element.filename);
    // });
    // } catch (e) {
    //   print(e);
    // }

    // _tasks!.forEach((element) async {
    //   // print(_localPath + "/" + element.fileName + "." + element.fileExt);
    //   if (await File(_localPath + element.fileName + "." + element.fileExt)
    //       .exists())
    //     print("yes");
    //   else
    //     print("no");
    // });

    setState(() {
      _isLoading = false;
    });
  }

  void _requestDownload(
    SimpleFile task,
  ) async {
    var name = task.fileName + "." + task.fileExt;

    print(name);
    Get.snackbar("파일 다운로드", "파일 다운로드 중입니다");
    task.taskId = await FlutterDownloader.enqueue(
      url: task.fileUrl,
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

  void _delete(SimpleFile task) async {
    await FlutterDownloader.remove(
        taskId: task.taskId!, shouldDeleteContent: true);
    await _prepare();
    setState(() {});
  }

  Future<bool> _openDownloadedFile(SimpleFile? task) {
    if (task != null) {
      return FlutterDownloader.open(taskId: task.taskId!);
    } else {
      return Future.value(false);
    }
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
        body: Builder(
          builder: (context) => _tasks == null
              ? Container(
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
                )
              : SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(
                        left: width * 0.04,
                        right: width * 0.04,
                        top: height * 0.02,
                        bottom: height * 0.02),
                    child: Column(
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
                                          builder: (context) =>
                                              FileUploadPage()))
                                      .then((value) {
                                    setState(() {
                                      fetchFileSimpleDetail();
                                    });
                                  });
                                }),
                          ],
                        ),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _tasks!.length,
                          itemBuilder: (context, index) {
                            return Card(
                              color: Colors.green[50],
                              child: ListTile(
                                onTap: () {
                                  Provider.of<SimpleFile>(context,
                                          listen: false)
                                      .setFileService(_tasks![index]);

                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) => FileDetailPage(
                                                fileName:
                                                    _tasks![index].fileName +
                                                        "." +
                                                        _tasks![index].fileExt,
                                              )))
                                      .then((value) => setState(() {
                                            fetchFileSimpleDetail();
                                          }));
                                },
                                leading: svgFileIcon(
                                    width, _tasks![index].fileExt, index),
                                title: Text(
                                  _tasks![index].fileName +
                                      "." +
                                      _tasks![index].fileExt,
                                  style: tileTitleStyle,
                                  maxLines: 2,
                                ),
                                trailing: _buildActionForTask(_tasks![index]),
                                // subtitle:
                                //     Text(_tasks![index].taskId ?? "no match"),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
        ));
  }

  existFileCheck(String name) async {
    var value = await File(name).exists();
    print(value);
  }

  Widget? _buildActionForTask(SimpleFile task) {
    if (task.status == DownloadTaskStatus.undefined) {
      return RawMaterialButton(
        onPressed: () {
          if (task.status == DownloadTaskStatus.undefined) {
            _requestDownload(task);
          } else if (task.status == DownloadTaskStatus.running) {
            _pauseDownload(task);
          } else if (task.status == DownloadTaskStatus.paused) {
            _resumeDownload(task);
          } else if (task.status == DownloadTaskStatus.complete) {
            _delete(task);
          } else if (task.status == DownloadTaskStatus.failed) {
            _retryDownload(task);
          }
        },
        child: Icon(Icons.file_download),
        shape: CircleBorder(),
        constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.running) {
      return RawMaterialButton(
        onPressed: () {
          if (task.status == DownloadTaskStatus.undefined) {
            _requestDownload(task);
          } else if (task.status == DownloadTaskStatus.running) {
            _pauseDownload(task);
          } else if (task.status == DownloadTaskStatus.paused) {
            _resumeDownload(task);
          } else if (task.status == DownloadTaskStatus.complete) {
            _delete(task);
          } else if (task.status == DownloadTaskStatus.failed) {
            _retryDownload(task);
          }
        },
        child: Icon(
          Icons.pause,
          color: Colors.red,
        ),
        shape: CircleBorder(),
        constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.paused) {
      return RawMaterialButton(
        onPressed: () {
          if (task.status == DownloadTaskStatus.undefined) {
            _requestDownload(task);
          } else if (task.status == DownloadTaskStatus.running) {
            _pauseDownload(task);
          } else if (task.status == DownloadTaskStatus.paused) {
            _resumeDownload(task);
          } else if (task.status == DownloadTaskStatus.complete) {
            _delete(task);
          } else if (task.status == DownloadTaskStatus.failed) {
            _retryDownload(task);
          }
        },
        child: Icon(
          Icons.play_arrow,
          color: Colors.green,
        ),
        shape: CircleBorder(),
        constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.complete) {
      return RawMaterialButton(
        onPressed: () {
          _openDownloadedFile(task).then((success) {
            if (!success) {
              Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text('Cannot open this file')));
            }
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("열기"),
            SizedBox(
              width: 5,
            ),
            Icon(
              Icons.open_in_new,
              color: Colors.grey,
            ),
          ],
        ),
        shape: CircleBorder(),
        constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.canceled) {
      return Text('Canceled', style: TextStyle(color: Colors.red));
    } else if (task.status == DownloadTaskStatus.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Failed', style: TextStyle(color: Colors.red)),
          RawMaterialButton(
            onPressed: () {
              if (task.status == DownloadTaskStatus.undefined) {
                _requestDownload(task);
              } else if (task.status == DownloadTaskStatus.running) {
                _pauseDownload(task);
              } else if (task.status == DownloadTaskStatus.paused) {
                _resumeDownload(task);
              } else if (task.status == DownloadTaskStatus.complete) {
                _delete(task);
              } else if (task.status == DownloadTaskStatus.failed) {
                _retryDownload(task);
              }
            },
            child: Icon(
              Icons.refresh,
              color: Colors.green,
            ),
            shape: CircleBorder(),
            constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else if (task.status == DownloadTaskStatus.enqueued) {
      return Text('Pending', style: TextStyle(color: Colors.orange));
    } else {
      return null;
    }
  }

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
