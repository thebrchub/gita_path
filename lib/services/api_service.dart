import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'google_auth_service.dart';

class ApiService {
  // VedicScriptures API base URL (for Gita content)
  static const String vedicScripturesBaseUrl = "https://vedicscriptures.github.io";
  
  // Backend API base URL (for user and AI endpoints)
  static const String backendBaseUrl = "https://sbga.brchub.me";

  // ============================================================================
  // VEDIC SCRIPTURES APIs (Bhagavad Gita Content)
  // ============================================================================

  // Get all 18 chapters
  static Future<List<dynamic>> getChapters() async {
    // VedicScriptures doesn't have a /chapters/ endpoint
    // We'll return mock data for chapters list
    // But you can fetch individual chapters from /chapter/{id}/
    return _getMockChapters();
  }

  // Get specific chapter details
  static Future<Map<String, dynamic>> getChapter(int chapterId) async {
    final String url = "$vedicScripturesBaseUrl/chapter/$chapterId/";

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
    final String url = "$vedicScripturesBaseUrl/slok/$chapterId/$verseNumber/";
    
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

  // ============================================================================
  // USER RESOURCE APIs
  // ============================================================================

  /// Login with Google ID token
  /// POST /v1/user/login
  static Future<Map<String, dynamic>> login(String idToken) async {
    final String url = "$backendBaseUrl/v1/user/login";
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Login failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Error during login: $e");
      rethrow;
    }
  }

  /// Get user profile
  /// GET /v1/user
  static Future<Map<String, dynamic>> getUserProfile() async {
    final String url = "$backendBaseUrl/v1/user";
    
    try {
      final token = await GoogleAuthService.getAuthToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      rethrow;
    }
  }

  /// Update user profile
  /// Note: The OpenAPI spec doesn't show a PUT/PATCH endpoint for user updates
  /// Keeping this method for backward compatibility, but may need adjustment
  static Future<bool> updateUserProfile(Map<String, dynamic> profileData) async {
    final String url = "$backendBaseUrl/v1/user";
    
    try {
      final token = await GoogleAuthService.getAuthToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      // Try PATCH first
      http.Response response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(profileData),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }

      if (response.statusCode == 405) {
        // Try PUT as fallback
        print('PATCH returned 405; trying PUT.');
        response = await http.put(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(profileData),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 201) {
          return true;
        }
      }

      print('Failed to update profile. Status: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Failed to update profile: ${response.statusCode}');
    } catch (e) {
      print("Error updating user profile: $e");
      rethrow;
    }
  }

  // ============================================================================
  // AI RESOURCE APIs
  // ============================================================================

  /// Create a new AI chat session with an initial query
  /// POST /v1/ai/new
  /// Returns AISession with sessionId, title, response, and createdAt
  static Future<Map<String, dynamic>> createNewAISession(String query) async {
    final String url = "$backendBaseUrl/v1/ai/new";
    
    try {
      final token = await GoogleAuthService.getAuthToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'query': query,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create AI session: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Error creating AI session: $e");
      rethrow;
    }
  }

  /// Get all AI chat sessions for the current user
  /// GET /v1/ai
  /// Returns list of AISession objects with sessionId, title, createdAt
  static Future<List<dynamic>> getAISessions() async {
    final String url = "$backendBaseUrl/v1/ai";
    
    try {
      final token = await GoogleAuthService.getAuthToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to load AI sessions: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Error fetching AI sessions: $e");
      rethrow;
    }
  }

  /// Get chat history for a specific session
  /// GET /v1/ai/{sessionId}
  /// Returns list of AIResponse objects with query, response, and createdAt
  static Future<List<dynamic>> getSessionHistory(String sessionId) async {
    final String url = "$backendBaseUrl/v1/ai/$sessionId";
    
    try {
      final token = await GoogleAuthService.getAuthToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to load session history: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Error fetching session history: $e");
      rethrow;
    }
  }

  /// Send a new message to an existing AI session (streaming endpoint)
  /// POST /v1/ai/{sessionId}
  /// Returns Stream<String> for real-time responses
  static Future<Stream<String>> sendMessageToSession(String sessionId, String query) async {
    final String url = "$backendBaseUrl/v1/ai/$sessionId";
    
    try {
      final token = await GoogleAuthService.getAuthToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final request = http.Request('POST', Uri.parse(url));
      request.headers.addAll(headers);
      request.body = jsonEncode({
        'query': query,
      });

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));

      if (streamedResponse.statusCode == 201 || streamedResponse.statusCode == 200) {
        return streamedResponse.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter());
      } else {
        final responseBody = await streamedResponse.stream.bytesToString();
        throw Exception('Failed to send message: ${streamedResponse.statusCode} - $responseBody');
      }
    } catch (e) {
      print("Error sending message to session: $e");
      rethrow;
    }
  }

  /// Convenience method: Send message and get complete response (non-streaming)
  /// Use this if you want to wait for the full response before displaying
  static Future<String> sendMessageToSessionComplete(String sessionId, String query) async {
    try {
      final stream = await sendMessageToSession(sessionId, query);
      final buffer = StringBuffer();
      
      await for (final chunk in stream) {
        buffer.write(chunk);
      }
      
      return buffer.toString();
    } catch (e) {
      print("Error getting complete message response: $e");
      rethrow;
    }
  }

  // ============================================================================
  // HELPER METHODS FOR AI
  // ============================================================================

  /// Create a new session and get the session ID (for starting a new chat)
  static Future<String> startNewChat(String initialMessage) async {
    try {
      final session = await createNewAISession(initialMessage);
      return session['sessionId'] as String;
    } catch (e) {
      print("Error starting new chat: $e");
      rethrow;
    }
  }

  /// Get all previous chat sessions with titles and dates
  static Future<List<Map<String, dynamic>>> getChatHistory() async {
    try {
      final sessions = await getAISessions();
      return sessions.map((session) => session as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error getting chat history: $e");
      return [];
    }
  }

  /// Deprecated: Use createNewAISession() and sendMessageToSession() instead
  @Deprecated('Use createNewAISession() and sendMessageToSession() instead')
  static Future<String> getAIResponse(String question) async {
    try {
      final session = await createNewAISession(question);
      return session['response'] ?? 'No response received';
    } catch (e) {
      print("Error getting AI response: $e");
      return "Failed to get response. Please try again.";
    }
  }
}