import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together_android/componet/empty_data_display.dart';
import 'package:together_android/componet/live_project_cards.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/sign_in_model.dart';
import 'package:together_android/page/after_login/make_project/make_project_page.dart';
import 'package:together_android/service/api.dart';

class LiveProjectBody extends StatefulWidget {
  const LiveProjectBody({Key? key}) : super(key: key);

  @override
  _LiveProjectBodyState createState() => _LiveProjectBodyState();
}

class _LiveProjectBodyState extends State<LiveProjectBody> {
  late Future future;
  bool showFloatingButton = true;
  @override
  void initState() {
    super.initState();
    future = getDeviceUserIdx();
  }

  Future getDeviceUserIdx() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString('email');
    var pw = prefs.getString('pw');
    var idx = prefs.getInt('idx');

    if (idx != 0)
      return afterLoginGetAPI('/main', '?user_idx=$idx');
    else {
      var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;
      return afterLoginGetAPI('/main', '?user_idx=$userIdx');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: titleColor,
        title: Text("진행 중인 프로젝트"),
      ),
      body: FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            showFloatingButton = true;
            return LiveProjectCards(projects: snapshot.data);
          } else if (snapshot.hasError) {
            print("error");
            return Text("$snapshot.error");
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            print("waiting");
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            showFloatingButton = false;
            print("empty state");
            return EmptyDataDisplay();
          }
        },
      ),
      // floatingActionButton: Visibility(
      //   visible: showFloatingButton,
      //   child: FloatingActionButton(
      //     onPressed: () {
      //       Navigator.of(context).push(
      //           MaterialPageRoute(builder: (context) => MakeProjectBody()));
      //     },
      //     child: Icon(Icons.add),
      //   ),
      // ),
    );
  }
}