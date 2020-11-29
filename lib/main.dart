import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/screens/Park/park_screen.dart';
import 'package:test_app/Provider/FavoriteParkService.dart';
import 'package:test_app/Provider/auth.dart';
import 'package:test_app/service/geolocator_service.dart';
import 'screens/User/Login_Page.dart';
import 'screens/Main_Screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final locatorService = GeoLocatorService();
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        FutureProvider(create: (context)=>locatorService.getLocation(),),
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context)=> FavoriteParkService())
      ],
      child: MaterialApp(
        title: 'welcome to Flutter',
        home: MainScreen()
        //LoginPage(),
      ),
    );
  }
}
