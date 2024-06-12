import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:uwu_chat/configurations/config.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  bool _isDarkMode = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
  }

  void _loadDarkModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> deleteAccount(String email, String password) async {
    var url = Uri.parse('$delacc');

    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email, 'password': password});

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      print("account deltedddddddddddddddddd");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account deleted successfully')),
      );
    } else {
      print(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete account')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Delete Account',
            style: TextStyle(
              color: _isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded),
            color: _isDarkMode ? Colors.white : Colors.black,
            onPressed: () {
              Navigator.of(context).pop();
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                          RegExp regex =
                              RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
                          if (!regex.hasMatch(value)) {
                            return 'Please enter a valid Gmail address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: _currentPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
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
                            return 'Please enter your current password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final email = _emailController.text;
                              final password = _currentPasswordController.text;

                              await deleteAccount(email, password);
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: BorderSide(color: Colors.blueGrey, width: 3),
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                            minimumSize: MaterialStateProperty.all<Size>(Size(double.infinity, 50)),
                          ),
                          child: Text(
                            'Delete Account',
                            style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w700, fontSize: 18),
                          ),
                        ),
                      ),
                    ]),
              ),
            )));
  }
}
