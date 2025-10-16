import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import 'login_screen.dart';
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
    print('🚀 Splash screen initialized');

    // 🌅 Simple fade-in animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // ⏳ Navigate after delay
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    print('⏳ Starting 3 second delay...');
    await Future.delayed(const Duration(seconds: 3));
    print('✅ Delay complete!');

    if (!mounted) {
      print('❌ Widget not mounted, canceling navigation');
      return;
    }

    try {
      print('📦 Getting SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      
      print('🔐 Is logged in: $isLoggedIn');

      if (mounted) {
        print('🧭 Navigating to ${isLoggedIn ? "HomeScreen" : "LoginScreen"}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => isLoggedIn 
                ? const HomeScreen() 
                : const LoginScreen(),
          ),
        );
        print('✅ Navigation complete!');
      } else {
        print('❌ Widget unmounted before navigation');
      }
    } catch (e, stackTrace) {
      print('❌ ERROR: $e');
      print('Stack trace: $stackTrace');
      
      // Fallback: try to navigate to login screen anyway
      if (mounted) {
        print('🔄 Attempting fallback navigation to LoginScreen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    print('🗑️ Splash screen disposed');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 Building splash screen');
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
                  errorBuilder: (context, error, stackTrace) {
                    print('❌ Image load error: $error');
                    return Icon(
                      Icons.auto_awesome,
                      size: 120,
                      color: Colors.deepOrange,
                    );
                  },
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

                const SizedBox(height: 40),

                // Loading indicator
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFFFF9800),
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