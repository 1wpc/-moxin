import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:flutter_application_test/NotificationUtility.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Global {
  static bool isInit = false;
  static bool isConnect = false;
  static Map<String, dynamic> contacts = {};
  static late NotificationUtility notif;
  static late SendPort sp;
  static late ReceivePort rp;
  static late SharedPreferences preferences;
  static Future<types.User> init() async{
    preferences = await SharedPreferences.getInstance();
    var user = preferences.getString("user") == null ?
    types.User(id: "null0", firstName: "null0",) :
    types.User.fromJson(jsonDecode(preferences.getString("user")!));
    var contact_data = preferences.getString("contacts")?? "";
    if (contact_data != ""){
      contacts = jsonDecode(contact_data);
    }
    isInit = true;
    return user;
  }
  static Future<void> save()async{
    if (contacts.isNotEmpty){
      await preferences.setString("contacts", jsonEncode(contacts));
    }
  }
  //static late File file_user;

  //static Future<String> get _localPath async {
    //final directory = await getApplicationDocumentsDirectory();

    //return directory.path;
  //}
}

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

int randomInt(max){
  return Random().nextInt(max);
}

class Controller extends GetxController{

  Controller(){
    //Global.initFile();
    //Global.init();
    //var content = Global.file_user.readAsStringSync();
    //user = content != null ? types.User.fromJson(jsonDecode(content)) : types.User(id: "null", firstName: "null",);
    //user = types.User(id: "null", firstName: "null",);
  }
  List<types.TextMessage> messagebox = [].obs.cast<types.TextMessage>();
  List<types.TextMessage> messages = [].obs.cast<types.TextMessage>();
  List<types.TextMessage> messageshow = [].obs.cast<types.TextMessage>();

  late types.User user;

  int currentIndex = 0;

  List<types.Message> get msgs => messages;

  void addMsg(types.TextMessage msg){
    messages.insert(0, msg);
    update();
  }

  void addMsgShow(types.TextMessage msg){
    messageshow.insert(0, msg);
    update();
  }

  void addMsgBox(types.TextMessage msg){
    messagebox.insert(0, msg);
    update();
  }

  void changePage(int index){
    if (index != currentIndex){
      currentIndex = index;
      update();
    }
  }

  void reloadMsgs(String friendId){
    messages.clear();
    for (var i=messagebox.length-1; i>=0; i--) {
      var msg =messagebox[i];
      if (msg.author.id == friendId||msg.roomId == friendId){
        addMsg(msg);
      }
    }
  }

  void updateUser(types.User newUser){
    user = newUser;
    Global.preferences.setString("user", jsonEncode(user.toJson()));
    Global.sp.send("close");
    Global.sp.send(user.id);
  }

  void initUser()async{
    if (!Global.isInit) {
      user = await Global.init();
      var clientId = user.id;
      Global.rp.listen((data){
        if(data is SendPort){
          Global.sp = data;
          if (clientId != "null0"){
            print("id = $clientId");
            Global.sp.send(clientId);
          }
          else {//待实现逻辑
            //c.changePage(2);
            EasyLoading.showInfo("请注册");
          }
          print("receive sp");
        }else{
          var msg = types.TextMessage.fromJson(json.decode(data));
          Global.notif.showNotification(title: msg.author.firstName.toString(), body: msg.text);
          addMsgBox(msg);
          var authorId = msg.author.id;//friend id
          if (Global.contacts[authorId] == null){
            Global.contacts[authorId] = msg.author;
          }
          for (var i in messageshow){
            if (i.author.id == authorId||i.roomId == authorId){
              messageshow.remove(i);
              break;
            }
          }
          addMsgShow(msg);
          if (messages.isNotEmpty){
            if (messages[0].author.id == authorId||messages[0].roomId == authorId){
              addMsg(msg);
            }
          }
        }
      });
    }
    Global.isInit = true;
    EasyLoading.dismiss();
    Global.sp.send(user.id);
  }
}