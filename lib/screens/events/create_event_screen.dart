import 'package:flutter/material.dart';

class CreateEventScreen extends StatelessWidget {
  const CreateEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        actions: [TextButton(onPressed: () {}, child: const Text('Create'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Event Title')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Description'), maxLines: 4),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Location')),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Select Date & Time'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}