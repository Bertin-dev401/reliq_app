import 'package:flutter/material.dart';

class DonationsScreen extends StatelessWidget {
  const DonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donations')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Support Our Mission', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Your generous donation helps us spread the word of God'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _DonationButton(amount: '5,000'),
                      _DonationButton(amount: '10,000'),
                      _DonationButton(amount: '20,000'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const TextField(decoration: InputDecoration(labelText: 'Custom Amount (RWF)')),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(onPressed: () {}, child: const Text('Donate Now')),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Recent Donations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...List.generate(5, (i) => ListTile(
            leading: const CircleAvatar(child: Icon(Icons.volunteer_activism)),
            title: Text('Anonymous donated RWF ${(i + 1) * 5000}'),
            subtitle: const Text('2 hours ago'),
          )),
        ],
      ),
    );
  }
}

class _DonationButton extends StatelessWidget {
  final String amount;
  const _DonationButton({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(onPressed: () {}, child: Text('$amount RWF')),
      ),
    );
  }
}