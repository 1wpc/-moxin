import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_test/home.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import 'data.dart';

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000);
}

void loadShow()async{
  await EasyLoading.show(status: "正在初始化",);
}

class Loading extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return LoadingState();
  }
  
}

class LoadingState extends State<StatefulWidget>{
  @override
  Widget build(BuildContext context) {
    loadShow();
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Get.to(MyHomePage());
        },
        child: Text("enter"),
      ),
    );
  }

  @override
  void initState() {
    final Controller c = Get.put(Controller());
    c.initUser();
    configLoading();
    EasyLoading.addStatusCallback((status){
      if (status == EasyLoadingStatus.dismiss){
        Get.off(MyHomePage());
      }
    });
    super.initState();
  }
  
}