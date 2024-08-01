import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'data.dart';

class Contacts extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ContactsState();
  }
}

class ContactsState extends State<Contacts>{
  final Controller c = Get.put(Controller());
  final List<String> alphabet = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I',
    'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R',
    'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    c.updateFriend();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: c.friends.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(c.friends[index]["firstName"].toString()),
                subtitle: Text(c.friends[index]["id"]),
                leading: CircleAvatar(
                  child: Text(c.friends[index]["firstName"].toString()[0]), // 使用姓名的首字母
                ),
                onTap: () {
                  // 处理点击事件，例如导航到联系人详情页面
                  print('点击了: ${c.friends[index]["firstName"]}');
                },
                onLongPress: (){},
              );
            },
          ),
        ),
        Container(
          width: 30,
          child: ListView.builder(
            itemCount: alphabet.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // 当点击字母时，跳转到对应的首个联系人
                  final String letter = alphabet[index];
                  final int position = c.friends.indexWhere((contact) => contact["firstName"].toString().startsWith(letter));
                  if (position != -1) {
                    _scrollController.jumpTo(position.toDouble());
                    //Scrollable.ensureVisible(context, alignment: 0.5, duration: Duration(milliseconds: 500), curve: Curves.easeInOut, alignmentPolicy: ScrollPositionAlignmentPolicy.explicit, key: Key('$position'));
                  }
                },
                child: Center(
                  child: Text(
                    alphabet[index],
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}