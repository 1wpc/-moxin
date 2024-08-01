import 'package:dart_sm/dart_sm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'data.dart';

class SignUp extends StatefulWidget{
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final Controller c = Get.put(Controller());
  final GlobalKey _formKey = GlobalKey<FormState>();
  late String _moxinId, _password = "", _name;
  bool _isObscure = true;
  Color _eyeColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey, // 设置globalKey，用于后面获取FormStat
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: kToolbarHeight), // 距离顶部一个工具栏的高度
            buildTitle(), // Login
            buildTitleLine(), // Login下面的下划线
            const SizedBox(height: 60),
            buildIdTextField(),
            const SizedBox(height: 30),
            buildNameTextField(),
            const SizedBox(height: 30),
            buildPasswordTextField(context), // 输入密码
            const SizedBox(height: 30),
            buildEnsurePasswordTextField(context),//确认密码
            const SizedBox(height: 60),
            buildSignupButton(context), // 登录按钮
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget buildSignupButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 45,
        width: 270,
        child: ElevatedButton(
          style: ButtonStyle(
            // 设置圆角
              shape: MaterialStateProperty.all(const StadiumBorder(
                  side: BorderSide(style: BorderStyle.none)))),
          child: Text('Signup',
              style: Theme.of(context).primaryTextTheme.headlineLarge),
          onPressed: () async{
            // 表单校验通过才会继续执行
            if ((_formKey.currentState as FormState).validate()) {
              (_formKey.currentState as FormState).save();
              bool? delete = await showSignupConfirmDialog1();
              if (delete == null) {
                print("取消");
              } else {
                print("已确定");
                KeyPair kp = SM2.generateKeyPair();
                Global.privateKey = kp.privateKey;
                Global.preferences.setString("privateKey", kp.privateKey);
                c.updateUser("init_user",types.User(id:_moxinId, firstName:_name, metadata: {"password": _password, "publicKey": kp.publicKey}));
              }
            }
          },
        ),
      ),
    );
  }

  Future<bool?> showSignupConfirmDialog1() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("提示"),
          content: Text("注册将会自动生成密钥"),
          actions: <Widget>[
            TextButton(
              child: Text("取消"),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            TextButton(
              child: Text("确定"),
              onPressed: () {
                //关闭对话框并返回true
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildPasswordTextField(BuildContext context) {
    return TextFormField(
        obscureText: _isObscure, // 是否显示文字
        onSaved: (v) => _password = v!,
        onChanged: (v) => _password = v,
        validator: (v) {
          if (v!.isEmpty) {
            return '请输入密码';
          }
        },
        decoration: InputDecoration(
            labelText: "Password",
            suffixIcon: IconButton(
              icon: Icon(
                Icons.remove_red_eye,
                color: _eyeColor,
              ),
              onPressed: () {
                // 修改 state 内部变量, 且需要界面内容更新, 需要使用 setState()
                setState(() {
                  _isObscure = !_isObscure;
                  _eyeColor = (_isObscure
                      ? Colors.grey
                      : Theme.of(context).iconTheme.color)!;
                });
              },
            )));
  }

  Widget buildEnsurePasswordTextField(BuildContext context) {
    return TextFormField(
        obscureText: _isObscure, // 是否显示文字
        validator: (v) {
          if (v! != _password) {
            print(v+"//"+_password);
            return '两次密码不一致';
          }
        },
        decoration: InputDecoration(
            labelText: "Password",
            suffixIcon: IconButton(
              icon: Icon(
                Icons.remove_red_eye,
                color: _eyeColor,
              ),
              onPressed: () {
                // 修改 state 内部变量, 且需要界面内容更新, 需要使用 setState()
                setState(() {
                  _isObscure = !_isObscure;
                  _eyeColor = (_isObscure
                      ? Colors.grey
                      : Theme.of(context).iconTheme.color)!;
                });
              },
            )));
  }

  Widget buildIdTextField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: '墨信号'),
      validator: (v) {
        if (v!.isEmpty){
          return '请输入墨信号';
        }
      },
      onSaved: (v) => _moxinId = v!,
    );
  }

  Widget buildNameTextField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: '昵称'),
      validator: (v) {
        if (v!.isEmpty){
          return '请输入昵称';
        }
      },
      onSaved: (v) => _name = v!,
    );
  }

  Widget buildTitleLine() {
    return Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 4.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            color: Colors.black,
            width: 40,
            height: 2,
          ),
        ));
  }

  Widget buildTitle() {
    return const Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          'Signup',
          style: TextStyle(fontSize: 42),
        ));
  }
}