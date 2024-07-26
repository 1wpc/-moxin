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

thread(sendPort)async{
  var rp = ReceivePort();
  sendPort.send(rp.sendPort);
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
  Future<void> connect()async{
    try{
      socket = await Socket.connect("192.168.31.7", 8848,timeout: Duration(seconds: 10));
      isconnect = true;
      socket.add(utf8.encode("$clientId\n"));
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
        clientId = msg;
        print("clientId=$clientId");
        if (!isconnect && clientId != "null0"){
          connect();
        }
      }else {
        if(socket != null){
          socket.close();
        }
        isconnect = false;
      }
    }
    else{
      if (isconnect){
        socket.add(utf8.encode("${json.encode(msg)}\n"));
      }
    }
  });
  while (true){
    await Future.delayed(Duration(seconds: 5));
    if (!isconnect && clientId != "null0"){
      await connect();
    }
  }
  // await for (var data in socket){
  //   sendPort.send(utf8.decode(data));
  // }
}

startThread()async{
    Global.rp = ReceivePort();
    await Isolate.spawn(thread, Global.rp.sendPort);
}

@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  startThread();
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

  // Called when the task is started.
  @override
  void onStart(DateTime timestamp) {
    print('onStart');
  }

  // Called every [ForegroundTaskOptions.interval] milliseconds.
  @override
  void onRepeatEvent(DateTime timestamp) {
    FlutterForegroundTask.updateService(notificationText: 'count: $_count');

    // Send data to main isolate.
    FlutterForegroundTask.sendDataToMain(_count);

    _count++;
  }

  // Called when the task is destroyed.
  @override
  void onDestroy(DateTime timestamp) {
    print('onDestroy');
  }

  // Called when data is sent using [FlutterForegroundTask.sendDataToTask].
  @override
  void onReceiveData(Object data) {
    print('onReceiveData: $data');
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
