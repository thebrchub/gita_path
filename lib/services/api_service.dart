import 'dart:convert';
import '../config/api_key.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Using bhagavadgita.io API (free tier)
  static const String baseUrl = "https://bhagavadgita.io/api/v1";
  static const String apiKey = "YOUR_API_KEY_HERE"; // Get from bhagavadgita.io
  
  // Alternative: Use bhagavadgitaapi.in (no API key needed)
  static const String altBaseUrl = "https://bhagavadgitaapi.in";

  // Get all 18 chapters
  static Future<List<dynamic>> getChapters() async {
    const String url = "https://bhagavad-gita3.p.rapidapi.com/v2/chapters/?skip=0&limit=18";
    const Map<String, String> headers = {
      "x-rapidapi-host": "bhagavad-gita3.p.rapidapi.com",
      "x-rapidapi-key": "df18d817b0mshac874949a6a54bdp15a01bjsn18889ceba92a",
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception("Failed to load chapters: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching chapters: $e");
      return _getMockChapters();
    }
  }


  static Future<List<dynamic>> _getChaptersAlternative(String language) async {
    try {
      final response = await http.get(
        Uri.parse("$altBaseUrl/chapters/"),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to load chapters');
      }
    } catch (e) {
      print("Alternative API also failed: $e");
      // Return mock data as last resort
      return _getMockChapters();
    }
  }

  // Get verses for a specific chapter
  static Future<List<dynamic>> getVerses(int chapterId) async {
    final String url =
        "https://bhagavad-gita3.p.rapidapi.com/v2/chapters/$chapterId/verses/";
    const Map<String, String> headers = {
      "x-rapidapi-host": "bhagavad-gita3.p.rapidapi.com",
      "x-rapidapi-key": ApiKeys.rapidApiKey,

    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception("Failed to load verses: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching verses: $e");
      return _getMockVerses(chapterId);
    }
  }


  static Future<List<dynamic>> _getVersesAlternative(int chapterId, String language) async {
    try {
      final response = await http.get(
        Uri.parse("$altBaseUrl/chapter/$chapterId/"),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Transform data structure to match expected format
        final List<dynamic> verses = [];
        for (int i = 1; i <= (data['verses_count'] ?? 0); i++) {
          verses.add({
            'verse_number': i,
            'text': 'Loading verse $i...',
            'meaning': 'Meaning will be loaded',
          });
        }
        return verses;
      } else {
        throw Exception('Failed to load verses');
      }
    } catch (e) {
      print("Alternative verses API failed: $e");
      return _getMockVerses(chapterId);
    }
  }

  // Get specific verse details
  static Future<Map<String, dynamic>> getVerseDetail(
    int chapterId,
    int verseNumber,
    {String language = 'en'}
  ) async {
    try {
      final response = await http.get(
        Uri.parse("$altBaseUrl/slok/$chapterId/$verseNumber/"),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load verse detail');
      }
    } catch (e) {
      print("Error fetching verse detail: $e");
      return {};
    }
  }

  // Mock data for offline/fallback
  static List<dynamic> _getMockChapters() {
    return [
      {
        'chapter_number': 1,
        'name': 'Arjuna Vishada Yoga',
        'translation': 'The Yoga of Arjuna\'s Dejection',
        'verses_count': 47,
        'meaning': 'Chapter 1 describes how Arjuna is overcome with grief and confusion before the battle.',
      },
      {
        'chapter_number': 2,
        'name': 'Sankhya Yoga',
        'translation': 'The Yoga of Knowledge',
        'verses_count': 72,
        'meaning': 'Krishna begins his teachings about the eternal soul and the path of wisdom.',
      },
      {
        'chapter_number': 3,
        'name': 'Karma Yoga',
        'translation': 'The Yoga of Action',
        'verses_count': 43,
        'meaning': 'Krishna explains the importance of performing one\'s duty without attachment.',
      },
      {
        'chapter_number': 4,
        'name': 'Jnana Karma Sanyasa Yoga',
        'translation': 'The Yoga of Knowledge and Renunciation',
        'verses_count': 42,
        'meaning': 'Krishna reveals his divine nature and the path of renunciation through knowledge.',
      },
      {
        'chapter_number': 5,
        'name': 'Karma Sanyasa Yoga',
        'translation': 'The Yoga of Renunciation',
        'verses_count': 29,
        'meaning': 'The path of renunciation and its relationship with action is discussed.',
      },
      {
        'chapter_number': 6,
        'name': 'Dhyana Yoga',
        'translation': 'The Yoga of Meditation',
        'verses_count': 47,
        'meaning': 'Krishna teaches the practice and benefits of meditation.',
      },
      {
        'chapter_number': 7,
        'name': 'Jnana Vijnana Yoga',
        'translation': 'The Yoga of Knowledge and Wisdom',
        'verses_count': 30,
        'meaning': 'The nature of God and different paths to reach Him are explained.',
      },
      {
        'chapter_number': 8,
        'name': 'Aksara Brahma Yoga',
        'translation': 'The Yoga of the Imperishable Brahman',
        'verses_count': 28,
        'meaning': 'Krishna discusses the nature of God and attaining Him at death.',
      },
      {
        'chapter_number': 9,
        'name': 'Raja Vidya Raja Guhya Yoga',
        'translation': 'The Yoga of Royal Knowledge and Secret',
        'verses_count': 34,
        'meaning': 'The most confidential knowledge of devotion is revealed.',
      },
      {
        'chapter_number': 10,
        'name': 'Vibhuti Yoga',
        'translation': 'The Yoga of Divine Glories',
        'verses_count': 42,
        'meaning': 'Krishna describes his divine manifestations and opulences.',
      },
      {
        'chapter_number': 11,
        'name': 'Visvarupa Darsana Yoga',
        'translation': 'The Yoga of the Universal Form',
        'verses_count': 55,
        'meaning': 'Arjuna witnesses Krishna\'s cosmic universal form.',
      },
      {
        'chapter_number': 12,
        'name': 'Bhakti Yoga',
        'translation': 'The Yoga of Devotion',
        'verses_count': 20,
        'meaning': 'The path of devotion and qualities of a devotee are explained.',
      },
      {
        'chapter_number': 13,
        'name': 'Ksetra Ksetrajna Vibhaga Yoga',
        'translation': 'The Yoga of Distinction between Field and Knower',
        'verses_count': 35,
        'meaning': 'The difference between the body and the soul is described.',
      },
      {
        'chapter_number': 14,
        'name': 'Gunatraya Vibhaga Yoga',
        'translation': 'The Yoga of the Three Modes of Nature',
        'verses_count': 27,
        'meaning': 'The three modes of material nature are explained.',
      },
      {
        'chapter_number': 15,
        'name': 'Purusottama Yoga',
        'translation': 'The Yoga of the Supreme Person',
        'verses_count': 20,
        'meaning': 'Krishna reveals himself as the Supreme Personality.',
      },
      {
        'chapter_number': 16,
        'name': 'Daivasura Sampad Vibhaga Yoga',
        'translation': 'The Yoga of Divine and Demoniac Qualities',
        'verses_count': 24,
        'meaning': 'The difference between divine and demonic natures is discussed.',
      },
      {
        'chapter_number': 17,
        'name': 'Sraddhatraya Vibhaga Yoga',
        'translation': 'The Yoga of Three Types of Faith',
        'verses_count': 28,
        'meaning': 'The three types of faith and their manifestations are explained.',
      },
      {
        'chapter_number': 18,
        'name': 'Moksa Sanyasa Yoga',
        'translation': 'The Yoga of Liberation and Renunciation',
        'verses_count': 78,
        'meaning': 'Krishna concludes with the path to liberation and complete surrender.',
      },
    ];
  }

  static List<dynamic> _getMockVerses(int chapterId) {
    // Return placeholder verses
    return List.generate(
      10,
      (index) => {
        'verse_number': index + 1,
        'text': 'Sanskrit verse text ${index + 1}',
        'transliteration': 'Transliteration ${index + 1}',
        'meaning': 'This is the meaning of verse ${index + 1} from chapter $chapterId. Full content will be loaded when online.',
      },
    );
  }

  // AI Integration (for future use)
  static Future<String> getAIResponse(String question, {String language = 'en'}) async {
    // TODO: Integrate Gemini API
    // Example endpoint structure:
    /*
    final response = await http.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent'),
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': 'YOUR_GEMINI_API_KEY',
      },
      body: jsonEncode({
        'contents': [{
          'parts': [{
            'text': 'You are Krishna from Bhagavad Gita. Answer this question based on Gita\'s teachings: $question'
          }]
        }]
      }),
    );
    */
    
    // For now, return mock response
    return "This is a placeholder AI response. Gemini API will be integrated soon!";
  }
}