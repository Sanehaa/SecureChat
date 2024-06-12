import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uwu_chat/features/settings/settings.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isPasswordVisibleNew = false;
  bool _isPasswordVisibleConfirm = false;
  bool passwordsMatch = false;

  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void changePassword() async {
    if (_formKey.currentState!.validate()) {
      String token = prefs.getString('token') ?? '';
      String userEmail = prefs.getString('userEmail') ?? '';

      var reqBody = {
        "email": userEmail,
        "current_password": _currentPasswordController.text,
        "new_password": _newPasswordController.text
      };

      var response = await http.post(
          Uri.parse('http://192.168.112.37/change_password'),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: jsonEncode(reqBody)
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Password changed successfully")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to change password")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("HTTP request failed with status code: ${response.statusCode}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Change Password', style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SettingScreen(),
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _currentPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisibleNew ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisibleNew = !_isPasswordVisibleNew;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isPasswordVisibleNew,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your new password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8,),
                // Password Validator
                FlutterPwValidator(
                  controller: _newPasswordController,
                  minLength: 6,
                  uppercaseCharCount: 2,
                  lowercaseCharCount: 2,
                  numericCharCount: 3,
                  specialCharCount: 1,
                  width: 400,
                  height: 190,
                  onSuccess: () {
                  },
                  onFail: () {
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _confirmPasswordController,
                  onChanged: (value) {
                    setState(() {
                      passwordsMatch = value == _newPasswordController;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisibleConfirm ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisibleConfirm = !_isPasswordVisibleConfirm;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isPasswordVisibleConfirm,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      passwordsMatch = true;
                      changePassword();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 3,
                    backgroundColor: const Color(0xFF088395),
                    minimumSize: const Size(200, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Change Password',
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
    );
  }
}
