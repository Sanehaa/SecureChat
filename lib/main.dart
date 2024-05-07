import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:uwu_chat/features/one_to_one_chat/home.dart';
import 'package:uwu_chat/features/start_screens/screen_2.dart';
import 'package:http/http.dart'as http;

import 'configurations/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: const FirebaseOptions(
    apiKey: "AIzaSyB4mWP3odjVdqT9c9rckQ_i1ej4vtMsrAw",
    authDomain: "chat-da109.firebaseapp.com",
    projectId: "chat-da109",
    storageBucket: "chat-da109.appspot.com",
    messagingSenderId: "313821460928",
    appId: "1:313821460928:web:3d6b4eae2943ab44e97025",
  ));


  FirebaseMessaging.instance.getToken().then((value) {
    print("getToken: $value");
    if (value != null) {
      SharedPreferences.getInstance().then((prefs) {
        String? userId = prefs.getString('userId');
        if (userId != null) {
          saveFCMToken(userId, value);
        } else {
          print('User ID not found in SharedPreferences');
        }
      });
    }
  });
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp(token: token));
  });
}


Future<void> saveFCMToken(String userId, String token) async {

  var regBody = {
    "userId": userId,
    "token": token
  };
  try {
    final response = await http.post(
      Uri.parse('$savefcm'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody));


    if (response.statusCode == 201) {
      print('FCM token saved successfully');
    } else {
      print('Failed to save FCM token');
    }
  } catch (error) {
    print('Error saving FCM token: $error');
  }
}

class MyApp extends StatelessWidget {
  final String? token;

  const MyApp({
    @required this.token,
    Key? key,
  }) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => Screen2()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: (token != null && !JwtDecoder.isExpired(token!))
            ? HomeScreen(token: token, logout: _logout)
            : const Screen2(),
      ),
    );
  }
}