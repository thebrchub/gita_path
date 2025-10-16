import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Using VedicScriptures API (no API key needed)
  static const String baseUrl = "https://vedicscriptures.github.io";

  // Get all 18 chapters
  static Future<List<dynamic>> getChapters() async {
    // VedicScriptures doesn't have a /chapters/ endpoint
    // We'll return mock data for chapters list
    // But you can fetch individual chapters from /chapter/{id}/
    return _getMockChapters();
  }

  // Get specific chapter details
  static Future<Map<String, dynamic>> getChapter(int chapterId) async {
    final String url = "$baseUrl/chapter/$chapterId/";

    try {
      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load chapter: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching chapter: $e");
      return {};
    }
  }

  // Get specific verse details with all translations
  static Future<Map<String, dynamic>> getVerseDetail(
    int chapterId,
    int verseNumber,
  ) async {
    final String url = "$baseUrl/slok/$chapterId/$verseNumber/";
    
    try {
      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load verse detail');
      }
    } catch (e) {
      print("Error fetching verse detail: $e");
      return {
        'slok': 'Unable to load verse',
        'transliteration': '',
        'tej': {
          'ht': 'Please check your internet connection and try again.'
        },
      };
    }
  }

  // Get all verses for a chapter (helper method)
  static Future<List<Map<String, dynamic>>> getChapterVerses(int chapterId) async {
    try {
      // First get chapter info to know verse count
      final chapter = await getChapter(chapterId);
      final verseCount = chapter['verses_count'] ?? 0;
      
      // Return verse list without fetching all (for performance)
      return List.generate(
        verseCount,
        (index) => {
          'verse': index + 1,
          'chapter': chapterId,
        },
      );
    } catch (e) {
      print("Error generating verses list: $e");
      return [];
    }
  }

  // Mock data for chapters list (since API doesn't provide all chapters endpoint)
  static List<dynamic> _getMockChapters() {
    return [
      {
        'chapter_number': 1,
        'name': 'अर्जुनविषादयोग',
        'translation': 'Arjuna Visada Yoga',
        'transliteration': 'Arjun Viṣhād Yog',
        'verses_count': 47,
        'meaning': {
          'en': 'Arjuna\'s Dilemma',
          'hi': 'अर्जुन विषाद योग'
        },
      },
      {
        'chapter_number': 2,
        'name': 'सांख्ययोग',
        'translation': 'Sankhya Yoga',
        'transliteration': 'Sānkhya Yog',
        'verses_count': 72,
        'meaning': {
          'en': 'Transcendental Knowledge',
          'hi': 'सांख्य योग'
        },
      },
      {
        'chapter_number': 3,
        'name': 'कर्मयोग',
        'translation': 'Karma Yoga',
        'transliteration': 'Karm Yog',
        'verses_count': 43,
        'meaning': {
          'en': 'Path of Action',
          'hi': 'कर्म योग'
        },
      },
      {
        'chapter_number': 4,
        'name': 'ज्ञानकर्मसंन्यासयोग',
        'translation': 'Jnana Karma Sanyasa Yoga',
        'transliteration': 'Jñāna Karm Sanyās Yog',
        'verses_count': 42,
        'meaning': {
          'en': 'Path of Knowledge and Renunciation',
          'hi': 'ज्ञान कर्म संन्यास योग'
        },
      },
      {
        'chapter_number': 5,
        'name': 'कर्मसंन्यासयोग',
        'translation': 'Karma Sanyasa Yoga',
        'transliteration': 'Karm Sanyās Yog',
        'verses_count': 29,
        'meaning': {
          'en': 'Path of Renunciation',
          'hi': 'कर्म संन्यास योग'
        },
      },
      {
        'chapter_number': 6,
        'name': 'आत्मसंयमयोग',
        'translation': 'Atma Samyama Yoga',
        'transliteration': 'Dhyān Yog',
        'verses_count': 47,
        'meaning': {
          'en': 'Path of Meditation',
          'hi': 'ध्यान योग'
        },
      },
      {
        'chapter_number': 7,
        'name': 'ज्ञानविज्ञानयोग',
        'translation': 'Jnana Vijnana Yoga',
        'transliteration': 'Jñāna Vijñāna Yog',
        'verses_count': 30,
        'meaning': {
          'en': 'Path of Knowledge and Wisdom',
          'hi': 'ज्ञान विज्ञान योग'
        },
      },
      {
        'chapter_number': 8,
        'name': 'अक्षरब्रह्मयोग',
        'translation': 'Aksara Brahma Yoga',
        'transliteration': 'Akṣhar Brahma Yog',
        'verses_count': 28,
        'meaning': {
          'en': 'Path to the Supreme',
          'hi': 'अक्षर ब्रह्म योग'
        },
      },
      {
        'chapter_number': 9,
        'name': 'राजविद्याराजगुह्ययोग',
        'translation': 'Raja Vidya Raja Guhya Yoga',
        'transliteration': 'Rāj Vidyā Yog',
        'verses_count': 34,
        'meaning': {
          'en': 'Sovereign Science and Sovereign Secret',
          'hi': 'राज विद्या योग'
        },
      },
      {
        'chapter_number': 10,
        'name': 'विभूतियोग',
        'translation': 'Vibhuti Yoga',
        'transliteration': 'Vibhūti Yog',
        'verses_count': 42,
        'meaning': {
          'en': 'Divine Glories',
          'hi': 'विभूति योग'
        },
      },
      {
        'chapter_number': 11,
        'name': 'विश्वरूपदर्शनयोग',
        'translation': 'Vishvarupa Darshana Yoga',
        'transliteration': 'Viśhwarūp Darśhan Yog',
        'verses_count': 55,
        'meaning': {
          'en': 'Vision of the Universal Form',
          'hi': 'विश्वरूप दर्शन योग'
        },
      },
      {
        'chapter_number': 12,
        'name': 'भक्तियोग',
        'translation': 'Bhakti Yoga',
        'transliteration': 'Bhakti Yog',
        'verses_count': 20,
        'meaning': {
          'en': 'Path of Devotion',
          'hi': 'भक्ति योग'
        },
      },
      {
        'chapter_number': 13,
        'name': 'क्षेत्रक्षेत्रज्ञविभागयोग',
        'translation': 'Ksetra Ksetrajna Vibhaga Yoga',
        'transliteration': 'Kṣhetra Kṣhetrajña Vibhāg Yog',
        'verses_count': 35,
        'meaning': {
          'en': 'Distinction between Field and Knower',
          'hi': 'क्षेत्र क्षेत्रज्ञ विभाग योग'
        },
      },
      {
        'chapter_number': 14,
        'name': 'गुणत्रयविभागयोग',
        'translation': 'Gunatraya Vibhaga Yoga',
        'transliteration': 'Guṇa Traya Vibhāg Yog',
        'verses_count': 27,
        'meaning': {
          'en': 'Three Modes of Material Nature',
          'hi': 'गुण त्रय विभाग योग'
        },
      },
      {
        'chapter_number': 15,
        'name': 'पुरुषोत्तमयोग',
        'translation': 'Purusottama Yoga',
        'transliteration': 'Puruṣhottam Yog',
        'verses_count': 20,
        'meaning': {
          'en': 'Path of the Supreme Person',
          'hi': 'पुरुषोत्तम योग'
        },
      },
      {
        'chapter_number': 16,
        'name': 'दैवासुरसंपद्विभागयोग',
        'translation': 'Daivasura Sampad Vibhaga Yoga',
        'transliteration': 'Daivāsura Sampad Vibhāg Yog',
        'verses_count': 24,
        'meaning': {
          'en': 'Divine and Demoniac Natures',
          'hi': 'दैवासुर संपद विभाग योग'
        },
      },
      {
        'chapter_number': 17,
        'name': 'श्रद्धात्रयविभागयोग',
        'translation': 'Sraddhatraya Vibhaga Yoga',
        'transliteration': 'Śhraddhā Traya Vibhāg Yog',
        'verses_count': 28,
        'meaning': {
          'en': 'Three Divisions of Faith',
          'hi': 'श्रद्धा त्रय विभाग योग'
        },
      },
      {
        'chapter_number': 18,
        'name': 'मोक्षसंन्यासयोग',
        'translation': 'Moksa Sanyasa Yoga',
        'transliteration': 'Mokṣha Sanyās Yog',
        'verses_count': 78,
        'meaning': {
          'en': 'Path of Liberation and Renunciation',
          'hi': 'मोक्ष संन्यास योग'
        },
      },
    ];
  }

  // AI Integration placeholder
  static Future<String> getAIResponse(String question) async {
    // TODO: Integrate Gemini API
    return "This is a placeholder AI response. Gemini API will be integrated soon!";
  }
}