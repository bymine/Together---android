// import 'dart:collection';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:together_android/componet/bottom_sheet_top_bar.dart';
// import 'package:together_android/componet/textfield_widget.dart';
// import 'package:together_android/constant.dart';
// import 'package:together_android/model/after_login_model/live_project_model.dart';
// import 'package:together_android/model/after_project_model/project_schedule_model.dart';
// import 'package:together_android/model/before_login_model/sign_in_model.dart';
// import 'package:together_android/service/api.dart';
// import 'package:together_android/utils.dart';

// class ProjectSchedulePage extends StatefulWidget {
//   const ProjectSchedulePage({Key? key}) : super(key: key);

//   @override
//   _ProjectSchedulePageState createState() => _ProjectSchedulePageState();
// }

// class _ProjectSchedulePageState extends State<ProjectSchedulePage> {
//   List<Schedule> _allSchedule = [];
//   List<Schedule> _selectedSchedule = [];
//   CalendarFormat _calendarFormat = CalendarFormat.month;
//   RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;
//   DateTime? _rangeStart;
//   DateTime? _rangeEnd;
//   TextEditingController titleController = TextEditingController();
//   TextEditingController contentController = TextEditingController();

//   DateTime startDate = DateTime.now();
//   DateTime endDate = DateTime.now();

//   var schedules = LinkedHashMap(
//     equals: isSameDay,
//     hashCode: getHashCode,
//   );

