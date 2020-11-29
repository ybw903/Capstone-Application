import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/models/User.dart';
import 'package:test_app/screens/BookInfo/book_info_screen.dart';
import 'package:test_app/screens/Home/Home.dart';
import 'package:test_app/screens/User/Login_Page.dart';
import 'package:test_app/screens/notify/notify.dart';
import 'package:test_app/screens/User/user_info.dart';
import 'package:test_app/Provider/FavoriteParkService.dart';
import 'package:test_app/Provider/auth.dart';
import 'package:test_app/Provider/auth.dart';
import 'package:test_app/util/appUrl.dart';
import 'package:test_app/util/userPrefernces.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'Home/Home.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

class MainScreen extends StatefulWidget{
  MainScreen({Key key}):super(key:key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>{

  @override
  void initState(){
    super.initState();
    checkLoginStatus();
    firebaseCloudMessaging_Listeners();
  }

  tokenUpload() async{
    String token= await _firebaseMessaging.getToken();
    final Map<String,dynamic> tokenInfo = {
      'user_name': Provider.of<AuthService>(context).user.username,
      'token': token
    };
    print(tokenInfo['token']);
    Response response = await post(
        AppUrl.serverURL+"/users/token",
        body: json.encode(tokenInfo),
        headers: {'Content-Type': 'application/json'}
    );
    if(response.statusCode==200||response.statusCode==201){
      print("success");
      }
    else{
      print("failed");
    }
  }

  checkLoginStatus() async{
    String token = await UserPrefernces().getToken();
    if(token==null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()), (
          Route<dynamic> route) => false);
    }
    else{
      AuthService auth = Provider.of<AuthService>(context);
      auth.setUser();
      await Provider.of<FavoriteParkService>(context).getFavoritePark(Provider.of<AuthService>(context).user.username);
    }
  }

  void firebaseCloudMessaging_Listeners() async{


    _firebaseMessaging.getToken().then((token){
      print('token:'+token);
    });

    await tokenUpload();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  //User Provider 추가
  @override
  Widget build(BuildContext context){
    User user = Provider.of<AuthService>(context).user;
    AuthService auth = Provider.of<AuthService>(context);
    return Scaffold(
          appBar: AppBar(
            //title: Text('title'),
            backgroundColor: Colors.blue,
            elevation: 6.0,
          ),
          drawer: Drawer(
            child: ListView(
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text(user.username),
                  accountEmail: Text(user.email==""?"email":user.email),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      "user",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ),
                ListTile(
                    title: Text('예약내역'),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>BookInfoScreen()));
                    }
                ),
                ListTile(
                    title: Text('계정관리'),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>UserPage()));
                    }
                ),
                Divider(
                  color: Colors.blue,
                ),
                ListTile(
                    title: Text('공지사항'),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=> NotifyPage()));
                    }
                ),
                ListTile(
                    title: Text('환경설정'),
                    onTap: (){}
                ),
                ListTile(
                  title: Text('LogOut'),
                  onTap: (){
                    auth.logout();
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context)=>LoginPage()), (Route<dynamic> route)=>false);
                  },
                )
              ],
            ),
          ),
          body: MultiProvider(
            providers: [

            ],
            child: Center(
              child: MyHomePage(),

            ),
          ),
        );
      }
}