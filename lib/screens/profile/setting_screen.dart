import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.star, color: Color(0xFF6C63FF), size: 32),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Upgrade to Premium', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('Unlock exclusive features', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
          const _SettingsSection(title: 'Preferences', items: [
            _SettingsItem(icon: Icons.notifications, title: 'Notifications'),
            _SettingsItem(icon: Icons.dark_mode, title: 'Dark Mode'),
            _SettingsItem(icon: Icons.language, title: 'Language'),
          ]),
          const _SettingsSection(title: 'Account', items: [
            _SettingsItem(icon: Icons.person, title: 'Manage Account'),
            _SettingsItem(icon: Icons.payment, title: 'Manage Subscription'),
            _SettingsItem(icon: Icons.privacy_tip, title: 'Privacy Policy'),
          ]),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log Out', style: TextStyle(color: Colors.red)),
            onTap: () => Get.offAllNamed('/welcome'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;
  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
        ),
        ...items,
        const Divider(),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SettingsItem({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }
}