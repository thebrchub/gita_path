import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/custom_header.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

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
                  child: Column(
                    children: [
                      _buildWelcomeCard(),
                      const SizedBox(height: 20),
                      _buildContactCard(
                        icon: Icons.email_outlined,
                        title: 'Email Support',
                        subtitle: 'Get help from our support team',
                        description: 'support@gitapath.com',
                        color: Colors.blue,
                        onTap: () => _launchEmail('support@gitapath.com'),
                      ),
                      const SizedBox(height: 16),
                      _buildContactCard(
                        icon: Icons.bug_report_outlined,
                        title: 'Report Bugs',
                        subtitle: 'Help us improve the app',
                        description: 'bugs@gitapath.com',
                        color: Colors.red,
                        onTap: () => _launchEmail('bugs@gitapath.com'),
                      ),
                      const SizedBox(height: 16),
                      _buildContactCard(
                        icon: Icons.lightbulb_outline,
                        title: 'Feature Requests',
                        subtitle: 'Share your ideas with us',
                        description: 'features@gitapath.com',
                        color: Colors.amber,
                        onTap: () => _launchEmail('features@gitapath.com'),
                      ),
                    ],
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
  return const CustomHeader(title: 'Contact Us');
}


  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.support_agent,
            size: 48,
            color: Colors.deepOrange.shade600,
          ),
          const SizedBox(height: 12),
          Text(
            'We\'re Here to Help',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Have questions or suggestions? We\'d love to hear from you!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=GitaPath App Support',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }
}