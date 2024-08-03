import 'dart:convert';
import 'dart:io';

import 'package:dart_sm/dart_sm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_test/MsgCreator.dart';
import 'package:flutter_application_test/data.dart';
import 'package:flutter_application_test/explore.dart';
import 'package:flutter_application_test/user.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'SignUp.dart';
import 'contacts.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'main.dart';

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

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
      // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
      // onNotificationPressed function to be called.
      //
      // When the notification is pressed while permission is denied,
      // the onNotificationPressed function is not called and the app opens.
      //
      // If you do not use the onNotificationPressed or launchApp function,
      // you do not need to write this code.
      // if (!await FlutterForegroundTask.canDrawOverlays) {
      //   // This function requires `android.permission.SYSTEM_ALERT_WINDOW` permission.
      //   await FlutterForegroundTask.openSystemAlertWindowSettings();
      // }

      // Android 12 or higher, there are restrictions on starting a foreground service.
      //
      // To restart the service on device reboot or unexpected problem, you need to allow below permission.
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }

      // Android 13 and higher, you need to allow notification permission to expose foreground service notification.
      final NotificationPermission notificationPermissionStatus =
      await FlutterForegroundTask.checkNotificationPermission();
      if (notificationPermissionStatus != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }
    }
  }

  Future<void> _initService() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription:
        'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<ServiceRequestResult?> _startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      return null;
    } else {
      return FlutterForegroundTask.startService(
        notificationTitle: '后台保护',
        notificationText: 'Tap to return to the app',
        notificationIcon: null,
        notificationButtons: [
          const NotificationButton(id: 'btn_hello', text: 'hello'),
        ],
        callback: startCallback,
      );
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    if (c.user.id == "null0"){
      EasyLoading.showInfo("请注册");
    }
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Request permissions and initialize the service.
      _requestPermissions();
      _initService();
      _startService();
    });
  }

  void _onReceiveTaskData(dynamic data) {
    var data_map = json.decode(data);
    if(data_map["info"] == "normal"){
      var content = jsonDecode(data_map["data"]);
      if (content["metadata"]["isEncrypted"] == true){
        var userName = content["author"]["firstName"];
        content["author"]["firstName"] = SM2.decrypt(userName, Global.privateKey);
        content["text"] = SM2.decrypt(content["text"], Global.privateKey);
        content.remove("metadata");
      }
      var msg = types.TextMessage.fromJson(content);
      Global.notif.showNotification(title: msg.author.firstName.toString(), body: msg.text);
      c.addMsgBox(msg);
      var authorId = msg.author.id;//friend id
      if (Global.contacts[authorId] == null){
        Global.contacts[authorId] = msg.author.toJson();
      }
      for (var i in c.messageshow){
        if (i.author.id == authorId||i.roomId == authorId){
          c.messageshow.remove(i);
          break;
        }
      }
      c.addMsgShow(msg);
      if (c.messages.isNotEmpty){
        if (c.messages[0].author.id == authorId||c.messages[0].roomId == authorId){
          var isExist = false;
          c.messages.forEach((v){
            if (v == msg){isExist = true;}
          });
          if (!isExist){c.addMsg(msg);}
        }
      }
      // if (authorId == Global.currentContactId){
      //   addMsg(msg);
      // }
      Global.messageProvider.insert(msg);
    }else if (data_map["info"] == "success_verify"){
      EasyLoading.showSuccess("登录成功");
    }else if (data_map["info"] == "success_init"){
      EasyLoading.showSuccess("注册成功");
    }else if (data_map["info"] == "error_pw"){
      EasyLoading.showError("密码错误");
    }else if (data_map["info"] == "error_null_user"){
      EasyLoading.showError("用户不存在");
    }else if (data_map["info"] == "error_user_repeat"){
      EasyLoading.showError("用户已存在");
    }else if (data_map["info"] == "public_key"){
      var publicKey = data_map["return"];
      var id = data_map["extra"];
      Global.contacts[id]["metadata"] = {"publicKey": publicKey};
      Global.save();
    }
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
      Global.save();

    }else if(state == AppLifecycleState.resumed){
      print("000应用进入前台 resumed");
      FlutterForegroundTask.sendDataToTask(Global.wrapper("verify_user", user: c.user));

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
        title: const Text("墨信"),
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
          Get.to(MsgCreator());
        } ),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
      },
    );
  }
}