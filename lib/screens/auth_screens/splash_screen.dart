import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Get.offNamed('/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.church_rounded, size: 72, color: color),
            const SizedBox(height: 24),
            Text('RELIQ',
                style: TextStyle(
                    fontSize: 48, fontWeight: FontWeight.bold,
                    letterSpacing: 10, color: color)),
            const SizedBox(height: 8),
            Text('Faith · Community · Connection',
                style: TextStyle(fontSize: 13, letterSpacing: 3,
                    color: color.withOpacity(0.6))),
            const SizedBox(height: 48),
            SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                color: color,
                backgroundColor: color.withOpacity(0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}