import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/live_project_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/page/after_login/main_page.dart';
import 'package:together_android/page/before_login/sign_in_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  var idx = prefs.getInt('idx');
  print(idx);
  idx == 0
      ? runApp(MyApp(
          skip: false,
        ))
      : runApp(MyApp(
          skip: true,
        ));
}

class MyApp extends StatelessWidget {
  final bool skip;
  MyApp({required this.skip});
  @override
  Widget build(BuildContext context) {
    //print(skip);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => SignInModel(
                userIdx: 0, userName: "", userPhoto: "", signInCode: "")),
        ChangeNotifierProvider(
            create: (_) => LiveProject(
                projectIdx: 0,
                memberCount: 0,
                files: 0,
                projectName: "",
                projectExp: "",
                startDate: "",
                endDate: "",
                photoes: []))
      ],
      child: MaterialApp(
          title: 'Together',
          theme: ThemeData(
              appBarTheme: AppBarTheme(color: titleColor),
              elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ButtonStyle(
                      //backgroundColor: Color(0xff82C290),
                      ))),
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('ko', ''),
            Locale('en', ''),
          ],
          home: skip == true ? MainPage() : SignInPage()),
    );
  }
}
