import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Call this when user taps "Sign in with Google"
  static Future<bool> signInAndSendTokenToBackend() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false; // user cancelled

      final auth = await googleUser.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('No idToken from Google');

      // send token to your backend
      final resp = await http.post(
        Uri.parse('https://your-backend.com/api/auth/google-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final backendJwt = body['token']; // whatever your backend returns
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', backendJwt);
        // you can also store user profile fields returned by backend
        return true;
      } else {
        // handle backend rejection
        print('Backend rejected token: ${resp.statusCode} ${resp.body}');
        return false;
      }
    } catch (e) {
      print('Google sign in error: $e');
      return false;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
