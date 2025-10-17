import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  int? expandedIndex;

  final List<Map<String, String>> faqs = [
    {
      'question': 'How do I navigate through the chapters?',
      'answer': 'Tap on the "Study Gita" card from the home screen to see all 18 chapters. Tap on any chapter to view its verses.',
    },
    {
      'question': 'Can I bookmark my favorite verses?',
      'answer': 'Yes! While reading any verse, tap the bookmark icon to save it to your favorites for quick access later.',
    },
    {
      'question': 'How does the Krishna AI feature work?',
      'answer': 'The Ask Krishna feature uses AI to provide guidance based on the teachings of Bhagavad Gita. Simply ask your question and receive wisdom-based responses.',
    },
    {
      'question': 'How do I turn off the Tanpura sound?',
      'answer': 'Tap the Tanpura icon on the home screen to pause or play the background music. Your preference is automatically saved.',
    },
    {
      'question': 'Can I read offline?',
      'answer': 'Yes! Once you\'ve loaded the chapters, you can read them offline. However, the Krishna AI feature requires an internet connection.',
    },
    {
      'question': 'How do I change the language?',
      'answer': 'Go to Settings from the menu and select your preferred language. We support English, Hindi, Sanskrit, and Tamil.',
    },
    {
      'question': 'What are daily notifications?',
      'answer': 'You can enable daily verse notifications to receive Krishna\'s wisdom every morning. Configure this in Settings > Notifications.',
    },
    {
      'question': 'Is the app completely free?',
      'answer': 'The app is free to use with all core features. Some premium features like advanced AI interactions may require a subscription.',
    },
    {
      'question': 'How do I make a donation?',
      'answer': 'Tap the "Support" card from the home screen. Your contribution helps us maintain and improve the app.',
    },
    {
      'question': 'Can I share verses with friends?',
      'answer': 'Yes! When viewing any verse, tap the share icon to send it via WhatsApp, email, or other apps.',
    },
    {
      'question': 'How do I report a bug?',
      'answer': 'Go to Contact Us from the menu and select "Report Bugs". Our team will investigate and fix issues promptly.',
    },
    {
      'question': 'What if I forget my password?',
      'answer': 'On the login screen, tap "Forgot Password" and follow the instructions to reset it via email.',
    },
    {
      'question': 'How is my data protected?',
      'answer': 'We take privacy seriously. Most data is stored locally on your device. Read our Privacy Policy for detailed information.',
    },
    {
      'question': 'Can I suggest new features?',
      'answer': 'Absolutely! We love hearing from users. Go to Contact Us > Feature Requests to share your ideas.',
    },
    {
      'question': 'Which devices are supported?',
      'answer': 'GitaPath works on Android 6.0+ and iOS 12.0+ devices. We recommend keeping your OS updated for the best experience.',
    },
  ];

  final List<Map<String, String>> userGuides = [
    {
      'title': 'Getting Started',
      'description': 'Learn the basics of navigating the app and exploring the Bhagavad Gita.',
    },
    {
      'title': 'Reading Verses',
      'description': 'Tips for a better reading experience, including bookmarks and notes.',
    },
    {
      'title': 'Using Krishna AI',
      'description': 'How to ask meaningful questions and get the most from AI guidance.',
    },
    {
      'title': 'Customizing Your Experience',
      'description': 'Personalize themes, fonts, notifications, and more in Settings.',
    },
  ];

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchCard(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('User Guides'),
                      const SizedBox(height: 12),
                      ...userGuides.map((guide) => _buildGuideCard(guide)),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Frequently Asked Questions'),
                      const SizedBox(height: 12),
                      ...faqs.asMap().entries.map((entry) {
                        return _buildFaqItem(
                          entry.key,
                          entry.value['question']!,
                          entry.value['answer']!,
                        );
                      }).toList(),
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
  return const CustomHeader(title: 'Help & FAQ');
}


  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.deepOrange.shade600, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Search for help...',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.deepOrange.shade800,
      ),
    );
  }

  Widget _buildGuideCard(Map<String, String> guide) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to detailed guide
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${guide['title']} guide - Coming soon!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.menu_book, color: Colors.blue.shade600, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guide['title']!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        guide['description']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(int index, String question, String answer) {
    final isExpanded = expandedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? Colors.deepOrange.withOpacity(0.3)
              : Colors.white.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              expandedIndex = isExpanded ? null : index;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        question,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.remove_circle_outline : Icons.add_circle_outline,
                      color: Colors.deepOrange.shade600,
                      size: 22,
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      answer,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}