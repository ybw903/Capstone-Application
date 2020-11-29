import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/models/User.dart';
import 'package:test_app/util/decode.dart';
import 'package:test_app/util/appUrl.dart';
import 'package:test_app/util/userPrefernces.dart';

enum AuthMode {Singup, Login}
enum AuthState{AuthLoading, AuthLoaded, UnAthenticated, Authenticated, Uninitialized}
class AuthService with ChangeNotifier{

  User _user = new User();
  User get user => _user;
  AuthMode _authMode = AuthMode.Login;
  AuthState _authState = AuthState.Uninitialized;

  Future<Map<String,dynamic>> getUser(String username, String token) async{
    Response response = await get(
        AppUrl.serverURL+"/users/$username",
        headers: {'Content-Type': 'application/json',  'Authorization': token}
    );
    if(response.statusCode==200){
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData['user_info'];
    }
  }
  setUser() async{
    String token = await UserPrefernces().getToken();
    var payload = Decode().parseJwtPayload(token);
    _user.username = payload['user_name'];
    var user_info = await getUser(payload['user_name'], token);
    print(user_info);
    _user.car_plate = user_info['car_plate']==null?"":user_info['car_plate'];
    _user.email = user_info['email']==null?"":user_info['email'];
    _authState = AuthState.Authenticated;
    notifyListeners();
  }

  AuthMode get authmode => _authMode;
  set authmode(AuthMode mode){
    _authMode=mode;
    notifyListeners();
  }
  AuthMode switchAuth(){
    if(authmode == AuthMode.Login)
      authmode=AuthMode.Singup;
    else
      authmode=AuthMode.Login;
    return authmode;
  }

  Future<bool> signup(String username, String password) async{
    final Map<String,dynamic> userData = {
      'username': username,
      'password': password
    };

    Response response = await post(
      AppUrl.sign_up,
      body: json.encode(userData),
      headers: {'Content-Type': 'application/json'}
    );
    if(response.statusCode==201){
      return true;
    }
    else return false;
  }
  Future<Map<String,dynamic>> login(String username, String password) async{
    var result;
    final Map<String,dynamic> loginData = {
      'username': username,
      'password': password
    };

    Response response = await post(
      AppUrl.login,
      body: json.encode(loginData),
      headers: {'Content-Type': 'application/json'}
    );

    if(response.statusCode==200){
      final Map<String, dynamic> responseData = json.decode(response.body);
      var token = responseData['access_token'];
      await UserPrefernces().setToken(token);
      setUser();
      result ={
        'status': true,
        'message': 'Login Success'
      };
    }
    else{
      result={
        'status': false,
        'message': json.decode(response.body)['error']
      };
    }

    return result;
  }
  Future logout() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
    sharedPreferences.commit();
  }

}