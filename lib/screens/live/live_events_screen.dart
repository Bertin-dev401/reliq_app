import 'package:flutter/material.dart';

class LiveEventsScreen extends StatelessWidget {
  const LiveEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.circle, color: Colors.red, size: 12),
            SizedBox(width: 8),
            Text('LIVE'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle_outline, size: 100, color: Colors.white),
                    SizedBox(height: 16),
                    Text('Live Stream', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sunday Prayer Session', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('245 watching now', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    Icon(Icons.share),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(child: TextField(decoration: InputDecoration(hintText: 'Say something...'))),
                    IconButton(icon: const Icon(Icons.send), onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}