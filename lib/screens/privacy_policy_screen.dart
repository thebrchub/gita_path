import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFF5E6),
              const Color(0xFFFFE4CC),
              const Color(0xFFE3F2FD),
              const Color(0xFFBBDEFB),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          'Last Updated',
                          'October 17, 2025',
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          '1. Information We Collect',
                          'We collect minimal information necessary to provide you with the best experience:\n\n'
                          '• Device information for app functionality\n'
                          '• Usage data to improve our services\n'
                          '• Preferences and settings you customize\n'
                          '• Bookmarked verses and reading history (stored locally)',
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          '2. How We Use Your Information',
                          'Your information is used to:\n\n'
                          '• Provide and maintain the app\n'
                          '• Personalize your experience\n'
                          '• Send notifications (if enabled)\n'
                          '• Improve app features and performance\n'
                          '• Respond to your support requests',
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          '3. Data Storage',
                          'Most of your data is stored locally on your device. We do not sell, rent, or share your personal information with third parties for marketing purposes.',
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          '4. Third-Party Services',
                          'We may use third-party services like:\n\n'
                          '• Analytics to understand app usage\n'
                          '• Cloud services for data backup (optional)\n'
                          '• Notification services for daily verses\n\n'
                          'These services have their own privacy policies.',
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          '5. Your Rights',
                          'You have the right to:\n\n'
                          '• Access your data\n'
                          '• Delete your data\n'
                          '• Opt-out of notifications\n'
                          '• Request data portability',
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          '6. Children\'s Privacy',
                          'Our app is designed for all ages. We do not knowingly collect personal information from children under 13 without parental consent.',
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          '7. Security',
                          'We implement appropriate security measures to protect your information. However, no method of transmission over the internet is 100% secure.',
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          '8. Changes to This Policy',
                          'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy in the app.',
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          '9. Contact Us',
                          'If you have questions about this Privacy Policy, please contact us at:\n\n'
                          'Email: privacy@gitapath.com',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
  return const CustomHeader(title: 'Privacy Policy');
}


  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}