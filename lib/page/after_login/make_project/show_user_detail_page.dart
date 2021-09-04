import 'package:flutter/material.dart';
import 'package:together_android/model/user_profile_model.dart';
import 'package:together_android/service/api.dart';

class ShowUserDetailPage extends StatelessWidget {
  final UserProfile userProfile;

  ShowUserDetailPage({required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("프로필 조회"),
      ),
      body: Column(
        children: [
          Text(userProfile.nickname),
          ElevatedButton(
              onPressed: () async {
                final code = await togetherGetAPI(
                    '/project/inviteMember', '/${userProfile.nickname}');
                print(code);
                Navigator.of(context).pop(userProfile.nickname.toString());
                Navigator.of(context).pop();
              },
              child: Text("초대하기"))
        ],
      ),
    );
  }
}
