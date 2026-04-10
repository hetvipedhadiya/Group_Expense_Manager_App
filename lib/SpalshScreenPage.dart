import 'package:aswdc_flutter_pub/aswdc_flutter_pub.dart';
import 'package:flutter/material.dart';
import 'package:grocery/HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'design_system.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3)); // Splash duration

    // Offline-first approach: directly go to Homescreen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Homescreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: DesignSystem.premiumGradient,
        ),
        child: const SplashScreen(
          appLogo: "assets/logo4.png",
          appName: "Group Expense Manager",
          appVersion: "1.9",
        ),
      ),
    );
  }
}