//   Future<List<Schedule>> fetchProjectSchdeule() async {
//     var proejctIdx =
//         Provider.of<LiveProject>(context, listen: false).projectIdx;
//     var list =
//         await togetherGetAPI("/project/main", "?project_idx=$proejctIdx");
//     return list as List<Schedule>;
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchProjectSchdeule().then((value) => setState(() {
//           _allSchedule = value;
//           _allSchedule.forEach((schedule) {
//             DateTime start = DateTime.parse(schedule.startTime);
//             DateTime end = DateTime.parse(schedule.endTime);

//             int startCode = getHashCode(start);
//             int endCode = getHashCode(end);

//             for (startCode = startCode;
//                 startCode <= endCode;
//                 startCode = startCode + 1000000) {
//               List<Schedule> list = schedules[getDateTime(startCode)] ?? [];
//               list.add(schedule);
//               schedules[getDateTime(startCode)] = list;
//             }
//           });
//         }));
//   }

//   List<Schedule> _getSchdeuleForDay(DateTime day) {
//     return schedules[day] ?? [];
//   }

//   List<Schedule> _getSchdeuleForRange(DateTime start, DateTime end) {
//     final dayCount = end.difference(start).inDays + 1;
//     final days = List.generate(dayCount,
//         (index) => DateTime(start.year, start.month, start.day + index));

//     return [for (var d in days) ..._getSchdeuleForDay(d)].toSet().toList();
//   }

//   void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
//     setState(() {
//       _selectedDay = null;
//       _focusedDay = focusedDay;
//       _rangeStart = start;
//       _rangeEnd = end;
//       _rangeSelectionMode = RangeSelectionMode.toggledOn;
//     });

//     if (start != null && end != null) {
//       _selectedSchedule = _getSchdeuleForRange(start, end);
//     } else if (start != null) {
//       _selectedSchedule = _getSchdeuleForDay(start);
//     } else if (end != null) {
//       _selectedSchedule = _getSchdeuleForDay(end);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     return Scaffold(
//       backgroundColor: Colors.green[50],
//       appBar: AppBar(
//         title: Text("프로젝트 일정"),
//       ),
//       body: Container(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TableCalendar(
//               calendarStyle: CalendarStyle(
//                 outsideDaysVisible: true,
//                 weekendTextStyle: TextStyle().copyWith(color: Colors.red),
//                 holidayTextStyle: TextStyle().copyWith(color: Colors.blue[800]),
//               ),
//               locale: 'ko-KR',
//               focusedDay: _focusedDay,
//               startingDayOfWeek: StartingDayOfWeek.monday,
//               firstDay: DateTime(2021),
//               lastDay: DateTime(2023),
//               calendarFormat: _calendarFormat,
//               rangeStartDay: _rangeStart,
//               rangeEndDay: _rangeEnd,
//               rangeSelectionMode: _rangeSelectionMode,
//               onRangeSelected: _onRangeSelected,
//               onFormatChanged: (format) {
//                 setState(() {
//                   _calendarFormat = format;
//                 });
//               },
//               selectedDayPredicate: (day) {
//                 return isSameDay(_selectedDay, day);
//               },
//               eventLoader: _getSchdeuleForDay,
//               onDaySelected: (selectedDay, focusedDay) {
//                 if (!isSameDay(_selectedDay, selectedDay)) {
//                   setState(() {
//                     _selectedDay = selectedDay;
//                     _focusedDay = focusedDay;
//                     _rangeStart = null;
//                     _rangeEnd = null;
//                     _rangeSelectionMode = RangeSelectionMode.toggledOff;
//                   });

//                   _selectedSchedule = _getSchdeuleForDay(selectedDay);
//                 }
//               },
//             ),
//             Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "Daily Task",
//                   style: TextStyle(
//                       fontSize: width * 0.048, fontWeight: FontWeight.bold),
//                 )),
//             Expanded(
//                 child: ListView.builder(
//                     itemCount: _selectedSchedule.length,
//                     itemBuilder: (context, index) {
//                       int from = getHashCode(
//                           DateTime.parse(_selectedSchedule[index].startTime));
//                       int to = getHashCode(
//                           DateTime.parse(_selectedSchedule[index].endTime));

//                       return Card(
//                         child: ListTile(
//                           leading: Container(
//                             width: width * 0.15,
//                             color: Colors.red[50],
//                           ),
//                           title: Text(_selectedSchedule[index].title),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(_selectedSchedule[index].content),
//                               from == to
//                                   ? Text(toDateTime(
//                                         DateTime.parse(
//                                             _selectedSchedule[index].startTime),
//                                       ) +
//                                       " ~ " +
//                                       toTime(DateTime.parse(
//                                           _selectedSchedule[index].endTime)))
//                                   : Text(
//                                       toDateTime(
//                                             DateTime.parse(
//                                                 _selectedSchedule[index]
//                                                     .startTime),
//                                           ) +
//                                           " ~ " +
//                                           toDateTime(
//                                             DateTime.parse(
//                                                 _selectedSchedule[index]
//                                                     .endTime),
//                                           ),
//                                     ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }))
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: titleColor,
//         onPressed: () async {
//           if (_rangeSelectionMode == RangeSelectionMode.toggledOn) {
//             startDate = _rangeStart!;
//             endDate = _rangeEnd ?? startDate;
//           } else {
//             startDate = _selectedDay ?? DateTime.now();
//             endDate = _selectedDay ?? DateTime.now();
//           }
//           showModalBottomSheet(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(16),
//                       topRight: Radius.circular(16))),
//               isScrollControlled: true,
//               context: context,
//               builder: (context) {
//                 return SafeArea(
//                   child: SingleChildScrollView(
//                     child: StatefulBuilder(builder: (context, setState) {
//                       return Padding(
//                         padding: MediaQuery.of(context).viewInsets,
//                         child: Container(
//                           child: Column(
//                             children: [
//                               BottomSheetTopBar(
//                                   title: "스케줄 추가",
//                                   onPressed: () async {
//                                     var userIdx = Provider.of<SignInModel>(
//                                             context,
//                                             listen: false)
//                                         .userIdx;
//                                     var projectIdx = Provider.of<LiveProject>(
//                                             context,
//                                             listen: false)
//                                         .projectIdx;
//                                     Schedule schedule = Schedule(
//                                         title: titleController.text,
//                                         content: contentController.text,
//                                         startTime: startDate.toIso8601String(),
//                                         endTime: endDate.toIso8601String(),
//                                         projectIdx: projectIdx,
//                                         writedIdx: userIdx);

//                                     await togetherPostAPI(
//                                       "/project/addSchedule",
//                                       jsonEncode(schedule.toJson()),
//                                     );

//                                     int from = getHashCode(startDate);
//                                     int to = getHashCode(endDate);

//                                     for (from = from;
//                                         from <= to;
//                                         from = from + 1000000) {
//                                       List<Schedule> list =
//                                           schedules[getDateTime(from)] ?? [];
//                                       list.add(schedule);
//                                       schedules[getDateTime(from)] = list;
//                                     }

//                                     Navigator.of(context).pop();
//                                   }),
//                               Container(
//                                 padding: EdgeInsets.symmetric(
//                                     vertical: width * 0.01,
//                                     horizontal: width * 0.02),
//                                 decoration: BoxDecoration(
//                                     border: Border(
//                                         bottom: BorderSide(
//                                             width: 1, color: Colors.grey))),
//                                 child: TextFormFieldWidget(
//                                     header: Text("제목"),
//                                     body: TextFormField(
//                                       controller: titleController,
//                                       decoration: InputDecoration(
//                                         border: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(8)),
//                                       ),
//                                     ),
//                                     footer: null,
//                                     heightPadding: 0),
//                               ),
//                               Container(
//                                 padding: EdgeInsets.symmetric(
//                                     vertical: width * 0.01,
//                                     horizontal: width * 0.02),
//                                 decoration: BoxDecoration(
//                                     border: Border(
//                                         bottom: BorderSide(
//                                             width: 1, color: Colors.grey))),
//                                 child: TextFormFieldWidget(
//                                     header: Text("세부 내용"),
//                                     body: TextField(
//                                       controller: contentController,
//                                       decoration: InputDecoration(
//                                         border: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(8)),
//                                       ),
//                                     ),
//                                     footer: null,
//                                     heightPadding: 0),
//                               ),
//                               Container(
//                                 padding: EdgeInsets.symmetric(
//                                     vertical: width * 0.01,
//                                     horizontal: width * 0.02),
//                                 decoration: BoxDecoration(
//                                     border: Border(
//                                         bottom: BorderSide(
//                                             width: 1, color: Colors.grey))),
//                                 child: TextFormFieldWidget(
//                                     header: Text(
//                                       "시작 시간",
//                                       style: TextStyle(fontSize: width * 0.04),
//                                     ),
//                                     body: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceEvenly,
//                                       children: [
//                                         Container(
//                                           width: width * 0.45,
//                                           padding: EdgeInsets.only(
//                                               left: width * 0.004),
//                                           decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                               border: Border.all(
//                                                   width: 1,
//                                                   color: Colors.grey)),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Text(toDate(startDate)),
//                                               IconButton(
//                                                   onPressed: () async {
//                                                     await showDatePicker(
//                                                       context: context,
//                                                       initialDate:
//                                                           DateTime.now(),
//                                                       firstDate: DateTime(2020),
//                                                       lastDate: DateTime(2025),
//                                                     ).then((value) {
//                                                       if (value != null) {
//                                                         setState(() {
//                                                           startDate = value;
//                                                           if (startDate.isAfter(
//                                                               endDate)) {
//                                                             endDate = DateTime(
//                                                               startDate.year,
//                                                               startDate.month,
//                                                               startDate.day,
//                                                             );
//                                                           }
//                                                         });
//                                                       }
//                                                     });
//                                                   },
//                                                   icon: Icon(
//                                                       Icons
//                                                           .arrow_drop_down_outlined,
//                                                       size: 32))
//                                             ],
//                                           ),
//                                         ),
//                                         Container(
//                                           width: width * 0.3,
//                                           padding: EdgeInsets.only(
//                                               left: width * 0.02),
//                                           decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                               border: Border.all(
//                                                   width: 1,
//                                                   color: Colors.grey)),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Text(toTime(startDate)),
//                                               IconButton(
//                                                   onPressed: () async {
//                                                     await showTimePicker(
//                                                             context: context,
//                                                             initialTime: TimeOfDay
//                                                                 .fromDateTime(
//                                                                     startDate))
//                                                         .then((value) {
//                                                       if (value != null) {
//                                                         setState(() {
//                                                           startDate = DateTime(
//                                                               startDate.year,
//                                                               startDate.month,
//                                                               startDate.day,
//                                                               value.hour,
//                                                               value.minute);
//                                                         });
//                                                       }
//                                                     });
//                                                   },
//                                                   icon: Icon(
//                                                       Icons
//                                                           .arrow_drop_down_outlined,
//                                                       size: 32))
//                                             ],
//                                           ),
//                                         )
//                                       ],
//                                     ),
//                                     footer: null,
//                                     heightPadding: 0),
//                               ),
//                               Container(
//                                 padding: EdgeInsets.symmetric(
//                                     vertical: width * 0.01,
//                                     horizontal: width * 0.02),
//                                 child: TextFormFieldWidget(
//                                     header: Text(
//                                       "종료 시간",
//                                       style: TextStyle(fontSize: width * 0.04),
//                                     ),
//                                     body: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceEvenly,
//                                       children: [
//                                         Container(
//                                           width: width * 0.45,
//                                           padding: EdgeInsets.only(
//                                               left: width * 0.004),
//                                           decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                               border: Border.all(
//                                                   width: 1,
//                                                   color: Colors.grey)),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Text(toDate(endDate)),
//                                               IconButton(
//                                                   onPressed: () async {
//                                                     await showDatePicker(
//                                                       context: context,
//                                                       initialDate: startDate,
//                                                       firstDate: startDate,
//                                                       lastDate: DateTime(2025),
//                                                     ).then((value) {
//                                                       if (value != null) {
//                                                         setState(() {
//                                                           endDate = value;
//                                                         });
//                                                       }
//                                                     });
//                                                   },
//                                                   icon: Icon(
//                                                       Icons
//                                                           .arrow_drop_down_outlined,
//                                                       size: 32))
//                                             ],
//                                           ),
//                                         ),
//                                         Container(
//                                           width: width * 0.3,
//                                           padding: EdgeInsets.only(
//                                               left: width * 0.02),
//                                           decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                               border: Border.all(
//                                                   width: 1,
//                                                   color: Colors.grey)),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Text(toTime(endDate)),
//                                               IconButton(
//                                                   onPressed: () async {
//                                                     await showTimePicker(
//                                                             context: context,
//                                                             initialTime: TimeOfDay
//                                                                 .fromDateTime(
//                                                                     startDate))
//                                                         .then((value) {
//                                                       if (value != null) {
//                                                         setState(() {
//                                                           endDate = DateTime(
//                                                               endDate.year,
//                                                               endDate.month,
//                                                               endDate.day,
//                                                               value.hour,
//                                                               value.minute);
//                                                           if (startDate
//                                                               .isAfter(endDate))
//                                                             endDate = DateTime(
//                                                                 endDate.year,
//                                                                 endDate.month,
//                                                                 endDate.day,
//                                                                 startDate.hour +
//                                                                     1,
//                                                                 value.minute);
//                                                         });
//                                                       }
//                                                     });
//                                                   },
//                                                   icon: Icon(
//                                                       Icons
//                                                           .arrow_drop_down_outlined,
//                                                       size: 32))
//                                             ],
//                                           ),
//                                         )
//                                       ],
//                                     ),
//                                     footer: null,
//                                     heightPadding: 0),
//                               )
//                             ],
//                           ),
//                         ),
//                       );
//                     }),
//                   ),
//                 );
//               }).then((value) => setState(() {}));
//         },
//         child: Icon(
//           Icons.post_add,
//           size: 32,
//           color: Colors.purple,
//         ),
//       ),
//     );
//   }
// }
