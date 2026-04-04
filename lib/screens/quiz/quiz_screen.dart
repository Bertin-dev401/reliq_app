import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(title: const Text('Bible Quiz')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, primary.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                Text('🎯', style: TextStyle(fontSize: 48)),
                SizedBox(height: 12),
                Text(
                  'Test Your Bible Knowledge',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Answer questions and grow in faith',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Available Quizzes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...[
            ('Old Testament Basics', '10 questions', Icons.book),
            ('New Testament', '10 questions', Icons.menu_book),
            ('Psalms & Proverbs', '8 questions', Icons.format_quote),
            ('The Gospels', '12 questions', Icons.church),
          ].map((q) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: primary.withOpacity(0.1),
                child: Icon(q.$3, color: primary),
              ),
              title: Text(q.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(q.$2),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Get.toNamed('/quiz-detail'),
            ),
          )),
        ],
      ),
    );
  }
}
