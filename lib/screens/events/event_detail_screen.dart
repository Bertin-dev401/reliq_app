import 'package:flutter/material.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Sunday Service'),
              background: Container(
                color: const Color(0xFF6C63FF),
                child: const Center(child: Icon(Icons.church, size: 80, color: Colors.white)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      const Text('Sunday, Feb 15, 2026 • 10:00 AM'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(Icons.location_on, size: 20),
                      SizedBox(width: 8),
                      Text('Kigali Community Church'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('About', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('Join us for our weekly Sunday service...', style: TextStyle(height: 1.6)),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('RSVP'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}