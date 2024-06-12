import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uwu_chat/features/forgot_password/change_password.dart';
import 'package:uwu_chat/features/settings/edit_profile.dart';
import 'package:uwu_chat/features/settings/help_support.dart';
import 'package:uwu_chat/features/one_to_one_chat/home.dart';
import 'package:http/http.dart' as http;
import '../notifications/notifications.dart';
import '../start_screens/screen_2.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  Color customColor1 = const Color(0xff0F2630);
  TextEditingController _searchController = TextEditingController();
  String _searchText = "";
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

  void _toggleDarkMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = value;
      prefs.setBool('isDarkMode', value);
    });
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.112.37:3000/logout'),
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
    home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: _isDarkMode ? Colors.white : Colors.black, // Change color based on dark mode
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              );
            },
          ),
          title: Text(
            'Settings',
            style: TextStyle(
              color: _isDarkMode ? Colors.white : Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              color: _isDarkMode ? Colors.white : Colors.black, // Change color based on dark mode
              onPressed: () {
                showSearch(context: context, delegate: SettingSearchDelegate());
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSection('Account', [
              _buildSetting('My Account', Icons.account_circle, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Profile(),
                  ),
                );
              },),
              _buildSetting('Privacy and Security', Icons.security),
            ]),
            _buildDivider(),
            _buildSection('General', [
              _buildSetting('Notifications', Icons.notifications, onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NotificationScreen(),
                  ),
                );
              }),
              _buildSetting('Language', Icons.language),
              _buildDarkModeSetting(),
              _buildSetting('Change Password', Icons.remove_red_eye, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                );
              }),
            ]),
            _buildDivider(),
            _buildSection('About', [
              _buildSetting('Terms and Services', Icons.description),
              _buildSetting('Help and Support', Icons.help, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HelpandSupport()),
                );
              }),
              _buildSetting('FAQs', Icons.question_answer),
            ]),
            _buildDivider(),
            _buildSection('Other', [
              _buildSetting('Version and Update', Icons.system_update),
              _buildSetting('Logout', Icons.exit_to_app, onTap: () {
                _logout(context);

              },),
            ]),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildSection(String title, List<Widget> settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...settings,
      ],
    );
  }

  Widget _buildSetting(String title, IconData icon, {Function()? onTap}) {
    if (_searchText.isNotEmpty && !title.toLowerCase().contains(_searchText.toLowerCase())) {
      return Container();
    }
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      onTap: onTap,
    );
  }

  Widget _buildDarkModeSetting() {
    return ListTile(
      title: Text('Dark Mode'),
      leading: Icon(Icons.dark_mode),
      trailing: Switch(
        value: _isDarkMode,
        onChanged: _toggleDarkMode,
      ),
    );
  }


  Widget _buildDivider() {
    return const Divider(
      height: 16,
      thickness: 1,
      color: Colors.grey,
    );
  }
}

class SettingSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> settings = [
    {'title': 'My Account', 'icon': Icons.account_circle, 'widget': Profile()},
    {'title': 'Privacy and Security', 'icon': Icons.security, 'widget': null},
    {'title': 'Payments', 'icon': Icons.payment, 'widget': null},
    {'title': 'Notifications', 'icon': Icons.notifications, 'widget': NotificationScreen()},
    {'title': 'Language', 'icon': Icons.language, 'widget': null},
    {'title': 'Dark Mode', 'icon': Icons.dark_mode, 'widget': null},
    {'title': 'Change Password', 'icon': Icons.remove_red_eye, 'widget': ChangePasswordScreen()},
    {'title': 'Terms and Services', 'icon': Icons.description, 'widget': null},
    {'title': 'Help and Support', 'icon': Icons.help, 'widget': HelpandSupport()},
    {'title': 'FAQs', 'icon': Icons.question_answer, 'widget': null},
    {'title': 'Version and Update', 'icon': Icons.system_update, 'widget': null},
    {'title': 'Logout', 'icon': Icons.exit_to_app, 'widget': null},
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = settings.where((setting) => setting['title'].toLowerCase().contains(query.toLowerCase()));

    return ListView(
      children: results.map<Widget>((setting) {
        return ListTile(
          title: Text(setting['title']),
          leading: Icon(setting['icon']),
          onTap: () {
            if (setting['widget'] != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => setting['widget']),
              );
            }
          },
        );
      }).toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = settings.where((setting) => setting['title'].toLowerCase().contains(query.toLowerCase()));

    return ListView(
      children: suggestions.map<Widget>((setting) {
        return ListTile(
          title: Text(setting['title']),
          leading: Icon(setting['icon']),
          onTap: () {
            if (setting['widget'] != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => setting['widget']),
              );
            }
          },
        );
      }).toList(),
    );
  }
}
