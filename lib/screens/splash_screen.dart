import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'homescreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    // 🌅 Simple fade-in animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // ⏳ Navigate after delay
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 🌄 Calm orange-white gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFE0B2), // soft orange
              Color(0xFFFFFFFF), // white
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeIn,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🕉️ App Logo
                Image.asset(
                  'assets/images/splash_logo.png',
                  height: 120,
                  width: 120,
                ),
                const SizedBox(height: 20),

                // App Title
                Text(
                  "GITA PATH",
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  "Wisdom for the Modern Soul",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
