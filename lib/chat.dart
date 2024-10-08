import 'package:flutter/material.dart';
import 'package:flutter_application_test/data.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'package:get/get.dart';

class ChatPage extends StatefulWidget{
  late types.User user;

  ChatPage({super.key, required this.user}){}

  @override
  State<StatefulWidget> createState(){
    return ChatPageState(toUser: user);
  }
}

class ChatPageState extends State<StatefulWidget> {

  final Controller c = Get.find();

  ChatPageState({required this.toUser}){
    _user = c.userProcessor(c.user);
  }
  types.User toUser;
  late types.User _user;
  
  Future loadMessages() async {
    for (int i = 0; i<16; i++){
      if (await Global.messageProvider.cursor.moveNext()){
        var readonly_msg_map = Global.messageProvider.cursor.current;
        var author_id = readonly_msg_map['author_id'];
        var msg_map = Map<String, dynamic>.from(readonly_msg_map)..remove("author_id");
        if(author_id == _user.id){
          msg_map["author"] = _user.toJson();
        }else{
          msg_map["author"] = toUser.toJson();
        }
        msg_map.remove("metadata");
        c.addMsg(types.TextMessage.fromJson(msg_map), order: false);
      }else{
        break;
      }
    }
  }
  
  @override
  void dispose() {
    Global.currentContactId = "";
    Global.messageProvider.cursor.close();
    super.dispose(); 
  }

  void init()async{
    Global.currentContactId = c.user.id;
    //Global.sp.send({"cmd": "get_public_key", "data": toUser.id});
    FlutterForegroundTask.sendDataToTask({"cmd": "get_public_key", "data": toUser.id});
    await Global.messageProvider.initCursorForPerson(toUser.id);
    if (c.messages.length<16){
      loadMessages();
    }
  }

  @override
  void initState() {
    init();
    super.initState();
  }

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
            onEndReached: ()async{
              loadMessages();
            },
            messages: controller.messages,
            user: _user,
            onSendPressed: (types.PartialText message) {
              final textMessage = types.TextMessage(
                id: randomString(),
                createdAt: DateTime.now().millisecondsSinceEpoch,
                author: controller.userProcessor(_user),
                text: message.text,
                roomId: toUser.id,
              );
              final encryptTextmessage = Global.messageConstructor(textMessage, message.text, toUser.id);
              controller.addMsg(textMessage);
              controller.addMsgBox(textMessage);
              for (var i in controller.messageshow){
                if (i.author.id == toUser.id||i.roomId == toUser.id){
                  controller.messageshow.remove(i);
                  break;
                }
              }
              controller.addMsgShow(textMessage);
              Global.messageProvider.insert(textMessage);
              FlutterForegroundTask.sendDataToTask(Global.wrapper("send_msg", message: encryptTextmessage));
        },
      )
    );
      },
    );
    }
}