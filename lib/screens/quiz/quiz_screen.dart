import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  static const _quizzes = [
    (title: 'Old Testament',    subtitle: '10 questions', icon: Icons.history_edu_outlined),
    (title: 'New Testament',    subtitle: '10 questions', icon: Icons.menu_book_outlined),
    (title: 'Psalms & Proverbs',subtitle: '8 questions',  icon: Icons.format_quote_outlined),
    (title: 'The Gospels',      subtitle: '12 questions', icon: Icons.auto_stories_outlined),
    (title: 'Prophets',         subtitle: '8 questions',  icon: Icons.record_voice_over_outlined),
    (title: 'Acts & Letters',   subtitle: '10 questions', icon: Icons.mail_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bible Quiz')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          // Header card — clean, no gradient, no emoji
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ReliqTheme.surface(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ReliqTheme.border(context)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: ReliqTheme.surface2(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.quiz_outlined, size: 22, color: ReliqTheme.ink(context)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Test your knowledge', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text('Answer questions and grow in faith', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Available quizzes',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: ReliqTheme.text2(context),
            ),
          ),
          const SizedBox(height: 12),

          ..._quizzes.map((q) => _QuizTile(
            title: q.title,
            subtitle: q.subtitle,
            icon: q.icon,
          )),
        ],
      ),
    );
  }
}

class _QuizTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _QuizTile({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Get.toNamed('/quiz-detail');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: ReliqTheme.surface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ReliqTheme.border(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ReliqTheme.surface2(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: ReliqTheme.ink(context)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
            Icon(Icons.arrow_forward, size: 14, color: ReliqTheme.text3(context)),
          ],
        ),
      ),
    );
  }
}
