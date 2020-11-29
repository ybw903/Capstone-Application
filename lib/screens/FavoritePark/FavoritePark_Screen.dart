import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/models/FavoritePark.dart';
import 'package:test_app/Provider/FavoriteParkService.dart';
import 'package:test_app/Provider/auth.dart';
import 'package:test_app/util/appUrl.dart';
import 'package:test_app/util/userPrefernces.dart';
import 'package:http/http.dart' as http;
class FavorieParkScreen extends StatefulWidget {
  @override
  _FavorieParkScreenState createState() => _FavorieParkScreenState();
}

class _FavorieParkScreenState extends State<FavorieParkScreen> {

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<FavoritePark> list = Provider.of<FavoriteParkService>(context).list;
    return Scaffold(
      appBar: AppBar(title: Text('즐겨찾기'),),
     body:  ListView.builder(
            itemCount: list?.length??0,
    //itemCount: snapshot?.data?.length ?? 0,
            itemBuilder: (context, index){
              return Padding(
                padding: EdgeInsets.all(8.0),

                  child: GestureDetector(
                    onTap: (){
                      //Navigator.pop(context,[snapshot.data[index].lat, snapshot.data[index].lng]);
                      Navigator.pop(context,[list[index].lat, list[index].lng]);
                    },
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                  children: <Widget>[
                                    Text(list[index].name, style: TextStyle(fontSize: 20.0),)
                                  ]
                              ),
                              Text(list[index].address??""),
                            ],
                          ),
                        ),
                      )
                    //child: Text(snapshot.data[index])
                ),
              );
            }
        )
    );
  }
}


