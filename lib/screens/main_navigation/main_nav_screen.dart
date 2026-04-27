import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../home/home_screen.dart';
import '../bible/bible_screen.dart';
import '../community/community_screen.dart';
import '../profile/profile_screen.dart';
import '../../config/theme.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // IndexedStack keeps all screens alive in memory so switching tabs
  // is instant and state is preserved — no rebuilds on tab switch.
  static const List<Widget> _screens = [
    HomeScreen(),
    BibleScreen(),
    CommunityScreen(),
    ProfileScreen(),
  ];

  void _onTap(int index) {
    if (index == _currentIndex) return;
    // Light haptic on tab switch — micro interaction
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = ReliqTheme.border(context);
    final surface = ReliqTheme.surface(context);
    final ink = ReliqTheme.ink(context);
    final text3 = ReliqTheme.text3(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surface,
          border: Border(top: BorderSide(color: border, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                _NavItem(icon: Icons.home_outlined,      activeIcon: Icons.home,           label: 'Home',      index: 0, current: _currentIndex, onTap: _onTap, ink: ink, text3: text3),
                _NavItem(icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book,      label: 'Bible',     index: 1, current: _currentIndex, onTap: _onTap, ink: ink, text3: text3),
                _NavItem(icon: Icons.people_outline,     activeIcon: Icons.people,         label: 'Community', index: 2, current: _currentIndex, onTap: _onTap, ink: ink, text3: text3),
                _NavItem(icon: Icons.person_outline,     activeIcon: Icons.person,         label: 'Profile',   index: 3, current: _currentIndex, onTap: _onTap, ink: ink, text3: text3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int current;
  final void Function(int) onTap;
  final Color ink;
  final Color text3;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
    required this.ink,
    required this.text3,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: isActive ? 1.0 : 0.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 22,
                color: isActive ? ink : text3,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? ink : text3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
