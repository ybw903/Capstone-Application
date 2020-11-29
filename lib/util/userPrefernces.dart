import 'package:shared_preferences/shared_preferences.dart';

class UserPrefernces{
  Future<bool> setToken(String token) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("token",token );
    return sharedPreferences.commit();
  }

  Future<String> getToken() async{
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString("token");
    return token;
  }
  Future<bool> setFCMToken(String FCMtoken) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("FCMtoken",FCMtoken );
    return sharedPreferences.commit();
  }
}