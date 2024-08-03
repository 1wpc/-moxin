import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_application_test/Loading.dart';
import 'package:flutter_application_test/NotificationUtility.dart';
import 'package:flutter_application_test/data.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

Isolate? _isolate;

thread(sendPort)async{
  var rp = ReceivePort();
  sendPort.send(rp.sendPort);
  types.User user = types.User(id: "null0");
  var clientId = "";
  bool isconnect = false;
  print("connecting...");
  late Socket socket;
  Future<void> receive()async {
    try{
      await for (var data in socket){
        isconnect = true;
        sendPort.send(utf8.decode(data));
      }
    }catch(e){
      print("错误$e");
      socket.close();
      isconnect = false;
    }
  }
  Future<void> connect(Map<String, dynamic> data)async{
    try{
      socket = await Socket.connect("120.46.131.50", 8848,timeout: Duration(seconds: 10));
      isconnect = true;
      socket.add(utf8.encode("${json.encode(data)}\n"));
      socket.flush();
      receive();
      print("connect sucess");
    }catch(e){
      print("错误$e");
      isconnect = false;
    }
  }
  rp.listen((msg)async{
    if(msg is String){
      if (msg != "close"){
      }else {
        if(socket != null){
          socket.close();
        }
        isconnect = false;
      }
    }
    else{
      if (msg["cmd"] == "send_msg"){
        if (isconnect){
          socket.add(utf8.encode("${json.encode(msg["data"])}\n"));
        }
      }else if (msg["cmd"] == "init_user" || msg["cmd"] == "verify_user"){
        var user_map = msg["data"];
        user = types.User.fromJson(user_map);
        clientId = user_map["id"];
        print("clientId=$clientId");
        if (!isconnect && clientId != "null0"){
          connect(msg);
        }
      }else if (msg["cmd"] == "get_public_key"){
        if (isconnect){
          socket.add(utf8.encode("${json.encode(msg)}\n"));
        }
      }
    }
  });
  while (true){
    await Future.delayed(Duration(seconds: 5));
    if (!isconnect && clientId != "null0"){
      await connect(Global.wrapper("verify_user", user: user));
    }
  }
  // await for (var data in socket){
  //   sendPort.send(utf8.decode(data));
  // }
}

startThread()async{
    Global.rp = ReceivePort();
    if (_isolate != null ) return;
    _isolate = await Isolate.spawn(thread, Global.rp.sendPort, debugName: 'receiver');
}

@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Global.rp = ReceivePort();
  //startThread();
  Global.notif = NotificationUtility();
  await Global.notif.initialize();
  FlutterForegroundTask.initCommunicationPort();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: EasyLoading.init(),
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Loading(),
    );
  }
}

class MyTaskHandler extends TaskHandler {
  int _count = 0;
  types.User user = types.User(id: "null0");
  var clientId = "null0";
  bool isconnect = false;
  late Socket socket;

  Future<void> receive()async {
    try{
      await for (var data in socket){
        isconnect = true;
        FlutterForegroundTask.sendDataToMain(utf8.decode(data));
      }
    }catch(e){
      print("错误$e");
      socket.close();
      isconnect = false;
    }
  }
  Future<void> connect(Map<String, dynamic> data)async{
    try{
      socket = await Socket.connect("120.46.131.50", 8848,timeout: Duration(seconds: 10));
      isconnect = true;
      socket.add(utf8.encode("${json.encode(data)}\n"));
      socket.flush();
      receive();
      print("connect sucess");
    }catch(e){
      print("错误$e");
      isconnect = false;
    }
  }
  // Called when the task is started.
  @override
  void onStart(DateTime timestamp)async {
    print('onStart');
    while (true){
      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  // Called every [ForegroundTaskOptions.interval] milliseconds.
  @override
  void onRepeatEvent(DateTime timestamp) async{
    FlutterForegroundTask.updateService(notificationText: 'count: $_count');
    _count++;
    print("isconnect=$isconnect, clientId=$clientId");
    if (!isconnect && clientId != "null0"){
      await connect(Global.wrapper("verify_user", user: user));
    }
  }

  // Called when the task is destroyed.
  @override
  void onDestroy(DateTime timestamp) {
    print('onDestroy');
    socket.close();
    isconnect = false;
  }

  // Called when data is sent using [FlutterForegroundTask.sendDataToTask].
  @override
  void onReceiveData(dynamic msg) {
    print('onReceiveData');
    if(msg is String){
      if (msg != "close"){
      }else {
        if(socket != null){
          socket.close();
        }
        isconnect = false;
      }
    } else{
      if (msg["cmd"] == "send_msg"){
        if (isconnect){
          socket.add(utf8.encode("${json.encode(Map<String, dynamic>.from(msg)["data"])}\n"));
        }
      }else if (msg["cmd"] == "init_user" || msg["cmd"] == "verify_user"){
        var data = msg["data"];
        Map<String, dynamic> user_map = Map<String, dynamic>.from(data);
        user_map["metadata"] = Map<String, dynamic>.from(data["metadata"]);
        user = types.User.fromJson(user_map);
        clientId = user_map["id"];
        print("clientId=$clientId");
        if (!isconnect && clientId != "null0"){
          print(4);
          connect(Map<String, dynamic>.from(msg));
        }
      }else if (msg["cmd"] == "get_public_key"){
        if (isconnect){
          socket.add(utf8.encode("${json.encode(Map<String, dynamic>.from(msg))}\n"));
        }
      }
    }
  }

  // Called when the notification button on the Android platform is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    print('onNotificationButtonPressed: $id');
  }

  // Called when the notification itself on the Android platform is pressed.
  //
  // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
  // this function to be called.
  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/');
    print('onNotificationPressed');
  }

  // Called when the notification itself on the Android platform is dismissed
  // on Android 14 which allow this behaviour.
  @override
  void onNotificationDismissed() {
    print('onNotificationDismissed');
  }
}
