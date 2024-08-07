import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

LoginResponseModel loginResponseModel(String str) =>
    LoginResponseModel.fromJson(
      json.decode(str),
    );

class LoginResponseModel {
  LoginResponseModel({
    required this.message,
    this.data,
  });

  late final String message;
  late final String? data;

  LoginResponseModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data["message"] = message;
    _data["data"] = data;

    return _data;
  }
}


class APIService{
  static var client = http.Client();

  static Future<LoginResponseModel> otpLogin(String email) async{
    var url = Uri.parse('$otplogin/');

    var response = await client.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email
        })
    );
    if (response.statusCode == 200) {
      return loginResponseModel(response.body);
    } else {
      throw Exception('Failed to load data, status code: ${response.statusCode}');
    }
  }


  static Future<LoginResponseModel> verifyOTP(String email, String otpHash, String otpCode, int expires) async{
    var url = Uri.parse('$otpverify/');


    try {
      var response = await client.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "otp": otpCode,
          "hash": otpHash,
          "expires": expires,
        }),
      );
      if (response.statusCode == 200) {
        return loginResponseModel(response.body);
      } else {
        throw Exception('Failed to load data, status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error in API call: $e");
      throw e;
    }
  }
}