import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/input_field.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_project_model/project_schedule_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

class SchdeuleDetailPage extends StatefulWidget {
  final Schedule schedule;
  const SchdeuleDetailPage({Key? key, required this.schedule})
      : super(key: key);

  @override
  _SchdeuleDetailPageState createState() => _SchdeuleDetailPageState();
}

class _SchdeuleDetailPageState extends State<SchdeuleDetailPage> {
  String name = "";
  @override
  void initState() {
    fetchDetail();
    super.initState();
  }

  fetchDetail() async {
    var data = await togetherGetAPI("/project/detailSchedule",
        "?schedule_idx=${widget.schedule.scheduleIdx}");

    if (data != null)
      setState(() {
        name = data['schedule_writer_name'];
      });
  }

  @override
  Widget build(BuildContext context) {
    var photo = Provider.of<SignInModel>(context, listen: false).userPhoto;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: _appBar(context, photo),
      body: Wrap(
        children: [
          Container(
            margin: EdgeInsets.only(
                left: width * 0.08,
                right: width * 0.08,
                bottom: height * 0.02,
                top: height * 0.02),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xffffe0e0e0),
                    spreadRadius: 10,
                    blurRadius: 10,
                    offset: Offset(0, 5), // changes position of shadow
                  ),
                ]),
            padding: EdgeInsets.only(
                left: width * 0.08,
                right: width * 0.08,
                bottom: height * 0.04,
                top: height * 0.02),
            child: Column(
              children: [
                Text(
                  "Schdeule",
                  style: headingStyle,
                ),
                MyInputField(
                  title: "Title",
                  hint: widget.schedule.title,
                  suffixIcon: SizedBox(
                    width: 1,
                  ),
                ),
                MyInputField(
                  title: "Note",
                  hint: widget.schedule.content,
                  suffixIcon: SizedBox(
                    width: 1,
                  ),
                ),
                MyInputField(
                  title: "Start Day",
                  hint: toDateTimeISO(widget.schedule.startTime),
                  suffixIcon: SizedBox(
                    width: 1,
                  ),
                ),
                MyInputField(
                  title: "End Day",
                  hint: toDateTimeISO(widget.schedule.endTime),
                  suffixIcon: SizedBox(
                    width: 1,
                  ),
                ),
                MyInputField(
                  title: "Writer",
                  hint: name,
                  suffixIcon: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(widget.schedule.photo),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[200],
        onPressed: () async {
          // await togetherGetAPI("/project/", parameter)
        },
        child: Icon(
          Icons.delete_outline,
          color: Colors.red,
        ),
      ),
    );
  }

  _appBar(BuildContext context, String photo) {
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
