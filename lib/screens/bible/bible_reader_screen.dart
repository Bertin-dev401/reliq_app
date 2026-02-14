import 'package:flutter/material.dart';

class BibleReaderScreen extends StatelessWidget {
  const BibleReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Genesis 1'),
        actions: [
          IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
          IconButton(icon: const Icon(Icons.text_fields), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: 31,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, height: 1.8, color: Colors.black87),
              children: [
                TextSpan(
                  text: '${index + 1} ',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6C63FF)),
                ),
                const TextSpan(text: 'In the beginning God created the heaven and the earth.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}