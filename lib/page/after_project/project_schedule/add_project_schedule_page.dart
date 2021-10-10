import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/input_field.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/live_project_model.dart';
import 'package:together_android/model/after_project_model/project_schedule_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

// ignore: must_be_immutable
class AddProjectSchdeule extends StatefulWidget {
  DateTime startDate;
  DateTime endDate;

  AddProjectSchdeule({
    Key? key,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  _AddProjectSchdeuleState createState() => _AddProjectSchdeuleState();
}

class _AddProjectSchdeuleState extends State<AddProjectSchdeule> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: _appBar(context),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
              left: width * 0.08, right: width * 0.08, bottom: height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Add Schedule", style: headingStyle),
              MyInputField(
                title: "Title",
                hint: "Input Schdeule Title",
                controller: titleController,
              ),
              MyInputField(
                title: "Note",
                hint: "Input Schdeule Description",
                maxLine: 3,
                controller: contentController,
              ),
              MyInputField(
                title: "Start Day",
                hint: toDate(widget.startDate),
                suffixIcon: IconButton(
                  onPressed: () {
                    _getDateTimeFromUser(true, true);
                  },
                  icon: Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),
              MyInputField(
                title: "Start Time",
                hint: toAMPMTimeISO(widget.startDate.toIso8601String()),
                suffixIcon: IconButton(
                  onPressed: () {
                    _getDateTimeFromUser(false, true);
                  },
                  icon: Icon(
                    Icons.schedule,
                    color: Colors.grey,
                  ),
                ),
              ),
              MyInputField(
                title: "End Day",
                hint: toDate(widget.endDate),
                suffixIcon: IconButton(
                  onPressed: () {
                    _getDateTimeFromUser(true, false);
                  },
                  icon: Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),
              MyInputField(
                title: "End Time",
                hint: toAMPMTimeISO(widget.endDate.toIso8601String()),
                suffixIcon: IconButton(
                  onPressed: () {
                    _getDateTimeFromUser(false, false);
                  },
                  icon: Icon(
                    Icons.schedule,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                  width: width,
                  height: height * 0.08,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: titleColor),
                      onPressed: () async {
                        var userIdx =
                            Provider.of<SignInModel>(context, listen: false)
                                .userIdx;
                        var projectIdx =
                            Provider.of<LiveProject>(context, listen: false)
                                .projectIdx;
                        Schedule schedule = Schedule(
                            title: titleController.text,
                            content: contentController.text,
                            startTime: widget.startDate.toIso8601String(),
                            endTime: widget.endDate.toIso8601String(),
                            projectIdx: projectIdx,
                            writedIdx: userIdx);

                        await togetherPostAPI(
                          "/project/addSchedule",
                          jsonEncode(schedule.toJson()),
                        );

                        Navigator.of(context).pop(schedule);
                      },
                      child: Text("+ Add Schdeule")))
            ],
          ),
        ),
      ),
    );
  }

  _getDateTimeFromUser(bool isDate, bool isStart) async {
    DateTime? _pickerDate;
    TimeOfDay? _pickerTime;
    if (isDate) {
      // date picker
      _pickerDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2024));
      if (_pickerDate != null) {
        if (isStart) {
          if (_pickerDate.isAfter(
              widget.endDate)) // start가 end이후 날짜일때 -->end = start + 1day
            setState(() {
              widget.startDate = _pickerDate!.add(Duration(
                  hours: widget.startDate.hour,
                  minutes: widget.startDate.minute));
              widget.endDate = _pickerDate.add(Duration(
                  days: 1,
                  hours: widget.endDate.hour,
                  minutes: widget.endDate.minute));
            });
          else
            setState(() {
              widget.startDate = _pickerDate!.add(Duration(
                  hours: widget.startDate.hour,
                  minutes: widget.startDate.minute));
            });
        } else {
          if (_pickerDate.isBefore(
              widget.startDate)) // end가 start 이전일때   --> start = end -1day
            setState(() {
              widget.startDate = _pickerDate!.add(Duration(
                  days: -1,
                  hours: widget.startDate.hour,
                  minutes: widget.startDate.minute));
              widget.endDate = _pickerDate.add(Duration(
                  hours: widget.endDate.hour, minutes: widget.endDate.minute));
            });
          else
            setState(() {
              widget.endDate = _pickerDate!.add(Duration(
                  hours: widget.endDate.hour, minutes: widget.endDate.minute));
            });
        }
      }
    } else if (isDate == false) {
      // time picker
      _pickerTime = await showTimePicker(
          context: context,
          initialEntryMode: TimePickerEntryMode.input,
          initialTime: isStart == true
              ? TimeOfDay.fromDateTime(widget.startDate)
              : TimeOfDay.fromDateTime(widget.endDate));
      if (_pickerTime != null) {
        if (isStart) {
          setState(() {
            widget.startDate = DateTime(
                widget.startDate.year,
                widget.startDate.month,
                widget.startDate.day,
                _pickerTime!.hour,
                _pickerTime.minute);
            if (widget.startDate.isAfter(widget.endDate)) {
              widget.endDate = widget.startDate.add(Duration(hours: 1));
            }
          });
        } else if (isStart == false) {
          setState(() {
            widget.endDate = DateTime(widget.endDate.year, widget.endDate.month,
                widget.endDate.day, _pickerTime!.hour, _pickerTime.minute);
          });
        }
      }
    }
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
