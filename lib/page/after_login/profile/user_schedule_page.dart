import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/private_schedule_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/page/after_login/profile/add_user_schdeule_page.dart';
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
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  var events = LinkedHashMap(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  @override
  void initState() {
    super.initState();
    fetchPrivateSchedule();
    _selectedEvents = _getEventsForDay(DateTime.now());
  }

  fetchPrivateSchedule() async {
    var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;
    _allEvents =
        await togetherGetAPI("/user/getUserSchedules", "?user_idx=$userIdx");
    events.clear();
    setState(() {
      _allEvents.forEach((schedule) {
        DateTime start = DateTime.parse(schedule.startTime);
        DateTime end = DateTime.parse(schedule.endTime);

        int startCode = getHashCode(start);
        int endCode = getHashCode(end);

        for (startCode = startCode;
            startCode <= endCode;
            startCode = startCode + 1000000) {
          List<Event> list = events[getDateTime(startCode)] ?? [];
          list.add(schedule);
          events[getDateTime(startCode)] = list;
        }
      });
    });
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
    var photo = Provider.of<SignInModel>(context, listen: false).userPhoto;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: _appBar(context, photo),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
                left: width * 0.04, right: width * 0.04, bottom: height * 0.02),
            decoration: BoxDecoration(
                color: Color(0xffD0EBFF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 5,
                    blurRadius: 5,
                    offset: Offset(3, 3), // changes position of shadow
                  ),
                ]),
            child: Column(
              children: [
                header(context),
                TableCalendar(
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: true,
                    weekendTextStyle: TextStyle().copyWith(color: Colors.red),
                    holidayTextStyle:
                        TextStyle().copyWith(color: Colors.blue[800]),
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
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
              child: Container(
            padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 8),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Daily Task",
                        style: editTitleStyle,
                      )),
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _selectedEvents.length,
                      itemBuilder: (context, index) {
                        int from = getHashCode(
                            DateTime.parse(_selectedEvents[index].startTime));
                        int to = getHashCode(
                            DateTime.parse(_selectedEvents[index].endTime));
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(photo),
                            ),
                            title: Text(
                              _selectedEvents[index].title,
                              style: tileTitleStyle,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  _selectedEvents[index].content,
                                  maxLines: 2,
                                  style: tileSubTitleStyle,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                from == to // 스케줄 시간에따라 표현 다름
                                    ? cardDateTimeInfo(index)
                                    : cardDateInfo(index)
                              ],
                            ),
                          ),
                        );
                      }),
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }

  cardDateInfo(int index) {
    return Row(
      children: [
        Row(
          children: [
            Icon(Icons.event, color: Colors.grey, size: 16),
            SizedBox(
              width: 5,
            ),
            Text(
                schdeuleDateFormat(_selectedEvents[index].startTime,
                    _selectedEvents[index].endTime, false),
                style: tileSubTitleStyle)
          ],
        ),
      ],
    );
  }

  cardDateTimeInfo(int index) {
    return Row(
      children: [
        Row(
          children: [
            Icon(Icons.event, color: Colors.grey, size: 16),
            SizedBox(
              width: 5,
            ),
            Text(
                schdeuleDateFormat(_selectedEvents[index].startTime,
                    _selectedEvents[index].endTime, true),
                style: tileSubTitleStyle)
          ],
        ),
        SizedBox(
          width: 20,
        ),
        Row(
          children: [
            Icon(Icons.schedule, color: Colors.grey, size: 16),
            SizedBox(
              width: 5,
            ),
            Text(
                schdeuleTimeFormat(_selectedEvents[index].startTime,
                    _selectedEvents[index].endTime),
                style: tileSubTitleStyle)
          ],
        ),
      ],
    );
  }

  header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Text(
              "내 일정",
              style: headingStyle,
            ),
          ],
        ),
        MyButton(
            label: "+ 추가",
            onTap: () async {
              if (_rangeSelectionMode == RangeSelectionMode.toggledOn) {
                startDate = _rangeStart!;
                endDate = _rangeEnd ?? startDate;
              } else {
                startDate = _focusedDay;
                endDate = _focusedDay.add(Duration(hours: 1));
              }

              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => AddUserSchdeule(
                            startDate: startDate,
                            endDate: endDate,
                          )))
                  .then((value) => setState(() {
                        fetchPrivateSchedule();
                      }));
            })
      ],
    );
  }

  _appBar(BuildContext context, String photo) {
    return AppBar(
      backgroundColor: Color(0xffD0EBFF),
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
