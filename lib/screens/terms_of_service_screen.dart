import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
                          '1. Acceptance of Terms',
                          'By downloading, installing, or using the GitaPath app, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the app.',
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          '2. Use of the App',
                          'GitaPath is designed to provide access to the sacred text of Bhagavad Gita. You agree to:\n\n'
                          '• Use the app for personal, non-commercial purposes\n'
                          '• Respect the spiritual nature of the content\n'
                          '• Not attempt to reverse engineer or modify the app\n'
                          '• Not use the app for any unlawful purpose',
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          '3. Intellectual Property',
                          'The app and its original content, features, and functionality are owned by Blazing Render Creation Hub LLP and are protected by international copyright, trademark, and other intellectual property laws.',
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          '4. User Accounts',
                          'If you create an account with us, you are responsible for:\n\n'
                          '• Maintaining the security of your account\n'
                          '• All activities that occur under your account\n'
                          '• Notifying us of any unauthorized use',
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          '5. Content Disclaimer',
                          'The spiritual teachings and interpretations provided in this app are for educational purposes. While we strive for accuracy, we do not guarantee the completeness or reliability of any content.',
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          '6. Donations',
                          'Any donations made through the app are voluntary and non-refundable. Donations support the maintenance and development of the app.',
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          '7. Premium Features',
                          'Some features may require a premium subscription. Subscription fees are non-refundable except as required by law.',
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          '8. Limitation of Liability',
                          'To the fullest extent permitted by law, Blazing Render Creation Hub LLP shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the app.',
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          '9. Changes to Terms',
                          'We reserve the right to modify these terms at any time. We will notify users of any material changes through the app or via email.',
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          '10. Termination',
                          'We may terminate or suspend your access to the app immediately, without prior notice, for any breach of these Terms.',
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          '11. Governing Law',
                          'These Terms shall be governed by and construed in accordance with the laws of India, without regard to its conflict of law provisions.',
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          '12. Contact Information',
                          'For any questions about these Terms of Service, please contact us at:\n\n'
                          'Email: legal@gitapath.com\n'
                          'Company: Blazing Render Creation Hub LLP',
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
  return const CustomHeader(title: 'Terms of Service');
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