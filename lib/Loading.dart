import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_test/home.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'data.dart';

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000);
}

void loadShow()async{
  await EasyLoading.show(status: "正在初始化",);
}

class Loading extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return LoadingState();
  }
  
}

class LoadingState extends State<StatefulWidget>{
  final Controller c = Get.put(Controller());

  @override
  Widget build(BuildContext context) {
    loadShow();
    return Center();
  }

  Future getMsgShow()async{
    var category = Map.from(Global.contacts);
    await Global.messageProvider.open();
    await Global.messageProvider.initCursorForShow();
    while(await Global.messageProvider.cursor.moveNext()){
      if (category.isNotEmpty){
        var readonly_msg_map = Global.messageProvider.cursor.current;
        var author_id = readonly_msg_map['author_id'];
        var friend_id = readonly_msg_map['roomId'];
        var msg = Map<String, dynamic>.from(readonly_msg_map)..remove("author_id");
        if (category[author_id] != null){
          msg["author"] = category[author_id];
          category.remove(author_id);
          c.addMsgShow(types.TextMessage.fromJson(msg));
          break;
        }else if (category[friend_id] != null){
          msg["author"] = c.userProcessor(c.user).toJson();
          category.remove(friend_id);
          c.addMsgShow(types.TextMessage.fromJson(msg));
          break;
        }
      }else{
        break;
      }
    }
    Global.messageProvider.cursor.close();
  }

  void init()async{
    configLoading();
    EasyLoading.addStatusCallback((status){
      if (status == EasyLoadingStatus.dismiss){
        Get.off(MyHomePage());
      }
    });
    await c.initUser();
    await getMsgShow();
    EasyLoading.dismiss();
  }

  @override
  void initState() {
    init();
    super.initState();
  }
  
}