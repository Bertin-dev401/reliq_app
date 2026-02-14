import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EMAIL')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.email_outlined, size: 80, color: Color(0xFF6C63FF)),
            const SizedBox(height: 32),
            const Text(
              'Check your email',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'An email was sent to\nexample@email.com with\nyour magic link to log in.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () {},
              child: const Text('RESEND EMAIL'),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text('Having trouble with your magic link?\nENTER CODE'),
            ),
          ],
        ),
      ),
    );
  }
}