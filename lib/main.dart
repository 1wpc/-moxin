import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_application_test/Loading.dart';
import 'package:flutter_application_test/data.dart';
import 'package:get/get.dart';
import 'home.dart';
import 'home.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_easyloading/flutter_easyloading.dart';

thread(sendPort)async{
  var clientId = "000";
  var rp = ReceivePort();
  sendPort.send(rp.sendPort);
  print("connecting...");
  late Socket socket;// = await Socket.connect("192.168.31.7", 8848);
  Future<void> receive()async {
    try{
      await for (var data in socket){
        sendPort.send(utf8.decode(data));
      }
    }catch(e){
      print("错误$e");
      socket.close();
      Global.isConnect = false;
    }
  }
  rp.listen((msg)async{
    if(msg is String){
      if (msg != "close"){
        clientId = msg;
        print("clientId=$clientId");
        try{
          socket = await Socket.connect("192.168.45.184", 8848);
          print("connect sucess");
          Global.isConnect = true;
          socket.add(utf8.encode("$clientId\n"));
          socket.flush();
          receive();
        }catch(e){
          print("错误$e");
          Global.isConnect = false;
        }
      }else {
        socket.close();
        Global.isConnect = false;
      }
    }
    else{
      if (socket != null){
        socket.add(utf8.encode("${json.encode(msg)}\n"));
      }else{
        EasyLoading.showError("未连接服务器");
      }//待实现逻辑
    }
  });
  // await for (var data in socket){
  //   sendPort.send(utf8.decode(data));
  // }
}

startThread()async{
    Isolate isolate;
    Global.rp = ReceivePort();
    isolate = await Isolate.spawn(thread, Global.rp.sendPort);
  }

void main() {
  startThread();
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
