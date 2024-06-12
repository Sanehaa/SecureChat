import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uwu_chat/configurations/config.dart';
import 'package:uwu_chat/features/forgot_password/reset_password.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  Color customColor1 = const Color(0xff0F2630);
  Color customColor3 = const Color(0xFF088395);
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> sendOtp() async {
    final email = _emailController.text;
    final url = Uri.parse('$forgotpwd');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        print('forgot pasword email sent successfully');
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ResetPassword(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Failed to send OTP'),
              backgroundColor: Colors.blueGrey,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send OTP'),
            backgroundColor: Colors.blueGrey,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $error'),
          backgroundColor: Colors.blueGrey,
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
              height: 340,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(width: 3, color: customColor3)),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 16,),
                    Text(
                      "Forgot Password?",
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
                        'Don’t worry, we got you! Just enter the email associated with your account and we’ll send you instructions to reset your password!',
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
                      child: Form(
                        key: _formKey,
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
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          sendOtp();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: customColor3,
                          minimumSize: const Size(200, 48),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                      child: Text(
                        'Send Email',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.blueGrey,
                          ),
                          textAlign: TextAlign.center,
                        ))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
