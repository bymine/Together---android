import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:together_android/model/live_project_model.dart';
import 'package:together_android/model/sign_in_model.dart';

//String serverUrl = "http://101.101.216.93:8080";
String localUrl = "http://10.0.2.2:8080";

Future beforeLoginGetAPI(String service, String parameter) async {
  final response = await http.get(Uri.parse(localUrl + service + parameter));

  switch (service) {
    case "/user/checkDeviceValidation":
      return response.body;

    default:
  }
}

Future afterLoginGetAPI(String service, String parameter) async {
  final response = await http.get(Uri.parse(localUrl + service + parameter));

  // var statusCode = response.statusCode;

  // print(service + " api 연결 상태: " + statusCode.toString());
  // print(service + " api 데이터: " + parsedData.toString());

  switch (service) {
    case "/main":
      List returnData = jsonDecode(utf8.decode(response.bodyBytes))
          .map<LiveProject>((json) => LiveProject.fromJson(json))
          .toList();
      if (returnData.isEmpty)
        return;
      else
        return returnData;
  }
}

Future beforeLoginPostAPI(String service, String body) async {
  final response = await http.post(Uri.parse(localUrl + service),
      headers: {'Content-Type': "application/json"}, body: body);

  // var statusCode = response.statusCode;
  // var parsedData = jsonDecode(utf8.decode(response.bodyBytes));
  // var parsedSignal = response.body;
  // print(service + " api 연결 상태: " + statusCode.toString());
  // print(service + " api 데이터: " + parsedData.toString());
  // var returnData;

  switch (service) {
    case "/user/login":
      // returnData = SignInModel.fromJson(parsedData);
      return SignInModel.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));

    case "/user/checkInfoForFindId":
      return response.body;

    case "/user/checkInfoForChangePw":
      return response.body;

    case "/user/findUserId":
      return response.body;

    case "/user/changePw":
      return response.body;

    default:
  }
}



// 인정번호 전송 api
                                          // var code = await beforeLoginPostAPI(
                                          //     '/user/checkInfoForFindId',
                                          //     jsonEncode({
                                          //       "user_name": findNameController.text,
                                          //       "user_phone": phoneNumerFormat(
                                          //           findPhoneController.text)
                                          //     }));