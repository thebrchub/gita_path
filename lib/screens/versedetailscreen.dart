import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';


class VerseDetailScreen extends StatefulWidget {
  final int chapterId;
  const VerseDetailScreen({super.key, required this.chapterId});

  @override
  State<VerseDetailScreen> createState() => _VerseDetailScreenState();
}

class _VerseDetailScreenState extends State<VerseDetailScreen> with TickerProviderStateMixin {
  List<dynamic> verses = [];
  bool loading = true;
  int? expandedVerseIndex;
  late AnimationController _breathingController;
  late AnimationController _fadeController;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    loadVerses();
  }

  Future<void> loadVerses() async {
    try {
      var data = await ApiService.getVerses(widget.chapterId);
      setState(() {
        verses = data;
        loading = false;
      });
      _fadeController.forward();
    } catch (e) {
      print("Error loading verses: $e");
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _fadeController.dispose();
    _scrollController.dispose();
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
              _buildHeader(),  // This stays static
              Expanded(
                child: loading ? _buildLoadingState() : _buildVersesList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: Colors.deepOrange.shade700, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'अध्याय ${widget.chapterId}',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.deepOrange.shade800,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Chapter ${widget.chapterId}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _breathingController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_breathingController.value * 0.1),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.shade200.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.self_improvement,
                    color: Colors.deepOrange.shade400,
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChapterIntro() {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 10, 20, 16), // Keep horizontal, adjust vertical
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
                Icons.auto_awesome,
                color: Colors.deepOrange.shade300,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                'Listen with your heart',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepOrange.shade900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Each verse is a gift from Krishna',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ],
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
          AnimatedBuilder(
            animation: _breathingController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_breathingController.value * 0.15),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.shade200.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.deepOrange.shade400,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Unveiling divine wisdom...',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersesList() {
    return FadeTransition(
      opacity: _fadeController,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 0), // Remove vertical padding
        physics: const BouncingScrollPhysics(),
        itemCount: verses.length + 1, // +1 for the intro card
        itemBuilder: (context, index) {
          // First item is the intro card
          if (index == 0) {
            return _buildChapterIntro();
          }
          
          // Rest are verse cards
          final verse = verses[index - 1]; // Adjust index
          final isExpanded = expandedVerseIndex == (index - 1);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildVerseCard(verse, index - 1, isExpanded),
          );
        },
      ),
    );
  }

  Widget _buildVerseCard(dynamic verse, int index, bool isExpanded) {
    final verseNumber = verse['verse_number'] ?? (index + 1);
    final sanskritText = verse['text'] ?? '';
    final transliteration = verse['transliteration'] ?? '';
    final translation = verse['translation'] ?? '';
    final meaning = verse['meaning'] ?? 'No meaning available';
    
    // Extract English meaning if it's a map
    String meaningText = meaning;
    if (meaning is Map) {
      meaningText = meaning['en'] ?? meaning['english'] ?? 'No meaning available';
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          expandedVerseIndex = isExpanded ? null : index;
        });
        if (!isExpanded) {
          HapticFeedback.lightImpact();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isExpanded
                ? [
                    Colors.white.withOpacity(0.8),
                    Colors.orange.shade50.withOpacity(0.8),
                  ]
                : [
                    Colors.white.withOpacity(0.6),
                    Colors.white.withOpacity(0.5),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isExpanded 
                ? Colors.deepOrange.shade200.withOpacity(0.5)
                : Colors.white.withOpacity(0.4),
            width: isExpanded ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isExpanded 
                  ? Colors.orange.shade200.withOpacity(0.4)
                  : Colors.grey.shade200.withOpacity(0.3),
              blurRadius: isExpanded ? 20 : 12,
              offset: Offset(0, isExpanded ? 10 : 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepOrange.shade400,
                          Colors.orange.shade300,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.shade300.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$verseNumber',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verse $verseNumber',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange.shade800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isExpanded ? 'Tap to collapse' : 'Tap to expand',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.deepOrange.shade400,
                      size: 28,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Sanskrit Text
              if (sanskritText.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.shade100,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    sanskritText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepOrange.shade900,
                      fontWeight: FontWeight.w600,
                      height: 1.8,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Divider
              Center(
                child: Container(
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
              ),
              
              // Expanded Content
              AnimatedCrossFade(
                firstChild: const SizedBox(height: 12),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Transliteration
                    if (transliteration.isNotEmpty) ...[
                      _buildSectionLabel('Pronunciation'),
                      const SizedBox(height: 8),
                      Text(
                        transliteration,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Translation
                    if (translation.isNotEmpty) ...[
                      _buildSectionLabel('Translation'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.shade100,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          translation,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade800,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Meaning/Commentary
                    _buildSectionLabel('Krishna\'s Teaching'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.purple.shade50.withOpacity(0.5),
                            Colors.pink.shade50.withOpacity(0.4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.purple.shade100,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.format_quote,
                            color: Colors.purple.shade300,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              meaningText,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade800,
                                height: 1.7,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.bookmark_border,
                            label: 'Save',
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Verse saved to favorites'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Colors.green.shade400,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.share_outlined,
                            label: 'Share',
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              // Share functionality
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                  ],
                ),
                crossFadeState: isExpanded 
                    ? CrossFadeState.showSecond 
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.deepOrange.shade400,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange.shade700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.deepOrange.shade200,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.deepOrange.shade600),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.deepOrange.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}