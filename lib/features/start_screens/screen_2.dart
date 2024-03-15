import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uwu_chat/features/start_screens/journey.dart';
import 'package:uwu_chat/features/auth/login.dart';

class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  Color customColor1 = const Color(0xff0F2630);
  Color customColor2 = const Color(0xff0F2630);
  Color customColor3 = const Color(0xFF088395);

  void navigate() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const Journey(),
      ),
    );
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
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        const SizedBox(height: 72),
        Container(
          width: 172,
          height: 172,
          child: Image.asset('assets/SecureChatlogo.png'),
        ),
        SizedBox(height: 2),
        Text(
          'SecureChat',
          style: GoogleFonts.poppins(
            fontSize: 28,
            letterSpacing: 3.0,
            color: customColor3,
            fontWeight: FontWeight.bold,
          ),
        ),
        Flexible(child: const SizedBox(height: 248)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Your Conversations,Your Privacy, Our Commitment',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: navigate,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF088395),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              //       side: BorderSide(
              //       color: Color(0xFFbc13fe),
              //   width: 1,
              // ),
            ),
            elevation: 3,
          ),
          child: SizedBox(
            width: 200,
            height: 48,
            child: Center(
              child: Text(
                'Get Started',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        )
      ]),
    ));
  }
}
