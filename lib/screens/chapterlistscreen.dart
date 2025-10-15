import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'versedetailscreen.dart';

class ChapterListScreen extends StatefulWidget {
  const ChapterListScreen({super.key});

  @override
  State<ChapterListScreen> createState() => _ChapterListScreenState();
}

class _ChapterListScreenState extends State<ChapterListScreen> with SingleTickerProviderStateMixin {
  List<dynamic> chapters = [];
  bool loading = true;
  late AnimationController _breathingController;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    loadChapters();
  }

  Future<void> loadChapters() async {
    try {
      var data = await ApiService.getChapters();
      setState(() {
        chapters = data;
        loading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
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
              // Custom Header (STATIC - stays at top)
              _buildHeader(),
              
              // Chapters List (Now includes the shloka card inside scroll)
              Expanded(
                child: loading
                    ? _buildLoadingState()
                    : Column(
                        children: [
                          // Move the shloka card INSIDE the scrollable area
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.only(top: 0), // Remove top padding
                              physics: const BouncingScrollPhysics(),
                              itemCount: chapters.length + 1, // +1 for the shloka card
                              itemBuilder: (context, index) {
                                // First item is the shloka card
                                if (index == 0) {
                                  return _buildInspirationCard();
                                }
                                // Rest are chapter cards
                                final ch = chapters[index - 1]; // Adjust index
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: _buildChapterCard(ch, index - 1),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.deepOrange.shade700),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '18 अध्याय',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.deepOrange.shade800,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'The Eighteen Chapters',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          // Peaceful Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.self_improvement,
              color: Colors.deepOrange.shade400,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspirationCard() {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_breathingController.value * 0.02),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade100.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.format_quote,
                  color: Colors.deepOrange.shade300,
                  size: 28,
                ),
                const SizedBox(height: 12),
                Text(
                  'योगस्थः कुरु कर्माणि',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepOrange.shade900,
                    letterSpacing: 0.8,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 1,
                  width: 40,
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
                const SizedBox(height: 8),
                Text(
                  '"Established in yoga, perform action"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.5),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.deepOrange.shade400,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading sacred wisdom...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterCard(dynamic chapter, int index) {
    final chapterNumber = chapter['chapter_number'] ?? (index + 1);
    final name = chapter['name'] ?? 'Unknown';
    final translation = chapter['translation'] ?? '';
    final meaning = chapter['meaning']?['en'] ?? '';
    
    // Colors for different chapters - creating a peaceful palette
    final colors = _getChapterColors(index);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    VerseDetailScreen(chapterId: chapterNumber),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chapter Number Circle
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$chapterNumber',
                      style: const TextStyle(
                        fontFamily: 'NotoSerifDevanagari',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Chapter Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        translation,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.95),
                          height: 1.3,
                        ),
                      ),
                      if (meaning.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          meaning.length > 80 
                              ? '${meaning.substring(0, 80)}...' 
                              : meaning,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.85),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Arrow Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getChapterColors(int index) {
    final colorSets = [
      [const Color(0xFF6C63FF), const Color(0xFF8B7FFF)], // Purple
      [const Color(0xFF00BCD4), const Color(0xFF4DD0E1)], // Cyan
      [const Color(0xFF9C27B0), const Color(0xFFBA68C8)], // Deep Purple
      [const Color(0xFFFF9800), const Color(0xFFFFB74D)], // Orange
      [const Color(0xFF4CAF50), const Color(0xFF81C784)], // Green
      [const Color(0xFFE91E63), const Color(0xFFF06292)], // Pink
      [const Color(0xFF3F51B5), const Color(0xFF7986CB)], // Indigo
      [const Color(0xFFFF5722), const Color(0xFFFF8A65)], // Deep Orange
      [const Color(0xFF009688), const Color(0xFF4DB6AC)], // Teal
    ];
    
    return colorSets[index % colorSets.length];
  }
}