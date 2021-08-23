import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together_android/model/sign_in_model.dart';
import 'package:together_android/page/after_login/main_page.dart';
import 'package:together_android/page/before_login/sign_in_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // var email = prefs.getString('email');
  // var pw = prefs.getString('pw');
  // print(email);
  // print(pw);
  var auto = prefs.getBool('auto');
  if (auto == true) {
    runApp(MyApp(login: "auto"));
  } else {
    runApp(MyApp(login: "manual"));
  }
}

class MyApp extends StatelessWidget {
  final String login;

  MyApp({required this.login});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => SignInModel(
                userIdx: 0,
                userEmail: "",
                userPassword: "",
                userName: "",
                userPhoto: "",
                signInCode: "")),
      ],
      child: MaterialApp(
          title: 'Together',
          theme: ThemeData(
              primarySwatch: Colors.green,
              elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ButtonStyle(
                      //backgroundColor: Color(0xff82C290),
                      ))),
          home: login == "auto" ? MainPage() : SignInPage()),
    );
  }
}
