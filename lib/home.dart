import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_application_test/data.dart';
import 'package:flutter_application_test/explore.dart';
import 'package:flutter_application_test/user.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat.dart';
import 'contacts.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class MyHomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return MyHomePageState();
  }
}

class MyHomePageState extends State<StatefulWidget> with WidgetsBindingObserver{
  late types.User user;
  final Controller c = Get.put(Controller());
  final pages = [Explore(), Contacts(), User()];
  final List<BottomNavigationBarItem> bnItems = [
    const BottomNavigationBarItem(
      backgroundColor: Colors.blue,
      icon: Icon(Icons.home),
      label: "首页"
      ),
      const BottomNavigationBarItem(
        backgroundColor: Color.fromARGB(255, 152, 244, 54),
        icon: Icon(Icons.account_box),
        label: "联系人"
      ),
      const BottomNavigationBarItem(
        backgroundColor: Color.fromARGB(255, 244, 228, 54),
        icon: Icon(Icons.person),
        label: "我的"
      )
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    //Global.init();
    //init();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print("000当前的应用生命周期状态 : ${state}");

    if(state == AppLifecycleState.paused){
      print("000应用进入后台 paused");

    }else if(state == AppLifecycleState.resumed){
      print("000应用进入前台 resumed");
      if (!Global.isConnect){
        Global.sp.send(c.user.id);
      }

    }else if(state == AppLifecycleState.inactive){
      // 应用进入非活动状态 , 如来了个电话 , 电话应用进入前台
      // 本应用进入该状态
      print("000应用进入非活动状态 inactive");

    }else if(state == AppLifecycleState.detached){
      // 应用程序仍然在 Flutter 引擎上运行 , 但是与宿主 View 组件分离
      print("000应用进入 detached 状态 detached");

    }
  }

  @override
  Widget build(BuildContext context) {
    c.initUser();

    return GetBuilder(
      init: c,
      builder: (controller) {
        return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("墨"),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: bnItems,
        currentIndex: controller.currentIndex,
        type: BottomNavigationBarType.shifting,
        onTap: (idx) => controller.changePage(idx),
        ),
      body: pages[controller.currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          // var simulatedMsg = types.TextMessage(//simulate message from srver
          //   author: const types.User(id: "id10", firstName: "测试用户"),
          //   id: randomString(), 
          //   text: "这是一条模拟从服务器获取的测试消息${randomInt(5)}。"
          //     );
              
          // controller.addMsgBox(simulatedMsg);
          // var authorId = simulatedMsg.author.id;//friend id
          // for (var i in controller.messageshow){
          //   if (i.author.id == authorId||i.roomId == authorId){
          //     controller.messageshow.remove(i);
          //     break;
          //   }
          // }
          // controller.addMsgShow(simulatedMsg);
        } ),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
      },
    );
  }
}