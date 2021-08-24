import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:together_android/model/live_project_model.dart';
import 'package:together_android/model/sign_in_model.dart';

String serverUrl = "http://101.101.216.93:8080";

void beforeLoginGetAPI(String service) async {
  //final response = await http.get(Uri.parse(serverUrl + service));
}

Future afterLoginGetAPI(String service, String parameter) async {
  final response = await http.get(Uri.parse(serverUrl + service + parameter));

  // var statusCode = response.statusCode;
  var parsedData = jsonDecode(utf8.decode(response.bodyBytes));

  // print(service + " api 연결 상태: " + statusCode.toString());
  // print(service + " api 데이터: " + parsedData.toString());

  switch (service) {
    case "/main":
      List returnData = parsedData
          .map<LiveProject>((json) => LiveProject.fromJson(json))
          .toList();
      if (returnData.isEmpty)
        return;
      else
        return returnData;
  }
}

Future beforeLoginPostAPI(String service, String body) async {
  final response = await http.post(Uri.parse(serverUrl + service),
      headers: {'Content-Type': "application/json"}, body: body);

  //var statusCode = response.statusCode;
  var parsedData = jsonDecode(utf8.decode(response.bodyBytes));

  // print(service + " api 연결 상태: " + statusCode.toString());
  // print(service + " api 데이터: " + parsedData.toString());
  var returnData;

  switch (service) {
    case "/user/login":
      returnData = SignInModel.fromJson(parsedData);
      return returnData;

    default:
  }
}
