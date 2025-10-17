import 'package:flutter/material.dart';
import 'dart:io';
import '../config/chapter_config.dart';
import '../screens/versedetailscreen.dart';

class ChapterCard extends StatelessWidget {
  final dynamic chapter;
  final int index;

  const ChapterCard({
    super.key,
    required this.chapter,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final chapterNumber = chapter['chapter_number'] ?? (index + 1);
    final name = chapter['name'] ?? 'Unknown';
    final translation = chapter['translation'] ?? '';
    
    final theme = ChapterConfig.getThemeForChapter(index);
    final gradient = theme['gradient'] as List<Color>;
    final imagePath = theme['image'] as String;
    final essence = theme['essence'] as String;
    final textBgColor = theme['textBgColor'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 180, // Fixed height for consistency
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Image with gradient overlay
            Positioned.fill(
              child: _buildImageBackground(imagePath, gradient),
            ),

            // Content overlay
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _navigateToChapter(context, chapterNumber),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top section: Chapter number
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildChapterNumber(chapterNumber),
                            _buildArrowIcon(),
                          ],
                        ),

                        // Bottom section: Text details
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildChapterName(name),
                            const SizedBox(height: 4),
                            _buildTranslation(translation, textBgColor),
                            const SizedBox(height: 6),
                            _buildEssence(essence),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageBackground(String imagePath, List<Color> gradient) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image with error handling
        Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to gradient if image not found
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
              ),
            );
          },
        ),
        
        // Dark gradient overlay for text readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.7),
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChapterNumber(int number) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '$number',
          style: const TextStyle(
            fontFamily: 'NotoSerifDevanagari',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildArrowIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.white.withOpacity(0.9),
      ),
    );
  }

  Widget _buildChapterName(String name) {
    return Text(
      name,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
        shadows: [
          Shadow(
            color: Colors.black26,
            offset: Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTranslation(String translation, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        translation,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.2,
          letterSpacing: 0.3,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEssence(String essence) {
    return Text(
      essence,
      style: TextStyle(
        fontSize: 11,
        color: Colors.white.withOpacity(0.9),
        height: 1.3,
        fontStyle: FontStyle.italic,
        shadows: const [
          Shadow(
            color: Colors.black38,
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  void _navigateToChapter(BuildContext context, int chapterNumber) {
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
  }
}