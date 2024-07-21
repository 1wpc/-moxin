import 'package:flutter/material.dart';
import 'package:flutter_application_test/data.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'package:get/get.dart';

String clientId = "000";


class ChatPage extends StatelessWidget {

  final Controller c = Get.find();

  ChatPage({super.key, required this.toUser}){
    _user = c.user;
  }
  types.User toUser;
  late types.User _user;
  // var _user = const types.User(
  //   id: "",
  //   //id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
  //   firstName: 'Test',
  //   lastName: 'test'
  // );

  // void _addMessage(types.Message message) {
  //   setState(() {
  //     _messages.insert(0, message);
  //   });
  // }

  // @override
  // void initState(){
  //   super.initState();
  //   print("userId=$userId");
  //   _user = types.User(
  //     id: userId,
  //      firstName: 'Test',
  //      lastName: 'test'
  //   );
  //   print("user.id=${_user.id}");
  //   clientId = _user.id;
  //   print("after user.id:$clientId");
  //   startThread();
  // }

  @override
  Widget build (BuildContext context) {
    return GetBuilder(
      init: Controller(), 
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(toUser.firstName?? "null"),
          ),
          body: Chat(
          messages: controller.messages,
          user: _user,
          onSendPressed: (types.PartialText message) {
            final textMessage = types.TextMessage(
                author: _user,
                createdAt: DateTime.now().millisecondsSinceEpoch,
                id: randomString(),
                text: message.text,
                roomId: toUser.id
            );

            controller.addMsg(textMessage);
            controller.addMsgBox(textMessage);
            for (var i in controller.messageshow){
              if (i.author.id == toUser.id||i.roomId == toUser.id){
                controller.messageshow.remove(i);
                break;
              }
            }
            controller.addMsgShow(textMessage);
            Global.sp.send(textMessage.toJson());
        },
      )
    );
      },
    );
    }
}