import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:uwu_chat/features/forgot_password/forgot_password.dart';
import 'package:uwu_chat/features/one_to_one_chat/home.dart';
import 'package:uwu_chat/features/start_screens/journey.dart';
import 'package:uwu_chat/features/auth/signup.dart';
import 'package:http/http.dart' as http;
import 'package:uwu_chat/configurations/config.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../constants/theme_constants.dart'; // Import jwt_decoder package

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Color customColor1 = const Color(0xff0F2630);
  Color customColor2 = const Color(0xff0F2630);
  Color customColor3 = const Color(0xFF088395);
  bool _isPasswordVisible = false;

  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void loginUser() async {
    try {
      if (_emailController != null &&
          _passwordController != null &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty) {
        var reqBody = {
          "email": _emailController.text,
          "password": _passwordController.text
        };

        var response = await http.post(Uri.parse('$login'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(reqBody));

        print("Request URL: $login");
        print("Request Body: $reqBody");
        print("Response Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");

        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);

          if (jsonResponse.containsKey('status')) {
            if (jsonResponse['status']) {
              var myToken = jsonResponse['token'];

              // Decode the token to get userId
              Map<String, dynamic> decodedToken = JwtDecoder.decode(myToken);
              var userId = decodedToken['_id'];

              if (userId != null) {
                print('User ID from login: $userId');
                prefs.setString('token', myToken);
                prefs.setString('userEmail', _emailController.text);
                prefs.setString('userId', userId);

                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => HomeScreen(token: myToken, )));
              } else {
                throw Exception("User ID not found in token");
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Invalid email or password. Please try again."),
                ),
              );
            }
          } else {
            print("Unexpected JSON structure: $jsonResponse");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Unexpected response from server"),
              ),
            );
          }
        } else {
          print("HTTP request failed with status code: ${response.statusCode}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("HTTP request failed. Please try again."),
            ),
          );
        }
      }
    } catch (error) {
      print("Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Wrong email or password. Please try again."),
        ),
      );
    }
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

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
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        print("Google sign-in cancelled or failed");
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> saveGoogleEmailToBackend(
      String googleToken, String email) async {
    final Uri uri = Uri.parse('$glogin/');

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

  void navigate() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      ),
    );
  }

  void journey() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const Journey(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final containerWidth = screenSize.width * 1;
    final containerHeight = screenSize.height * 1;
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [customColor1, customColor2],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: 198,
            child: Container(
              width: containerWidth,
              height: containerHeight,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                    topLeft: Radius.circular(24),
                  )),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Welcome Back',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        color: customColor1,
                      ),
                    ),
                    Text(
                      'enter your details',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          labelText: 'Email',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }
                          RegExp regex =
                          RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
                          if (!regex.hasMatch(value)) {
                            return 'Please enter a valid Gmail address';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: 'Password',hintStyle: TextStyle(color:AppColors.iconLight,),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_isPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          loginUser();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: customColor3,
                          minimumSize: const Size(200, 48),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                      child: Text(
                        'Login',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPassword(),
                          ),
                        );
                      },
                      child: Text('Forgot password?',
                          style: GoogleFonts.poppins(
                              color: Colors.blueGrey, fontSize: 15)),
                    ),
                    const SizedBox(
                      height: 40.0,
                    ),
                    Text(
                      "or continue with",
                      style: GoogleFonts.poppins(
                        color: Colors.blueGrey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    //google, apple , fb signin
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
                          width: 40.0,
                          height: 40.0,
                        ),
                        const SizedBox(width: 16.0),
                        Image.asset(
                          'assets/apple-icon.png',
                          width: 40.0,
                          height: 40.0,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: ElevatedButton(
              onPressed: navigate,
              style: ElevatedButton.styleFrom(
                  backgroundColor: customColor3,
                  minimumSize: const Size(110, 40),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
              child: Text(
                'Sign Up',
                style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    )),
              ),
            ),
          ),
          Positioned(
            top: 30,
            child: CupertinoButton(
              onPressed: journey,
              child: const Icon(
                CupertinoIcons.back,
                color: Colors.white,
                size: 30.0,
              ),
            ),
          )
        ],
      ),
    );
  }
}
