import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../configurations/userservice.dart';
import 'chatscreen.dart';

class Contacts extends StatefulWidget {
  const Contacts({super.key});

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  bool _isDarkMode = false;

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

  Future<List<Map<String, dynamic>>?> fetchAcceptedFriendRequests() async {
    try {
      final acceptedRequests = await UserService.getAcceptedFriendRequests();
      return acceptedRequests;
    } catch (error) {
      print('Error fetching accepted friend requests: $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Contacts',
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
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: fetchAcceptedFriendRequests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final acceptedRequests =
                  snapshot.data as List<Map<String, dynamic>>;
                  return ListView.builder(
                    itemCount: acceptedRequests.length,
                    itemBuilder: (context, index) {
                      final senderEmail = acceptedRequests[index]['senderEmail'];

                      return Column(
                          children:[ ListTile(
                              leading: const Padding(
                                padding: EdgeInsets.all(4),
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage('https://images.nightcafe.studio//assets/profile.png?tr=w-1600,c-at_max'),
                                ),
                              ),
                              title: Text('$senderEmail'),
                              onTap: () async {
                                String? userId = await SharedPreferences.getInstance().then((prefs) => prefs.getString('userId'));
                                if (userId != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChatScreenn(
                                            username: senderEmail,
                                            userId: userId,
                                          ),
                                    ),
                                  );
                                } else {
                                  print('User ID not found in SharedPreferences');
                                }
                              }


                          ),
                            const Divider(
                              thickness: 1, // Adjust the thickness as needed
                            ),
                          ]
                      );

                    },
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
