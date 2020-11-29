import 'package:flutter/material.dart';

class NotifyPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState(){
    return _NotifyPage();
  }
}

class _NotifyPage extends State<NotifyPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('안내'),),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          ListTile(
            title: Text('공지사항'),
          )
        ],
      )
    );
  }
}