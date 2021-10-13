import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/page/after_login/main_page.dart';
import 'package:together_android/page/after_login/match_project/search_project_page.dart';

class MatchProjectBody extends StatefulWidget {
  const MatchProjectBody({Key? key}) : super(key: key);

  @override
  _MatchProjectBodyState createState() => _MatchProjectBodyState();
}

class _MatchProjectBodyState extends State<MatchProjectBody> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String photo = Provider.of<SignInModel>(context, listen: false).userPhoto;
    return Scaffold(
      appBar: _appBar(context, photo),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
              left: width * 0.08, right: width * 0.08, bottom: height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Search Team",
                style: subHeadingStyle,
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "박수빈",
                style: headingStyle,
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _searchBar() {
    return TextField(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => SearchTeamPage()));
      },
      readOnly: true,
      decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none),
          fillColor: Colors.grey[200],
          filled: true,
          hintText: "Search",
          hintStyle: editSubTitleStyle,
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey,
          )),
    );
  }

  _appBar(BuildContext context, String photo) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MainPage()));
        },
        icon: Icon(Icons.home_outlined, color: Colors.grey),
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
