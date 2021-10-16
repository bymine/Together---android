import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as GET;
import 'package:group_button/group_button.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/componet/input_field.dart';
import 'package:together_android/constant.dart';
import 'package:path/path.dart' as Path;
import 'package:together_android/model/after_login_model/live_project_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';

class FileUploadPage extends StatefulWidget {
  const FileUploadPage({Key? key}) : super(key: key);

  @override
  _FileUploadPageState createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  File? _file;
  Dio dio = new Dio();

  var fileType = ["Read", "All"];
  String selectedType = "All";
  ValueNotifier<String> fileName = ValueNotifier<String>("No File Selected");

  @override
  Widget build(BuildContext context) {
    String projectName =
        Provider.of<LiveProject>(context, listen: false).projectName;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: _appBar(context),
      body: Container(
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
            Text("Upload File", style: headingStyle),
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
            Container(
              margin: EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Type",
                    style: editTitleStyle,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GroupButton(
                    selectedColor: titleColor,
                    mainGroupAlignment: MainGroupAlignment.start,
                    groupingType: GroupingType.wrap,
                    spacing: 8,
                    selectedTextStyle:
                        editSubTitleStyle.copyWith(color: Colors.black),
                    unselectedTextStyle: editSubTitleStyle,
                    selectedButton: fileType.indexOf(selectedType),
                    buttons: fileType,
                    onSelected: (index, isSelected) {
                      setState(() {
                        selectedType = fileType[index];
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            MyButton(
                label: "Upload",
                onTap: () async {
                  try {
                    var userIdx =
                        Provider.of<SignInModel>(context, listen: false)
                            .userIdx;
                    var projectIdx =
                        Provider.of<LiveProject>(context, listen: false)
                            .projectIdx;
                    String fileOriginName = fileName.value.split('.').first;
                    String fileExtenstion = fileName.value.split('.').last;

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

                    String url = "http://101.101.216.93:8080/file/uploadNew";

                    try {
                      final response = await dio.post(url,
                          data: formdata,
                          options: Options(headers: {
                            "Content-Type": "multipart/form-data"
                          }));

                      print(response.statusCode);
                      print(response.data);

                      if (response.toString() == "success") {
                        Navigator.pop(context, true);
                      } else if (response.toString() == "existed") {
                        GET.Get.snackbar(
                            "Faild Uplaod File", "This File Already Exists",
                            icon: Icon(Icons.warning, color: Colors.red),
                            snackPosition: GET.SnackPosition.BOTTOM);
                      }
                    } catch (e) {
                      GET.Get.snackbar(
                          "Faild Uplaod File", "The Maximum File Size is 10MB",
                          icon: Icon(Icons.warning, color: Colors.red),
                          snackPosition: GET.SnackPosition.BOTTOM);
                    }
                  } catch (e) {
                    GET.Get.snackbar("Faild Uplaod File", "Select File",
                        icon: Icon(Icons.warning, color: Colors.red),
                        snackPosition: GET.SnackPosition.BOTTOM);
                  }
                })
          ],
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
