import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/models/User.dart';
import 'package:test_app/Provider/auth.dart';
import 'package:test_app/util/appUrl.dart';
import 'package:test_app/util/userPrefernces.dart';

class ListItem {
  int value;
  String name;

  ListItem(this.value, this.name);
}

class BookScreen extends StatefulWidget {
  final data;
  BookScreen({Key key, this.data}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _BookScreen();
  }
}

class _BookScreen extends State<BookScreen> {
  final currentDateTime = DateTime.now().toLocal();
  final f = DateFormat('yyyy-MM-dd');


  requestBooking(String username, String car_plate) async {
    if (car_plate == "") {
      _showDialog("차량번호 등록 후 이용해주세요.");
      return;
    }

    String date = f.format(currentDateTime);
    var token = await UserPrefernces().getToken();
    final response = await http.post(
      //AppUrl.localBaseURL+"/booking",
      AppUrl.booking,
      headers: {'Content-Type': "application/json", 'Authorization': token},
      body: jsonEncode({
        'username': username,
        'car_plate': car_plate,
        'parking_id': widget.data['id'],
        'parking_name': widget.data['name'],
        'startDate': date+" "+_selectedStartTime.value.toString()+":"+"00",
        'endDate': date+" "+_selectedEndTime.value.toString()+":"+"00",
        'cost': (_selectedEndTime.value-_selectedStartTime.value)*int.parse(widget.data['default_bill'].split(" ")[2])
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      _showDialog("예약에 성공하였습니다.");
    } else {
      _showDialog("예약내역이 존재합니다.");
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
  List<ListItem> _startTime = [];
  List<ListItem> _endTime = [];
  List<DropdownMenuItem<ListItem>> _startTimeMenus;
  List<DropdownMenuItem<ListItem>> _endTimeMenus;
  ListItem _selectedStartTime;
  ListItem _selectedEndTime;

  List<DropdownMenuItem<ListItem>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<ListItem>> items = List();
    for (ListItem listItem in listItems) {
      items.add(
        DropdownMenuItem(

          child: Text(listItem.name, style: TextStyle(fontSize: 20),),
          value: listItem,
        ),
      );
    }
    return items;
  }

  void initState() {
    super.initState();

    int h=currentDateTime.hour;
    DateTime date = DateTime.now().toLocal();
    print(date.hour);
    bool week = (date.weekday<6?false:true);//false : 주중, true: 주말
    int et;
    if(week)et=int.parse(widget.data['week_day_end'].split(':')[0]);
    else et = int.parse( widget.data['week_end_end'].split(':')[0]);

    while(true) {
      _startTime.add(ListItem(h, h.toString()+"시"));
      _endTime.add(ListItem(h, h.toString()+"시"));
      h+=1;
      if(h>et)
      break;
    }

    _startTimeMenus = buildDropDownMenuItems(_startTime);
    _endTimeMenus = buildDropDownMenuItems(_endTime);
    _selectedStartTime = _startTimeMenus[0].value;
    _selectedEndTime = _endTimeMenus[1].value;

  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<AuthService>(context).user;
    return Scaffold(
      appBar: AppBar(title: Text("주차장")),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Text(
                        "예약내역",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "이용시간",
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            DropdownButton<ListItem>(
                                style: TextStyle(color: Colors.black,fontSize: 16),
                                value: _selectedStartTime,
                                items: _startTimeMenus,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedStartTime = value;
                                  });
                                }),
                            Text("~", style: TextStyle(fontSize: 20),),
                            DropdownButton<ListItem>(
                                style: TextStyle(color: Colors.black,fontSize: 16),
                                value: _selectedEndTime,
                                items: _endTimeMenus,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedEndTime = value;
                                  });
                                })

                          ],
                        ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "차량번호",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          Text(
                            user.car_plate,
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          )
                        ],
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            RaisedButton(
              onPressed: () {
                if(_selectedEndTime.value>_selectedStartTime.value&&_selectedStartTime!=_selectedEndTime)
                requestBooking(user.username, user.car_plate);
                else _showDialog("올바른 시간을 입력해 주세요");
              },
              color: Colors.blue,
              child: Text(
                "예약요쳥",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          ],
        ),
      ),
    );
  }
}
