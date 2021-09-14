import 'package:intl/intl.dart';

String phoneNumerFormat(String phone) {
  String first;
  String second;
  String third;

  first = phone.substring(0, 3);

  if (phone.length == 10) {
    second = phone.substring(3, 6);
    third = phone.substring(6, 10);
  } else {
    second = phone.substring(3, 7);
    third = phone.substring(7, 11);
  }
  print(first + "-" + second + "-" + third);

  return first + "-" + second + "-" + third;
}

String toPhoneString(String number) {
  return number.replaceAll('-', '');
}

String durationFormatTime(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "$twoDigitMinutes:$twoDigitSeconds";
}

String toDateTime(DateTime dateTime) {
  final date = DateFormat('yyyy년 M월 d일').format(dateTime);

  final time = DateFormat('HH:mm').format(dateTime);

  return '$date $time';
}

String toDate(DateTime dateTime) {
  final date = DateFormat('yyyy년 M월 d일').format(dateTime);

  return '$date';
}

String toTime(DateTime dateTime) {
  final time = DateFormat.Hm().format(dateTime);

  return '$time';
}

String projectEnumFormat(String value) {
  switch (value) {
    case "상":
      return "High";

    case "중":
      return "Mid";

    case "하":
      return "Low";

    case "설정 안함":
      return "Any";

    case "스터디":
      return "Study";

    case "대외활동":
      return "Out";

    case "교내활동":
      return "In";

    default:
      return "Any";
  }
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

DateTime getDateTime(int hash) {
  int day = hash ~/ 1000000;
  int month = (hash % 1000000) ~/ 10000;
  int year = (hash % 1000000) % 10000;

  return DateTime(year, month, day);
}

String licenseToString(String license1, String license2, String license3) {
  String string = "";
  string = license1 + "," + license2 + "," + license3;

  string = string.replaceAll(",,", ",");

  if (string[0] == ",") {
    print("first");
    string = string.substring(1, string.length);
  }
  if (string.length != 0 && string[string.length - 1] == ",") {
    print("last");
    string = string.substring(0, string.length - 1);
  }
  if (string.length == 0) string = "";
  return string;
}
