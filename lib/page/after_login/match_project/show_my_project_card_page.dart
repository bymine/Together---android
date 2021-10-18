import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/componet/input_field.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/team_card.dart';
import 'package:together_android/model/mappingProject_model.dart';

// ignore: must_be_immutable
class ShowProjectCard extends StatefulWidget {
  ProjectCard? card;
  Map<String, int> map;
  ShowProjectCard({Key? key, this.card, required this.map}) : super(key: key);

  @override
  _ShowProjectCardState createState() => _ShowProjectCardState();
}

class _ShowProjectCardState extends State<ShowProjectCard> {
  String _selectProject = "";

  @override
  void initState() {
    super.initState();
    _selectProject = widget.map.keys.first;
  }

  @override
  Widget build(BuildContext context) {
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
                top: height * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.card == null ? "Add Card" : "My Card",
                      style: headingStyle,
                    ),
                    MyButton(
                        label:
                            widget.card == null ? "+ Add Card" : "Update Card",
                        onTap: () {})
                  ],
                ),
                Visibility(
                  visible: widget.card == null,
                  child: MyInputField(
                    title: "Select Project",
                    hint: _selectProject,
                    suffixIcon: DropdownButton(
                      dropdownColor: Colors.blueGrey,
                      value: _selectProject,
                      underline: Container(),
                      items: Provider.of<MappingProject>(context, listen: false)
                          .map
                          .keys
                          .toList()
                          .map((value) {
                        return DropdownMenuItem(
                            value: value,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(value,
                                  style: editSubTitleStyle.copyWith(
                                      color: Colors.white)),
                            ));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectProject = value.toString();
                          print(_selectProject);
                        });
                      },
                    ),
                  ),
                ),
                MyInputField(
                    title: "Project Info",
                    hint: "이름\n 설명\n 시작날짜\n 종료날짜\n 타입\n 레벨\n 표시 구간"),
                MyInputField(title: "Comment", hint: "")
              ],
            ),
          ),
        ));
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
