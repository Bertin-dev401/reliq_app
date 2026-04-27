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
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;
      try {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final loggedIn = await auth.tryAutoLogin();
        Get.offNamed(loggedIn ? '/main' : '/welcome');
      } catch (_) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0A0A) : Colors.white;
    final textColor = isDark ? const Color(0xFFF5F5F5) : const Color(0xFF0D0D0D);
    final subColor = isDark ? const Color(0xFF555555) : const Color(0xFFABABAB);
    final barColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8);

    return Scaffold(
      backgroundColor: bg,
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.church_rounded,
                size: 48,
                color: textColor,
              ),
              const SizedBox(height: 20),
              Text(
                'RELIQ',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 8,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Faith · Community · Connection',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2,
                  color: subColor,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 80,
                child: LinearProgressIndicator(
                  color: textColor,
                  backgroundColor: barColor,
                  minHeight: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
