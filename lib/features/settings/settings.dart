import 'package:flutter/material.dart';
import 'package:uwu_chat/features/settings/help_support.dart';
import 'package:uwu_chat/features/one_to_one_chat/home.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  Color customColor1 = const Color(0xff0F2630);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          },
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: Colors.black,
            onPressed: () {
              // Add your search logic here
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.settings),
            color: Colors.black,
            onPressed: () {
              // Add your settings logic here
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSection('Account', [
              _buildSetting('My Account', Icons.account_circle),
              _buildSetting('Privacy and Security', Icons.security),
              _buildSetting('Payments', Icons.payment),
            ]),
            _buildDivider(),
            _buildSection('General', [
              _buildSetting('Notifications', Icons.notifications),
              _buildSetting('Language', Icons.language),
              _buildSetting('Dark Mode', Icons.dark_mode),
              _buildSetting('Data Saver', Icons.data_usage),
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
              _buildSetting('Logout', Icons.exit_to_app),
            ]),
          ],
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
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      onTap: onTap,
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
