import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_drawer.dart';
import 'chapterlistscreen.dart';
import 'askkrishnascreen.dart';
import 'donationscreen.dart';
import '../theme/app_theme.dart';
import 'notificationscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _floatingController;
  late AudioPlayer _audioPlayer;
  late ScrollController _scrollController;
  bool _isPlaying = false;
  bool _userWantsAudioOn = false; // MASTER CONTROL - only user can set this
  int currentVerseIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // App going to background or notification slider opened
      // Just pause, don't change user preference
      if (_isPlaying) {
        _audioPlayer.pause();
        if (mounted) setState(() => _isPlaying = false);
      }
    } else if (state == AppLifecycleState.resumed) {
      // App back to foreground - resume ONLY if user wants audio
      if (_userWantsAudioOn) {
        _resumeAudio();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _scrollController = ScrollController();
    
    // CRITICAL: Set audio context to NOT duck other audio
    _audioPlayer = AudioPlayer();
    _audioPlayer.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
          options: [
            AVAudioSessionOptions.mixWithOthers,
          ],
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.none, // KEY: Don't request audio focus
        ),
      ),
    );
    
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    
    // REMOVE onPlayerStateChanged listener completely - it causes issues
    
    WidgetsBinding.instance.addObserver(this);
    _loadAudioPreference();
    currentVerseIndex = Random().nextInt(dailyVerses.length);
  }

  Future<void> _loadAudioPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final hasOpenedBefore = prefs.getBool('hasOpenedBefore') ?? false;
    final isAudioEnabled = prefs.getBool('isAudioEnabled') ?? true;
    
    if (!hasOpenedBefore) {
      await prefs.setBool('hasOpenedBefore', true);
      await prefs.setBool('isAudioEnabled', true);
      _userWantsAudioOn = true;
      _playTanpura();
    } else if (isAudioEnabled) {
      _userWantsAudioOn = true;
      _playTanpura();
    } else {
      _userWantsAudioOn = false;
      setState(() => _isPlaying = false);
    }
  }

  Future<void> _saveAudioPreference(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAudioEnabled', enabled);
  }

  Future<void> _playTanpura() async {
    try {
      await _audioPlayer.setSource(AssetSource('audios/gita_path_app.mp3'));
      await _audioPlayer.setVolume(0.3);
      await _audioPlayer.resume();
      if (mounted) setState(() => _isPlaying = true);
      await _saveAudioPreference(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Audio error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resumeAudio() async {
    try {
      await _audioPlayer.resume();
      if (mounted) setState(() => _isPlaying = true);
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _toggleAudio() async {
    try {
      if (_isPlaying) {
        // User wants to STOP
        _userWantsAudioOn = false;
        await _audioPlayer.pause();
        if (mounted) setState(() => _isPlaying = false);
        await _saveAudioPreference(false);
      } else {
        // User wants to PLAY
        _userWantsAudioOn = true;
        await _playTanpura();
      }
    } catch (e) {
      // Error handling
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _floatingController.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
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
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth: min(MediaQuery.of(context).size.width * 0.7, 360),
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
              // Header
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.menu, color: Colors.deepOrange.shade700, size: 26),
                          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                          tooltip: 'Menu',
                        ),
                        Opacity(
                          opacity: 0.7,
                          child: Text(
                            'श्रीभगवानुवाच',
                            style: AppTheme.devanagari(
                              fontSize: 18,
                              color: Colors.deepOrange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.notifications_outlined, color: Colors.deepOrange.shade700, size: 26),
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => const NotificationScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                                transitionDuration: const Duration(milliseconds: 300),
                              ),
                            );
                          },
                          tooltip: 'Notifications',
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    height: 1,
                    color: Colors.deepOrange.shade100,
                  ),
                ],
              ),

              
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        
                        // Tanpura + Title Section
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
                              // Tanpura with audio toggle
                              GestureDetector(
                                onTap: _toggleAudio,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        (_isPlaying ? Colors.orange : Colors.grey).shade200.withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.3),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (_isPlaying ? Colors.orange : Colors.grey)
                                                .shade200
                                                .withOpacity(0.4),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipOval(
                                          child: ColorFiltered(
                                            colorFilter: _isPlaying
                                                ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                                                : const ColorFilter.matrix(<double>[
                                                    0.2126, 0.7152, 0.0722, 0, 0,
                                                    0.2126, 0.7152, 0.0722, 0, 0,
                                                    0.2126, 0.7152, 0.0722, 0, 0,
                                                    0, 0, 0, 1, 0,
                                                  ]),
                                            child: Transform.scale(
                                              scale: 1.2,
                                              child: Image.asset(
                                                'assets/images/tanpura.png',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 8),
                              
                              Text(
                                _isPlaying ? 'Tanpura Playing' : 'Tanpura Paused',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _isPlaying ? Colors.deepOrange.shade600 : Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Main title
                              Text(
                                '॥ श्रीमद्भगवद्गीता ॥',
                                style: AppTheme.devanagari(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.deepOrange.shade800,
                                ).copyWith(
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
                        
                        const SizedBox(height: 32),
                        
                        // Daily Verse Card
                        _buildDailyVerseCard(currentVerse),
                        
                        const SizedBox(height: 32),
                        
                        // Action Cards Grid
                        _buildActionCards(context),
                        
                        const SizedBox(height: 32),
                        
                        // Bottom reflection message
                        _buildReflectionCard(),
                        
                        const SizedBox(height: 30),
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

  Widget _buildDailyVerseCard(Map<String, String> currentVerse) {
    return Container(
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
          Text(
            currentVerse['sanskrit']!,
            textAlign: TextAlign.center,
            style: AppTheme.devanagari(
              fontSize: 16,
              color: Colors.deepOrange.shade900,
              fontWeight: FontWeight.w500,
              height: 1.6,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
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
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return GridView.count(
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
    );
  }

  Widget _buildReflectionCard() {
    return Container(
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
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
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
}