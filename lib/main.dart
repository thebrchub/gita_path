import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const GitaAIApp());
}

class GitaAIApp extends StatelessWidget {
  const GitaAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gita Path',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Use centralized theme
      home: const SplashScreen(),
    );
  }
}
