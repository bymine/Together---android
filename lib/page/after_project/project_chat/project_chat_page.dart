import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:together_android/constant.dart';
import 'package:together_android/main.dart';
import 'package:together_android/model/after_login_model/live_project_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
import 'package:together_android/page/after_login/main_page.dart';
import 'package:together_android/utils.dart';

StompClient stompClient = StompClient(
  config: StompConfig.SockJS(
    url: 'http://101.101.216.93:8080/ws',
    onWebSocketError: (dynamic error) {
      print(error.toString());
    },
    onConnect: (StompFrame frame) {
      print("onConnect 실행");
      stompClient.subscribe(
        destination: '/return/message/$chatRoom',
        callback: (frame) {
          print('ddd');
        },
      );
    },
  ),
);

class ProjectChatPage extends StatefulWidget {
  const ProjectChatPage();

  @override
  _ProjectChatPageState createState() => _ProjectChatPageState();
}

class _ProjectChatPageState extends State<ProjectChatPage> {
  TextEditingController _textEditingController = TextEditingController();
  StreamController _streamController = StreamController();
  ScrollController _scrollController = ScrollController();
  List<ChatMessage> a = [];
  List<ChatMessage> addMessage = [];
  List<ChatMessage> chatList = [];
  late ChatMessage add;

