import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/models/FavoritePark.dart';
import 'package:test_app/models/User.dart';
import 'package:test_app/Provider/auth.dart';
import 'package:test_app/util/appUrl.dart';
import 'package:test_app/util/userPrefernces.dart';

class BookInfoScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BookInfoScreen();
  }
}

class _BookInfoScreen extends State<BookInfoScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  getBookingInfo(String username) async {
    var token = await UserPrefernces().getToken();
    final response = await http.get(
      AppUrl.serverURL+"/booking/users/$username",
        headers: {'Content-Type': "application/json", 'Authorization': token});

    if (response.statusCode == 200) {
      final Booking_info = jsonDecode(response.body);
      print(Booking_info);
      return Booking_info;
    } else {
      print('failed');
    }
  }

  cancleBookingInfo(var book_info) async {
    var token = await UserPrefernces().getToken();
    final response = await http.post(
      AppUrl.serverURL+"/booking/cancle",
      headers: {'Content-Type': "application/json", 'Authorization': token},
      body: jsonEncode({
        'idreservation': book_info['id'],
        'idparking': book_info['parking_info']['parking_id']
      }),
    );
    if (response.statusCode == 200) {
      print('success');
    } else {
      print('failed');
    }
  }

  void onClick(var book_info, String Username) {
    cancleBookingInfo(book_info);
    setState(() {
      getBookingInfo(Username);
    });
  }

  Widget _contentHeader(){
    return   Row(
      children: <Widget>[
        Expanded(
          child: Text("주차장", style: TextStyle(fontWeight: FontWeight.bold),),
        ),
        Expanded(
          child: Text("차량번호",style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Text("예약날짜",style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Text("예약현황",style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<AuthService>(context).user;

    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text('예약 내역'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              children: <Widget>[
            _contentHeader(),
            Divider(),
            FutureBuilder(
              future: getBookingInfo(user.username),
              builder: (context, snapshot) {
                if (snapshot != null) {
                  return Expanded(
                    child: Container(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot?.data?.length ?? 0,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.only(bottom:8.0),
                            color: index%2==0? Colors.white10:Colors.white,
                            child: Row(

                              children: <Widget>[
                                Expanded(
                                  child: Text(snapshot.data[index]['parking_info']
                                      ['parking_name']),
                                ),
                                Expanded(child: Text(snapshot.data[index]['carplate'])),
                                Expanded(child: Text(snapshot.data[index]['date'])),
                                snapshot.data[index]['booking_state'] == 0
                                    ? Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 12.0),
                                        child: RaisedButton(

                                          color:Theme.of(context).primaryColor,
                                            onPressed: () {
                                              onClick(snapshot.data[index], user.username);
                                            },
                                            child: Text("취소",style: TextStyle(color: Colors.white),),
                                          ),
                                      ),
                                    )
                                    : Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 12.0),
                                        child: Text(snapshot.data[index]['booking_state'] == 3
                                            ? "취소"
                                            : "완료", textAlign: TextAlign.center,),
                                      ),
                                    )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            )
          ]),
        ));
  }
}
