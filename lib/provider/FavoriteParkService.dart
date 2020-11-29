import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:test_app/models/FavoritePark.dart';
import 'package:test_app/util/appUrl.dart';
import 'package:test_app/util/userPrefernces.dart';
import 'package:http/http.dart' as http;
class FavoriteParkService extends ChangeNotifier{
  List<FavoritePark> _list;
  Set<String> _favroiteParkSet = Set<String>();

  List<FavoritePark> get list =>_list;
  Set<String> get favoriteParkSet => _favroiteParkSet;

  addFP(var data){
    print(data);
    if(data['id'] is int)data['id']= data['id'].toString();
    _list.add(FavoritePark.fromJson(data));
    _favroiteParkSet.add(data['name']);
    notifyListeners();
  }
  delFP(var data){
    int idx=-1;
    for(int i=0; i<_list.length; i++){
      if(_list[i].name==data['name'])idx=i;
    }
    if(idx!=-1)
    _list.removeAt(idx);
    _favroiteParkSet.remove(data['name']);
    notifyListeners();
  }

  Future getFavoritePark(String username) async{
    var token = await UserPrefernces().getToken();
    final response = await http.get(
        AppUrl.serverURL+"/userfavorite/$username",

        headers: {'Content-Type': "application/json", 'Authorization': token});


    if (response.statusCode == 200) {
      final results = jsonDecode(response.body)['results'];
      final results2 = jsonDecode(response.body)['results2'];
      //print(results2[0]);
      //FavoritePark fp = FavoritePark.fromJson(results2[0]);
      //print(fp);


      List<FavoritePark> list =  List<FavoritePark>.from(
          results.map((result){
            _favroiteParkSet.add(result['name']);
        return FavoritePark.fromJson(result);

      }
      ));
      //List<FavoritePark> list2 = List<FavoritePark>.from(results2.map((result)=>FavoritePark.fromJson(result)));
      list.addAll(List<FavoritePark>.from(
          results2.map((result){
            _favroiteParkSet.add(result['name']);
            return FavoritePark.fromJson(result);

          }
          )));

      _list = list;
      //print(list[0].avail);
      //print() ;


    } else {
      print('failed');
    }
  }

//  FavoriteParkService(String username){
//    loadList(username);
//  }
//
//  Future loadList(String username) async {
//    var token = await UserPrefernces().getToken();
//    final response = await http.get(
//        AppUrl.serverURL+"/userfavorite/$username",
//        headers: {'Content-Type': "application/json", 'Authorization': token});
//
//    if (response.statusCode == 200) {
//      final results = jsonDecode(response.body)['results'];
//      _list = List<FavoritePark>.from(
//          results.map((result) => FavoritePark.fromJson(result)));
//    }
//  }
}