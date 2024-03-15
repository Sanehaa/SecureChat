import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uwu_chat/features/auth/login.dart';
import 'package:uwu_chat/features/auth/signup.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uwu_chat/features/one_to_one_chat/home.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Journey extends StatefulWidget {
  const Journey({super.key});

  @override
  State<Journey> createState() => _JourneyState();
}

class _JourneyState extends State<Journey> {

  //google signin logic and api function
  googleLogin() async {
    print("googleLogin method Called");
    GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
    try {
      var result = await _googleSignIn.signIn();
      if (result != null) {
        var authentication = await result.authentication;
        var googleToken = authentication.accessToken;

        var googleEmail = result.email;

        print("Google Token: $googleToken");
        print("Google Email: $googleEmail");
        await saveGoogleEmailToBackend(googleToken!, googleEmail);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),);}
      else {
        print("Google sign-in cancelled or failed");
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> saveGoogleEmailToBackend(String googleToken, String email) async {
    final Uri uri = Uri.parse('http://172.16.168.90:3000/google-login');

    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      print('Google Email saved successfully');
    } else {
      print('Failed to save Google email. Status code: ${response.statusCode}');
    }
  }

  late SharedPreferences prefs;
  Color customColor1 = const Color(0xff0F2630);
  Color customColor2 = const Color(0xff0F2630);
  Color customColor3 = const Color(0xFF088395);

  void navigate() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  void signup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>  SignupScreen(),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "Start your Journey",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            //login button
            const SizedBox(height: 20.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200.0,
                  height: 48.0,
                  child: ElevatedButton(
                    onPressed: navigate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customColor3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                    ),
                    child: Container(
                      height: 48.0,
                      alignment: Alignment.center,
                      child: Text(
                        "Log In",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                //signup button
                const SizedBox(height: 16.0),
                Container(
                  width: 200.0,
                  height: 48.0,
                  child: ElevatedButton(
                    onPressed: signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 48.0,
                          alignment: Alignment.center,
                          child: Text(
                            "Sign Up",
                            style: GoogleFonts.poppins(
                              color: customColor2,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 32.0,
                ),
                Text(
                  "or continue with",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        googleLogin();
                      },
                      child: Image.asset(
                        'assets/google-icon.png',
                        width: 40.0,
                        height: 40.0,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Image.asset(
                      'assets/fb-icon.png',
                      width: 48.0,
                      height: 48.0,
                    ),
                    const SizedBox(width: 16.0),
                    Image.asset(
                      'assets/apple-icon.png',
                      width: 48.0,
                      height: 48.0,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
