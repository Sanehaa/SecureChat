import 'package:flutter/material.dart';
import '../../configurations/userservice.dart';

class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({super.key});

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  TextEditingController _searchController = TextEditingController();
  List<String> searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Users'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter user email',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    // Call a method to search for users based on the entered email
                    searchUsers(_searchController.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final userEmail = searchResults[index];

                return ListTile(
                  title: Text(userEmail),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Call a method to send a friend request
                      sendFriendRequest(userEmail);
                    },
                    child: Text('Send Request'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Method to search for users
  void searchUsers(String query) async {
    try {
      List<String> results = await UserService.searchUsers(query);
      setState(() {
        searchResults = results;
      });
    } catch (error) {
      // Handle error
      print('Error searching users: $error');
    }
  }

  // Method to send a friend request
  void sendFriendRequest(String recipientEmail) async {
    try {
      await UserService.sendFriendRequest(recipientEmail);
      // Optionally show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Friend request sent successfully to $recipientEmail'),
        ),
      );
    } catch (error) {
      // Handle error
      print('Error sending friend request: $error');
    }
  }
}
