import 'package:flutter/material.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [TextButton(onPressed: () {}, child: const Text('Post'))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const TextField(
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(icon: const Icon(Icons.image), onPressed: () {}),
                IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}