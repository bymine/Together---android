import 'package:flutter/material.dart';
import 'package:together_android/utils.dart';

// ignore: must_be_immutable
class DatePickerWidget extends StatefulWidget {
  DateTime selectedDate;

  DateTime standardDate;
  DatePickerWidget({required this.selectedDate, required this.standardDate});
  @override
  _DatePickerWidgetState createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(toDate(widget.selectedDate)),
        IconButton(
            onPressed: () async {
              await showDatePicker(
                context: context,
                initialDate: widget.standardDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2025),
              ).then((value) {
                setState(() {
                  widget.selectedDate = value!;
                });
              });
            },
            icon: Icon(Icons.arrow_drop_down_outlined, size: 32))
      ],
    );
  }
}
