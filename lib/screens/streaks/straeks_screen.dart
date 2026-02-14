import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/streak_provider.dart';

class StreaksScreen extends StatelessWidget {
  const StreaksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Streak')),
      body: Consumer<StreakProvider>(
        builder: (context, streakProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 80)),
                      const SizedBox(height: 16),
                      Text(
                        '${streakProvider.currentStreak}',
                        style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const Text('Day Streak', style: TextStyle(fontSize: 20, color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text('Daily Activities', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _ActivityCard(
                  title: 'Read Daily Verse',
                  icon: Icons.menu_book,
                  completed: streakProvider.todayCompleted,
                  onTap: () => streakProvider.completeToday(),
                ),
                _ActivityCard(title: 'Pray for 5 minutes', icon: Icons.favorite, completed: false, onTap: () {}),
                _ActivityCard(title: 'Share a testimony', icon: Icons.share, completed: false, onTap: () {}),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool completed;
  final VoidCallback onTap;

  const _ActivityCard({required this.title, required this.icon, required this.completed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: completed ? Colors.green : Colors.grey[300],
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title),
        trailing: completed ? const Icon(Icons.check_circle, color: Colors.green) : null,
        onTap: completed ? null : onTap,
      ),
    );
  }
}