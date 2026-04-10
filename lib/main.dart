import 'package:flutter/material.dart';
import 'package:grocery/design_system.dart';
import 'package:grocery/SpalshScreenPage.dart';
import 'package:grocery/database/database_helper.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database; // Initialize DB on startup
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Group Expense Manager',
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme).copyWith(
          displayLarge: DesignSystem.displayLarge,
          headlineSmall: DesignSystem.headlineSmall,
          titleLarge: DesignSystem.titleLarge,
          bodyLarge: DesignSystem.bodyLarge,
          labelMedium: DesignSystem.labelMedium,
        ),
        scaffoldBackgroundColor: DesignSystem.background,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false, // Editorial style often uses left-aligned titles
          titleTextStyle: DesignSystem.headlineSmall.copyWith(color: DesignSystem.textPrimary),
          iconTheme: const IconThemeData(color: DesignSystem.primary),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: DesignSystem.primary,
          primary: DesignSystem.primary,
          secondary: DesignSystem.secondary,
          tertiary: DesignSystem.tertiary,
          surface: DesignSystem.surface,
          onPrimary: DesignSystem.textWhite,
          outlineVariant: DesignSystem.outlineVariant,
        ),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignSystem.primary,
            foregroundColor: DesignSystem.textWhite,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: DesignSystem.borderRadius,
            ),
            elevation: 0,
            textStyle: DesignSystem.labelMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: DesignSystem.textWhite,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: false, // Editorial style: no bounding box
          border: const UnderlineInputBorder(
            borderSide: BorderSide(color: DesignSystem.outlineVariant, width: 1),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: DesignSystem.outlineVariant, width: 1),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: DesignSystem.primary, width: 2),
          ),
          labelStyle: DesignSystem.labelMedium,
          floatingLabelStyle: DesignSystem.labelMedium.copyWith(color: DesignSystem.primary),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        dividerTheme: const DividerThemeData(
          color: Colors.transparent, // Editorial style: strictly forbid dividers
          space: 24,
        ),
      ),
      home: const SplashScreenPage(),
    );
  }
}
