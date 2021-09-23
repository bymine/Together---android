import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/empty_data_display.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/live_project_model.dart';
import 'package:together_android/model/after_project_model/project_file_simple_model.dart';
import 'package:together_android/model/after_project_model/project_file_version_model.dart';
import 'package:together_android/page/after_project/project_file/project_file_main.dart';
import 'package:together_android/service/api.dart';

class ProjectFilePage extends StatefulWidget {
  const ProjectFilePage({Key? key}) : super(key: key);

  @override
  _ProjectFilePageState createState() => _ProjectFilePageState();
}

class _ProjectFilePageState extends State<ProjectFilePage> {
  Future<List<SimpleFile>> fetchFileSimpleDetail() async {
    var projectIdx =
        Provider.of<LiveProject>(context, listen: false).projectIdx;
    return await togetherGetAPI("/file/main", "?project_idx=$projectIdx");
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("공유 파일"),
      ),
      body: FutureBuilder<List<SimpleFile>>(
          future: fetchFileSimpleDetail(),
          builder: (context, snapshot) {
            print("공유 파일 builder 실행");
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return EmptyFileDataDisplay();
              } else {
                return FileMainPage(files: snapshot.data);
              }
            } else if (snapshot.hasError) return Text("error");

            return CircularProgressIndicator();
          }),
    );
  }
}

String SvgIconAsset(String type) {
  type = type.toLowerCase();
  switch (type) {
    case "png":
      return "assets/svg_icon/png.svg";

    case "jpg":
      return "assets/svg_icon/jpg.svg";

    case "doc":
      return "assets/svg_icon/doc.svg";

    case "csv":
      return "assets/svg_icon/csv.svg";

    case "docx":
      return "assets/svg_icon/docx.svg";

    case "pptx":
      return "assets/svg_icon/pptx.svg";

    case "ppt":
      return "assets/svg_icon/ppt.svg";

    case "txt":
      return "assets/svg_icon/txt.svg";

    case "xls":
      return "assets/svg_icon/xls.svg";

    case "xlsx":
      return "assets/svg_icon/xlsx.svg";

    case "pdf":
      return "assets/svg_icon/pdf.svg";

    default:
      return "assets/svg_icon/default.svg";
  }
}
