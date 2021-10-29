import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/live_project_model.dart';
import 'package:together_android/model/after_project_model/project_schedule_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/page/after_login/main_page.dart';
import 'package:together_android/page/after_project/project_schedule/add_project_schedule_page.dart';
import 'package:together_android/page/after_project/project_schedule/project_schedule_detail_page.dart';
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
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  var schedules = LinkedHashMap(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  fetchProjectSchdeule() async {
    var proejctIdx =
        Provider.of<LiveProject>(context, listen: false).projectIdx;
    _allSchedule =
        await togetherGetAPI("/project/main", "?project_idx=$proejctIdx");
    schedules.clear();
    setState(() {
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
    });
  }

  @override
  void initState() {
    super.initState();
    fetchProjectSchdeule();
    _selectedSchedule = _getSchdeuleForDay(DateTime.now());
    if (_selectedSchedule.length >= 2)
      _calendarFormat = CalendarFormat.twoWeeks;
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
    var photo = Provider.of<SignInModel>(context, listen: false).userPhoto;
    var projectName =
        Provider.of<LiveProject>(context, listen: false).projectName;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: _appBar(context, photo),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(
                left: width * 0.02, right: width * 0.02, bottom: height * 0.02),
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
                headeer(projectName, context),
                TableCalendar(
                  calendarStyle: CalendarStyle(
                    // markerDecoration: BoxDecoration(
                    //     color: titleColor, shape: BoxShape.circle),
                    outsideDaysVisible: true,
                    weekendTextStyle: TextStyle().copyWith(color: Colors.red),
                    holidayTextStyle:
                        TextStyle().copyWith(color: Colors.blue[800]),
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
                    ),
                  ),
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _selectedSchedule.length,
                      itemBuilder: (context, index) {
                        int from = getHashCode(
                            DateTime.parse(_selectedSchedule[index].startTime));
                        int to = getHashCode(
                            DateTime.parse(_selectedSchedule[index].endTime));

                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => SchdeuleDetailPage(
                                      schedule: _selectedSchedule[index],
                                    )));
                          },
                          child: Card(
                            //color: Color(0xffEDE6DB),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    _selectedSchedule[index].photo),
                              ),
                              title: Text(
                                _selectedSchedule[index].title,
                                style: tileTitleStyle,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    _selectedSchedule[index].content,
                                    maxLines: 1,
                                    style: tileSubTitleStyle,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  from == to
                                      ? cardDateTimeInfo(index)
                                      : cardDateInfo(index)
                                ],
                              ),
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
                schdeuleDateFormat(_selectedSchedule[index].startTime,
                    _selectedSchedule[index].endTime, false),
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
                schdeuleDateFormat(_selectedSchedule[index].startTime,
                    _selectedSchedule[index].endTime, true),
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
                schdeuleTimeFormat(_selectedSchedule[index].startTime,
                    _selectedSchedule[index].endTime),
                style: tileSubTitleStyle)
          ],
        ),
      ],
    );
  }

  headeer(String projectName, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Text(
              "프로젝트 스케줄",
              style: subHeadingStyle,
            ),
            Text(
              projectName,
              style: headingStyle,
            )
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
                      builder: (context) => AddProjectSchdeule(
                            startDate: startDate,
                            endDate: endDate,
                          )))
                  .then((value) => setState(() {
                        fetchProjectSchdeule();
                      }));
            })
      ],
    );
  }

  _appBar(BuildContext context, String photo) {
    return AppBar(
      backgroundColor: Color(0xffD0EBFF),
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MainPage()));
        },
        icon: Icon(Icons.home_outlined, color: Colors.grey),
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
