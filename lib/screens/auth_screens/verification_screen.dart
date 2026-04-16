import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Firebase sends a password reset link directly to the user's email.
// There is no OTP to verify — this screen just informs the user to
// check their inbox and routes them back to sign in.
class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF6C63FF);
    const dark = Color(0xFF2D3748);
    final args = Get.arguments as Map<String, dynamic>?;
    final email = args?['email'] ?? 'your email';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: dark,
        title: const Text('Check Your Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_read_outlined, size: 80, color: accent),
            const SizedBox(height: 24),
            const Text(
              'Reset link sent',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: dark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'We sent a password reset link to $email. Open your email and tap the link to set a new password.',
              style: TextStyle(fontSize: 14, color: Colors.grey[500], height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Get.offAllNamed('/signin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Sign In',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
