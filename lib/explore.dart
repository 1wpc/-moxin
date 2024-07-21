import 'package:flutter/material.dart';
import 'package:flutter_application_test/chat.dart';
import 'package:flutter_application_test/data.dart';
import 'package:get/get.dart';

class Explore extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: Controller(),
      builder: (controller) {
        return ListView.builder(
          itemCount: controller.messageshow.length,
          itemBuilder: (context, index){
            var msg = controller.messageshow[index];
            var slectedAuthorName = msg.author.firstName.toString();
            var slectedAuthorId = msg.author.id;
            bool isMyMsg = slectedAuthorId == controller.user.id;
            var friendName = isMyMsg ? msg.roomId.toString() : slectedAuthorName;
            var friendId = isMyMsg ? msg.roomId.toString() : slectedAuthorId;
            return ListTile(
              onTap: () {
                controller.messages.clear();
                for (var i=controller.messagebox.length-1; i>=0; i--) {
                  var msg =controller.messagebox[i];
                  if (msg.author.id == friendId||msg.roomId == friendId){
                    controller.addMsg(msg);
                  }
                }
                
                Get.to(ChatPage(roomId: friendId));
              },
              title: Text(friendName),
              subtitle: Text(controller.messageshow[index].text),
          );
        }
      );
      },
    );
  }
  
}