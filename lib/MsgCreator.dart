import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_test/chat.dart';
import 'package:flutter_application_test/data.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class MsgCreator extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return MsgCreatorState();
  }
}

class MsgCreatorState extends State<StatefulWidget>{
  final _formKey = GlobalKey<FormState>();

  // 用户名和密码的控制器
  final _useridController = TextEditingController();
  final _remarkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: Controller(),
        builder: (controller){
          return Scaffold(
            appBar: AppBar(
              title: Text('新建会话'),
            ),
            body: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: _useridController,
                    decoration: InputDecoration(
                      labelText: 'ID号码',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入目标ID';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _remarkController,
                    decoration: InputDecoration(
                      labelText: '备注',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入备注';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('创建中...'), duration: Durations.short1,),
                          );
                          controller.reloadMsgs(_useridController.text);
                          Get.off(ChatPage(user: types.User(id: _useridController.text, firstName: _remarkController.text),));
                        }
                      },
                      child: Text('确认新建'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}