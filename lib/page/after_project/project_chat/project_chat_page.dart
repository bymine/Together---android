import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:together_android/main.dart';
import 'package:together_android/model/after_login_model/live_project_model.dart';
import 'package:together_android/model/before_login_model/sign_in_model.dart';
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
          var result = ChatMessage.fromJson(json.decode(frame.body!));
          //addMessage.add(result);

          //print(addMessage.length);
          // print("frame: " + frame.toString());
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
    String userPhoto = Provider.of<SignInModel>(context).userPhoto;
    int projectIdx = Provider.of<LiveProject>(context).projectIdx;
    print(stompClient.connected);
    return Scaffold(
      backgroundColor: Colors.green[50],
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('프로젝트$projectIdx 채팅방'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 6,
              child: Container(
                padding: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                ),
                child: StreamBuilder(
                    stream: _streamController.stream,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        chatList = [];
                        var list = snapshot.data as List<ChatMessage>;
                        for (var item in list) {
                          chatList.add(item);
                        }
                        for (var item in addMessage) {
                          chatList.insert(0, item);
                        }

                        print(chatList.length);
                        print("StreamBuilder 실행");
                        return ListView.builder(
                          // physics: NeverScrollableScrollPhysics(),
                          controller: _scrollController,
                          shrinkWrap: true,
                          reverse: true,
                          itemCount: chatList.length,
                          itemBuilder: (context, index) {
                            ChatMessage streamChat = chatList[index];
                            return buildChatMessage(
                                a: streamChat, userIdx: userIdx);
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                      return Center(
                        child: Text("대화 내역이 없습니다.."),
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

    //_streamController.add();
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

                // stompClient.subscribe(
                //   destination: '/return/message/$chatRoom',
                //   callback: (frame) {
                //     print('새로운 메세지');
                //     var result = ChatMessage.fromJson(json.decode(frame.body!));
                //     addMessage.add(result);
                //     setState(() {});
                //     //print(addMessage.length);
                //     // print("frame: " + frame.toString());
                //   },
                // );
                var result;

                // stompClient.subscribe(
                //   destination: '/return/message/$projectIdx',
                //   callback: (frame) {
                //     print('subscribe 실행');
                //     result = ChatMessage.fromJson(json.decode(frame.body!));

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
                // Timer(Duration(milliseconds: 100),
                //     () => _scrollController.position.maxScrollExtent);
              },
            )
          ],
        ),
      );

  Widget buildChatMessage({required ChatMessage a, required int userIdx}) =>
      Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: a.userIdx != userIdx
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          children: [
            if (a.userIdx != userIdx)
              Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border: Border.all(width: 5, color: Colors.grey),
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(
                                "http://101.101.216.93:8080/images/" +
                                    a.userPhoto))),
                  ),
                  Text(a.userName)
                ],
              ),
            Flexible(
              child: Container(
                padding:
                    EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
                child: Align(
                  alignment: a.userIdx == userIdx
                      ? Alignment.topRight
                      : Alignment.topLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: a.userIdx == userIdx
                          ? Colors.yellow[300]
                          : Colors.white,
                    ),
                    padding: EdgeInsets.all(16),
                    child: Text(a.messageBody),
                  ),
                ),
              ),
            ),
            Container(
                width: 40,
                height: 20,
                child: Text(toTime(DateTime.parse(a.sendDateTime)))),
          ],
        ),
      );
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
