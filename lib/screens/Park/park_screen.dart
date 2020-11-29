import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/models/User.dart';
import 'package:test_app/screens/Book/book_screen.dart';
import 'package:test_app/Provider/FavoriteParkService.dart';
import 'package:test_app/Provider/auth.dart';
import 'package:test_app/util/appUrl.dart';
import 'package:test_app/util/call.dart';
import 'package:test_app/util/userPrefernces.dart';
import 'package:http/http.dart' as http;
class ParkScreen extends StatefulWidget {
  final data;
  bool favCheck;
  ParkScreen({Key key, this.data, this.favCheck}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return _ParkScreen();
  }
}

class _ParkScreen extends State<ParkScreen> {

  addFavorite(String idpark) async{
    var token = await UserPrefernces().getToken();
    User user = Provider.of<AuthService>(context).user;

    print(idpark);
    final response = await http.post(
      AppUrl.serverURL+"/userfavorite",
      headers: {'Content-Type': "application/json", 'Authorization': token},
      body: jsonEncode({
        'username': user.username,
        'idpark' : idpark
      }),
    );

    if (response.statusCode == 200) {
      _showDialog('추가성공');
      Provider.of<FavoriteParkService>(context).addFP(widget.data);
      setState(() {
        widget.favCheck=true;
      });
    } else {
      print('failed');
    }
  }

  delFavorite(String idpark) async{
    var token = await UserPrefernces().getToken();
    String username = Provider.of<AuthService>(context).user.username;

    print(idpark);
    final response = await http.delete(
      AppUrl.serverURL+"/userfavorite/$username/$idpark",
      headers: {'Content-Type': "application/json", 'Authorization': token},
    );

    if (response.statusCode == 200) {
      _showDialog('삭제성공');
      Provider.of<FavoriteParkService>(context).delFP(widget.data);
      setState(() {
        widget.favCheck=false;
      });
    } else {
      print('failed');
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
    Color color = Theme.of(context).primaryColor;

    DateTime date =DateTime.now().toLocal();
    TimeOfDay time = TimeOfDay.now();
    int st = int.parse(date.weekday<6?widget.data['week_day_start'].split(':')[0]:widget.data['week_end_start'].split(':')[0]);
    int et = int.parse(date.weekday<6?widget.data['week_day_end'].split(':')[0]:widget.data['week_end_end'].split(':')[0]);

    bool sp = false;
    if(widget.data['id'] is int)sp=true;
    if(!(st<=time.hour&&time.hour<=et))sp=false;
    return Scaffold(
      appBar:AppBar(),
      body: ListView(
        children: <Widget>[
          Container(
            child: Image.asset('assets/park_image.jpg', width: MediaQuery.of(context).size.width, fit:BoxFit.fitWidth),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(widget.data['name'], style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),)),
                          Text( "총 "+widget.data['avail'].toString()+"면")
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                        onTap: sp?(){
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>BookScreen(data: widget.data,)));
                        }:(){},
                        child: sp?_buildButtonColumn(color, Icons.book, 'BOOKING'):
                        _buildButtonColumn(Colors.grey, Icons.book, 'BOOKING')
                    ),
                    GestureDetector(
                      onTap: (){
                        CallHelper().launchURL(widget.data['tel']);
                      },

                      child: _buildButtonColumn(color, Icons.call, 'CALL'),
                    ),
                    Provider.of<FavoriteParkService>(context).favoriteParkSet.contains(widget.data['name'])
                    ?
                    GestureDetector(
                      onTap: (){
                        delFavorite(widget.data['id'] is int ? widget.data['id'].toString():widget.data['id']);
                      },
                        child: _buildButtonColumn(color, Icons.star, 'Favorite')
                    ):
                    GestureDetector(
                        onTap: (){
                          addFavorite(widget.data['id'] is int ? widget.data['id'].toString():widget.data['id']);
                        },
                        child: _buildButtonColumn(color, Icons.star_border, 'Favorite')
                    )
                    //_buildButtonColumn(color, Icons.share, 'SHARE'),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)
              ),
              elevation: 6,
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: <Widget>[
                    Text('운영요금'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("기본 요금"),
                        Text(widget.data['default_bill'])
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("추가 요금"),
                        Text(widget.data['add_bill'])
                      ],
                    ),
                    Divider(),
                    Text('운영시간'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("평일 운영 시간"),
                        Text(widget.data['week_day_start']+"~"+widget.data['week_day_end'])
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("주말 운영 시간"),
                        Text(widget.data['week_end_start']+"~"+widget.data['week_end_end'])
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),


        ],
      ),
    );
  }

  Column _buildButtonColumn(Color color, IconData icon, String label) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w400, color: color),
            ),
          )
        ]);
  }
}
