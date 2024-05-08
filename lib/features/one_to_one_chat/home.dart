import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uwu_chat/common_widgets/random_img_api.dart';
import 'package:uwu_chat/features/friend_req/searchuser.dart';
import 'package:uwu_chat/features/settings/settings.dart';
import 'package:uwu_chat/constants/story_data.dart';
import 'package:uwu_chat/constants/theme_constants.dart';
import 'package:uwu_chat/features/start_screens/screen_2.dart';
import '../../constants/avatar.dart';
import 'chatscreen.dart';
import '../settings/edit_profile.dart';
import '../notifications/notifications.dart';
import '../../configurations/userservice.dart';
import 'package:http/http.dart' as http;
import 'package:uwu_chat/configurations/config.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({@required this.token, @required this.logout, super.key});
  final Function(BuildContext)? logout;
  final String? token;
  final ValueNotifier<int> pageIndex = ValueNotifier(0);

  final ValueNotifier<String> title = ValueNotifier('Messages');

  final screenTitles = const [
    'Messages',
    'Calls',
    'Contacts',
    'Notifications',
  ];

  Future<List<Map<String, dynamic>>?> fetchAcceptedFriendRequests() async {
    try {
      final acceptedRequests = await UserService.getAcceptedFriendRequests();
      return acceptedRequests;
    } catch (error) {
      print('Error fetching accepted friend requests: $error');
      return null;
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.107:3000/logout'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logging out')),
        );
        print('Logging out');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => Screen2()),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out')),
        );
        print('Error logging out');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => Screen2()),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out')),
      );
      print('Error logging out: $error');
    }
  }
  void _onNavigationIconSelected(index) {
    title.value = screenTitles[index];
    pageIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ValueListenableBuilder(
          valueListenable: title,
          builder: (BuildContext context, String value, _) {
            return Center(
              child: Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            );
          },
        ),
        leadingWidth: 54,
        leading: Align(
            alignment: Alignment.centerRight,
            child: IconButton(
                icon: Icon(
                  Icons.search_rounded,
                ),
                onPressed: () {})),
        actions: [
          GestureDetector(
            onTap: () {
              final RenderBox overlay =
              Overlay.of(context).context.findRenderObject() as RenderBox;
              final RenderBox button = context.findRenderObject() as RenderBox;
              final Offset position =
              button.localToGlobal(Offset.zero, ancestor: overlay);
              final Size buttonSize = button.size;
              final Size screenSize = MediaQuery.of(context).size;

              final double dx = screenSize.width + buttonSize.width;
              final double dy = position.dy + 54;

              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                  dx,
                  dy,
                  dx + buttonSize.width,
                  dy + buttonSize.height + 10,
                ),
                items: [
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.exit_to_app),
                      title: Text('Logout'),
                      onTap: () {
                          _logout(context);

                      },
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SettingScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'newGroup',
                    child: ListTile(
                      leading: Icon(Icons.group),
                      title: Text('New Group'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'selectChats',
                    child: ListTile(
                      leading: Icon(Icons.select_all),
                      title: Text('Select Chats'),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: ListTile(
                      leading: Icon(Icons.account_circle),
                      title: Text('Profile'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const Profile(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
      body:Column(
          children:[
            Stories(),
            Divider(
              thickness: 1,
            ),
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
          ]
      ),
      bottomNavigationBar:
      _BottomNavigationBar(onIconSelected: _onNavigationIconSelected),
    );
  }
}

class _BottomNavigationBar extends StatefulWidget {
  const _BottomNavigationBar({super.key, required this.onIconSelected});

  final ValueChanged<int> onIconSelected;

  @override
  State<_BottomNavigationBar> createState() => _BottomNavigationBarState();
}

class _BottomNavigationBarState extends State<_BottomNavigationBar> {
  var selectedIndex = 0;

  void handleIconSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
    widget.onIconSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavBarItem(
                  index: 0,
                  label: 'Messages',
                  icon: Icons.chat,
                  isSelected: (selectedIndex == 0),
                  onTap: () {
                    handleIconSelected(3);
                  }),
              _NavBarItem(
                  index: 2,
                  label: 'Contacts',
                  icon: Icons.perm_contact_cal,
                  isSelected: (selectedIndex == 2),
                  onTap: () {
                    handleIconSelected(3);
                  }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                    color: Colors.black,
                    icon: Icon(
                      Icons.add,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchUsersScreen(),
                        ),
                      );
                    }),
              ),
              _NavBarItem(
                  index: 1,
                  label: 'Calls',
                  icon: Icons.call,
                  isSelected: (selectedIndex == 1),
                  onTap: () {
                    handleIconSelected(3);
                  }),
              _NavBarItem(
                index: 3,
                label: 'Notifications',
                icon: Icons.notifications,
                isSelected: (selectedIndex == 3),
                onTap: () {
                  handleIconSelected(3);
                  // Use Navigator to navigate to the Notifications screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NotificationScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    Key? key,
    required this.index,
    required this.label,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
  }) : super(key: key);

  final int index;
  final String? label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(icon, size: 20, color: isSelected ? Colors.black : null),
            const SizedBox(height: 8),
            Text(
              label!,
              style: isSelected
                  ? const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)
                  : const TextStyle(fontSize: 11),
            )
          ],
        ),
      ),
    );
  }
}


class Stories extends StatelessWidget {
  const Stories({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16, bottom: 8),
            child: Text(
              'Stories',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: AppColors.textFaded,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  final faker = Faker();
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 60,
                      child: StorySection(
                        storyData: StoryData(
                          name: faker.person.name(),
                          url: RandomImage.randomPictureUrl(),
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

class StorySection extends StatelessWidget {
  const StorySection({super.key, required this.storyData});

  final StoryData storyData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Avatar.medium(url: storyData.url),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 9, left: 10, right: 10),
            child: Text(
              storyData.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 0.3,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
      ],
    );
  }
}