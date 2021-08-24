import 'package:flutter/material.dart';
import 'package:together_android/page/after_login/make_project/make_project_page.dart';

class EmptyDataDisplay extends StatefulWidget {
  const EmptyDataDisplay({Key? key}) : super(key: key);

  @override
  _EmptyDataDisplayState createState() => _EmptyDataDisplayState();
}

class _EmptyDataDisplayState extends State<EmptyDataDisplay> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        children: [
          Container(
            child: Image.asset('assets/empty.png'),
          ),
          Text(
            "진행 중인 프로젝트가 없습니다.",
            style:
                TextStyle(fontSize: width * 0.048, fontWeight: FontWeight.bold),
          ),
          Text(
            "새로운 프로젝트를 생성 하세요",
            style:
                TextStyle(fontSize: width * 0.042, color: Colors.grey.shade500),
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
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => MakeProjectBody()));
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add),
                  Text("프로젝트 생성하기"),
                ],
              ))
        ],
      ),
    );
  }
}
