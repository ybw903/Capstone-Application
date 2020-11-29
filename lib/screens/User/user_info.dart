import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/models/User.dart';
import 'package:test_app/Provider/auth.dart';
import 'package:test_app/util/appUrl.dart';
import 'package:test_app/util/userPrefernces.dart';
import 'package:http/http.dart' as http;
class UserPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UserPage();
  }
}

class _UserPage extends State<UserPage> {
  final formKey = new GlobalKey<FormState>();
  String  _car_plate, _email;

  _updateUser(String username) async{
    if(formKey.currentState.validate()) {
      formKey.currentState.save();
      var token = await UserPrefernces().getToken();
      final response = await http.post(
          AppUrl.updateUser,
          headers: {'Content-Type': "application/json", 'Authorization': token},
          body: json.encode({
            'username': username, 'car_plate': _car_plate,
            'email': _email
          })
      );

      if (response.statusCode == 200) {
        AuthService auth = Provider.of<AuthService>(context);
        auth.setUser();
        _showDialog("변경되었습니다.");
      }
      else{
        _showDialog("변경에 실패했습니다.");
      }
    }
    else{

    }
  }
  void _showDialog(String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                child: Text('닫기'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    User user = Provider.of<AuthService>(context).user;
    return Scaffold(
        appBar: AppBar(
          title: Text('계정관리'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(top: size.height * 0.1),
          child:
          Column(
            children: <Widget>[
              Image.asset('user_no_photo_300x300.png', width: size.height*0.3, height:size.height*0.3 ,),
              Stack(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(size.width*0.05),
                    child: Card(

                      shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 12.0,right: 12.0, top:12, bottom: 32
                        ),
                        child: Form(
                          key: formKey,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                initialValue: user.username,
                                readOnly: true,
                                decoration: new InputDecoration(
                                    icon: Icon(Icons.account_circle),
                                    labelText: 'UserName'),
                              ),
                              TextFormField(
                                initialValue: user.email,
                                decoration: new InputDecoration(
                                    icon: Icon(Icons.email), labelText: 'E-mail'),
                                validator: (val){
                                  Pattern pattern =
                                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                  RegExp regex = RegExp(pattern);
                                  if(user.email==val)return null;
                                  if(!regex.hasMatch(val)){
                                    return '유효하지 않은 E-mail입니다.';
                                  }
                                  return null;
                                },
                                onSaved: (val)=>_email=val,
                              ),
                              TextFormField(
                                initialValue: user.car_plate,
                                decoration: new InputDecoration(
                                    icon: Icon(Icons.directions_car), labelText: '차량번호'),
                                validator: (val){
                                  Pattern pattern =
                                      r'^(([0-9]{2}[가-힣]{1}[0-9]{4}|[0-9]{3}[가-힣]{1}[0-9]{4}|[가-힣]{2}[0-9]{2}[가-힣]{1}[0-9]{4}|)$)';
                                  //확인필요
                                  RegExp regex = RegExp(pattern);
                                  if(user.car_plate==val)return null;
                                  if(!regex.hasMatch(val)){
                                    return '유효하지 않은 차량번호입니다.';
                                  }
                                  return null;
                                },
                                onSaved: (val)=>_car_plate=val,
                              ),

                              Container(
                                height: 8,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: size.width*0.2,
                    right: size.width*0.2,
                    bottom: 0,
                    child: RaisedButton(
                      child: Text("변 경",style: TextStyle(
                        fontSize: 20.0,
                          color: Colors.white),),
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      onPressed: (){
                        _updateUser(user.username);
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
          ),
        );
  }
}
