import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Get.offNamed('/main'),
          child: const Text('Sign In (placeholder)'),
        ),
      ),
    );
  }
}