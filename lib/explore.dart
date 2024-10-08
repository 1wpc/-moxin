import 'package:flutter/material.dart';
import 'package:flutter_application_test/chat.dart';
import 'package:flutter_application_test/data.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

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
            var friendName = isMyMsg ? Global.contacts[msg.roomId.toString()]!["firstName"] : slectedAuthorName;
            var friendId = isMyMsg ? msg.roomId.toString() : slectedAuthorId;
            var text = msg.text;
            return Column(
              children: [
                ListTile(
                  onTap: () {
                    //controller.reloadMsgs(friendId);
                    controller.messages.clear();
                    Get.to(ChatPage(user: types.User(id: friendId, firstName: friendName),));
                  },
                  title: Text(friendName),
                  subtitle: Text(text.length <= 20 ? text : text.substring(0, 20)),
                  leading: CircleAvatar(
                  child: Text(friendName.toString()[0])
                  )
                ),
                Divider()
              ],
            );
        }
      );
      },
    );
  }
  
}