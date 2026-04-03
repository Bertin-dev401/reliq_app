import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Reliq',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Get.toNamed('/signin'),
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Get.toNamed('/signup'),
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}