import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text('User ${index + 1}'),
          subtitle: const Text('Last message preview...'),
          trailing: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('2h', style: TextStyle(fontSize: 12, color: Colors.grey)),
              SizedBox(height: 4),
              CircleAvatar(radius: 10, backgroundColor: Color(0xFF6C63FF), child: Text('2', style: TextStyle(fontSize: 10, color: Colors.white))),
            ],
          ),
          onTap: () => Get.toNamed('/chat-detail'),
        ),
      ),
    );
  }
}