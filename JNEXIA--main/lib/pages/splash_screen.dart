import 'package:flutter/material.dart';
import 'dart:async';
import 'login_page.dart';
import 'dashboard_page.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Show splash screen for 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    final token = await AuthService.getToken();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => token != null ? const DashboardPage() : const LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.jpeg',
              width: 280,
              height: 280,
            ),
            const SizedBox(height: 24),
            const Text(
              'Campus ++',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Color(0xFF7DD3C0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
