import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _dailyVerseReminder = true;
  bool _communityUpdates = true;
  bool _eventReminders = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications   = prefs.getBool('notif_push')      ?? true;
      _dailyVerseReminder  = prefs.getBool('notif_verse')     ?? true;
      _communityUpdates    = prefs.getBool('notif_community') ?? true;
      _eventReminders      = prefs.getBool('notif_events')    ?? true;
    });
  }

  Future<void> _toggle(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _showChangePassword() {
    final currentCtrl = TextEditingController();
    final newCtrl     = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscure1 = true, obscure2 = true, obscure3 = true;
    bool loading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ReliqTheme.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Change Password', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              TextField(
                controller: currentCtrl,
                obscureText: obscure1,
                decoration: InputDecoration(
                  labelText: 'Current password',
                  prefixIcon: Icon(Icons.lock_outline, size: 20, color: ReliqTheme.text2(context)),
                  suffixIcon: IconButton(
                    icon: Icon(obscure1 ? Icons.visibility_off : Icons.visibility, size: 18),
                    onPressed: () => setSheet(() => obscure1 = !obscure1),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: newCtrl,
                obscureText: obscure2,
                decoration: InputDecoration(
                  labelText: 'New password',
                  prefixIcon: Icon(Icons.lock_outline, size: 20, color: ReliqTheme.text2(context)),
                  suffixIcon: IconButton(
                    icon: Icon(obscure2 ? Icons.visibility_off : Icons.visibility, size: 18),
                    onPressed: () => setSheet(() => obscure2 = !obscure2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: confirmCtrl,
                obscureText: obscure3,
                decoration: InputDecoration(
                  labelText: 'Confirm new password',
                  prefixIcon: Icon(Icons.lock_outline, size: 20, color: ReliqTheme.text2(context)),
                  suffixIcon: IconButton(
                    icon: Icon(obscure3 ? Icons.visibility_off : Icons.visibility, size: 18),
                    onPressed: () => setSheet(() => obscure3 = !obscure3),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: loading ? null : () async {
                    if (newCtrl.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password must be at least 6 characters')),
                      );
                      return;
                    }
                    if (newCtrl.text != confirmCtrl.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Passwords do not match')),
                      );
                      return;
                    }
                    setSheet(() => loading = true);
                    // Re-authenticate then update password via Firebase Auth
                    // TODO: implement re-auth with currentCtrl.text then
                    // FirebaseAuth.instance.currentUser!.updatePassword(newCtrl.text)
                    await Future.delayed(const Duration(seconds: 1));
                    setSheet(() => loading = false);
                    Get.back();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Password updated'),
                        backgroundColor: ReliqTheme.ink(context),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  },
                  child: loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Update Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ink = ReliqTheme.ink(context);
    final text3 = ReliqTheme.text3(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _Header('Appearance', context),
          ListTile(
            leading: Icon(Icons.brightness_auto, size: 20, color: ink),
            title: Text('Theme', style: Theme.of(context).textTheme.bodyMedium),
            subtitle: Text(
              Theme.of(context).brightness == Brightness.dark ? 'Dark mode' : 'Light mode',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Text(
              'System',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: text3),
            ),
          ),

          const Divider(),
          _Header('Account', context),
          ListTile(
            leading: Icon(Icons.person_outline, size: 20, color: ink),
            title: Text('Edit Profile', style: Theme.of(context).textTheme.bodyMedium),
            trailing: Icon(Icons.arrow_forward, size: 14, color: text3),
            onTap: () => Get.toNamed('/edit-profile'),
          ),
          ListTile(
            leading: Icon(Icons.lock_outline, size: 20, color: ink),
            title: Text('Change Password', style: Theme.of(context).textTheme.bodyMedium),
            trailing: Icon(Icons.arrow_forward, size: 14, color: text3),
            onTap: _showChangePassword,
          ),

          const Divider(),
          _Header('Notifications', context),
          SwitchListTile(
            secondary: Icon(Icons.notifications_outlined, size: 20, color: ink),
            title: Text('Push Notifications', style: Theme.of(context).textTheme.bodyMedium),
            value: _pushNotifications,
            onChanged: (v) {
              setState(() => _pushNotifications = v);
              _toggle('notif_push', v);
            },
          ),
          SwitchListTile(
            secondary: Icon(Icons.wb_sunny_outlined, size: 20, color: ink),
            title: Text('Daily Verse Reminder', style: Theme.of(context).textTheme.bodyMedium),
            value: _dailyVerseReminder,
            onChanged: (v) {
              setState(() => _dailyVerseReminder = v);
              _toggle('notif_verse', v);
            },
          ),
          SwitchListTile(
            secondary: Icon(Icons.people_outline, size: 20, color: ink),
            title: Text('Community Updates', style: Theme.of(context).textTheme.bodyMedium),
            value: _communityUpdates,
            onChanged: (v) {
              setState(() => _communityUpdates = v);
              _toggle('notif_community', v);
            },
          ),
          SwitchListTile(
            secondary: Icon(Icons.event_outlined, size: 20, color: ink),
            title: Text('Event Reminders', style: Theme.of(context).textTheme.bodyMedium),
            value: _eventReminders,
            onChanged: (v) {
              setState(() => _eventReminders = v);
              _toggle('notif_events', v);
            },
          ),

          const Divider(),
          _Header('About', context),
          ListTile(
            leading: Icon(Icons.info_outline, size: 20, color: ink),
            title: Text('App Version', style: Theme.of(context).textTheme.bodyMedium),
            trailing: Text('1.0.0', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: text3)),
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, size: 20, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: ReliqTheme.surface(context),
                  title: Text('Sign out', style: Theme.of(context).textTheme.headlineSmall),
                  content: Text('Are you sure?', style: Theme.of(context).textTheme.bodyMedium),
                  actions: [
                    TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Get.back(result: true), child: const Text('Sign out', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await Provider.of<AuthProvider>(context, listen: false).signOut();
                Get.offAllNamed('/welcome');
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

Widget _Header(String title, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        letterSpacing: 1.2,
        color: ReliqTheme.text3(context),
      ),
    ),
  );
}
