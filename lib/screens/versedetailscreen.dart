import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class VerseDetailScreen extends StatefulWidget {
  final int chapterId;
  const VerseDetailScreen({super.key, required this.chapterId});

  @override
  State<VerseDetailScreen> createState() => _VerseDetailScreenState();
}

class _VerseDetailScreenState extends State<VerseDetailScreen> with TickerProviderStateMixin {
  List<dynamic> verses = [];
  Map<int, Map<String, dynamic>> verseDetails = {};
  bool loading = true;
  int? expandedVerseIndex;
  bool isBookMode = false;
  bool showFullCommentary = true;
  bool showTransliteration = false;
  bool showHindiTranslation = true;  // Changed to true
  bool showHindiCommentary = true;   // Changed to true
  bool showHindiShloka = true;  
  bool isCentralizedHindi = true;  // Add this     

  late PageController _pageController;
  int currentPage = 0;
  
  late AnimationController _breathingController;
  late AnimationController _fadeController;
  late AnimationController _pageTurnController;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSavedState();
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pageTurnController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    loadVerses();
  }

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'chapter_${widget.chapterId}';
    
    setState(() {
      isBookMode = prefs.getBool('${key}_bookMode') ?? false;
      currentPage = prefs.getInt('${key}_currentPage') ?? 0;
    });
    
    _pageController = PageController(
      initialPage: currentPage,
      viewportFraction: 0.95,
    );
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'chapter_${widget.chapterId}';
    
    await prefs.setBool('${key}_bookMode', isBookMode);
    await prefs.setInt('${key}_currentPage', currentPage);
  }

  Future<void> loadVerses() async {
    try {
      var versesList = await ApiService.getChapterVerses(widget.chapterId);
      setState(() {
        verses = versesList;
        loading = false;
      });
      _fadeController.forward();
      
      if (verses.isNotEmpty && currentPage < verses.length) {
        final verseNumber = verses[currentPage]['verse'] ?? (currentPage + 1);
        _fetchVerseDetail(verseNumber);
      }
    } catch (e) {
      print("Error loading verses: $e");
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _fetchVerseDetail(int verseNumber) async {
    if (verseDetails.containsKey(verseNumber)) return;
    
    try {
      final detail = await ApiService.getVerseDetail(widget.chapterId, verseNumber);
      setState(() {
        verseDetails[verseNumber] = detail;
      });
    } catch (e) {
      print("Error fetching verse detail: $e");
    }
  }

  void _toggleViewMode() {
    setState(() {
      isBookMode = !isBookMode;
      if (isBookMode && currentPage < verses.length) {
        final verseNumber = verses[currentPage]['verse'] ?? (currentPage + 1);
        _fetchVerseDetail(verseNumber);
        if (currentPage + 1 < verses.length) {
          final nextVerseNumber = verses[currentPage + 1]['verse'] ?? (currentPage + 2);
          _fetchVerseDetail(nextVerseNumber);
        }
      }
    });
    _saveState();
    HapticFeedback.mediumImpact();
  }

  void _onPageChanged(int page) {
    setState(() {
      currentPage = page;
    });
    _saveState();
    
    if (page + 1 < verses.length) {
      final nextVerseNumber = verses[page + 1]['verse'] ?? (page + 2);
      _fetchVerseDetail(nextVerseNumber);
    }
    
    HapticFeedback.lightImpact();
  }

  void _showJumpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Jump to Verse',
          style: TextStyle(
            color: Colors.brown.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          height: 300,
          width: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: verses.length,
            itemBuilder: (context, index) {
              final isCurrentPage = index == currentPage;
              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isCurrentPage 
                        ? Colors.deepOrange.shade400 
                        : Colors.brown.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.brown.shade300,
                      width: isCurrentPage ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCurrentPage ? Colors.white : Colors.brown.shade800,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStyledVerse(String verse, bool isHindi) {
    List<String> lines = verse.split('\n');
    List<Widget> widgets = [];
    
    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;
      
      // Check if line is a speaker label (for both English and Hindi)
      bool isSpeakerLabel = false;
      
      if (isHindi) {
        // Hindi speaker detection
        isSpeakerLabel = line.contains('उवाच') || 
                        line.contains('धृतराष्ट्र') ||
                        line.contains('श्रीभगवान') ||
                        line.contains('भगवान') ||
                        line.contains('अर्जुन');
      } else {
        // English speaker detection
        isSpeakerLabel = line.toLowerCase().contains('uvāca') || 
                        line.toLowerCase().contains('uvacha') ||
                        line.toLowerCase().contains('sañjaya') ||
                        line.toLowerCase().contains('sanjaya') ||
                        line.toLowerCase().contains('arjuna') ||
                        line.toLowerCase().contains('bhagavān') ||
                        line.toLowerCase().contains('bhagavan') ||
                        line.toLowerCase().contains('dhṛtarāṣṭra') ||
                        line.toLowerCase().contains('dhritarashtra');
      }
      
      widgets.add(
        Text(
          line,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isHindi ? 19 : 16,  // Hindi: 19, English: 16
            color: isSpeakerLabel 
                ? Colors.brown.shade600  // Lighter color for labels
                : Colors.brown.shade900,
            fontWeight: isSpeakerLabel 
                ? FontWeight.w500         // Normal weight for labels
                : FontWeight.w600,        // Bold for actual shloka
            height: isHindi ? 2.0 : 1.6,
            letterSpacing: isHindi ? 0.4 : 0.2,
            fontFamily: isHindi ? 'NotoSerifDevanagari' : null,
            fontStyle: isSpeakerLabel 
                ? FontStyle.italic        // Italic for labels
                : (isHindi ? FontStyle.normal : FontStyle.italic),
          ),
        ),
      );
      
      if (line != lines.last) {
        widgets.add(const SizedBox(height: 4));
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: widgets,
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _fadeController.dispose();
    _pageTurnController.dispose();
    _scrollController.dispose();
    _pageController.dispose();
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
            colors: isBookMode
                ? [
                    const Color(0xFFFFF8E1),
                    const Color(0xFFFFFBF0),
                    const Color(0xFFFFF3CC),
                    const Color(0xFFFFE6B3),
                  ]
                : [
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
              _buildHeader(),
              if (isBookMode && !loading) _buildProgressBar(),
              Expanded(
                child: loading 
                    ? _buildLoadingState() 
                    : (isBookMode ? _buildBookView() : _buildScrollView()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                    fontFamily: 'NotoSerifDevanagari',
                  ),
                ),
                Text(
                  isBookMode 
                      ? 'Verse ${currentPage + 1} of ${verses.length}'
                      : 'Chapter ${widget.chapterId}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          // View Mode Toggle
          GestureDetector(
            onTap: _toggleViewMode,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isBookMode 
                    ? Colors.brown.shade100.withOpacity(0.8)
                    : Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isBookMode 
                      ? Colors.brown.shade300
                      : Colors.orange.shade200,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.shade200.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon(
                  //   isBookMode ? Icons.menu_book : Icons.view_list,
                  //   color: isBookMode ? Colors.brown.shade700 : Colors.deepOrange.shade600,
                  //   size: 20,
                  // ),
                  const SizedBox(width: 1),
                  Text(
                    isBookMode ? '📖' : '📜',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              setState(() {
                isCentralizedHindi = !isCentralizedHindi;
                showHindiShloka = isCentralizedHindi;
                showHindiTranslation = isCentralizedHindi;
                showHindiCommentary = isCentralizedHindi;
              });
              HapticFeedback.mediumImpact();
            },
            child: AnimatedBuilder(
              animation: _breathingController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_breathingController.value * 0.1),
                  child: Container(
                      width: 40, // 🔥 fixed width
                      height: 40, // 🔥 fixed height
                    alignment: Alignment.center, // 🔥 centers content perfectly
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCentralizedHindi 
                          ? Colors.orange.shade100 
                          : Colors.blue.shade100,
                      boxShadow: [
                        BoxShadow(
                          color: (isCentralizedHindi 
                              ? Colors.orange.shade200 
                              : Colors.blue.shade200).withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      isCentralizedHindi ? 'हिं' : 'En',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isCentralizedHindi 
                            ? Colors.deepOrange.shade700 
                            : Colors.blue.shade700,
                        fontFamily: isCentralizedHindi ? 'NotoSansDevanagari' : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = verses.isEmpty ? 0.0 : (currentPage + 1) / verses.length;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      height: 6,
      decoration: BoxDecoration(
        color: Colors.brown.shade100.withOpacity(0.3),
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepOrange.shade400,
                Colors.orange.shade300,
              ],
            ),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.shade300.withOpacity(0.5),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BOOK VIEW MODE
  Widget _buildBookView() {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const BouncingScrollPhysics(),
          itemCount: verses.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                double value = 1.0;
                if (_pageController.position.haveDimensions) {
                  value = _pageController.page! - index;
                  value = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0);
                }
                
                return Center(
                  child: SizedBox(
                    height: Curves.easeInOut.transform(value) * MediaQuery.of(context).size.height * 0.85,
                    child: child,
                  ),
                );
              },
              child: _buildBookPage(index),
            );
          },
        ),
        
        // Page Navigation Arrows
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          left: 0,
          child: currentPage > 0
              ? GestureDetector(
                  onTap: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.shade300.withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.brown.shade700,
                      size: 28,
                    ),
                  ),
                )
              : const SizedBox(),
        ),
        
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          right: 0,
          child: currentPage < verses.length - 1
              ? GestureDetector(
                  onTap: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.shade300.withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.brown.shade700,
                      size: 28,
                    ),
                  ),
                )
              : const SizedBox(),
        ),
        
        // Bookmark Ribbon
        Positioned(
          top: 0,
          right: 60,
          child: Container(
            width: 40,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.red.shade400,
                  Colors.red.shade600,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.shade900.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: CustomPaint(
              painter: BookmarkPainter(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookPage(int index) {
    final verse = verses[index];
    final verseNumber = verse['verse'] ?? (index + 1);
    final cachedDetail = verseDetails[verseNumber];
    
    final sanskritText = cachedDetail?['slok'] ?? '';
    final transliteration = cachedDetail?['transliteration'] ?? '';
    
    // Get translation based on selected language
    // Get both translations
      String englishTranslation = cachedDetail?['siva']?['et'] ?? 
                                cachedDetail?['purohit']?['et'] ?? 
                                cachedDetail?['adi']?['et'] ?? 
                                cachedDetail?['gambir']?['et'] ?? '';

      String hindiTranslation = cachedDetail?['tej']?['ht'] ?? 
                              cachedDetail?['rams']?['ht'] ?? '';

      // Get both commentaries
      String englishCommentary = cachedDetail?['prabhu']?['ec'] ?? '';
      String hindiCommentary = cachedDetail?['chinmay']?['hc'] ?? '';

    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          showFullCommentary = !showFullCommentary;
        });
        HapticFeedback.lightImpact();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF0),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.shade400.withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, 12),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.brown.shade300.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(8, 8),
            ),
          ],
          border: Border.all(
            color: Colors.brown.shade300,
            width: 3,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Stack(
            children: [
              // Paper texture overlay
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.brown.shade50.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
              
              // Content
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(30, 40, 30, 30),
                child: cachedDetail == null 
                  ? _buildBookPageLoading(verseNumber)
                  : _buildBookPageContent(
                      verseNumber, 
                      sanskritText, 
                      transliteration,
                      englishTranslation,
                      hindiTranslation,
                      englishCommentary,
                      hindiCommentary,
                    ),
              ),
              
              // Decorative corner ornaments
              Positioned(
                top: 15,
                left: 15,
                child: _buildCornerOrnament(),
              ),
              Positioned(
                top: 15,
                right: 15,
                child: Transform.rotate(
                  angle: math.pi / 2,
                  child: _buildCornerOrnament(),
                ),
              ),
              Positioned(
                bottom: 15,
                left: 15,
                child: Transform.rotate(
                  angle: -math.pi / 2,
                  child: _buildCornerOrnament(),
                ),
              ),
              Positioned(
                bottom: 15,
                right: 15,
                child: Transform.rotate(
                  angle: math.pi,
                  child: _buildCornerOrnament(),
                ),
              ),
              
              // Page number at bottom center
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showJumpDialog,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.brown.shade100.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.brown.shade300,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Verse ${currentPage + 1} of ${verses.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.brown.shade700,
                          letterSpacing: 0.5,
                        ),
                      ),
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

  Widget _buildCornerOrnament() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.brown.shade400, width: 2),
          top: BorderSide(color: Colors.brown.shade400, width: 2),
        ),
      ),
    );
  }

  Widget _buildBookPageLoading(int verseNumber) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 100),
        Text(
          'Verse $verseNumber',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.brown.shade800,
            fontFamily: null,
          ),
        ),
        const SizedBox(height: 40),
        CircularProgressIndicator(
          color: Colors.brown.shade400,
          strokeWidth: 2,
        ),
        const SizedBox(height: 20),
        Text(
          'Loading divine wisdom...',
          style: TextStyle(
            fontSize: 14,
            color: Colors.brown.shade600,
            fontStyle: FontStyle.italic,
            fontFamily: null,
          ),
        ),
      ],
    );
  }

  Widget _buildBookPageContent(
    int verseNumber,
    String sanskritText,
    String transliteration,
    String englishTranslation,
    String hindiTranslation,
    String englishCommentary,
    String hindiCommentary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Verse number header
        Text(
          '॥ श्लोक $verseNumber ॥',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange.shade700,
            letterSpacing: 2,
            fontFamily: 'NotoSerifDevanagari',
          ),
        ),
        
        const SizedBox(height: 25),
        
        // Decorative divider
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDividerLine(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                Icons.auto_awesome,
                color: Colors.orange.shade400,
                size: 16,
              ),
            ),
            _buildDividerLine(),
          ],
        ),
        
        const SizedBox(height: 25),
        
        // Sanskrit verse
        // Sanskrit verse with transliteration toggle
        if (sanskritText.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade50.withOpacity(0.4),
                  Colors.amber.shade50.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.brown.shade300.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                 _buildStyledVerse(
                    showHindiShloka ? sanskritText : _formatEnglishVerse(transliteration),
                    showHindiShloka,
                  ),
                // if (transliteration.isNotEmpty) ...[
                //   const SizedBox(height: 16),
                //   GestureDetector(
                //     onTap: () {
                //       setState(() {
                //         showTransliteration = !showTransliteration;
                //       });
                //     },
                //     child: Container(
                //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                //       decoration: BoxDecoration(
                //         color: showTransliteration 
                //             ? Colors.deepOrange.shade400 
                //             : Colors.brown.shade100,
                //         borderRadius: BorderRadius.circular(8),
                //         border: Border.all(
                //           color: Colors.brown.shade300,
                //           width: 1,
                //         ),
                //       ),
                //       child: Text(
                //         showTransliteration ? 'Hide' : 'Show',
                //         style: TextStyle(
                //           fontSize: 10,
                //           fontWeight: FontWeight.w600,
                //           color: showTransliteration ? Colors.white : Colors.brown.shade700,
                //         ),
                //       ),
                //     ),
                //   ),
                //   if (showTransliteration) ...[
                //     const SizedBox(height: 12),
                //     Text(
                //       transliteration,
                //       textAlign: TextAlign.center,
                //       style: TextStyle(
                //         fontSize: 14,
                //         color: Colors.brown.shade700,
                //         fontStyle: FontStyle.italic,
                //         height: 1.8,
                //       ),
                //     ),
                //   ],
                // ],
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
        
        // Translation

        if (englishTranslation.isNotEmpty || hindiTranslation.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBookSectionTitle('Translation'),
              Row(
                children: [
                  Text(
                    showHindiTranslation ? 'हिन्दी' : 'English',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.brown.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: showHindiTranslation,
                      onChanged: (value) {
                        setState(() {
                          showHindiTranslation = value;
                        });
                      },
                      activeColor: Colors.deepOrange.shade400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.green.shade50.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.brown.shade200,
                width: 1,
              ),
            ),
            child: Text(
              showHindiTranslation ? hindiTranslation : englishTranslation,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 15,
                color: Colors.brown.shade900,
                height: 1.9,
                fontWeight: FontWeight.w500,
                fontFamily: showHindiTranslation ? 'NotoSerifDevanagari' : null,
              ),
            ),
          ),
          const SizedBox(height: 25),
        ],
        
        // Meaning/Commentary
        // Commentary with toggle
        if ((englishCommentary.isNotEmpty || hindiCommentary.isNotEmpty) && showFullCommentary) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBookSectionTitle('Purport'),
              Row(
                children: [
                  Text(
                    showHindiCommentary ? 'हिन्दी' : 'English',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.brown.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: showHindiCommentary,
                      onChanged: (value) {
                        setState(() {
                          showHindiCommentary = value;
                        });
                      },
                      activeColor: Colors.deepOrange.shade400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(  // ADD THIS
            alignment: Alignment.centerLeft,  // ADD THIS
            child: Text(
              showHindiCommentary 
                  ? '— स्वामी चिन्मयानन्द'
                  : '— A.C. Bhaktivedanta Swami Prabhupada',
              textAlign: TextAlign.left,  // ADD THIS
              style: TextStyle(
                fontSize: 12,
                color: Colors.brown.shade600,
                fontStyle: FontStyle.italic,
                fontFamily: showHindiCommentary ? 'NotoSansDevanagari' : null,
              ),
            ),
          ),  // ADD THIS
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.shade50.withOpacity(0.3),
                  Colors.pink.shade50.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.brown.shade200,
                width: 1,
              ),
            ),
            child: Text(
              showHindiCommentary ? hindiCommentary : englishCommentary,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 15,
                color: Colors.brown.shade800,
                height: 1.9,
                fontFamily: showHindiCommentary ? 'NotoSansDevanagari' : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
            Center(
              child: Text(
                'Double-tap to ${showFullCommentary ? 'hide' : 'show'} commentary',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.brown.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
        
        const SizedBox(height: 30),
        
        // Action buttons
        Row(
          children: [
            Expanded(
              child: _buildBookActionButton(
                icon: Icons.bookmark_border,
                label: 'Save',
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Verse saved to favorites' ,   
                        style: TextStyle(
                          fontFamily: null,
                        ),
                      ),
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
              child: _buildBookActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: () {
                  HapticFeedback.mediumImpact();
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildDividerLine() {
    return Container(
      width: 40,
      height: 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.brown.shade400,
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildBookSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.deepOrange.shade600,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.brown.shade800,
            letterSpacing: 1,
            fontFamily: null,
          ),
        ),
      ],
    );
  }

  Widget _buildBookActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.brown.shade300,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.shade200.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.brown.shade700),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.brown.shade700,
                fontFamily: null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SCROLL VIEW MODE (Original)
  Widget _buildScrollView() {
    return FadeTransition(
      opacity: _fadeController,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 0),
        physics: const BouncingScrollPhysics(),
        itemCount: verses.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildChapterIntro();
          }
          
          final verse = verses[index - 1];
          final isExpanded = expandedVerseIndex == (index - 1);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildVerseCard(verse, index - 1, isExpanded),
          );
        },
      ),
    );
  }

  Widget _buildChapterIntro() {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 10, 20, 16),
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
                  fontFamily: null,
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
                  fontFamily: null,
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
              fontFamily: null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseCard(dynamic verse, int index, bool isExpanded) {
    final verseNumber = verse['verse'] ?? (index + 1);
    final cachedDetail = verseDetails[verseNumber];
    
    final sanskritText = cachedDetail?['slok'] ?? '';
    final transliteration = cachedDetail?['transliteration'] ?? '';
    
    // Get translation based on selected language
    // Get both translations
    String englishTranslation = cachedDetail?['siva']?['et'] ?? 
                              cachedDetail?['purohit']?['et'] ?? 
                              cachedDetail?['adi']?['et'] ?? 
                              cachedDetail?['gambir']?['et'] ?? '';

    String hindiTranslation = cachedDetail?['tej']?['ht'] ?? 
                            cachedDetail?['rams']?['ht'] ?? '';

    // Get both commentaries
    String englishCommentary = cachedDetail?['prabhu']?['ec'] ?? '';
    String hindiCommentary = cachedDetail?['chinmay']?['hc'] ?? '';

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isExpanded) {
            expandedVerseIndex = null;
          } else {
            expandedVerseIndex = index;
            if (cachedDetail == null) {
              _fetchVerseDetail(verseNumber);
            }
          }
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
                            fontFamily: null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isExpanded 
                              ? 'Tap to collapse' 
                              : 'Tap to expand' ,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                            fontFamily: null,
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
              
              if (isExpanded && sanskritText.isNotEmpty) ...[
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
                  child: _buildStyledVerse(sanskritText, true),
                ),
                const SizedBox(height: 16),
              ],
              
              if (isExpanded && cachedDetail == null) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: Colors.deepOrange.shade400,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ],
              
              if (isExpanded && cachedDetail != null)
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
              
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: isExpanded && cachedDetail != null ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    if (transliteration.isNotEmpty) ...[
                      _buildSectionLabel('Transliteration'),
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
                    
                    if (englishTranslation.isNotEmpty || hindiTranslation.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionLabel('Translation'),
                          Row(
                            children: [
                              Text(
                                showHindiTranslation ? 'हिन्दी' : 'English',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.brown.shade600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Transform.scale(
                                scale: 0.7,
                                child: Switch(
                                  value: showHindiTranslation,
                                  onChanged: (value) {
                                    setState(() {
                                      showHindiTranslation = value;
                                    });
                                  },
                                  activeColor: Colors.deepOrange.shade400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                          showHindiTranslation ? hindiTranslation : englishTranslation,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade800,
                            height: 1.6,
                            fontFamily: showHindiTranslation ? 'NotoSerifDevanagari' : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    if (englishCommentary.isNotEmpty || hindiCommentary.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionLabel('Purport'),
                          Row(
                            children: [
                              Text(
                                showHindiCommentary ? 'हिन्दी' : 'English',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.brown.shade600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Transform.scale(
                                scale: 0.7,
                                child: Switch(
                                  value: showHindiCommentary,
                                  onChanged: (value) {
                                    setState(() {
                                      showHindiCommentary = value;
                                    });
                                  },
                                  activeColor: Colors.deepOrange.shade400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        showHindiCommentary 
                            ? '— स्वामी चिन्मयानन्द'
                            : '— A.C. Bhaktivedanta Swami Prabhupada',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.brown.shade600,
                          fontStyle: FontStyle.italic,
                          fontFamily: showHindiCommentary ? 'NotoSansDevanagari' : null,
                        ),
                      ),
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
                        child: Text(
                          showHindiCommentary ? hindiCommentary : englishCommentary,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                            height: 1.7,
                            fontFamily: showHindiCommentary ? 'NotoSansDevanagari' : null,
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                    
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
                                  content: Text(
                                    'Verse saved to favorites', 
                                    style: TextStyle(
                                      fontFamily: null,
                                    ),
                                  ),
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
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ) : const SizedBox.shrink(),
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
            fontFamily: null,
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
                fontFamily: null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatEnglishVerse(String verse) {
  // Split by newlines and process each line
  List<String> lines = verse.split('\n');
  List<String> formattedLines = [];
  
  for (String line in lines) {
    line = line.trim();
    if (line.isEmpty) continue;
    
    // Check if line is a speaker label (ends with ':' or contains 'uvāca'/'uvacha')
    bool isSpeakerLabel = line.endsWith(':') || 
                          line.toLowerCase().contains('uvāca') || 
                          line.toLowerCase().contains('uvacha');
    
    if (isSpeakerLabel) {
      // Keep speaker labels as-is but ensure proper case
      formattedLines.add(line);
    } else {
      // Capitalize first letter of each word in the verse
      List<String> words = line.split(' ');
      List<String> capitalizedWords = words.map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).toList();
      formattedLines.add(capitalizedWords.join(' '));
    }
  }
  
  return formattedLines.join('\n');
}

// Custom painter for bookmark ribbon
class BookmarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.shade700
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height - 10)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}