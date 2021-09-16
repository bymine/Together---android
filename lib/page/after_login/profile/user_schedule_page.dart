import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:together_android/componet/bottom_sheet_top_bar.dart';
import 'package:together_android/componet/textfield_widget.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/private_schedule_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
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
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

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
            DateTime start = DateTime.parse(event.startTime);
            DateTime end = DateTime.parse(event.endTime);

            int startCode = getHashCode(start);
            int endCode = getHashCode(end);

            for (startCode = startCode;
                startCode <= endCode;
                startCode = startCode + 1000000) {
              List<Event> list = events[getDateTime(startCode)] ?? [];
              list.add(event);
              events[getDateTime(startCode)] = list;
            }
          });
        }));
  }

  Future<List<Event>> fetchPrivateSchedule() async {
    var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;
    var list =
        await togetherGetAPI("/user/getUserSchedules", "?user_idx=$userIdx");
    return list as List<Event>;
  }

  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    final dayCount = end.difference(start).inDays + 1;

    final days = List.generate(dayCount,
        (index) => DateTime(start.year, start.month, start.day + index));

    return [for (var d in days) ..._getEventsForDay(d)].toSet().toList();
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    if (start != null && end != null) {
      _selectedEvents = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents = _getEventsForDay(end);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text("일정 관리"),
      ),
      body: Container(
        child: Column(
          children: [
            TableCalendar(
              calendarStyle: CalendarStyle(
                outsideDaysVisible: true,
                weekendTextStyle: TextStyle().copyWith(color: Colors.red),
                holidayTextStyle: TextStyle().copyWith(color: Colors.blue[800]),
              ),
              locale: 'ko-KR',
              firstDay: DateTime(2021),
              lastDay: DateTime(2023),
              startingDayOfWeek: StartingDayOfWeek.monday,
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              rangeSelectionMode: _rangeSelectionMode,
              onRangeSelected: _onRangeSelected,
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
                    _rangeStart = null;
                    _rangeEnd = null;
                    _rangeSelectionMode = RangeSelectionMode.toggledOff;
                  });

                  _selectedEvents = _getEventsForDay(selectedDay);
                }
              },
            ),
            // Text("focused: " + _focusedDay.toString()),
            // Text("selected: " + _selectedDay.toString()),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Daily Task",
                  style: TextStyle(
                      fontSize: width * 0.048, fontWeight: FontWeight.bold),
                )),
            Expanded(
                child: ListView.builder(
                    itemCount: _selectedEvents.length,
                    itemBuilder: (context, index) {
                      int from = getHashCode(
                          DateTime.parse(_selectedEvents[index].startTime));
                      int to = getHashCode(
                          DateTime.parse(_selectedEvents[index].endTime));
                      return Card(
                        child: ListTile(
                          title: Text(_selectedEvents[index].title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_selectedEvents[index].content),
                              from == to
                                  ? Text(toDateTime(
                                        DateTime.parse(
                                            _selectedEvents[index].startTime),
                                      ) +
                                      " ~ " +
                                      toTime(DateTime.parse(
                                          _selectedEvents[index].endTime)))
                                  : Text(
                                      toDateTime(
                                            DateTime.parse(
                                                _selectedEvents[index]
                                                    .startTime),
                                          ) +
                                          " ~ " +
                                          toDateTime(
                                            DateTime.parse(
                                                _selectedEvents[index].endTime),
                                          ),
                                    ),
                            ],
                          ),
                          trailing: IconButton(
                              onPressed: () {}, icon: Icon(Icons.more_vert)),
                        ),
                      );
                    }))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: titleColor,
        onPressed: () async {
          if (_rangeSelectionMode == RangeSelectionMode.toggledOn) {
            startDate = _rangeStart!;
            endDate = _rangeEnd ?? startDate;
          } else {
            startDate = _selectedDay ?? DateTime.now();
            endDate = _selectedDay ?? DateTime.now();
          }
          showModalBottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16))),
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return SafeArea(
                  child: SingleChildScrollView(
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
                                    int from = getHashCode(startDate);
                                    int to = getHashCode(endDate);

                                    for (from = from;
                                        from <= to;
                                        from = from + 1000000) {
                                      List<Event> list =
                                          events[getDateTime(from)] ?? [];
                                      list.add(event);
                                      events[getDateTime(from)] = list;
                                    }

                                    Navigator.of(context).pop();
                                  }),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: width * 0.01,
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
                                    vertical: width * 0.01,
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
                                    vertical: width * 0.01,
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
                                          padding: EdgeInsets.only(
                                              left: width * 0.004),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  width: 1,
                                                  color: Colors.grey)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(toDate(startDate)),
                                              IconButton(
                                                  onPressed: () async {
                                                    await showDatePicker(
                                                      context: context,
                                                      initialDate:
                                                          DateTime.now(),
                                                      firstDate: DateTime(2020),
                                                      lastDate: DateTime(2025),
                                                    ).then((value) {
                                                      if (value != null) {
                                                        setState(() {
                                                          startDate = value;
                                                          if (startDate.isAfter(
                                                              endDate)) {
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
                                          padding: EdgeInsets.only(
                                              left: width * 0.02),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  width: 1,
                                                  color: Colors.grey)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(toTime(startDate)),
                                              IconButton(
                                                  onPressed: () async {
                                                    await showTimePicker(
                                                            context: context,
                                                            initialTime: TimeOfDay
                                                                .fromDateTime(
                                                                    startDate))
                                                        .then((value) {
                                                      if (value != null) {
                                                        setState(() {
                                                          startDate = DateTime(
                                                              startDate.year,
                                                              startDate.month,
                                                              startDate.day,
                                                              value.hour,
                                                              value.minute);
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
                                    vertical: width * 0.01,
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
                                          padding: EdgeInsets.only(
                                              left: width * 0.004),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  width: 1,
                                                  color: Colors.grey)),
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
                                          padding: EdgeInsets.only(
                                              left: width * 0.02),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  width: 1,
                                                  color: Colors.grey)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(toTime(endDate)),
                                              IconButton(
                                                  onPressed: () async {
                                                    await showTimePicker(
                                                            context: context,
                                                            initialTime: TimeOfDay
                                                                .fromDateTime(
                                                                    startDate))
                                                        .then((value) {
                                                      if (value != null) {
                                                        setState(() {
                                                          endDate = DateTime(
                                                              endDate.year,
                                                              endDate.month,
                                                              endDate.day,
                                                              value.hour,
                                                              value.minute);
                                                          if (startDate
                                                              .isAfter(endDate))
                                                            endDate = DateTime(
                                                                endDate.year,
                                                                endDate.month,
                                                                endDate.day,
                                                                startDate.hour +
                                                                    1,
                                                                value.minute);
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
                  ),
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
