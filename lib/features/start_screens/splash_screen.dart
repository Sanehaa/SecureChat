import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uwu_chat/features/start_screens/screen_2.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Color customColor1 = const Color(0xff0F2630);
  Color customColor2 = const Color(0xff0F2630);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => Screen2(),
      ));

    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [customColor1, customColor2],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 172,
              height: 172,
              child: Image.asset('assets/SecureChatlogo.png'),
            ),

          ],
        ),
      ),
    );
  }
}
