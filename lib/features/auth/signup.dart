import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:uwu_chat/features/one_to_one_chat/home.dart';
import 'package:uwu_chat/features/auth/login.dart';
import 'package:uwu_chat/features/start_screens/journey.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uwu_chat/configurations/verfication.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import '../../configurations/login_response_model.dart';
import 'package:uwu_chat/configurations/config.dart';

import '../../constants/theme_constants.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late BuildContext initialContext;
  String email = '';
  bool isApiCallProcess = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  GlobalKey<FormState> globalkey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  Future<void> _saveUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', _username.text);
  }

//register user api function
  Future<bool> registerUser() async {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userEmail', _emailController.text);
      // String userEmail = prefs.getString('userEmail') ?? '';
      String? userEmail = await getUserEmail();
      var regBody = {
        "email": _emailController.text,
        "password": _passwordController.text,
        "userEmail": userEmail,
      };
      try {
        final response = await http.post(
            Uri.parse('$registration/'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(regBody));
        print('Response Body: ${response.body}');
        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          print('JSON Response: $jsonResponse');
          var userId = jsonResponse['userId'];
          print('User ID from registration: $userId');

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('userId', userId);
          prefs.setString('username', _username.text);
          prefs.setString('email', _emailController.text);

          return true;
        } else {
          print("Server returned status code: ${response.statusCode}");
          print("Server response body: ${response.body}");
          return false;
        }
      } catch (e) {
        print("Error during registration: $e");
        return false;
      }
    } else {
      return false; // Email or password is empty
    }
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

  //google sign logic and api function

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
    final Uri uri = Uri.parse('glogin/');

    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      print('JSON Response: $jsonResponse');
      var userId = jsonResponse['userId'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userId', userId);
      print('Google Email saved successfully');
    } else {
      print('Failed to save Google email. Status code: ${response.statusCode}');
    }
  }

  Color customColor1 = const Color(0xff0F2630);
  Color customColor2 = const Color(0xff0F2630);
  Color customColor3 = const Color(0xFF088395);

  bool passwordsMatch = false;

  void navigate() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initialContext = context;
  }

  void journey() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const Journey(),
      ),
    );
  }

  void homescreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ProgressHUD(
          inAsyncCall: isApiCallProcess,
          opacity: .3,
          key: UniqueKey(),
          child: Stack(
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
                  width: 387,
                  height: 610,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(24),
                      topLeft: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Get Started',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                          color: customColor1,
                        ),
                      ),
                      Text(
                        'Create a new account, its easy!',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40),
                                  child: TextFormField(
                                    controller: _username,
                                    decoration: const InputDecoration(
                                      hintText: 'Username',
                                      labelText: 'Username',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a username';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40),
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
                                      RegExp regex = RegExp(
                                          r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
                                      if (!regex.hasMatch(value)) {
                                        return 'Please enter a valid Gmail address';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40),
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: _passwordController,
                                        decoration: InputDecoration(
                                          hintText: 'Create Password',
                                          labelText: 'Create Password',
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
                                      ),
                                      const SizedBox(height: 15),
                                      FlutterPwValidator(
                                        controller: _passwordController,
                                        minLength: 6,
                                        uppercaseCharCount: 2,
                                        lowercaseCharCount: 2,
                                        numericCharCount: 3,
                                        specialCharCount: 1,
                                        width: 400,
                                        height: 190,
                                        onSuccess: () {},
                                        onFail: () {
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40),
                                  child: TextFormField(
                                   // obscureText: true,
                                    controller: _confirmPasswordController,
                                    onChanged: (value) {
                                      setState(() {
                                        passwordsMatch =
                                            value == _passwordController.text;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Confirm Password',hintStyle: TextStyle(color:AppColors.iconLight,),
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
                                        return 'Please confirm your password';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                passwordsMatch
                                    ? const Text(
                                        'Passwords match',
                                        style: TextStyle(
                                          color: Colors.green,
                                        ),
                                      )
                                    : const SizedBox(),
                                const SizedBox(height: 30),
                                //all logic on signup button
                                ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        passwordsMatch = true;
                                        isApiCallProcess = true;
                                      });

                                      LoginResponseModel response;
                                      try {
                                        response = await APIService.otpLogin(_emailController.text);
                                        setState(() {
                                          isApiCallProcess = false;
                                        });

                                        if (response.data != null) {
                                          String email = _emailController.text;
                                          final BuildContext currentContext = context;
                                          Navigator.pushAndRemoveUntil(
                                            currentContext,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EmailVerification(
                                                    otpHash: response.data!,
                                                    email: email ?? '',
                                                  ),
                                            ),
                                                (route) => false,
                                          );
                                        } else {
                                          print("OTP Login failed: ${response.message}");
                                        }
                                      } catch (e) {
                                        print("Error during OTP login: $e");
                                        setState(() {
                                          isApiCallProcess = false;
                                        });
                                        return;
                                      }


                                      await _saveUsername();
                                      bool registrationSuccess =
                                          await registerUser();
                                      if (registrationSuccess) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EmailVerification(
                                              otpHash: response.data ?? '',
                                              email: _emailController.text,
                                            ),
                                          ),
                                        );
                                      } else {
                                        print("Registration failed");
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: customColor3,
                                    minimumSize: const Size(200, 48),
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(
                                    'Sign Up',
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 80.0)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              //top login button (switch to login page)
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
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Log In',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              //go back icon
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
        ),
      ),
    );
  }
}
