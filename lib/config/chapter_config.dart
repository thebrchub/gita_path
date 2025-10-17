import 'package:flutter/material.dart';

class ChapterConfig {
  // Chapter themes with colors and image paths
  static List<Map<String, dynamic>> getChapterThemes() {
    return [
      {
        'gradient': [const Color(0xFF6C63FF), const Color(0xFF8B7FFF)],
        'image': 'assets/images/chapters/chapter_1.jpg',
        'essence': 'Arjuna\'s moral dilemma on the battlefield',
        'textBgColor': const Color(0xFF6C63FF).withOpacity(0.85),
      },
      {
        'gradient': [const Color(0xFF00BCD4), const Color(0xFF4DD0E1)],
        'image': 'assets/images/chapters/chapter_2.jpg',
        'essence': 'The eternal soul and path of wisdom',
        'textBgColor': const Color(0xFF00BCD4).withOpacity(0.85),
      },
      {
        'gradient': [const Color(0xFF9C27B0), const Color(0xFFBA68C8)],
        'image': 'assets/images/chapters/chapter_3.jpg',
        'essence': 'Selfless action without attachment',
        'textBgColor': const Color(0xFF9C27B0).withOpacity(0.85),
      },
      {
        'gradient': [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
        'image': 'assets/images/chapters/chapter_4.jpg',
        'essence': 'Divine knowledge and transcendence',
        'textBgColor': const Color(0xFFFF9800).withOpacity(0.85),
      },
      {
        'gradient': [const Color(0xFF4CAF50), const Color(0xFF81C784)],
        'image': 'assets/images/chapters/chapter_5.jpg',
        'essence': 'Renunciation through action',
        'textBgColor': const Color(0xFF4CAF50).withOpacity(0.85),
      },
      {
        'gradient': [const Color(0xFFE91E63), const Color(0xFFF06292)],
        'image': 'assets/images/chapters/chapter_6.jpg',
        'essence': 'Meditation and self-control',
        'textBgColor': const Color(0xFFE91E63).withOpacity(0.85),
      },
      {
        'gradient': [const Color(0xFF3F51B5), const Color(0xFF7986CB)],
        'image': 'assets/images/chapters/chapter_7.jpg',
        'essence': 'Knowledge of the Absolute',
        'textBgColor': const Color(0xFF3F51B5).withOpacity(0.85),
      },
      {
        'gradient': [const Color(0xFFFF5722), const Color(0xFFFF8A65)],
        'image': 'assets/images/chapters/chapter_8.jpg',
        'essence': 'Attaining the Supreme',
        'textBgColor': const Color(0xFFFF5722).withOpacity(0.85),
      },
      {
        'gradient': [const Color(0xFF009688), const Color(0xFF4DB6AC)],
        'image': 'assets/images/chapters/chapter_9.jpg',
        'essence': 'Royal knowledge and secret',
        'textBgColor': const Color(0xFF009688).withOpacity(0.85),
      },
      {
        'gradient': [const Color(0xFF795548), const Color(0xFFA1887F)],
        'image': 'assets/images/chapters/chapter_10.jpg',
        'essence': 'Divine manifestations',
        'textBgColor': const Color(0xFF795548).withOpacity(0.85),
      },
      {
        'gradient': [const Color(0xFF607D8B), const Color(0xFF90A4AE)],
        'image': 'assets/images/chapters/chapter_11.jpg',
        'essence': 'Universal form revealed',
        'textBgColor': const Color(0xFF607D8B).withOpacity(0.85),
      },
      {
        'gradient': [const Color(0xFFFF6F00), const Color(0xFFFFB300)],
        'image': 'assets/images/chapters/chapter_12.jpg',
        'essence': 'Path of devotion',
        'textBgColor': const Color(0xFFFF6F00).withOpacity(0.85),
      },
      {
        'gradient': [const Color(0xFF8E24AA), const Color(0xFFBA68C8)],
        'image': 'assets/images/chapters/chapter_13.jpg',
        'essence': 'Nature, enjoyer and consciousness',
        'textBgColor': const Color(0xFF8E24AA).withOpacity(0.85),
      },
      {
        'gradient': [const Color(0xFF00897B), const Color(0xFF4DB6AC)],
        'image': 'assets/images/chapters/chapter_14.jpg',
        'essence': 'Three modes of nature',
        'textBgColor': const Color(0xFF00897B).withOpacity(0.85),
      },
      {
        'gradient': [const Color(0xFFC62828), const Color(0xFFEF5350)],
        'image': 'assets/images/chapters/chapter_15.jpg',
        'essence': 'Supreme person and eternal tree',
        'textBgColor': const Color(0xFFC62828).withOpacity(0.85),
      },
      {
        'gradient': [const Color(0xFF6A1B9A), const Color(0xFFAB47BC)],
        'image': 'assets/images/chapters/chapter_16.jpg',
        'essence': 'Divine and demonic natures',
        'textBgColor': const Color(0xFF6A1B9A).withOpacity(0.85),
      },
      {
        'gradient': [const Color(0xFF1565C0), const Color(0xFF42A5F5)],
        'image': 'assets/images/chapters/chapter_17.jpg',
        'essence': 'Three types of faith',
        'textBgColor': const Color(0xFF1565C0).withOpacity(0.85),
      },
      {
        'gradient': [const Color(0xFFD84315), const Color(0xFFFF7043)],
        'image': 'assets/images/chapters/chapter_18.jpg',
        'essence': 'Liberation through renunciation',
        'textBgColor': const Color(0xFFD84315).withOpacity(0.85),
      },
    ];
  }

  // Get theme for specific chapter
  static Map<String, dynamic> getThemeForChapter(int index) {
    final themes = getChapterThemes();
    return themes[index % themes.length];
  }
}