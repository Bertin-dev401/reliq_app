import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [TextButton(onPressed: () {}, child: const Text('Save'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF6C63FF),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const TextField(decoration: InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Bio'), maxLines: 3),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Location')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Denomination')),
          ],
        ),
      ),
    );
  }
}