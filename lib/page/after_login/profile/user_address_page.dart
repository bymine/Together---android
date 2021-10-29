import 'package:flutter/material.dart';
import 'package:juso/juso.dart';
import 'package:provider/provider.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';

class JusoScreen extends StatelessWidget {
  const JusoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var photo = Provider.of<SignInModel>(context, listen: false).userPhoto;
    return Scaffold(
      appBar: _appBar(context, photo),
      body: const JusoWebView(),
    );
  }

  _appBar(BuildContext context, String photo) {
    return AppBar(
      backgroundColor: Color(0xffD0EBFF),
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
