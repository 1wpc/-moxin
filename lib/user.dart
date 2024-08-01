import 'package:flutter/material.dart';
import 'package:flutter_application_test/Login.dart';
import 'package:flutter_application_test/data.dart';
import 'package:get/get.dart';

class User extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return UserState();
  }
}

class UserState extends State<StatefulWidget>{
  final Controller c = Get.put(Controller());
  var id = "";
  var name = "";
  var readonly = true;
  late String savedName;
  late String savedPassword;
  var changeButtonText = "更改信息";

  @override
  void initState() {
    super.initState();
    id = c.user.id;
    savedName = c.user.firstName.toString();
    savedPassword = c.user.metadata?["password"] ?? "00000";
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController ctl_user_name = TextEditingController(text: savedName);
    TextEditingController ctl_user_password = TextEditingController(text: savedPassword);

    return Center(
      child: Column(
        children: [
          TextButton(
            onPressed: (){
              Get.to(Login());
            },
            child: Text("墨信号：$id   >")
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 20)),
          FractionallySizedBox(
            widthFactor: 1.0,
            child: TextField(
              readOnly: readonly,
              controller: ctl_user_name,
              autofocus: false,
              decoration: const InputDecoration(
                  labelText: "用户名"
              ),
            ),
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 20)),
          FractionallySizedBox(
            widthFactor: 1.0,
            child: TextField(
              readOnly: true,
              obscureText: true,
              controller: ctl_user_password,
              autofocus: false,
              decoration: const InputDecoration(
                  labelText: "密码"
              ),
            ),
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: ()async{

                  },
                  child: Text("保存修改")
              ),
              Padding(padding: EdgeInsets.symmetric(horizontal: 20)),
              ElevatedButton(
                  onPressed: (){
                    if (!readonly){
                      ctl_user_name.text = savedName;
                      ctl_user_password.text = savedPassword;
                      changeButtonText = "更改信息";
                    }else{
                      changeButtonText = "取消更改";
                    }
                    setState(() {
                      readonly = !readonly;
                    });
                  },
                  child: Text(changeButtonText)
              )
            ],
          ),
        ],
      ),
    );
  }
}