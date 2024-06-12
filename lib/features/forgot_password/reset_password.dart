import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:uwu_chat/configurations/config.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  Color customColor1 = const Color(0xff0F2630);
  Color customColor3 = const Color(0xFF088395);
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newpwdController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  String _passwordError = '';

  Future<void> resetPassword() async {
    final email = _emailController.text;
    final otp = _otpController.text;
    final newPassword = _newpwdController.text;
    final url = Uri.parse('$resetpwd');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp, 'newPassword': newPassword}),
      );

      if (response.statusCode == 200) {
        print('your owd resetted');
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password reset successful'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['error'] ?? 'Failed to reset password'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final containerWidth = screenSize.width * 1;
    final containerHeight = screenSize.height * 1;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: customColor1,
        leading: CupertinoButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            CupertinoIcons.back,
            color: Colors.white,
            size: 30.0,
          ),
        ),
      ),
      body: Center(
        child: Container(
          width: containerWidth,
          height: containerHeight,
          color: customColor1,
          child: Center(
            child: Container(
              width: 350,
              height: 590,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(width: 3, color: customColor3)),
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 16,),
                        Text(
                          "Reset Password",
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                            color: customColor1,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Text(
                            'Don’t worry, we got you! Just enter the OTP sent on the email you entered and reset your password.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.blueGrey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            children: [
                              // Email
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  hintText: 'Email',
                                  labelText: 'Email',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an email';
                                  }
                                  RegExp regex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
                                  if (!regex.hasMatch(value)) {
                                    return 'Please enter a valid Gmail address';
                                  }
                                  return null;
                                },
                              ),
                              // OTP
                              TextFormField(
                                controller: _otpController,
                                decoration: const InputDecoration(
                                  hintText: '5 digit OTP',
                                  labelText: 'OTP',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the OTP';
                                  }
                                  if (value.length != 5 || !RegExp(r'^\d{5}$').hasMatch(value)) {
                                    return 'Please enter a valid 5 digit OTP';
                                  }
                                  return null;
                                },
                              ),
                              // New Password
                              TextFormField(
                                controller: _newpwdController,
                                decoration: InputDecoration(
                                  hintText: 'New Password',
                                  labelText: 'New Password',
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
                              const SizedBox(height: 8,),
                              // Password Validator
                              FlutterPwValidator(
                                controller: _newpwdController,
                                minLength: 6,
                                uppercaseCharCount: 2,
                                lowercaseCharCount: 2,
                                numericCharCount: 3,
                                specialCharCount: 1,
                                width: 400,
                                height: 190,
                                onSuccess: () {
                                  setState(() {
                                    _passwordError = '';
                                  });
                                },
                                onFail: () {
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate() && _passwordError.isEmpty) {
                              resetPassword();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: customColor3,
                              minimumSize: const Size(200, 48),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14))),
                          child: Text(
                            'Submit',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15,)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
