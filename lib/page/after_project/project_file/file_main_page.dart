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
    print(_localPath);
    final tasks = await FlutterDownloader.loadTasks();
    print(tasks);
    // tasks!.forEach((task) {
    //   if (task.savedDir == _localPath) {
    //     for (SimpleFile file in _tasks!) {

    //     }
    //   }
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
        body: SingleChildScrollView(
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
                                  builder: (context) => FileUploadPage()))
                              .then((value) {
                            setState(() {
                              fetchFileSimpleDetail();
                            });
                          });
                        }),
                  ],
                ),
                Builder(
                  builder: (context) => _tasks == null
                      ? Text("Empty Shared File")
                      : ListView.builder(
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
                                      .then((value) => setState(() {}));
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
                                subtitle: Column(
                                  children: [
                                    Text(_tasks![index].taskId.toString()),
                                    Text(_tasks![index].status.toString()),
                                  ],
                                ),
                                trailing: _buildActionForTask(_tasks![index]),
                              ),
                            );
                          },
                        ),
                ),
              ],
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
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: () {
              _openDownloadedFile(task).then((success) {
                if (!success) {
                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text('Cannot open this file')));
                }
              });
            },
            child: Text(
              '보기',
              style: TextStyle(color: Colors.green),
            ),
          ),
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
              Icons.delete_forever,
              color: Colors.red,
            ),
            shape: CircleBorder(),
            constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
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
