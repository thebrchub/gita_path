import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'homescreen.dart';
import '../services/google_auth_service.dart';
import '../services/api_service.dart';
import 'user_details_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return; // Prevent double-tap
    
    setState(() => _isLoading = true);

    try {
      final success = await GoogleAuthService.signInAndSendTokenToBackend();

      if (!mounted) return;

      if (success) {
        _showSuccessAndNavigate();
      } else {
        _showError('Sign-in was cancelled or failed. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('An unexpected error occurred. Please check your connection.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessAndNavigate() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Welcome! Signing you in...'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(milliseconds: 1500),
      ),
    );

    // Navigate to home screen
    Future.delayed(const Duration(milliseconds: 800), () async {
      if (mounted) {
        try {
          final userData = await ApiService.getUserProfile();
          
          // Check if profile is complete
          
          bool isProfileComplete = userData['name'] != null && 
                                  userData['name'].toString().isNotEmpty &&
                                  userData['dob'] != null;
          
          if (isProfileComplete) {
            // Existing user - go to home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else {
            // New user - go to user details screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UserDetailsScreen()),
            );
          }
        } catch (e) {
          // If API fails, assume new user
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserDetailsScreen()),
          );
        }
      }
    });
  }

  void _handleSkip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFF5E6), // Soft saffron
              const Color(0xFFFFE4CC),
              const Color(0xFFE3F2FD), // Pale blue
              const Color(0xFFBBDEFB),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // App Logo with glow effect
                  _buildAppLogo(),

                  const SizedBox(height: 32),

                  // App Title
                  _buildAppTitle(),

                  const Spacer(flex: 2),

                  // Welcome message
                  _buildWelcomeCard(),

                  const SizedBox(height: 40),

                  // Google Sign In Button
                  _buildGoogleSignInButton(),

                  const SizedBox(height: 16),

                  // Skip Button
                  _buildSkipButton(),

                  const Spacer(),

                  // Terms and Privacy
                  _buildTermsText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.orange.shade200.withOpacity(0.4),
            Colors.transparent,
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.3),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.shade200.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(103, 255, 86, 34)
                      .withAlpha((255 * 0.4).toInt()),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/app_logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback icon if logo not found
                  return Icon(
                    Icons.auto_stories,
                    size: 40,
                    color: Colors.deepOrange.shade700,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppTitle() {
    return Column(
      children: [
        Text(
          '॥ श्रीमद्भगवद्गीता ॥',
          style: TextStyle(
            fontFamily: 'NotoSerifDevanagari',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.deepOrange.shade800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'GITA PATH',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange.shade700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Wisdom for Life\'s Every Question',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade700,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.spa_rounded,
            color: Colors.green.shade400,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Welcome, Seeker',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to unlock AI guidance, save your favorite verses, and personalize your spiritual journey',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey.shade800,
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/google_logo.png',
                    height: 24,
                    width: 24,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if image not found
                      return Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return TextButton(
      onPressed: _isLoading ? null : _handleSkip,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
      ),
      child: Text(
        'Skip for now',
        style: TextStyle(
          fontSize: 15,
          color: _isLoading ? Colors.grey.shade400 : Colors.grey.shade700,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        'By continuing, you agree to our Terms of Service\nand Privacy Policy',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade600,
          height: 1.4,
        ),
      ),
    );
  }
}