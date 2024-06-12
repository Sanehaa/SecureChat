import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:uwu_chat/features/one_to_one_chat/home.dart';
import 'package:uwu_chat/features/start_screens/screen_2.dart';
import 'configurations/config.dart';


abstract class AppColors {
  static const secondary = Color(0xFF088395);
  static const accent = Color(0xFFFF0000);
  static const textDark = Color(0xFF53585A);
  static const textLight = Color(0xFFF5F5F5);
  static const textFaded = Color(0xFF9899A5);
  static const iconLight = Color(0xFFB1B4C0);
  static const iconDark = Color(0xFFB1B3C1);
  static const textHighlight = secondary;
  static const overlayLight = Color(0xFFF9FAFE);
  static const overlayDark = Color(0xFF303334);
}

abstract class _LightColors {
  static const background = Colors.white;
  static const card = AppColors.overlayLight;
}

abstract class _DarkColors {
  static const background = Color(0xFF1B1E1F);
  static const card = AppColors.overlayDark;
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyB4mWP3odjVdqT9c9rckQ_i1ej4vtMsrAw",
      authDomain: "chat-da109.firebaseapp.com",
      projectId: "chat-da109",
      storageBucket: "chat-da109.appspot.com",
      messagingSenderId: "313821460928",
      appId: "1:313821460928:web:3d6b4eae2943ab44e97025",
    ),
  );

  var initializationSettingsAndroid = AndroidInitializationSettings('@drawable/ic_launcher_foreground');
  var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(MyApp(token: token));
  });
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

Future<void> saveFCMToken(String userId, String token) async {
  var regBody = {"userId": userId, "token": token};
  try {
    final response = await http.post(
      Uri.parse('$savefcm'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(regBody),
    );

    if (response.statusCode == 201) {
      print('FCM token saved successfully');
    } else {
      print('Failed to save FCM token');
    }
  } catch (error) {
    print('Error saving FCM token: $error');
  }
}

class MyApp extends StatefulWidget {
  final String? token;

  const MyApp({@required this.token, Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'channel_id',
              'channel_name',
              importance: Importance.max,
              priority: Priority.high,
              showWhen: false,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: _LightColors.background,
        cardColor: _LightColors.card,
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _DarkColors.background,
        cardColor: _DarkColors.card,
      ),
      home: Scaffold(
        body: (widget.token != null && !JwtDecoder.isExpired(widget.token!))
            ? HomeScreen(token: widget.token, logout: _logout)
            : const Screen2(),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => Screen2()),
    );
  }
}
