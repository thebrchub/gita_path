import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GoogleAuthService {
  // ✅ Using Google Cloud Console (without Firebase)
  // The serverClientId should be your WEB client ID
  // This tells Google to return an ID token that your backend can verify
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '1027752902149-8ioibofpd5659m9jve63me8fu4f0g3uq.apps.googleusercontent.com',
  );

  /// Signs in with Google and sends ID token to backend
  /// Returns true if successful, false otherwise
  static Future<bool> signInAndSendTokenToBackend() async {
    final startTime = DateTime.now();
    try {
      // 1️⃣ Trigger Google Sign-In flow
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('ℹ️ User cancelled Google Sign-In');
        return false; // User cancelled
      }
        final stopwatch = Stopwatch()..start();

      // 2️⃣ Get authentication tokens from Google
      final auth = await googleUser.authentication;
      final idToken = auth.idToken;
      
      if (idToken == null) {
        throw Exception('No idToken received from Google');
      }

      // 🧪 DEBUG: Print and copy token BEFORE making API call
      print('✅ Got Google ID token!');
      print('🔑 ID Token (first 50 chars): ${idToken.substring(0, 50)}...');
      
      // Copy to clipboard immediately
      await Clipboard.setData(ClipboardData(text: 'Bearer $idToken'));
      print('📋 Token copied to clipboard!');

      // Persist basic Google profile locally so the app can show a profile
      // even if the backend has not yet stored a user profile.
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', googleUser.displayName ?? '');
        await prefs.setString('user_email', googleUser.email);
        // googleUser.photoUrl can be null
        if (googleUser.photoUrl != null) {
          await prefs.setString('user_photo', googleUser.photoUrl!);
        }
      } catch (e) {
        print('Failed to persist google profile locally: $e');
      }
      
  print('🌐 Sending to backend...');

      // 3️⃣ Send token to your backend for verification
      final resp = await http.post(
        Uri.parse('https://sbga.brchub.me/v1/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏰ Backend request timed out');
          throw Exception('Backend request timed out');
        },
      );

      // 4️⃣ Handle backend response
      // 4️⃣ Handle backend response
print('📥 Backend response: ${resp.statusCode}');

  if (resp.statusCode == 200) {
  final body = jsonDecode(resp.body);
  final backendJwt = body['accessToken']; // ✅ Changed from 'token' to 'accessToken'
  final refreshToken = body['refreshToken']; // Get refresh token too
  
  if (backendJwt == null || backendJwt.isEmpty) {
    throw Exception('Backend returned empty accessToken');
  }

  print('✅ Backend JWT received!');

  // 5️⃣ Store tokens locally
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', backendJwt);
  await prefs.setString('refresh_token', refreshToken ?? ''); // Store refresh token

  // 🧪 TEMP: Copy BACKEND token to clipboard
  await Clipboard.setData(ClipboardData(text: 'Bearer $backendJwt'));
  print('📋 Backend JWT copied to clipboard (remove this before production)');
  print('✅ Login successful!');

  // Optional: Store user profile data
            // Persist any backend-provided user fields (if present)
            if (body.containsKey('user')) {
              final user = body['user'];
              await prefs.setString('user_name', user['name'] ?? googleUser.displayName ?? '');
              await prefs.setString('user_email', user['email'] ?? googleUser.email);
              if ((user['profilePicture'] ?? '') != '') {
                await prefs.setString('user_photo', user['profilePicture']);
              } else if (googleUser.photoUrl != null) {
                await prefs.setString('user_photo', googleUser.photoUrl!);
              }
              if ((user['dob'] ?? '') != '') {
                await prefs.setString('user_dob', user['dob']);
              }
              if ((user['about'] ?? '') != '') {
                await prefs.setString('user_about', user['about']);
              }
              if (user.containsKey('pro')) {
                try {
                  await prefs.setBool('user_pro', user['pro'] == true);
                } catch (_) {}
              }
            }
  if (body.containsKey('user')) {
    final user = body['user'];
    await prefs.setString('user_name', user['name'] ?? '');
    await prefs.setString('user_email', user['email'] ?? '');
    if (user.containsKey('profilePicture') && user['profilePicture'] != null) {
      await prefs.setString('user_photo', user['profilePicture']);
            stopwatch.stop();
            print('⏱️ Login flow completed in ${stopwatch.elapsedMilliseconds} ms');
    }
    if (user.containsKey('dob') && user['dob'] != null) {
      await prefs.setString('user_dob', user['dob']);
    }
    if (user.containsKey('about') && user['about'] != null) {
      await prefs.setString('user_about', user['about']);
    }
    // store pro flag as bool
    if (user.containsKey('pro')) {
      try {
        await prefs.setBool('user_pro', user['pro'] == true);
      } catch (_) {}
    }
  }

  print('✅ Login successful! (took ${DateTime.now().difference(startTime).inMilliseconds} ms)');

  return true;
      } else {
        print('❌ Backend rejected token: ${resp.statusCode}');
        print('Response: ${resp.body}');
        print('Login failed (took ${DateTime.now().difference(startTime).inMilliseconds} ms)');
        return false;
      }
    } on SocketException catch (e) {
      print('❌ Network error: No internet connection or DNS failure');
      print('Details: $e');
      print('Login errored (took ${DateTime.now().difference(startTime).inMilliseconds} ms)');
      return false;
    } on TimeoutException catch (e) {
      print('❌ Request timed out: Backend took too long to respond');
      print('Details: $e');
      print('Login timed out (took ${DateTime.now().difference(startTime).inMilliseconds} ms)');
      return false;
    } on PlatformException catch (e) {
      print('❌ Platform error during Google Sign-In: ${e.message}');
      print('Login errored (took ${DateTime.now().difference(startTime).inMilliseconds} ms)');
      return false;
    } on http.ClientException catch (e) {
      print('❌ HTTP Client error: $e');
      print('Login errored (took ${DateTime.now().difference(startTime).inMilliseconds} ms)');
      return false;
    } catch (e, stackTrace) {
      print('❌ Google sign in error: $e');
      print('Stack trace: $stackTrace');
      print('Login errored (took ${DateTime.now().difference(startTime).inMilliseconds} ms)');
      return false;
    }
  }

  /// Sign out from Google and clear local auth data
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      print('✅ Signed out successfully');
    } catch (e) {
      print('❌ Error during sign out: $e');
    }
  }

  /// Check if user is currently signed in
  static Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }

  /// Get stored auth token
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Decode JWT payload (no signature verification) and return claims map
  static Map<String, dynamic>? _parseJwt(String token) {
    try {
      // Remove Bearer if present
      final raw = token.startsWith('Bearer ') ? token.substring(7) : token;
      final parts = raw.split('.');
      if (parts.length != 3) return null;

      String payload = parts[1];
      // Normalize base64 padding for URL-safe base64
      String normalized = payload.replaceAll('-', '+').replaceAll('_', '/');
      switch (normalized.length % 4) {
        case 2:
          normalized += '==';
          break;
        case 3:
          normalized += '=';
          break;
        case 1:
          // invalid padding but try to recover
          normalized += '===';
          break;
        default:
          break;
      }
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> claims = jsonDecode(decoded);
      return claims;
    } catch (e) {
      print('Error parsing JWT: $e');
      return null;
    }
  }

  /// Read stored auth token and return decoded claims if available
  static Future<Map<String, dynamic>?> getUserFromAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) return null;
      return _parseJwt(token);
    } catch (e) {
      print('Error getting user from auth token: $e');
      return null;
    }
  }

  /// Get stored refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

}