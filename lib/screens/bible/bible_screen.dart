
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BibleScreen extends StatelessWidget {
  const BibleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible'),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.today, color: Color(0xFF6C63FF)),
              title: const Text('Daily Verse'),
              onTap: () => Get.toNamed('/daily-verse'),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Books', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...['Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy'].map(
            (book) => ListTile(
              title: Text(book),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Get.toNamed('/bible-reader'),
            ),
          ),
        ],
      ),
    );
  }
}