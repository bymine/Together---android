import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/my_profile_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/page/after_login/profile/user_detail_profile.dart';
import 'package:together_android/page/before_login/sign_in_page.dart';
import 'package:together_android/service/api.dart';

class UserProfileBody extends StatefulWidget {
  @override
  _UserProfileBodyState createState() => _UserProfileBodyState();
}

class _UserProfileBodyState extends State<UserProfileBody> {
  late Future future;

  late File _image;
  Dio dio = new Dio();
  final picker = ImagePicker();

  Future changePhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      int userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;
      FormData formData = FormData.fromMap({
        "photo": await MultipartFile.fromFile(
          _image.path,
          filename: _image.path,
        ),
        "user_idx": userIdx,
      });

      String url = "http://101.101.216.93:8080/user/changePhoto";
      final response = await dio.post(url,
          data: formData,
          options: Options(headers: {"Content-Type": "multipart/form-data"}));

      if (response.statusCode == 200) {
        setState(() {});
      }
    } else {
      print('No image selected.');
    }
  }

  Future fetchProfil() async {
    var userIdx = Provider.of<SignInModel>(context, listen: false).userIdx;
    return togetherGetAPI("/user/detail_profile", "?user_idx=$userIdx");
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    future = fetchProfil();
    return Scaffold(
        appBar: AppBar(
          title: Text("프로필 보기"),
          actions: [
            IconButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString('email', "");
                  prefs.setString('pw', "");
                  prefs.setInt('idx', 0);

                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => SignInPage()));
                },
                icon: Icon(Icons.logout_outlined))
          ],
        ),
        body: FutureBuilder(
            future: future,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                var profile = snapshot.data as MyProfileDetail;
                return Container(
                    child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: width,
                          height: height * 0.5,
                          color: titleColor,
                        ),
                        Align(
                          child: Container(
                            width: width / 1.8,
                            height: width / 1.8,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 5, color: Colors.grey.shade500),
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(profile.userPhoto))),
                          ),
                        ),
                        Positioned(
                            bottom: width * 0.12,
                            right: width * 0.3,
                            child: Container(
                              child: IconButton(
                                  onPressed: changePhoto,
                                  icon: Icon(
                                    Icons.camera_alt,
                                    color: Colors.blue,
                                    size: 40,
                                  )),
                            ))
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: height * 0.02),
                      width: double.infinity,
                      height: height * 0.15,
                      child: Column(
                        children: [
                          Text(
                            profile.userName,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            profile.userNickName,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.orange.withOpacity(0.4)),
                            child: IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.today,
                                  color: Colors.orange,
                                  size: 32,
                                )),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.red.withOpacity(0.4)),
                            child: IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.local_post_office_outlined,
                                  color: Colors.red,
                                  size: 32,
                                )),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.blue.withOpacity(0.4)),
                            child: IconButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) =>
                                              UserDetailProfilePage()))
                                      .then((value) {
                                    setState(() {});
                                  });
                                },
                                icon: Icon(
                                  Icons.settings,
                                  color: Colors.blue,
                                  size: 32,
                                )),
                          )
                        ],
                      ),
                    ),
                  ],
                ));
              } else if (snapshot.hasError) {
                return Text('$snapshot.error');
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            }));
  }
}
