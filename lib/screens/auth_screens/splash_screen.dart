import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

    // After 3 seconds, check if user is already logged in.
    // tryAutoLogin() reads the saved token from SharedPreferences.
    // If valid → go to /main (skip welcome/signin).
    // If not   → go to /welcome (normal onboarding flow).
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;
      try {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final loggedIn = await auth.tryAutoLogin();
        Get.offNamed(loggedIn ? '/main' : '/welcome');
      } catch (_) {
        // If anything fails (Firebase, network etc.) just go to welcome
        Get.offNamed('/welcome');
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF6C63FF);
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.church_rounded, size: 72, color: accent),
              const SizedBox(height: 24),
              const Text(
                'RELIQ',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 10,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Faith · Community · Connection',
                style: TextStyle(
                  fontSize: 13,
                  letterSpacing: 3,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  color: accent,
                  backgroundColor: Color(0xFFE8E6FF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
