import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/streak_provider.dart';
import '../../config/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final streak = Provider.of<StreakProvider>(context);
    final user = auth.currentUser;

    final name = user?.name ?? 'Reliq User';
    final email = user?.email ?? '';
    final denomination = user?.denomination ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'R';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            // ── Header ───────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Profile', style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 22),
                    onPressed: () => Get.toNamed('/settings'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Avatar + name ─────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: ReliqTheme.surface2(context),
                    child: Text(
                      initial,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: Theme.of(context).textTheme.headlineSmall),
                        if (email.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(email, style: Theme.of(context).textTheme.bodySmall),
                        ],
                        if (denomination.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(denomination, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Stats row ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: ReliqTheme.surface(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ReliqTheme.border(context)),
                ),
                child: Row(
                  children: [
                    _StatItem(value: '${streak.currentStreak}', label: 'Day streak'),
                    _Divider(),
                    _StatItem(value: '0', label: 'Posts'),
                    _Divider(),
                    _StatItem(value: '0', label: 'Communities'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Menu ──────────────────────────────────
            _SectionLabel('Account', context),
            _MenuItem(icon: Icons.edit_outlined,     label: 'Edit Profile',    onTap: () => Get.toNamed('/edit-profile'), context: context),
            _MenuItem(icon: Icons.bookmark_outline,  label: 'Saved Verses',    onTap: () {}, context: context),
            _MenuItem(icon: Icons.history,           label: 'Activity',        onTap: () {}, context: context),
            _MenuItem(icon: Icons.shopping_bag_outlined, label: 'My Orders',   onTap: () => Get.toNamed('/marketplace'), context: context),

            const SizedBox(height: 8),
            _SectionLabel('More', context),
            _MenuItem(icon: Icons.settings_outlined, label: 'Settings',        onTap: () => Get.toNamed('/settings'), context: context),
            _MenuItem(icon: Icons.help_outline,      label: 'Help & Support',  onTap: () {}, context: context),

            const SizedBox(height: 8),

            // ── Sign out ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.logout, size: 20, color: ReliqTheme.text2(context)),
                title: Text(
                  'Sign out',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ReliqTheme.text2(context),
                  ),
                ),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: ReliqTheme.surface(context),
                      title: Text('Sign out', style: Theme.of(context).textTheme.headlineSmall),
                      content: Text(
                        'Are you sure you want to sign out?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      actions: [
                        TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () => Get.back(result: true),
                          child: Text('Sign out', style: TextStyle(color: ReliqTheme.ink(context))),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await auth.signOut();
                    Get.offAllNamed('/welcome');
                  }
                },
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: ReliqTheme.border(context),
    );
  }
}

Widget _SectionLabel(String label, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
    child: Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        letterSpacing: 1,
        color: ReliqTheme.text3(context),
      ),
    ),
  );
}

Widget _MenuItem({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  required BuildContext context,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 20, color: ReliqTheme.ink(context)),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      trailing: Icon(Icons.arrow_forward, size: 14, color: ReliqTheme.text3(context)),
      onTap: onTap,
    ),
  );
}
