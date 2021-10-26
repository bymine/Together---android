import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/componet/input_field.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_project_model/project_file_simple_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

class AddReservationPage extends StatefulWidget {
  const AddReservationPage({
    Key? key,
  }) : super(key: key);

  @override
  _AddReservationPageState createState() => _AddReservationPageState();
}

class _AddReservationPageState extends State<AddReservationPage> {
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now().add(Duration(hours: 1));

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var fileName = Provider.of<SimpleFile>(context, listen: false);
    return Scaffold(
      appBar: _appBar(context),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            left: width * 0.08,
            right: width * 0.08,
            bottom: height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("File Reservation", style: subHeadingStyle),
              MyInputField(
                title: "File",
                hint: fileName.fileName + "." + fileName.fileExt,
                suffixIcon: Container(
                  width: 1,
                ),
              ),
              MyInputField(
                title: "Start Day",
                hint: toDate(startTime),
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
                hint: toAMPMTimeISO(startTime.toIso8601String()),
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
                hint: toDate(endTime),
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
                hint: toAMPMTimeISO(endTime.toIso8601String()),
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
                height: 15,
              ),
              MyButton(
                  label: "+ 예약하기",
                  onTap: () async {
                    int userIdx =
                        Provider.of<SignInModel>(context, listen: false)
                            .userIdx;
                    int fileIdx =
                        Provider.of<SimpleFile>(context, listen: false).fileIdx;
                    var code = await togetherPostAPI(
                        "/file/detail/reserveFile",
                        jsonEncode({
                          'user_idx': userIdx,
                          'file_idx': fileIdx,
                          'start_datetime': startTime.toIso8601String(),
                          'end_datetime': endTime.toIso8601String(),
                        }));
                    print(code.toString());
                    if (code.toString() == "success") {
                      Navigator.of(context).pop();
                    } else {
                      Get.snackbar(
                        "파일 예약 실패",
                        "이미 예약된 시간입니다. 다시 예약해주세요",
                        colorText: Color(0xFFff4667),
                        icon: Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFff4667),
                        ),
                      );
                    }
                  })
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
          if (_pickerDate
              .isAfter(endTime)) // start가 end이후 날짜일때 -->end = start + 1day
            setState(() {
              startTime = _pickerDate!.add(
                  Duration(hours: startTime.hour, minutes: startTime.minute));
              endTime = _pickerDate.add(
                  Duration(hours: endTime.hour + 1, minutes: endTime.minute));
            });
          else
            setState(() {
              startTime = _pickerDate!.add(
                  Duration(hours: startTime.hour, minutes: startTime.minute));
            });
        } else {
          if (_pickerDate
              .isBefore(startTime)) // end가 start 이전일때   --> start = end -1day
            setState(() {
              startTime = _pickerDate!.add(
                  Duration(hours: startTime.hour, minutes: startTime.minute));
              endTime = _pickerDate
                  .add(Duration(hours: endTime.hour, minutes: endTime.minute));
            });
          else
            setState(() {
              endTime = _pickerDate!
                  .add(Duration(hours: endTime.hour, minutes: endTime.minute));
            });
        }
      }
    } else if (isDate == false) {
      // time picker
      _pickerTime = await showTimePicker(
          context: context,
          initialEntryMode: TimePickerEntryMode.input,
          initialTime: isStart == true
              ? TimeOfDay.fromDateTime(startTime)
              : TimeOfDay.fromDateTime(endTime));
      if (_pickerTime != null) {
        if (isStart) {
          setState(() {
            startTime = DateTime(startTime.year, startTime.month, startTime.day,
                _pickerTime!.hour, _pickerTime.minute);
            if (startTime.isAfter(endTime)) {
              endTime = startTime.add(Duration(hours: 1));
            }
          });
        } else if (isStart == false) {
          setState(() {
            endTime = DateTime(endTime.year, endTime.month, endTime.day,
                _pickerTime!.hour, _pickerTime.minute);
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
