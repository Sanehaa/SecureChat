import 'package:flutter/material.dart';
import 'package:uwu_chat/features/one_to_one_chat/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> friendRequests = [];
  static const String baseUrl = 'http://192.168.0.107:3000';

  @override
  void initState() {
    super.initState();
    fetchFriendRequests();
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

  //fetching fren req
  Future<void> fetchFriendRequests() async {
    try {
      final userEmail = await getUserEmail();
      if (userEmail == null) {
        throw Exception('User email not found in SharedPreferences');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/friend-requests/pending/$userEmail'),
      );

      if (response.statusCode == 200) {
        setState(() {
          friendRequests = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      } else {
        print('Failed to fetch friend requests. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching friend requests: $error');
    }
  }


//accepting fren req
  Future<void> acceptFriendRequest(String senderEmail) async {
    try {
      final userEmail = await getUserEmail();
      if (userEmail == null) {
        throw Exception('User email not found in SharedPreferences');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/friend-requests/accept/$userEmail/$senderEmail'),
      );

      if (response.statusCode == 200) {
        fetchFriendRequests();
      } else {
        print('Failed to accept friend request. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error accepting friend request: $error');
    }
  }
  //show a snack bar on other user screen that thier req was accepted

//decline a fren req
  Future<void> declineFriendRequest(String senderEmail) async {
    try {
      final userEmail = await getUserEmail();
      if (userEmail == null) {
        throw Exception('User email not found in SharedPreferences');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/friend-requests/decline/$userEmail/$senderEmail'),
      );

      if (response.statusCode == 200) {
        fetchFriendRequests();
      } else {
        print('Failed to decline friend request. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error declining friend request: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          },
        ),
        title:const  Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: friendRequests.length,
        itemBuilder: (context, index) {
          final senderEmail = friendRequests[index]['senderEmail'];

          return ListTile(
            title: Text('Friend Request from $senderEmail'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => acceptFriendRequest(senderEmail),
                  child: Text('Accept'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => declineFriendRequest(senderEmail),
                  child: Text('Decline'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}