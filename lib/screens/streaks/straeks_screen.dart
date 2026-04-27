import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/streak_provider.dart';
import '../../config/theme.dart';

class StreaksScreen extends StatelessWidget {
  const StreaksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Streaks')),
      body: Consumer<StreakProvider>(
        builder: (context, streak, _) {
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              // Streak count card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: ReliqTheme.surface(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ReliqTheme.border(context)),
                ),
                child: Column(
                  children: [
                    Text(
                      '${streak.currentStreak}',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 64,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      streak.currentStreak == 1 ? 'day streak' : 'day streak',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ReliqTheme.text2(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      streak.getEncouragementMessage(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ReliqTheme.text2(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                "Today's activities",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: ReliqTheme.text2(context),
                ),
              ),
              const SizedBox(height: 12),

              // Activity items
              ...streak.todayActivities.entries.map((entry) {
                final completed = entry.value;
                return GestureDetector(
                  onTap: completed ? null : () {
                    HapticFeedback.mediumImpact();
                    streak.completeActivity(entry.key);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: ReliqTheme.surface(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: completed
                            ? ReliqTheme.ink(context)
                            : ReliqTheme.border(context),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: completed
                                ? ReliqTheme.ink(context)
                                : ReliqTheme.surface2(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            completed ? Icons.check : _activityIcon(entry.key),
                            size: 16,
                            color: completed
                                ? ReliqTheme.inkInverse(context)
                                : ReliqTheme.text2(context),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            streak.getActivityName(entry.key),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: completed ? ReliqTheme.text2(context) : null,
                              decoration: completed ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        Text(
                          completed ? 'Done' : 'Tap to complete',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: ReliqTheme.text3(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Progress
              Text(
                'Progress',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: ReliqTheme.text2(context),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ReliqTheme.surface(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ReliqTheme.border(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${streak.activitiesCompletedToday} of ${streak.totalActivities} completed',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${((streak.activitiesCompletedToday / streak.totalActivities) * 100).round()}%',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: streak.totalActivities > 0
                            ? streak.activitiesCompletedToday / streak.totalActivities
                            : 0,
                        backgroundColor: ReliqTheme.surface2(context),
                        color: ReliqTheme.ink(context),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  IconData _activityIcon(String key) {
    switch (key) {
      case 'daily_verse': return Icons.menu_book_outlined;
      case 'prayer':      return Icons.self_improvement;
      case 'testimony':   return Icons.record_voice_over_outlined;
      default:            return Icons.check_circle_outline;
    }
  }
}
