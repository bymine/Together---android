import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:together_android/model/after_login_model/MemberResume.dart';
import 'package:together_android/model/after_login_model/hobby_model.dart';
import 'package:together_android/model/after_login_model/invitaion_model.dart';
import 'package:together_android/model/after_login_model/live_project_model.dart';
import 'package:together_android/model/after_login_model/my_profile_model.dart';
import 'package:together_android/model/after_login_model/private_schedule_model.dart';
import 'package:together_android/model/after_login_model/team_card.dart';
import 'package:together_android/model/after_project_model/project_file_detail_model.dart';
import 'package:together_android/model/after_project_model/project_file_simple_model.dart';
import 'package:together_android/model/after_project_model/project_file_version_model.dart';
import 'package:together_android/model/after_project_model/project_schedule_model.dart';
import 'package:together_android/model/after_project_model/project_setting_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/model/after_login_model/user_profile_model.dart';
import 'package:together_android/page/after_project/project_file/reservation_main.dart';

String serverUrl = "http://101.101.216.93:8080";
//String serverUrl = "http://10.0.2.2:8080";

Future togetherGetAPI(String service, String parameter) async {
  final response = await http.get(Uri.parse(serverUrl + service + parameter));
  switch (service) {
    case "/user/checkDeviceValidation": // check sms code or email code
      return response.body;

    case "/user/validationEmail": // verify & send out email for sign up
      return response.body;

    case "/user/validationPhone": //verify & send out sms for sign up
      return response.body;

    case "/user/validationNickname": // verify nickname
      return response.body;

    case "/user/mypage":
      return jsonDecode(utf8.decode(response.bodyBytes));

    case "/main": // fetch live projects list
      var returnData = jsonDecode(utf8.decode(response.bodyBytes))
          .map<LiveProject>((json) => LiveProject.fromJson(json))
          .toList();
      if (returnData.toString() == "[]") {
        return;
      } else {
        return returnData;
      }

    case "/user/getUserSchedules":
      List returnData = jsonDecode(utf8.decode(response.bodyBytes))
          .map<Event>((json) => Event.fromJson(json))
          .toList();
      return returnData;

    case "/project/main":
      List returnData = jsonDecode(utf8.decode(response.bodyBytes))
          .map<Schedule>((json) => Schedule.fromJson(json))
          .toList();
      return returnData;

    case "/project/getInfo":
      return ProjectSetting.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));

    case "/user/detail_profile":
      return MyProfileDetail.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));

    case "/user/invitationList":
      var returnData = jsonDecode(utf8.decode(response.bodyBytes))
          .map<Invitaion>((json) => Invitaion.fromJson(json))
          .toList();
      return returnData;

    case "/user/edit_hobby":
      var returnData = jsonDecode(utf8.decode(response.bodyBytes))
          .map<FetchHobby>((json) => FetchHobby.fromJson(json))
          .toList();
      return returnData;

    case "/project/UserInfo":
      var parsedData = json.decode(utf8.decode(response.bodyBytes));
      return UserProfile(
          nickname: parsedData[0][0],
          mbti: parsedData[0][1],
          age: parsedData[0][2].toString(),
          license1: parsedData[0][3] ?? "",
          license2: parsedData[0][4] ?? "",
          license3: parsedData[0][5] ?? "",
          photo: parsedData[0][6],
          address: parsedData[0][7] ?? "");

    case "/project/getTagList":
      var parsedData = json.decode(utf8.decode(response.bodyBytes));
      return parsedData;

    case "/project/detailSchedule":
      return json.decode(utf8.decode(response.bodyBytes));

    case "/member/search/cards":
      print(response.statusCode);
      var returnData = jsonDecode(utf8.decode(response.bodyBytes))
          .map<MemberResume>((json) => MemberResume.fromJson(json))
          .toList();
      return returnData;

    case "/member/search/main":
      if (response.body == "")
        return;
      else {
        var returnData = jsonDecode(utf8.decode(response.bodyBytes))
            .map<MemberResume>((json) => MemberResume.fromJson(json))
            .toList();
        return returnData;
      }

    case "/member/search/register":
      var parsedData =
          MemberResume.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      return parsedData;

    case "/file/main":
      var returnData = jsonDecode(utf8.decode(response.bodyBytes))
          .map<SimpleFile>((json) => SimpleFile.fromJson(json))
          .toList();
      if (returnData.toString() == "[]") {
        return;
      } else {
        return returnData;
      }

    case "/file/version":
      var returnData = jsonDecode(utf8.decode(response.bodyBytes))
          .map<VersionFile>((json) => VersionFile.fromJson(json))
          .toList();
      return returnData;

    case "/file/detail":
      return DetailFile.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));

    case "/file/detail/reserveFileList":
      var returnData = jsonDecode(utf8.decode(response.bodyBytes))
          .map<BookingFile>((json) => BookingFile.fromJson(json))
          .toList();
      return returnData;

    case "/file/detail/download/read":
      print(response.body);
      print(response.request);
      print(response.contentLength);
      print(response.headers);
      return response.bodyBytes;

    case "/teamMatching":
      var parsedData =
          ProjectCard.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      return parsedData;
  }
}

Future togetherPostAPI(String service, String body) async {
  final response = await http.post(Uri.parse(serverUrl + service),
      headers: {'Content-Type': "application/json"}, body: body);

  switch (service) {
    case "/user/login": // sign in & fetch simple user information
      return SignInModel.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));

    case "/user/checkInfoForFindId": // verify & send out sms for search email
      return response.body;

    case "/user/checkInfoForChangePw": // verify & send out sms for change password
      return response.body;

    case "/user/findUserId": // fetch user email
      return response.body;

    case "/user/changePw": // change user new password
      return response.body;

    case "/user/join": //sign up
      return response.statusCode;

    case "/user/validationEditEmail":
      return response.body;

    case "/user/validationEditPhone":
      return response.body;

    case "/project/searchMember":
      return json.decode(utf8.decode(response.bodyBytes));

    case "/project/inviteMember":
      return response.body;

    case "/project/createProject":
      print(response.statusCode);
      print(response.body);
      return response.body;

    case "/file/detail/reserveFile":
      return response.body;

    case "/file/detail/deleteFile":
      print(response.body);
      return response.body;

    case "/member/search/invite":
      print(response.body);
      return response.body;

    default:
  }
}

Future togetherPostSpecialAPI(String service, String body, String idx) async {
  final response = await http.post(Uri.parse(serverUrl + service + idx),
      headers: {'Content-Type': "application/json"}, body: body);
  switch (service) {
    case "/member/search/do":
      var returnData = jsonDecode(utf8.decode(response.bodyBytes))
          .map<MemberResume>((json) => MemberResume.fromJson(json))
          .toList();
      return returnData;

    default:
  }
}
