import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timelines/timelines.dart';
import 'package:together_android/componet/bottom_sheet_top_bar.dart';
import 'package:together_android/componet/textfield_widget.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/live_project_model.dart';
import 'package:together_android/model/after_project_model/project_file_simple_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

class FileReservation extends StatefulWidget {
  const FileReservation({Key? key}) : super(key: key);

  @override
  _FileReservationState createState() => _FileReservationState();
}

class _FileReservationState extends State<FileReservation> {
  late Future future;

  DateTime date = DateTime.now();
  var reservations = LinkedHashMap(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  List<BookingFile> _getBookingFiles(DateTime day) {
    return reservations[day] ?? [];
  }

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // fetchBooking().then((value) => setState(() {
    //       allBooking = value;
    //       allBooking.forEach((book) {
    //         DateTime start = DateTime.parse(book.startTime);
    //         DateTime end = DateTime.parse(book.endTime);

    //         int startCode = getHashCode(start);
    //         int endCode = getHashCode(end);

    //         for (startCode = startCode;
    //             startCode <= endCode;
    //             startCode = startCode + 1000000) {
    //           List<BookingFile> list =
    //               reservations[getDateTime(startCode)] ?? [];
    //           list.add(book);
    //           reservations[getDateTime(startCode)] = list;
    //         }
    //       });
    //       dateBooking = _getBookingFiles(date);
    //     }));
  }

  Future<List<BookingFile>> fetchBooking() async {
    int fileIdx = Provider.of<SimpleFile>(context, listen: false).fileIdx;

    var list =
        await togetherGetAPI("/file/detail/reserveFileList", "/$fileIdx");
    return list as List<BookingFile>;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text("파일 예약"),
      ),
      body: FutureBuilder(
          future: fetchBooking(),
          builder: (context, snapsot) {
            print("builder 실행");
            //print(snapsot.data);
            List<BookingFile> allBooking = [];
            List<BookingFile> dateBooking = [];

            if (snapsot.hasData) {
              if (snapsot.data != null) {
                allBooking = snapsot.data as List<BookingFile>;
              }
              print(allBooking.length);
              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    width: width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              date = date.add(Duration(days: -1));
                              // dateBooking = _getBookingFiles(date);
                            });
                          },
                          icon: Icon(
                            Icons.chevron_left,
                            size: 32,
                          ),
                        ),
                        Text(
                          toDate(date),
                          style: TextStyle(fontSize: width * 0.048),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              date = date.add(Duration(days: 1));
                              // dateBooking = _getBookingFiles(date);
                            });
                          },
                          icon: Icon(
                            Icons.chevron_right,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: Timeline.tileBuilder(
                        builder: TimelineTileBuilder.fromStyle(
                            contentsAlign: ContentsAlign.alternating,
                            itemCount: allBooking.length,
                            contentsBuilder: (context, i) {
                              return Container(
                                child: Card(
                                  child: Column(
                                    children: [
                                      Text(allBooking[i].user),
                                      Text(
                                        toTime(DateTime.parse(
                                                allBooking[i].startTime)) +
                                            " ~ " +
                                            toTime(DateTime.parse(
                                                allBooking[i].endTime)),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                  )
                ],
              );
            } else if (snapsot.hasError) {
              return Text("error");
            }
            return CircularProgressIndicator();
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showModalBottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16))),
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return StatefulBuilder(builder: (context, setState) {
                  return Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: Container(
                      child: Wrap(
                        children: [
                          BottomSheetTopBar(
                              title: "파일 예약하기",
                              onPressed: () async {
                                int userIdx = Provider.of<SignInModel>(context,
                                        listen: false)
                                    .userIdx;
                                int fileIdx = Provider.of<SimpleFile>(context,
                                        listen: false)
                                    .fileIdx;
                                var code = await togetherPostAPI(
                                    "/file/detail/reserveFile",
                                    jsonEncode({
                                      'user_idx': userIdx,
                                      'file_idx': fileIdx,
                                      'start_datetime':
                                          startDate.toIso8601String(),
                                      'end_datetime': endDate.toIso8601String(),
                                    }));
                                if (code == 200) {
                                  Navigator.of(context).pop();
                                }
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
                                          EdgeInsets.only(left: width * 0.004),
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
                                      padding:
                                          EdgeInsets.only(left: width * 0.004),
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
                                                            startDate.hour + 1,
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
                });
              }).then((value) => setState(() {}));
        },
        child: Icon(Icons.edit),
      ),
    );
  }
}

class BookingFile {
  int reservationIdx;
  String startTime;
  String endTime;
  String user;
  int userIdx;

  BookingFile(
      {required this.reservationIdx,
      required this.startTime,
      required this.endTime,
      required this.user,
      required this.userIdx});

  factory BookingFile.fromJson(Map<String, dynamic> json) {
    return BookingFile(
        reservationIdx: json['file_reservation_idx'],
        startTime: json['start_datetime'],
        endTime: json['end_datetime'],
        user: json['user_name'],
        userIdx: json['user_idx']);
  }
}
