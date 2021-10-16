import 'dart:convert';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/bottom_sheet_top_bar.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/componet/textfield_widget.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_project_model/project_file_simple_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/page/after_project/project_file/add_reservation_page.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

class FileReservation extends StatefulWidget {
  const FileReservation({Key? key}) : super(key: key);

  @override
  _FileReservationState createState() => _FileReservationState();
}

class _FileReservationState extends State<FileReservation> {
  late Future future;
  DatePickerController _controller = DatePickerController();

  DateTime date = DateTime.now();

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  Future<List<BookingFile>> fetchBooking() async {
    int fileIdx = Provider.of<SimpleFile>(context, listen: false).fileIdx;

    var list =
        await togetherGetAPI("/file/detail/reserveFileList", "/$fileIdx");
    return list as List<BookingFile>;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;
    var fileIdx = Provider.of<SimpleFile>(context, listen: false).fileIdx;
    var photo = Provider.of<SignInModel>(context, listen: false).userPhoto;

    return Scaffold(
      //backgroundColor: Colors.green[50],
      appBar: _appBar(context, photo),
      body: FutureBuilder(
          future: fetchBooking(),
          builder: (context, snapsot) {
            List<BookingFile> allBooking = [];

            if (snapsot.hasData) {
              if (snapsot.data != null) {
                allBooking = snapsot.data as List<BookingFile>;
              }
              return Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        left: width * 0.04,
                        right: width * 0.04,
                        top: width * 0.06),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  toDate(
                                    date,
                                  ),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  )),
                              Text("Today",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w400,
                                  ))
                            ],
                          ),
                        ),
                        MyButton(
                            label: "+ 예약하기",
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) =>
                                          AddReservationPage()))
                                  .then((value) => setState(() {}));
                            }),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20, left: 10),
                    child: DatePicker(
                      DateTime.now().add(Duration(days: -3)),
                      height: 100,
                      controller: _controller,
                      width: 60,
                      initialSelectedDate: DateTime.now(),
                      selectionColor: titleColor,
                      selectedTextColor: Colors.black,
                      dateTextStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey),
                      dayTextStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey),
                      monthTextStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey),
                      onDateChange: (newDate) {
                        setState(() {
                          date = newDate;
                        });
                      },
                      locale: "ko-KR",
                    ),
                  ),
                  SizedBox(height: width * 0.02),
                  if (allBooking.isEmpty)
                    Expanded(
                        child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: Duration(milliseconds: 100),
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/task.svg",
                                  color: Colors.green.withOpacity(0.5),
                                  height: 90,
                                  semanticsLabel: 'Task',
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 10),
                                  child: Text(
                                    "You do not have any tasks yet!",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ))
                  else
                    Expanded(
                      child: Container(
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: allBooking.length,
                              itemBuilder: (context, index) {
                                BookingFile book = allBooking[index];
                                var bookState = reservationState(
                                    book.startTime, book.endTime);
                                if (book.startTime.split("T")[0] ==
                                    date.toString().split(" ")[0])
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 800),
                                    child: SlideAnimation(
                                      horizontalOffset: 300.0,
                                      child: FadeInAnimation(
                                          child: reservationCard(context, book,
                                              userIdx, bookState, fileIdx)),
                                    ),
                                  );
                                // return reservationCard(context, book, userIdx,
                                //     bookState, fileIdx);
                                else
                                  return Container();
                              })),
                    )
                ],
              );
            } else if (snapsot.hasError) {
              return Text("error");
            }
            return CircularProgressIndicator();
          }),
    );
  }

  reservationCard(BuildContext context, BookingFile book, int userIdx,
      String bookState, int fileIdx) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14),
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(bottom: 8),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: titleColor,
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "예약자: " + book.user,
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      Text(
                        toDateTimeISO(book.startTime) +
                            " - " +
                            toTimeISO(book.endTime),
                        style: GoogleFonts.lato(
                          textStyle:
                              TextStyle(fontSize: 13, color: Colors.grey[100]),
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: book.userIdx == userIdx,
                    child: bookState != "Done"
                        ? IconButton(
                            onPressed: () async {
                              if (bookState == "Not yet") {
                                await togetherGetAPI(
                                    "/file/detail/deleteFileReservation",
                                    "/${book.reservationIdx}");
                                setState(() {});
                              } else if (bookState == "Live") {
                                await togetherGetAPI(
                                    "/file/detail/earlyFinish", "/$fileIdx");
                                setState(() {});
                              }
                            },
                            icon: (bookState == "Not yet")
                                ? Icon(Icons.delete_outline)
                                : Icon(Icons.stop, color: Colors.red))
                        : Container(),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              height: 60,
              width: 0.5,
              color: Colors.grey,
            ),
            RotatedBox(
              quarterTurns: 3,
              child: Text(bookState,
                  maxLines: 1,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  String reservationState(String startTime, String endTime) {
    DateTime now = DateTime.now();
    DateTime start = DateTime.parse(startTime);
    DateTime end = DateTime.parse(endTime);

    if (now.isBefore(start))
      return "Not yet";
    else if (now.isAfter(end))
      return "Done";
    else
      return "Live";
  }

  bottomSheetButton(BuildContext context, double width) async {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16))),
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
                          int userIdx =
                              Provider.of<SignInModel>(context, listen: false)
                                  .userIdx;
                          int fileIdx =
                              Provider.of<SimpleFile>(context, listen: false)
                                  .fileIdx;
                          var code = await togetherPostAPI(
                              "/file/detail/reserveFile",
                              jsonEncode({
                                'user_idx': userIdx,
                                'file_idx': fileIdx,
                                'start_datetime': startDate.toIso8601String(),
                                'end_datetime': endDate.toIso8601String(),
                              }));
                          print(code.toString());
                          if (code.toString() == "success") {
                            Navigator.of(context).pop();
                          } else {
                            // Get.snackbar("Time Already Reserved",
                            //     "Pleae Re-Write the time",
                            //     snackPosition: SnackPosition.TOP,
                            //     colorText: Color(0xFFff4667),
                            //     icon: Icon(
                            //       Icons.warning_amber_rounded,
                            //       color: Color(0xFFff4667),
                            //     ),
                            //     duration: Duration(seconds: 3));
                          }
                        }),
                    Container(
                      padding: EdgeInsets.symmetric(
                          vertical: width * 0.01, horizontal: width * 0.02),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom:
                                  BorderSide(width: 1, color: Colors.grey))),
                      child: TextFormFieldWidget(
                          header: Text(
                            "시작 시간",
                            style: TextStyle(fontSize: width * 0.04),
                          ),
                          body: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: width * 0.45,
                                padding: EdgeInsets.only(left: width * 0.004),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
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
                                            Icons.arrow_drop_down_outlined,
                                            size: 32))
                                  ],
                                ),
                              ),
                              Container(
                                width: width * 0.3,
                                padding: EdgeInsets.only(left: width * 0.02),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
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
                                                  initialEntryMode:
                                                      TimePickerEntryMode.input,
                                                  context: context,
                                                  initialTime:
                                                      TimeOfDay.fromDateTime(
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
                                            Icons.arrow_drop_down_outlined,
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
                          vertical: width * 0.01, horizontal: width * 0.02),
                      child: TextFormFieldWidget(
                          header: Text(
                            "종료 시간",
                            style: TextStyle(fontSize: width * 0.04),
                          ),
                          body: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: width * 0.45,
                                padding: EdgeInsets.only(left: width * 0.004),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
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
                                            Icons.arrow_drop_down_outlined,
                                            size: 32))
                                  ],
                                ),
                              ),
                              Container(
                                width: width * 0.3,
                                padding: EdgeInsets.only(left: width * 0.02),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
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
                                                  initialEntryMode:
                                                      TimePickerEntryMode.input,
                                                  context: context,
                                                  initialTime:
                                                      TimeOfDay.fromDateTime(
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
                                                if (startDate.isAfter(endDate))
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
                                            Icons.arrow_drop_down_outlined,
                                            size: 32))
                                  ],
                                ),
                              )
                            ],
                          ),
                          footer: null,
                          heightPadding: 0),
                    ),
                  ],
                ),
              ),
            );
          });
        }).then((value) => setState(() {}));
  }

  _appBar(BuildContext context, String photo) {
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
