import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String baseUrl = 'http://172.16.179.99:3001/';

  // method to search for users by email
  static Future<List<String>> searchUsers(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/search-users?query=$query'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((user) => user['email'].toString()).toList();
      } else {
        throw Exception('Failed to fetch search results');
      }
    } catch (error) {
      throw error;
    }
  }

// method to send a friend request
  static Future<void> sendFriendRequest(String recipientEmail) async {
    try {
      final userEmail = await getUserEmail();

      if (userEmail == null) {
        throw Exception('User email not found in SharedPreferences');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/friend-requests'),
        body: jsonEncode({
          'senderEmail': userEmail,
          'recipientEmail': recipientEmail,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['status'] == true) {
          print('Friend request sent successfully');
        } else {
          throw Exception(responseBody['error'] ?? 'Failed to send friend request');
        }
      } else {
        throw Exception('Failed to send friend request. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw error;
    }
  }


  // method to get user email from SharedPreferences
  static Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

  //method to get the accepted fren reqs
  static Future<List<Map<String, dynamic>>> getAcceptedFriendRequests() async {
    try {
      final userEmail = await getUserEmail();

      if (userEmail == null) {
        throw Exception('User email not found in SharedPreferences');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/friend-requests/accepted/$userEmail'),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch accepted friend requests');
      }
    } catch (error) {
      throw error;
    }
  }

}


