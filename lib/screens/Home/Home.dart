import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:test_app/models/FavoritePark.dart';
import 'package:test_app/screens/Book/book_screen.dart';
import 'package:test_app/screens/FavoritePark/FavoritePark_Screen.dart';
import 'package:test_app/Provider/FavoriteParkService.dart';
import 'package:test_app/util/constraints.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/screens/User/Login_Page.dart';
import 'package:test_app/screens/Park/park_screen.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set();
  double lat = 36.6290404, lng = 127.4541504;
  double cmp_dist = 2;
  bool needupdate = false;

  static final chungbukUniv = CameraPosition(
    target: LatLng(36.6290404, 127.4541504),
    zoom: 14.0,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<BitmapDescriptor> createCustomMarkerBitmap(String title) async {
    TextSpan span = new TextSpan(
      style: new TextStyle(
        color: Colors.white,
        fontSize: 35.0,
        fontWeight: FontWeight.bold,
      ),
      text: title,
    );

    TextPainter tp = new TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.text = TextSpan(
      text: title,
      style: TextStyle(
        fontSize: 200.0,
        color: Theme.of(context).accentColor,
        letterSpacing: 1.0,
        fontFamily: 'Roboto Bold',
      ),
    );

    PictureRecorder recorder = new PictureRecorder();
    Canvas c = new Canvas(recorder);

    tp.layout();
    tp.paint(c, new Offset(20.0, 10.0));

    /* Do your painting of the custom icon here, including drawing text, shapes, etc. */

    Picture p = recorder.endRecording();
    ByteData pngBytes =
        await (await p.toImage(tp.width.toInt() + 40, tp.height.toInt() + 20))
            .toByteData(format: ImageByteFormat.png);

    Uint8List data = Uint8List.view(pngBytes.buffer);

    return BitmapDescriptor.fromBytes(data);
  }

  void _searchPlaces(double latitude, double longitude, double dist) async {
    setState(() {
      _markers.clear();
    });
    //final String url = "http://10.0.2.2:5000/parks/$latitude/$longitude/$dist";
    final String url = "https://qiuutucpaj.execute-api.ap-northeast-2.amazonaws.com/dev/parks/$latitude/$longitude/$dist";

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        final foundPlaces2 = data['results2'];
        final foundPlaces = data['results'];
        BitmapDescriptor bitmapDescriptor =
            await createCustomMarkerBitmap(data['len'].toString());
        setState(() {
          //예약가능 주차장
          if (data['large']) {
            _markers.add(Marker(
                markerId: MarkerId(0.toString()),
                position: LatLng(latitude, longitude),
                icon: bitmapDescriptor));
          } else {
            for (int i = 0; i < foundPlaces2.length; i++) {
              _markers.add(Marker(
                  markerId: MarkerId(foundPlaces2[i]['id'].toString()),
                  position:
                      LatLng(foundPlaces2[i]['lat'], foundPlaces2[i]['lng']),
                  infoWindow: InfoWindow(
                    title: foundPlaces2[i]['name'],
                    snippet: "안녕",
                  ),
                  onTap: () {
                    //큰 괄호 뺴면 안됨????
                    bottomSheetMake(foundPlaces2[i]);
                  }));
            }
            //기타 주차장

            for (int i = 0; i < foundPlaces.length; i++) {
              print('here');
              _markers.add(Marker(
                  markerId: MarkerId(foundPlaces[i]['id']),
                  position: LatLng(
                    foundPlaces[i]['lat'],
                    foundPlaces[i]['lng'],
                  ),
                  onTap: () {
                    //큰 괄호 뺴면 안됨????
                    bottomSheetMake(foundPlaces[i]);
                  },
                  infoWindow: InfoWindow(
                      title: foundPlaces[i]['name'],
                      snippet: foundPlaces[i]['address'])));
            }
          }
        });
      }
    } else {
      print('Fail');
    }
  }

  _onMapCreated(GoogleMapController controller) {
    _searchPlaces(36.6290404, 127.4541504, 14.0);
    _controller.complete(controller);
  }

  moveCamera(double lat, double lng) async{
    if(lat==null&& lng==null)return;
    final c = await _controller.future;
    final p = CameraPosition(target: LatLng(lat,lng), zoom: 14.0);
    c.animateCamera(CameraUpdate.newCameraPosition(p));
  }

  bottomSheetMake(var data) {
    DateTime date = DateTime.now().toLocal();
    TimeOfDay time = TimeOfDay.now();
    int st = int.parse(date.weekday < 6
        ? data['week_day_start'].split(':')[0]
        : data['week_end_start'].split(':')[0]);
    int et = int.parse(date.weekday < 6
        ? data['week_day_end'].split(':')[0]
        : data['week_end_end'].split(':')[0]);

    final Size size = MediaQuery.of(context).size;

    bool sp = false;
    if (data['id'] is int) sp = true;
    if (!(st <= time.hour && time.hour <= et)) sp = false;

    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 16.0, bottom: 8.0, left: 18.0, right: 18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        data['name'],
                        style: TextStyle(fontSize: 20.0),
                      ),
                      sp
                          ? IconButton(
                              icon: Icon(
                                Icons.book,
                                color: Colors.blue,
                                size: size.width * 0.07,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            BookScreen(
                                              data: data,
                                            )));
                              })
                          : Text('')
                    ],
                  ),
                ),
                Divider(
                  thickness: 2.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          "주차요금",
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                      Text(
                        data['default_bill'],
                        style: TextStyle(fontSize: 20.0),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          "운영시간",
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                      Text(
                        date.weekday < 6
                            ? data['week_day_start'] +
                                "~" +
                                data['week_day_end']
                            : data['week_end_start'] +
                                "~" +
                                data['week_end_end'],
                        style: TextStyle(fontSize: 20.0),
                      )
                    ],
                  ),
                ),
                Divider(
                  thickness: 2.0,
                ),
                Column(
                  children: <Widget>[
                    //Image.asset('assets/parking.jpg',width: 100, height: 50,),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top:12.0, bottom: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          RaisedButton(
                              color: Colors.blue,
                              child: new Text('상세보기'),
                              textColor: Colors.white,
                              onPressed: () {
                                //print(_favroiteParkMap[data['name']])
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            ParkScreen(
                                              data: data,
                                              favCheck: Provider.of<FavoriteParkService>(context).favoriteParkSet.contains(data['name']),
                                            )));
                                //booking(data['id'].toString());
                              }),
                          RaisedButton(
                            color: Colors.blue,
                            child: new Text('뒤로가기'),
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        });
  }

  void _onCamerMove(CameraPosition position) {
    double dLat = (lat.abs() - position.target.latitude.abs()) * 92;
    double dLng = (lng.abs() - position.target.longitude.abs()) * 114;
    double root = pow(dLat, 2) + pow(dLng, 2);
    double dist = sqrt(root);
    print(position.zoom);
    cmp_dist = 2;
    if (position.zoom < 14) cmp_dist *= 2;
    if (position.zoom < 13) cmp_dist *= 2;
    if (position.zoom < 12) cmp_dist *= 2;
    if (position.zoom < 11) cmp_dist *= 2;
    if (position.zoom < 10) cmp_dist *= 2;
    print("dd: " + cmp_dist.toString());

    if (needupdate) {
      lat = position.target.latitude;
      lng = position.target.longitude;
    }
    if (dist > cmp_dist) {
      needupdate = true;
      lat = position.target.latitude;
      lng = position.target.longitude;
    }
  }

  void _onCamerIdle() async {
    if (needupdate) {
      await _searchPlaces(lat, lng, cmp_dist);
      needupdate = false;
    }
  }


  @override
  Widget build(BuildContext context) {

    final currentPosition = Provider.of<Position>(context);
    return Scaffold(
        body:
            Stack(
              children: <Widget>[
                Center(
                  child: GoogleMap(
                    mapType: MapType.normal,
                    //initialCameraPosition: currentPosition!=null?currentPosition:chungbukUniv,
                    initialCameraPosition: chungbukUniv,
//        initialCameraPosition: CameraPosition(
//          target: LatLng(currentPosition.latitude,currentPosition.longitude),
//          zoom: 14.0
//        ),
                    onMapCreated: _onMapCreated,
                    markers: _markers,
                    compassEnabled: true,
                    zoomGesturesEnabled: true,
                    rotateGesturesEnabled: true,
                    scrollGesturesEnabled: true,
                    tiltGesturesEnabled: true,
                    myLocationEnabled: true,
                    onCameraIdle: _onCamerIdle,
                    onCameraMove: _onCamerMove,
                  ),
                ),
                Container(

                    margin: EdgeInsets.only(bottom: 60, left: 20),
                    alignment: Alignment.bottomLeft,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (
                                  BuildContext context) => FavorieParkScreen()
                              )
                          ).then((onValue){if(onValue!=null) moveCamera(onValue[0], onValue[1]);});
                          //booking(data['id'].toString
                        },
                        icon: Icon(Icons.star),
                      ),
                    )
                )
              ],
            ),
    );

  }
}