  @override
  void initState() {
    addMessage = [];
    getData();
    super.initState();

    stompClient.subscribe(
      destination: '/return/message/$chatRoom',
      callback: (frame) {
        print('ddd');
        var result = ChatMessage.fromJson(json.decode(frame.body!));
        if (mounted) {
          if (result.userIdx !=
              Provider.of<SignInModel>(context, listen: false).userIdx) {
            setState(() {
              addMessage.add(result);
            });
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int userIdx = Provider.of<SignInModel>(context).userIdx;
    String userName = Provider.of<SignInModel>(context).userName;
    String photo = Provider.of<SignInModel>(context).userPhoto;

    String userPhoto = Provider.of<SignInModel>(context).userPhoto;
    int projectIdx = Provider.of<LiveProject>(context).projectIdx;
    String projectName = Provider.of<LiveProject>(context).projectName;

    print(stompClient.connected);
    return Scaffold(
      backgroundColor: Color(0xffD0EBFF),
      resizeToAvoidBottomInset: true,
      appBar: _appBar(context, projectName + " 채팅방", photo),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 6,
              child: Container(
                padding: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Color(0xffD0EBFF),
                ),
                child: StreamBuilder(
                    stream: _streamController.stream,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        chatList = [];
                        var list = snapshot.data as List<ChatMessage>;
                        for (var item in list) {
                          chatList.insert(0, item);
                        }
                        for (var item in addMessage) {
                          chatList.insert(0, item);
                        }

                        if (chatList.length != 0) {
                          return ListView.builder(
                            // physics: NeverScrollableScrollPhysics(),
                            controller: _scrollController,
                            shrinkWrap: true,
                            reverse: true,
                            itemCount: chatList.length,
                            itemBuilder: (context, index) {
                              int count = index;
                              ChatMessage streamChat = chatList[count];

                              if (count == chatList.length - 1) {
                                return Column(
                                  children: [
                                    buildTimeline(
                                        date: streamChat.sendDateTime),
                                    buildChatMessage(
                                        a: streamChat,
                                        userIdx: userIdx,
                                        samePeople: count == 0
                                            ? 0
                                            : chatList[count - 1].userIdx,
                                        sameTimeChat: count == 0
                                            ? "recently"
                                            : chatList[count - 1].sendDateTime)
                                  ],
                                );
                              } else if (getHashCode(DateTime.parse(
                                      streamChat.sendDateTime)) ==
                                  getHashCode(DateTime.parse(
                                      chatList[count + 1].sendDateTime))) {
                                return buildChatMessage(
                                    a: streamChat,
                                    userIdx: userIdx,
                                    samePeople: count == 0
                                        ? 0
                                        : chatList[count - 1].userIdx,
                                    sameTimeChat: count == 0
                                        ? "recently"
                                        : chatList[count - 1].sendDateTime);
                              } else {
                                return Column(
                                  children: [
                                    buildTimeline(
                                        date: streamChat.sendDateTime),
                                    buildChatMessage(
                                        a: streamChat,
                                        userIdx: userIdx,
                                        samePeople: count == 0
                                            ? 0
                                            : chatList[count - 1].userIdx,
                                        sameTimeChat: count == 0
                                            ? "recently"
                                            : chatList[count - 1].sendDateTime)
                                  ],
                                );
                              }
                            },
                          );
                        } else {
                          return Center(
                            child: Text("대화 내역이 없습니다.."),
                          );
                        }
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }),
              ),
            ),
            buildSendMessage(
                userIdx: userIdx,
                projectIdx: projectIdx,
                userName: userName,
                userPhoto: userPhoto)
          ],
        ),
      ),
    );
  }

  Future getData() async {
    print("getData 실행");
    int projectIdx =
        Provider.of<LiveProject>(context, listen: false).projectIdx;
    var url =
        "http://101.101.216.93:8080/message/chatroom?project_idx=$projectIdx";
    final response = await http.get(Uri.parse(url));
    final parsed = jsonDecode(utf8.decode(response.bodyBytes));
    //print(parsed);

    if (response.statusCode == 200) {
      a = parsed
          .map<ChatMessage>((json) => ChatMessage.fromJson(json))
          .toList();
      _streamController.add(a);
    }
  }

  Widget buildSendMessage(
          {required int userIdx,
          required int projectIdx,
          required String userName,
          required String userPhoto}) =>
      Container(
        margin: EdgeInsets.fromLTRB(15, 10, 15, 20),
        padding: EdgeInsets.symmetric(horizontal: 10),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                    hintText: "Message here", border: InputBorder.none),
              ),
            ),
            InkWell(
              child: Icon(Icons.arrow_forward),
              onTap: () {
                print("send 실행");

                stompClient.send(
                    destination: '/send/message/$projectIdx',
                    body: json.encode({
                      'user_idx': userIdx,
                      'project_idx': projectIdx,
                      'chat_message_body': _textEditingController.text
                      // 'chat_message_body': _textEditingController.text
                    }));

                setState(() {
                  print("setState 실행");
                  addMessage.add(ChatMessage(
                      userIdx: userIdx,
                      userName: userName,
                      userPhoto: userPhoto,
                      messageBody: _textEditingController.text,
                      sendDateTime: DateTime.now().toIso8601String()));
                });

                _textEditingController.clear();
              },
            )
          ],
        ),
      );

  Widget buildTimeline({required String date}) => Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Divider(thickness: 2, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(toDateDaysISO(date)),
            ),
            Expanded(
              child: Divider(thickness: 2, color: Colors.grey),
            ),
          ],
        ),
      );

  Widget buildChatMessage(
          {required ChatMessage a,
          required int userIdx,
          required int samePeople,
          required String sameTimeChat}) =>
      Container(
        // decoration: BoxDecoration(border: Border.all(width: 1)),
        // padding: (sameTimeChat == "recently" || samePeople != a.userIdx)
        //     ? EdgeInsets.all(30)
        //     : (chekcSameTimeChat(a.sendDateTime) !=
        //             chekcSameTimeChat(sameTimeChat))
        //         ? EdgeInsets.all(30)
        //         : EdgeInsets.all(0),
        child: ListTile(
          leading: a.userIdx != userIdx
              ? Wrap(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          //border: Border.all(width: 2, color: Colors.grey),
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage(
                                  "http://101.101.216.93:8080/images/" +
                                      a.userPhoto))),
                    )
                  ],
                )
              : null,
          title: Column(
            crossAxisAlignment: a.userIdx != userIdx
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: a.userIdx != userIdx
                ? [
                    Text(a.userName),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.only(right: 8, top: 4),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(20),
                              ),
                              color: Colors.grey[300],
                            ),
                            child: Text(
                              a.messageBody,
                            ),
                          ),
                        ),
                        (sameTimeChat == "recently" || samePeople != a.userIdx)
                            ? Text(toAMPMTimeISO(a.sendDateTime),
                                textAlign: TextAlign.end,
                                style: TextStyle(fontSize: 12))
                            : (chekcSameTimeChat(a.sendDateTime) !=
                                    chekcSameTimeChat(sameTimeChat))
                                ? Text(toAMPMTimeISO(a.sendDateTime),
                                    textAlign: TextAlign.end,
                                    style: TextStyle(fontSize: 12))
                                : Container(),
                      ],
                    ),
                  ]
                : [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        (sameTimeChat == "recently" || samePeople != a.userIdx)
                            ? Text(toAMPMTimeISO(a.sendDateTime),
                                textAlign: TextAlign.end,
                                style: TextStyle(fontSize: 12))
                            : (chekcSameTimeChat(a.sendDateTime) !=
                                    chekcSameTimeChat(sameTimeChat))
                                ? Text(toAMPMTimeISO(a.sendDateTime),
                                    textAlign: TextAlign.end,
                                    style: TextStyle(fontSize: 12))
                                : Container(),
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.only(
                              left: 8,
                              top: 4,
                            ),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(16),
                              ),
                              color: Colors.yellow[300],
                            ),
                            child: Text(
                              a.messageBody,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
          ),
        ),
      );

  _appBar(BuildContext context, String title, String photo) {
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
      title: Text(
        title,
        maxLines: 1,
        style: editTitleStyle,
      ),
      centerTitle: true,
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

class ChatMessage {
  int userIdx;
  String userName;
  String userPhoto;
  String messageBody;
  String sendDateTime;

  ChatMessage(
      {required this.userIdx,
      required this.userName,
      required this.userPhoto,
      required this.messageBody,
      required this.sendDateTime});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_idx'] = this.userIdx;
    data['user_name'] = this.userName;
    data['user_profile_photo'] = this.userPhoto;
    data['chat_message_body'] = this.messageBody;
    data['send_datetime'] = this.sendDateTime;
    return data;
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      userIdx: json['user_idx'] == null ? 1 : json['user_idx'],
      userName: json['user_name'] == null ? "이름없음" : json['user_name'],
      userPhoto: json['user_profile_photo'] == null
          ? "sample_picture.jpg"
          : json['user_profile_photo'],
      messageBody: json['chat_message_body'] == null
          ? "message"
          : json['chat_message_body'],
      sendDateTime: json['send_datetime'] == null
          ? DateTime.now().toIso8601String()
          : json['send_datetime'],
    );
  }
}
