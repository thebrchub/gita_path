import 'package:flutter/material.dart';
import 'dart:math';
import '../theme/colors.dart';
import 'chapterlistscreen.dart';
import 'askkrishnascreen.dart';
import 'donationscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _floatingController;
  int currentVerseIndex = 0;

  // Collection of daily wisdom quotes from Gita
  final List<Map<String, String>> dailyVerses = [
    {
      'text': 'You have the right to work, but never to the fruit of work.',
      'reference': 'Bhagavad Gita 2.47',
      'sanskrit': 'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन'
    },
    {
      'text': 'When meditation is mastered, the mind is unwavering like the flame of a lamp in a windless place.',
      'reference': 'Bhagavad Gita 6.19',
      'sanskrit': 'यथा दीपो निवातस्थो नेङ्गते'
    },
    {
      'text': 'The soul is neither born, and nor does it die.',
      'reference': 'Bhagavad Gita 2.20',
      'sanskrit': 'न जायते म्रियते वा कदाचित्'
    },
    {
      'text': 'Set thy heart upon thy work, but never on its reward.',
      'reference': 'Bhagavad Gita 2.47',
      'sanskrit': 'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन'
    },
    {
      'text': "I am seated in everyone's heart, and from Me come memory, knowledge and forgetfulness.",
      'reference': 'Bhagavad Gita 15.15',
      'sanskrit': 'सर्वस्य चाहं हृदि सन्निविष्टः'
    },
    {
      'text': 'One who sees inaction in action, and action in inaction, is intelligent among humans.',
      'reference': 'Bhagavad Gita 4.18',
      'sanskrit': 'कर्मण्यकर्म यः पश्येत्'
    },
    {
      'text': 'The humble sages, by virtue of true knowledge, see with equal vision.',
      'reference': 'Bhagavad Gita 5.18',
      'sanskrit': 'विद्याविनयसम्पन्ने'
    },
    {
      'text': 'Perform your obligatory duty, because action is indeed better than inaction.',
      'reference': 'Bhagavad Gita 3.8',
      'sanskrit': 'नियतं कुरु कर्म त्वं'
    },
  ];

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    // Randomize initial verse
    currentVerseIndex = Random().nextInt(dailyVerses.length);
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  void _changeVerse() {
    setState(() {
      currentVerseIndex = (currentVerseIndex + 1) % dailyVerses.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentVerse = dailyVerses[currentVerseIndex];
    
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Top bar with Sanskrit text and language icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Opacity(
                        opacity: 0.6,
                        child: Text(
                          'श्रीभगवानुवाच',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.deepOrange.shade700,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.language, color: Colors.deepOrange.shade700),
                        onPressed: () => _showLanguageDialog(context),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Hero section with floating animation
                  AnimatedBuilder(
                    animation: _floatingController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 8 * sin(_floatingController.value * 2 * pi)),
                        child: child,
                      );
                    },
                    child: Column(
                      children: [
                        // Krishna symbol with glow effect
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.orange.shade200.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.shade200.withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.auto_awesome,
                                size: 40,
                                color: Colors.deepOrange.shade400,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Main title
                        Text(
                          '॥ श्रीमद्भगवद्गीता ॥',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange.shade800,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: Colors.white.withOpacity(0.5),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'The Eternal Song of the Lord',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Daily Verse Card (Glassmorphic)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.shade200.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Krishna Speaks',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepOrange.shade700,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.refresh, color: Colors.deepOrange.shade600),
                              onPressed: _changeVerse,
                              tooltip: 'New Verse',
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Sanskrit verse
                        Text(
                          currentVerse['sanskrit']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.deepOrange.shade900,
                            fontWeight: FontWeight.w500,
                            height: 1.6,
                            letterSpacing: 0.5,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Divider
                        Container(
                          height: 1,
                          width: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.orange.shade300,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // English translation
                        Text(
                          '"${currentVerse['text']}"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.grey.shade800,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Reference
                        Text(
                          '— ${currentVerse['reference']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Action Cards Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.95,
                    children: [
                      _buildActionCard(
                        context,
                        icon: Icons.menu_book_rounded,
                        title: 'Study Gita',
                        subtitle: '18 Chapters\n700 Verses',
                        gradientColors: [Color(0xFF6C63FF), Color(0xFF8B7FFF)],
                        screen: const ChapterListScreen(),
                      ),
                      _buildActionCard(
                        context,
                        icon: Icons.psychology_rounded,
                        title: 'Ask Krishna',
                        subtitle: 'AI Guidance\nfor Life',
                        gradientColors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                        screen: const AskKrishnaScreen(),
                        isPremium: true,
                      ),
                      _buildActionCard(
                        context,
                        icon: Icons.volunteer_activism_rounded,
                        title: 'Support',
                        subtitle: 'Contribute to\nDharma',
                        gradientColors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                        screen: const DonationScreen(),
                      ),
                      _buildActionCard(
                        context,
                        icon: Icons.bookmark_rounded,
                        title: 'Favorites',
                        subtitle: 'Your Saved\nVerses',
                        gradientColors: [Color(0xFF00BCD4), Color(0xFF4DD0E1)],
                        screen: null,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Bottom reflection message
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
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
                          size: 28,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Close your eyes. Take a breath.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You are not alone — Krishna walks with you.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required Widget? screen,
    bool isPremium = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (screen != null) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => screen,
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Coming soon!'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              backgroundColor: Colors.deepOrange.shade400,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Subtle pattern overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 32),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            
            if (isPremium)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final languages = [
      {'name': 'English', 'code': 'en', 'native': 'English'},
      {'name': 'Hindi', 'code': 'hi', 'native': 'हिन्दी'},
      {'name': 'Sanskrit', 'code': 'sa', 'native': 'संस्कृत'},
      {'name': 'Tamil', 'code': 'ta', 'native': 'தமிழ்'},
    ];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange.shade50,
                Colors.blue.shade50,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange.shade800,
                ),
              ),
              const SizedBox(height: 20),
              ...languages.map((lang) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white),
                  ),
                  child: ListTile(
                    title: Text(
                      lang['native']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      lang['name']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${lang['native']} selected'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}