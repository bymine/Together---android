import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:together_android/componet/bottom_sheet_top_bar.dart';
import 'package:together_android/componet/textfield_widget.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/sign_in_model.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

class PrivateSchedulePage extends StatefulWidget {
  const PrivateSchedulePage({Key? key}) : super(key: key);

  @override
  _PrivateSchedulePageState createState() => _PrivateSchedulePageState();
}

class _PrivateSchedulePageState extends State<PrivateSchedulePage> {
  List<Event> _allEvents = [];
  List<Event> _selectedEvents = [];
  List datekeys = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  // Map<DateTime, List<Event>> mappingSchedule = Map<DateTime, List<Event>>();
  // Map<DateTime, List<Event>> mappingSchedule = {
  //   DateTime(2021, 9, 8): [
  //     Event(
  //         title: "example1",
  //         contnet: "contnet",
  //         startTime: DateTime(2021, 9, 8).toIso8601String(),
  //         endTime: DateTime(2021, 9, 8).toIso8601String())
  //   ]
  // };

  var events = LinkedHashMap(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  @override
  void initState() {
    super.initState();
    fetchPrivateSchedule().then((value) => setState(() {
          _allEvents = value;

          _allEvents.forEach((event) {
            DateTime time = DateTime.parse(event.startTime);
            List<Event> list = events[time] ?? [];
            list.add(event);
            events[time] = list;
          });
        }));
  }

  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  Future<List<Event>> fetchPrivateSchedule() async {
    var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;
    var list =
        await togetherGetAPI("/user/getUserSchedules", "?user_idx=$userIdx");
    return list as List<Event>;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text("일정 관리"),
      ),
      body: Container(
        child: Column(
          children: [
            TableCalendar(
              locale: 'ko-KR',
              firstDay: DateTime(2021),
              lastDay: DateTime(2023),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },

              // onPageChanged: (focusedDay) {
              //   _focusedDay = focusedDay;
              // },
              eventLoader: _getEventsForDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });

                  _selectedEvents = _getEventsForDay(selectedDay);
                }
              },
            ),
            // Text("focused: " + _focusedDay.toString()),
            // Text("selected: " + _selectedDay.toString()),
            Expanded(
                child: ListView.builder(
                    itemCount: _selectedEvents.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(_selectedEvents[index].title),
                          subtitle: Text(_selectedEvents[index].startTime),
                        ),
                      );
                    }))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: titleColor,
        onPressed: () async {
          showModalBottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16))),
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return SingleChildScrollView(
                  child: StatefulBuilder(builder: (context, setState) {
                    return Padding(
                      padding: MediaQuery.of(context).viewInsets,
                      child: Container(
                        child: Column(
                          children: [
                            BottomSheetTopBar(
                                title: "스케줄 추가",
                                onPressed: () async {
                                  var userIdx = Provider.of<SignInModel>(
                                          context,
                                          listen: false)
                                      .userIdx;
                                  Event event = Event(
                                      title: titleController.text,
                                      content: contentController.text,
                                      startTime: startDate.toIso8601String(),
                                      endTime: endDate.toIso8601String());
                                  await togetherPostAPI(
                                    "/user/addSchedule",
                                    jsonEncode(
                                      {
                                        "schedule_name": titleController.text,
                                        "schedule_content":
                                            contentController.text,
                                        "schedule_start_datetime":
                                            startDate.toIso8601String(),
                                        "schedule_end_datetime":
                                            endDate.toIso8601String(),
                                        "writer_idx": userIdx,
                                      },
                                    ),
                                  );
                                  List<Event> list = events[startDate] ?? [];
                                  list.add(event);
                                  setState(() {
                                    events[startDate] = list;
                                  });
                                  Navigator.of(context).pop();
                                }),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: width * 0.02,
                                  horizontal: width * 0.02),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 1, color: Colors.grey))),
                              child: TextFormFieldWidget(
                                  header: Text("제목"),
                                  body: TextFormField(
                                    controller: titleController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                  ),
                                  footer: null,
                                  heightPadding: 0),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: width * 0.02,
                                  horizontal: width * 0.02),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 1, color: Colors.grey))),
                              child: TextFormFieldWidget(
                                  header: Text("세부 내용"),
                                  body: TextField(
                                    controller: contentController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                  ),
                                  footer: null,
                                  heightPadding: 0),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: width * 0.02,
                                  horizontal: width * 0.02),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 1, color: Colors.grey))),
                              child: TextFormFieldWidget(
                                  header: Text(
                                    "시작 시간",
                                    style: TextStyle(fontSize: width * 0.04),
                                  ),
                                  body: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        width: width * 0.45,
                                        padding:
                                            EdgeInsets.only(left: width * 0.02),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                width: 1, color: Colors.grey)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(toDate(startDate)),
                                            IconButton(
                                                onPressed: () async {
                                                  await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime(2020),
                                                    lastDate: DateTime(2025),
                                                  ).then((value) {
                                                    if (value != null) {
                                                      setState(() {
                                                        startDate = value;
                                                        if (startDate
                                                            .isAfter(endDate)) {
                                                          endDate = DateTime(
                                                            startDate.year,
                                                            startDate.month,
                                                            startDate.day,
                                                          );
                                                        }
                                                      });
                                                    }
                                                  });
                                                },
                                                icon: Icon(
                                                    Icons
                                                        .arrow_drop_down_outlined,
                                                    size: 32))
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: width * 0.3,
                                        padding:
                                            EdgeInsets.only(left: width * 0.08),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                width: 1, color: Colors.grey)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(toTime(startDate)),
                                            IconButton(
                                                onPressed: () async {
                                                  await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime(2020),
                                                    lastDate: DateTime(2025),
                                                  ).then((value) {
                                                    if (value != null) {
                                                      setState(() {
                                                        startDate = value;
                                                        if (startDate
                                                            .isAfter(endDate)) {
                                                          endDate = DateTime(
                                                            startDate.year,
                                                            startDate.month,
                                                            startDate.day,
                                                          );
                                                        }
                                                      });
                                                    }
                                                  });
                                                },
                                                icon: Icon(
                                                    Icons
                                                        .arrow_drop_down_outlined,
                                                    size: 32))
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  footer: null,
                                  heightPadding: 0),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: height * 0.02,
                                  horizontal: width * 0.02),
                              child: TextFormFieldWidget(
                                  header: Text(
                                    "종료 시간",
                                    style: TextStyle(fontSize: width * 0.04),
                                  ),
                                  body: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        width: width * 0.45,
                                        padding:
                                            EdgeInsets.only(left: width * 0.02),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                width: 1, color: Colors.grey)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(toDate(endDate)),
                                            IconButton(
                                                onPressed: () async {
                                                  await showDatePicker(
                                                    context: context,
                                                    initialDate: startDate,
                                                    firstDate: startDate,
                                                    lastDate: DateTime(2025),
                                                  ).then((value) {
                                                    if (value != null) {
                                                      setState(() {
                                                        endDate = value;
                                                      });
                                                    }
                                                  });
                                                },
                                                icon: Icon(
                                                    Icons
                                                        .arrow_drop_down_outlined,
                                                    size: 32))
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: width * 0.3,
                                        padding:
                                            EdgeInsets.only(left: width * 0.08),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                width: 1, color: Colors.grey)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(toTime(endDate)),
                                            IconButton(
                                                onPressed: () async {
                                                  await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime(2020),
                                                    lastDate: DateTime(2025),
                                                  ).then((value) {
                                                    if (value != null) {
                                                      setState(() {
                                                        startDate = value;
                                                        if (startDate
                                                            .isAfter(endDate)) {
                                                          endDate = DateTime(
                                                            startDate.year,
                                                            startDate.month,
                                                            startDate.day,
                                                          );
                                                        }
                                                      });
                                                    }
                                                  });
                                                },
                                                icon: Icon(
                                                    Icons
                                                        .arrow_drop_down_outlined,
                                                    size: 32))
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  footer: null,
                                  heightPadding: 0),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
                );
              }).then((value) => setState(() {}));
        },
        child: Icon(
          Icons.event_note,
          size: 32,
          color: Colors.purple,
        ),
      ),
    );
  }
}

class Event {
  String title;
  String content;
  String startTime;
  String endTime;
  Event(
      {required this.title,
      required this.content,
      required this.startTime,
      required this.endTime});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['body'] = this.content;
    data['start_datetime'] = this.startTime;
    data['end_datetime'] = this.endTime;

    return data;
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
        title: json['title'],
        content: json['body'] ?? "",
        startTime: json['start_datetime'],
        endTime: json['end_datetime']);
  }
}
