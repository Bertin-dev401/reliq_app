import 'package:flutter/material.dart';

class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(radius: 16, child: Icon(Icons.person, size: 20)),
            SizedBox(width: 12),
            Text('User Name'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _MessageBubble(text: 'Hello!', isSent: false),
                _MessageBubble(text: 'Hi there! How are you?', isSent: true),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.add), onPressed: () {}),
                const Expanded(child: TextField(decoration: InputDecoration(hintText: 'Type a message...', border: InputBorder.none))),
                IconButton(icon: const Icon(Icons.send, color: Color(0xFF6C63FF)), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isSent;

  const _MessageBubble({required this.text, required this.isSent});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSent ? const Color(0xFF6C63FF) : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text, style: TextStyle(color: isSent ? Colors.white : Colors.black)),
      ),
    );
  }
}