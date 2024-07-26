import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_test/MsgCreator.dart';
import 'package:flutter_application_test/data.dart';
import 'package:flutter_application_test/explore.dart';
import 'package:flutter_application_test/user.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
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

  Future<ServiceRequestResult> _startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
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
    //Global.init();
    //init();
    super.initState();
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Request permissions and initialize the service.
      _requestPermissions();
      _initService();
      _startService();
    });
  }

  void _onReceiveTaskData(dynamic data) {
    if (data is int) {
      print('count: $data');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
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
      Global.sp.send(c.user.id);

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