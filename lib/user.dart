import 'package:flutter/material.dart';
import 'package:flutter_application_test/data.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class User extends StatelessWidget{
  final Controller c = Get.put(Controller());
  var id = "";
  var name = "";

  @override
  Widget build(BuildContext context) {
    TextEditingController ctl_id = TextEditingController(text: c.user.id);
    TextEditingController ctl_name = TextEditingController(text: c.user.firstName);

    return Column(
      children: [
        SizedBox(
          width: 200,
          child: TextField(
            controller: ctl_id,
            autofocus: false,
            decoration: const InputDecoration(
                labelText: "id"
            ),
          ),
        ),
        SizedBox(
          width: 200,
          child: TextField(
            controller: ctl_name,
            autofocus: false,
            decoration: const InputDecoration(
                labelText: "name"
            ),
          ),
        ),
        ElevatedButton(
            onPressed: (){
              c.updateUser(types.User(id: ctl_id.text, firstName: ctl_name.text));
            },
            child: Text("保存修改")
        ),
        ElevatedButton(
            onPressed: (){
              c.initUser();
            },
            child: Text("refresh")
        )
      ],
    );
  }
}