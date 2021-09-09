import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:together_android/model/live_project_model.dart';
import 'package:together_android/model/my_profile_model.dart';
import 'package:together_android/model/sign_in_model.dart';
import 'package:together_android/model/user_profile_model.dart';
import 'package:together_android/page/after_login/profile/user_schedule_page.dart';

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

    case "/main": // fetch live projects list
      List returnData = jsonDecode(utf8.decode(response.bodyBytes))
          .map<LiveProject>((json) => LiveProject.fromJson(json))
          .toList();
      // if (returnData.isEmpty)
      //   return;
      // else
      //   return returnData;
      return returnData;

    case "/user/getUserSchedules":
      List returnData = jsonDecode(utf8.decode(response.bodyBytes))
          .map<Event>((json) => Event.fromJson(json))
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

    case "/user/detail_profile":
      return MyProfileDetail.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));
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

    case "/project/searchMember":
      return json.decode(utf8.decode(response.bodyBytes));

    case "/project/inviteMember":
      return response.body;

    case "/project/createProject":
      print(response.statusCode);
      print(response.body);
      return response.body;

    default:
  }
}
