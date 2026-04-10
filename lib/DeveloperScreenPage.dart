import 'package:flutter/material.dart';
import 'package:aswdc_flutter_pub/aswdc_flutter_pub.dart';

class DeveloperScreenPage extends StatelessWidget {
  const DeveloperScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Theme(
        data: Theme.of(context).copyWith(
          appBarTheme: Theme.of(context).appBarTheme.copyWith(
                iconTheme: const IconThemeData(color: Colors.white),
              ),
        ),
        child: DeveloperScreen(
          developerName: 'Hetvi Pedhadiya',
          mentorName: 'Prof. Rajkumar Gondaliya',
          exploredByName: 'ASWDC',
          isAdmissionApp: false,
          isDBUpdate: false,
          shareMessage: '',
          appTitle: 'Group Expense Manager',
          appLogo: 'assets/logo4.png',
        ),
      ),
    );
  }
}
