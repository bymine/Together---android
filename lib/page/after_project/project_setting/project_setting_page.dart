import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:together_android/componet/button.dart';
import 'package:together_android/componet/listTile.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/model/after_login_model/live_project_model.dart';
import 'package:together_android/model/after_project_model/project_setting_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/page/after_login/main_page.dart';
import 'package:together_android/page/after_project/project_setting/edit_project_info_page.dart';
import 'package:together_android/service/api.dart';
import 'package:together_android/utils.dart';

class ProjectSettingPage extends StatefulWidget {
  const ProjectSettingPage({Key? key}) : super(key: key);

  @override
  _ProjectSettingPageState createState() => _ProjectSettingPageState();
}

class _ProjectSettingPageState extends State<ProjectSettingPage> {
  late Future future;
  fetchSetting() async {
    var projectIdx =
        Provider.of<LiveProject>(context, listen: false).projectIdx;
    return await togetherGetAPI("/project/getInfo", "/$projectIdx");
  }

  @override
  void initState() {
    super.initState();
    future = fetchSetting();
  }

  @override
  Widget build(BuildContext context) {
    var photo = Provider.of<SignInModel>(context, listen: false).userPhoto;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: _appBar(context, photo),
      body: SingleChildScrollView(
        child: FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                ProjectSetting setting = snapshot.data as ProjectSetting;
                return Container(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20)),
                            color: Color(0xffD0EBFF)),
                        padding: EdgeInsets.only(
                            left: width * 0.08,
                            right: width * 0.08,
                            bottom: height * 0.02),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Project Setting",
                                      style: subHeadingStyle,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      setting.projectName,
                                      style: headingStyle,
                                    ),
                                  ],
                                ),
                                MyButton(label: "수정하기", onTap: () {})
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                iconButton(
                                    width, "Message", Icons.email, () => null),
                                iconButton(
                                    width,
                                    "Edit",
                                    Icons.edit,
                                    () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditProjectInfo(
                                                  setting: setting,
                                                ))))
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            left: width * 0.04,
                            right: width * 0.04,
                            top: height * 0.04),
                        child: Column(
                          children: [
                            MyListTile(
                              title: Text(
                                'Intro',
                                style: editTitleStyle,
                              ),
                              subTitle: Text(
                                setting.projectExp,
                                style: editSubTitleStyle,
                              ),
                            ),
                            MyListTile(
                              title: Text(
                                'Start',
                                style: editTitleStyle,
                              ),
                              subTitle: Text(
                                toDateISO(setting.startDate),
                                style: editSubTitleStyle,
                              ),
                            ),
                            MyListTile(
                              title: Text(
                                'End',
                                style: editTitleStyle,
                              ),
                              subTitle: Text(
                                toDateISO(setting.endDate),
                                style: editSubTitleStyle,
                              ),
                            ),
                            MyListTile(
                              title: Text(
                                'Professionality',
                                style: editTitleStyle,
                              ),
                              subTitle: Text(
                                setting.level,
                                style: editSubTitleStyle,
                              ),
                            ),
                            MyListTile(
                              title: Text(
                                'Type',
                                style: editTitleStyle,
                              ),
                              subTitle: Text(
                                setting.type,
                                style: editSubTitleStyle,
                              ),
                            ),
                            MyListTile(
                              leading: CircleAvatar(
                                  child: Icon(Icons.tag, color: Colors.white),
                                  backgroundColor: Colors.red[300]),
                              title: Text(
                                'Tag',
                                style: editTitleStyle,
                              ),
                              subTitle: Container(
                                child: Wrap(
                                  spacing: 0.5,
                                  children: setting.tag
                                      .map((element) => Chip(
                                            label: Text(
                                              element,
                                            ),
                                            backgroundColor: titleColor,
                                            deleteIconColor: Colors.red[300],
                                            onDeleted: () async {
                                              setState(() {
                                                setting.tag.remove(element);
                                              });
                                            },
                                          ))
                                      .toList(),
                                ),
                              ),
                              trailing: IconButton(
                                  onPressed: () async {},
                                  icon: Icon(Icons.add)),
                            ),
                            MyListTile(
                              leading: CircleAvatar(
                                  child: Icon(Icons.manage_accounts,
                                      color: Colors.white),
                                  backgroundColor: Colors.purple[300]),
                              title: Text(
                                'Members',
                                style: editTitleStyle,
                              ),
                              subTitle: Text(
                                setting.members.toString(),
                                style: editSubTitleStyle,
                              ),
                              trailing: IconButton(
                                  onPressed: () async {},
                                  icon: Icon(Icons.chevron_right_outlined)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            }),
      ),
    );
  }

  iconButton(double width, String name, IconData icon, Function()? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width * 0.2,
        height: width * 0.2,
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Color(0xffffe0e0e0),
                spreadRadius: 2,
                blurRadius: 2,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: pinkClr,
              size: 32,
            ),
            Text(
              name,
              style: editSubTitleStyle,
            )
          ],
        ),
      ),
    );
  }

  _appBar(BuildContext context, String photo) {
    return AppBar(
      backgroundColor: Color(0xffD0EBFF),
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
