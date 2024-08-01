import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:dart_sm/dart_sm.dart';
import 'package:flutter_application_test/MessageProvider.dart';
import 'package:flutter_application_test/NotificationUtility.dart';
import 'package:flutter_application_test/SignUp.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Global {
  static bool isInit = false;
  static bool isConnect = false;
  static String privateKey = "";
  static String currentContactId = "";
  static MessageProvider messageProvider = MessageProvider();
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
    privateKey = preferences.getString("privateKey")?? "";
    //messageProvider.open();
    isInit = true;
    return user;
  }
  static Future<void> save()async{
    if (contacts.isNotEmpty){
      await preferences.setString("contacts", jsonEncode(contacts));
    }
  }

  static types.TextMessage messageConstructor(types.TextMessage msg, String text, String friendId){
    String publicKey = contacts[friendId]["metadata"]["publicKey"];
    if (publicKey == null || publicKey == ""){
      return types.TextMessage(
        author: msg.author,
        id: randomString(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        text: text,
        roomId: friendId
      );
    }else{
      var user = types.User(id: msg.author.id, firstName: SM2.encrypt(msg.author.firstName.toString(), publicKey));
      return types.TextMessage(
        author: user,
        id: randomString(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        text: SM2.encrypt(text, publicKey),
        roomId: friendId,
        metadata: {"isEncrypted": true}
      );
    }
  }

  static Map<String, dynamic> wrapper(String cmd,{types.User user = const types.User(id: "000"),
    types.TextMessage message = const types.TextMessage(author: const types.User(id: "000"), id: "00", text: "text")}){
    if (cmd == "init_user"){
      return {"cmd": "init_user", "data": user.toJson()};
    }else if(cmd == "verify_user"){
      return {"cmd": "verify_user", "data": user.toJson()};
    }else if(cmd == "send_msg"){
      return {"cmd": "send_msg", "data": message.toJson()};
    }else{
      return {};
    }
  }
}
  //static late File file_user;

  //static Future<String> get _localPath async {
    //final directory = await getApplicationDocumentsDirectory();

    //return directory.path;
  //}


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
  List<Map<String, dynamic>> friends = [].obs.cast<Map<String, dynamic>>();
  List<types.TextMessage> messagebox = [].obs.cast<types.TextMessage>();
  List<types.TextMessage> messages = [].obs.cast<types.TextMessage>();
  List<types.TextMessage> messageshow = [].obs.cast<types.TextMessage>();

  late types.User user;

  int currentIndex = 0;

  List<types.Message> get msgs => messages;

  void addMsg(types.TextMessage msg, {bool order = true}){
    if (order){
      messages.insert(0, msg);
    }else{
      messages.add(msg);
    }
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

  void updateUser(String cmd, types.User newUser){
    user = newUser;
    Global.preferences.setString("user", jsonEncode(user.toJson()));
    Global.messageProvider.deleteAll();
    Global.preferences.remove("contacts");
    Global.contacts.clear();
    Global.sp.send("close");
    Global.sp.send(Global.wrapper(cmd, user: user));
  }

  types.User userProcessor(types.User user){
    if(user.metadata != null){
      var user_map = user.toJson();
      user_map.remove("metadata");
      return types.User.fromJson(user_map);
    }else{
      return user;
    }
  }

  void updateFriend(){
    friends = Global.contacts.values.toList(growable: true).cast<Map<String, dynamic>>();
  }

  Future initUser()async{
    if (!Global.isInit) {
      user = await Global.init();
      friends = Global.contacts.values.toList(growable: true).cast<Map<String, dynamic>>();
      var clientId = user.id;
      Global.rp.listen((data){
        if(data is SendPort){
          Global.sp = data;
          if (clientId != "null0"){
            print("id = $clientId");
            Global.sp.send(Global.wrapper("verify_user", user: user));
          }
          else {
            EasyLoading.showInfo("请注册");
            Get.to(SignUp());
          }
          print("receive sp");
        }else{
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
            addMsgBox(msg);
            var authorId = msg.author.id;//friend id
            if (Global.contacts[authorId] == null){
              Global.contacts[authorId] = msg.author.toJson();
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
      });
    }
    Global.isInit = true;
    //Global.sp.send(user.id);
  }
}