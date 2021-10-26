import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as GET;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/componet/input_field.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/live_project_model.dart';
import 'package:path/path.dart' as Path;
import 'package:together_android/model/after_project_model/project_file_simple_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';

class FileVersionUpload extends StatefulWidget {
  final String name;
  FileVersionUpload({
    Key? key,
    required this.name,
  }) : super(key: key);

  @override
  _FileVersionUploadState createState() => _FileVersionUploadState();
}

class _FileVersionUploadState extends State<FileVersionUpload> {
  File? _file;
  Dio dio = new Dio();
  ValueNotifier<String> fileName = ValueNotifier<String>("No File Selected");
  TextEditingController controller = TextEditingController();

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

  @override
  void initState() {
    super.initState();

    // _findLocalPath().then((value) {
    //   final path = value! + "/" + widget.name;

    //   File(path).exists().then((value) {
    //     if (value == true) {
    //       setState(() {
    //         _file = File(path);
    //         print(_file!.path);
    //         fileName.value = widget.name;
    //       });
    //     } else {
    //       setState(() {
    //         fileName.value = "No File Selected";
    //       });
    //     }
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    String projectName =
        Provider.of<LiveProject>(context, listen: false).projectName;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: _appBar(context),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
              left: width * 0.08,
              right: width * 0.08,
              bottom: height * 0.02,
              top: height * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                projectName,
                style: subHeadingStyle,
              ),
              SizedBox(
                height: 5,
              ),
              Text("Upload ${widget.name} File", style: headingStyle),
              MyInputField(
                title: "File",
                hint: fileName.value,
                maxLine: 1,
                suffixIcon: IconButton(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.any,
                      allowMultiple: false,
                    );

                    if (result == null) return;
                    final path = result.files.single.path!;
                    setState(() {
                      _file = File(path);
                      fileName.value = _file != null
                          ? Path.basename(_file!.path)
                          : 'No File Selected';
                    });
                  },
                  icon: Icon(
                    Icons.cloud_upload,
                    color: Colors.grey,
                  ),
                ),
              ),
              MyInputField(
                title: "Comment",
                hint: "Input modify comment",
                controller: controller,
                maxLine: 4,
              ),
              SizedBox(
                height: 30,
              ),
              MyButton(
                  label: "Upload",
                  onTap: () async {
                    var userIdx =
                        Provider.of<SignInModel>(context, listen: false)
                            .userIdx;
                    var fileIdx =
                        Provider.of<SimpleFile>(context, listen: false).fileIdx;

                    if (fileName.value != widget.name) {
                      GET.Get.defaultDialog(
                          title: "업로드할 파일 이름이 다릅니다",
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("파일 이름 변경"),
                              Text(fileName.value + "-->" + widget.name)
                            ],
                          ),
                          confirm: Text("실행"),
                          cancel: Text("취소"));
                    } else {
                      try {
                        print(_file!.path);
                        FormData formdata = FormData.fromMap({
                          "multipartfile": await MultipartFile.fromFile(
                            _file!.path,
                            filename: fileName.value,
                            //show only filename from path
                          ),
                          "file_idx": fileIdx,
                          "user_modified_idx": userIdx,
                          "file_modified_comment": controller.text
                        });
                        String url =
                            "http://101.101.216.93:8080/file/detail/uploadVersion";
                        final response = await dio.post(url,
                            data: formdata,
                            options: Options(headers: {
                              "Content-Type": "multipart/form-data"
                            }));

                        print(response.statusCode);
                      } catch (e) {
                        print(e);
                      }
                    }
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
