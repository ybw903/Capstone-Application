import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/Provider/auth.dart';
import '../Main_Screen.dart';

class LoginPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState(){
    return new _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage>{
  final formKey = new GlobalKey<FormState>();
  String _user_name;
  String _password;

  void _showDialog(String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: Text(message),
            actions: <Widget>[FlatButton(child: Text('닫기'),onPressed: (){Navigator.pop(context);},)],
          );
        }
    );
  }


  @override
  Widget build(BuildContext context) {
    AuthService auth = Provider.of<AuthService>(context);

    void login  (){
      if(formKey.currentState.validate()) {
        formKey.currentState.save();

        final Future<Map<String, dynamic>> result = auth.login(_user_name, _password);


        result.then((res){
          if(res['status']){
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context)=>MainScreen()),
                    (Route<dynamic> route)=>false);
          }
          else _showDialog("로그인에 실패하였습니다.");
        });
      }
    };

    void signup() {
      if(formKey.currentState.validate()) {
        formKey.currentState.save();

        final Future<bool> result = auth.signup(_user_name, _password);

        result.then((res){
          if(res){
            login();
          }
          else _showDialog("회원가입에 실패하였습니다.");
        });
        auth.switchAuth();
      }
    }

    final Size size = MediaQuery.of(context).size;
    // TODO: implement build
    return Scaffold(

      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: size.height*0.2),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            new Container(color: Colors.white,),
            new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Image.asset(
                  'assets/parking.jpg',
                  height: size.height*0.35,
                  width: size.width,
                ),
                Padding(
                    padding: EdgeInsets.all(size.width*0.05),
                    child:  new Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)
                        ),
                        elevation: 6,
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Form(
                              key: formKey,
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  new TextFormField(
                                    decoration: new InputDecoration(
                                        icon: Icon(Icons.account_circle),
                                        labelText: 'UserName'),
                                    validator: (val) {
                                      var validSpecial = RegExp(r'^[a-zA-Z0-9 ]+$');
                                      if(val.isEmpty){
                                        return 'Username is empty';
                                      }
                                      else if(!validSpecial.hasMatch(val)){
                                        return 'Blocked Spell Input';
                                      }
                                      return null;
                                    },
                                    onSaved: (val)=> _user_name=val,
                                  ),
                                  new TextFormField(
                                    obscureText: true,
                                    decoration: new InputDecoration(
                                        icon: Icon(Icons.vpn_key),
                                        labelText: 'Password'),
                                    validator: (val){
                                      if(val.isEmpty){
                                        return 'Password empty';
                                      }
                                      return null;
                                    },
                                    onSaved: (val)=>_password=val,
                                  ),
                                  Container(
                                    height: 8.0,
                                  ),
                                  RaisedButton(
                                    color: auth.authmode==AuthMode.Login?Colors.blue:Colors.red,
                                      child: new Text(
                                        auth.authmode==AuthMode.Login?
                                        'Login':'Sign-up',
                                        style: new TextStyle(fontSize: 20.0,color: Colors.white),

                                      ),
                                      onPressed : (){
                                      auth.authmode==AuthMode.Login? login():signup();
                                      }
                                  ),
                                  GestureDetector(
                                    onTap: (){
                                      auth.switchAuth();
                                    },
                                    child:
                                    Text(auth.authmode==AuthMode.Login?"회원가입하러가기":"로그인하러가기",textAlign: TextAlign.center,style: TextStyle(color: Colors.blueGrey,decoration: TextDecoration.underline),)
                                  ),
                                ],
                              )
                          ),
                        )
                    )
                ),
                new Container(height: size.height*0.1,)
              ],
            )

          ],
        ),
      )
    );
  }
}

