// import 'dart:io';

// import 'package:dio/dio.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:group_button/group_button.dart';
// import 'package:provider/provider.dart';
// import 'package:together_android/componet/bottom_sheet_top_bar.dart';
// import 'package:together_android/constant.dart';
// import 'package:together_android/model/after_login_model/live_project_model.dart';
// import 'package:together_android/model/before_login_model/sign_in_model.dart';
// import 'package:together_android/page/after_login/make_project/make_project_page.dart';
// import 'package:path/path.dart' as Path;

// class EmptyDataDisplay extends StatefulWidget {
//   // const EmptyDataDisplay({Key? key}) : super(key: key);

//   @override
//   _EmptyDataDisplayState createState() => _EmptyDataDisplayState();
// }

// class _EmptyDataDisplayState extends State<EmptyDataDisplay> {
//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double height = MediaQuery.of(context).size.height;
//     return Scaffold(
//       body: Column(
//         children: [
//           Container(
//             width: width,
//             height: height * 0.5,
//             child: Image.asset('assets/empty.png'),
//           ),
//           Text(
//             "진행 중인 프로젝트가 없습니다.",
//             style:
//                 TextStyle(fontSize: width * 0.048, fontWeight: FontWeight.bold),
//           ),
//           Text(
//             "새로운 프로젝트를 생성 하세요",
//             style:
//                 TextStyle(fontSize: width * 0.042, color: Colors.grey.shade500),
//           ),
//           SizedBox(
//             height: height * 0.08,
//           ),
//           ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20)),
//                   minimumSize: Size(width * 0.6, height * 0.1),
//                   primary: Colors.green.withOpacity(0.5)),
//               onPressed: () {
//                 Navigator.of(context)
//                     .push(MaterialPageRoute(
//                         builder: (context) => MakeProjectBody()))
//                     .then((value) => setState(() {}));
//               },
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.add),
//                   Text("프로젝트 생성하기"),
//                 ],
//               ))
//         ],
//       ),
//     );
//   }
// }

// class EmptyFileDataDisplay extends StatefulWidget {
//   @override
//   _EmptyFileDataDisplayState createState() => _EmptyFileDataDisplayState();
// }

// class _EmptyFileDataDisplayState extends State<EmptyFileDataDisplay> {
//   File? _file;
//   Dio dio = new Dio();

//   var fileType = ["Read", "All"];
//   String selectedType = "All";
//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double height = MediaQuery.of(context).size.height;
//     return Scaffold(
//       body: Column(
//         children: [
//           Container(
//             width: width,
//             height: height * 0.5,
//             child: Image.asset('assets/empty.png'),
//           ),
//           Text(
//             "공유한 파일이 없습니다.",
//             style:
//                 TextStyle(fontSize: width * 0.048, fontWeight: FontWeight.bold),
//           ),
//           Text(
//             "새로운 파일을 업로드 하세요",
//             style:
//                 TextStyle(fontSize: width * 0.042, color: Colors.grey.shade500),
//           ),
//           SizedBox(
//             height: height * 0.08,
//           ),
//           ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20)),
//                   minimumSize: Size(width * 0.6, height * 0.1),
//                   primary: Colors.green.withOpacity(0.5)),
//               onPressed: () async {
//                 ValueNotifier<String> fileName =
//                     ValueNotifier<String>("No File Selected");

//                 showModalBottomSheet(
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(16),
//                             topRight: Radius.circular(16))),
//                     isScrollControlled: true,
//                     context: context,
//                     builder: (context) {
//                       return Container(
//                         height: height * 0.5,
//                         child: Column(
//                           children: [
//                             BottomSheetTopBar(
//                                 title: "파일 업로드",
//                                 onPressed: () async {
//                                   var userIdx = Provider.of<SignInModel>(
//                                           context,
//                                           listen: false)
//                                       .userIdx;
//                                   var projectIdx = Provider.of<LiveProject>(
//                                           context,
//                                           listen: false)
//                                       .projectIdx;
//                                   String fileOriginName =
//                                       fileName.value.split('.').first;
//                                   String fileExtenstion =
//                                       fileName.value.split('.').last;

//                                   FormData formdata = FormData.fromMap({
//                                     "multipartfile":
//                                         await MultipartFile.fromFile(
//                                       _file!.path,
//                                       filename: fileName.value,
//                                     ),
//                                     "project_idx": projectIdx,
//                                     "file_origin_name": fileOriginName,
//                                     "file_extension": fileExtenstion,
//                                     "file_type": selectedType,
//                                     'user_idx': userIdx,
//                                   });

//                                   String url =
//                                       "http://101.101.216.93:8080/file/uploadNew";
//                                   final response = await dio.post(url,
//                                       data: formdata,
//                                       options: Options(headers: {
//                                         "Content-Type": "multipart/form-data"
//                                       }));

//                                   print(response.statusCode);
//                                   print(response.data);

//                                   if (response.toString() == "success") {
//                                     setState(() {});
//                                     Navigator.pop(context, true);
//                                     print(response.toString());
//                                     //print response from server
//                                   } else {
//                                     // ScaffoldMessenger.of(context).showSnackBar(
//                                     //   const SnackBar(
//                                     //     content: Text(
//                                     //       '파일이름이 중복되어서는 안됩니다.',
//                                     //       style: TextStyle(fontSize: 16),
//                                     //     ),
//                                     //   ),
//                                     // );
//                                     print("Error during connection to server.");
//                                   }
//                                 }),
//                             FileButton(
//                                 icon: Icons.attach_file,
//                                 text: "파일 선택",
//                                 onClicked: () async {
//                                   final result =
//                                       await FilePicker.platform.pickFiles(
//                                     type: FileType.any,
//                                     allowMultiple: false,
//                                     //     allowedExtensions: [
//                                     //   'doc',
//                                     //   'docx',
//                                     //   'pptx',
//                                     //   'xlm',
//                                     //   'xlsm',
//                                     //   'xlsx',
//                                     //   'ppt',
//                                     //   'hwp',
//                                     //   'hwpx',
//                                     //   'png',
//                                     //   'jpg'
//                                     // ],
//                                   );

//                                   if (result == null) return;
//                                   final path = result.files.single.path!;

//                                   setState(() {
//                                     _file = File(path);
//                                     fileName.value = _file != null
//                                         ? Path.basename(_file!.path)
//                                         //? _file!.path
//                                         : 'No File Selected';
//                                   });
//                                 }),
//                             ValueListenableBuilder(
//                                 valueListenable: fileName,
//                                 builder: (context, filename, child) {
//                                   return Text(fileName.value);
//                                 }),
//                             GroupButton(
//                                 groupingType: GroupingType.wrap,
//                                 buttons: fileType,
//                                 isRadio: true,
//                                 selectedColor: titleColor,
//                                 spacing: width * 0.01,
//                                 selectedButton: fileType.indexOf(selectedType),
//                                 onSelected: (index, isSelected) {
//                                   setState(() {
//                                     selectedType = fileType[index];
//                                   });
//                                 })
//                           ],
//                         ),
//                       );
//                     }).then((value) => setState(() {}));
//               },
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.cloud_upload),
//                   Text("파일 업로드 하기"),
//                 ],
//               ))
//         ],
//       ),
//     );
//   }
// }
