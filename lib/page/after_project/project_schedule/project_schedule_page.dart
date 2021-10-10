import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/live_project_model.dart';
import 'package:together_android/model/after_project_model/project_schedule_model.dart';
import 'package:together_android/page/after_project/project_schedule/add_project_schedule_page.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

class ProjectSchedulePage extends StatefulWidget {
  const ProjectSchedulePage({Key? key}) : super(key: key);

  @override
  _ProjectSchedulePageState createState() => _ProjectSchedulePageState();
}

class _ProjectSchedulePageState extends State<ProjectSchedulePage> {
  List<Schedule> _allSchedule = [];
  List<Schedule> _selectedSchedule = [];
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

  var schedules = LinkedHashMap(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  Future<List<Schedule>> fetchProjectSchdeule() async {
    var proejctIdx =
        Provider.of<LiveProject>(context, listen: false).projectIdx;
    var list =
        await togetherGetAPI("/project/main", "?project_idx=$proejctIdx");
    return list as List<Schedule>;
  }

  @override
  void initState() {
    super.initState();
    fetchProjectSchdeule().then((value) => setState(() {
          _allSchedule = value;
          _allSchedule.forEach((schedule) {
            DateTime start = DateTime.parse(schedule.startTime);
            DateTime end = DateTime.parse(schedule.endTime);

            int startCode = getHashCode(start);
            int endCode = getHashCode(end);

            for (startCode = startCode;
                startCode <= endCode;
                startCode = startCode + 1000000) {
              List<Schedule> list = schedules[getDateTime(startCode)] ?? [];
              list.add(schedule);
              schedules[getDateTime(startCode)] = list;
            }
          });

          _selectedSchedule = _getSchdeuleForDay(DateTime.now());
          if (_selectedSchedule.length >= 2)
            _calendarFormat = CalendarFormat.twoWeeks;
        }));
  }

  List<Schedule> _getSchdeuleForDay(DateTime day) {
    return schedules[day] ?? [];
  }

  List<Schedule> _getSchdeuleForRange(DateTime start, DateTime end) {
    final dayCount = end.difference(start).inDays + 1;
    final days = List.generate(dayCount,
        (index) => DateTime(start.year, start.month, start.day + index));

    return [for (var d in days) ..._getSchdeuleForDay(d)].toSet().toList();
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
      _selectedSchedule = _getSchdeuleForRange(start, end);
    } else if (start != null) {
      _selectedSchedule = _getSchdeuleForDay(start);
    } else if (end != null) {
      _selectedSchedule = _getSchdeuleForDay(end);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      //backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text("프로젝트 일정"),
      ),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              calendarStyle: CalendarStyle(
                outsideDaysVisible: true,
                weekendTextStyle: TextStyle().copyWith(color: Colors.red),
                holidayTextStyle: TextStyle().copyWith(color: Colors.blue[800]),
              ),
              locale: 'ko-KR',
              focusedDay: _focusedDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              firstDay: DateTime(2021),
              lastDay: DateTime(2023),
              calendarFormat: _calendarFormat,
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              rangeSelectionMode: _rangeSelectionMode,
              onRangeSelected: _onRangeSelected,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              eventLoader: _getSchdeuleForDay,
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _rangeStart = null;
                    _rangeEnd = null;
                    _rangeSelectionMode = RangeSelectionMode.toggledOff;
                  });

                  _selectedSchedule = _getSchdeuleForDay(selectedDay);
                }
              },
            ),
            Text(
              "Daily Task",
              style: headingStyle,
            ),
            Expanded(
                child: ListView.builder(
                    itemCount: _selectedSchedule.length,
                    itemBuilder: (context, index) {
                      int from = getHashCode(
                          DateTime.parse(_selectedSchedule[index].startTime));
                      int to = getHashCode(
                          DateTime.parse(_selectedSchedule[index].endTime));

                      return Card(
                        child: ListTile(
                          leading: Container(
                            width: width * 0.15,
                            color: Colors.red[50],
                          ),
                          title: Text(_selectedSchedule[index].title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_selectedSchedule[index].content),
                              from == to
                                  ? Text(toDateTime(
                                        DateTime.parse(
                                            _selectedSchedule[index].startTime),
                                      ) +
                                      " ~ " +
                                      toTime(DateTime.parse(
                                          _selectedSchedule[index].endTime)))
                                  : Text(
                                      toDateTime(
                                            DateTime.parse(
                                                _selectedSchedule[index]
                                                    .startTime),
                                          ) +
                                          " ~ " +
                                          toDateTime(
                                            DateTime.parse(
                                                _selectedSchedule[index]
                                                    .endTime),
                                          ),
                                    ),
                            ],
                          ),
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
            startDate = _focusedDay;
            endDate = _focusedDay.add(Duration(hours: 1));
          }

          Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (context) => AddProjectSchdeule(
                        startDate: startDate,
                        endDate: endDate,
                      )))
              .then((value) => setState(() {
                    if (value != null) {
                      var schedule = value as Schedule;
                      int from =
                          getHashCode(DateTime.parse(schedule.startTime));
                      int to = getHashCode(DateTime.parse(schedule.endTime));

                      for (from = from; from <= to; from = from + 1000000) {
                        print(from);
                        print(to);
                        List<Schedule> list =
                            schedules[getDateTime(from)] ?? [];
                        list.add(schedule);
                        schedules[getDateTime(from)] = list;
                      }
                      _selectedSchedule = _getSchdeuleForDay(startDate);
                    }
                  }));
        },
        child: Icon(
          Icons.post_add,
          size: 32,
          color: Colors.purple,
        ),
      ),
    );
  }
}
