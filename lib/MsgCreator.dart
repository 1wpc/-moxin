import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MsgCreator extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return MsgCreatorState();
  }
}

class MsgCreatorState extends State<StatefulWidget>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("添加会话"),
      ),
    );
  }
}