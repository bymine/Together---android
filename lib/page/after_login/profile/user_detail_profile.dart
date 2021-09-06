import 'package:async/async.dart';
import 'package:flutter/material.dart';

class UserDetailProfilePage extends StatefulWidget {
  const UserDetailProfilePage({Key? key}) : super(key: key);

  @override
  _UserDetailProfilePageState createState() => _UserDetailProfilePageState();
}

class _UserDetailProfilePageState extends State<UserDetailProfilePage> {
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  late bool _switchValue;

  @override
  void initState() {
    super.initState();
    this._switchValue = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Switch(
            value: this._switchValue,
            onChanged: (newValue) {
              setState(() {
                this._switchValue = newValue;
              });
            },
          ),
          FutureBuilder(
              future: this._fetchData(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    return Center(child: Text(snapshot.data.toString()));
                }
              }),
        ],
      ),
    );
  }

  _fetchData() {
    return this._memoizer.runOnce(() async {
      await Future.delayed(Duration(seconds: 2));
      return 'REMOTE DATA';
    });
  }
}
