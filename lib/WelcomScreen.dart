import 'package:flutter/material.dart';
import 'package:grocery/HomeScreen.dart';
import 'package:grocery/design_system.dart';
import 'package:animate_do/animate_do.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      body: Stack(
        children: [
          // Background Gradient Ornaments
          Positioned(
            top: -100,
            left: -100,
            child: IgnorePointer(
              child: FadeInDown(
                child: Opacity(
                  opacity: 0.05,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: const BoxDecoration(color: DesignSystem.accent, shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  FadeInDown(
                    delay: const Duration(milliseconds: 0),
                    child: Container(
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: DesignSystem.primary,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: DesignSystem.premiumShadow,
                      ),
                      child: const Icon(Icons.account_balance_rounded, size: 40, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 64),
                  FadeInLeft(
                    delay: const Duration(milliseconds: 0),
                    child: Text(
                      "Group Expense\nManager",
                      style: DesignSystem.displayLarge.copyWith(height: 1.1, fontSize: 48),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeInLeft(
                    delay: const Duration(milliseconds: 0),
                    child: Text(
                      "Simple and fast expense tracking for your groups.",
                      style: DesignSystem.bodyLarge.copyWith(color: DesignSystem.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 80),
                  FadeInUp(
                    delay: const Duration(milliseconds: 0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const Homescreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignSystem.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 12,
                          shadowColor: DesignSystem.primary.withOpacity(0.5),
                        ),
                        child: const Text(
                          "Get Started", 
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 1.2)
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  FadeInUp(
                    delay: const Duration(milliseconds: 0),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            "EXPENSE TRACKER",
                            style: DesignSystem.labelMedium.copyWith(letterSpacing: 2.5, color: DesignSystem.textSecondary.withOpacity(0.5)),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
