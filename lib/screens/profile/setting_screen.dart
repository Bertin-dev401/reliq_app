import 'package:flutter/material.dart';
import '../../theme/reliq_themes.dart';
import '../../services/theme_service.dart';
import '../../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentTheme = 'gold';

  @override
  void initState() {
    super.initState();
    ThemeService.getTheme().then((t) {
      if (mounted) setState(() => _currentTheme = t);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _SectionHeader('Appearance'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Choose App Theme',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: primary),
            ),
          ),
          ...ReliqThemes.themeNames.entries.map((entry) {
            final color = ReliqThemes.themePrimaryColors[entry.key]!;
            final isSelected = _currentTheme == entry.key;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: color,
                radius: 14,
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              title: Text(entry.value),
              trailing: isSelected ? Icon(Icons.check_circle, color: primary) : null,
              onTap: () {
                ReliqApp.of(context)?.changeTheme(entry.key);
                setState(() => _currentTheme = entry.key);
              },
            );
          }),
          const Divider(),
          _SectionHeader('Account'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          const Divider(),
          _SectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Push Notifications'),
            value: true,
            onChanged: (_) {},
          ),
          SwitchListTile(
            secondary: const Icon(Icons.wb_sunny_outlined),
            title: const Text('Daily Verse Reminder'),
            value: true,
            onChanged: (_) {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey[500]),
      ),
    );
  }
}
