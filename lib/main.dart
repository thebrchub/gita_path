import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'theme/colors.dart';

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
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.bg,
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
    );
  }
}
