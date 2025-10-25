import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/user_details_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String name = 'Guest User';
  String email = '';
  String photo = '';
  String about = '';
  String dob = '';
  bool isPro = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        name = prefs.getString('user_name') ?? name;
        email = prefs.getString('user_email') ?? email;
        photo = prefs.getString('user_photo') ?? photo;
        about = prefs.getString('user_about') ?? about;
        dob = prefs.getString('user_dob') ?? dob;
        isPro = prefs.getBool('user_pro') ?? isPro;
      });
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserDetailsScreen()),
              );
            },
            child: const Text(
              'Edit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 56,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
              child: photo.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 56,
                      color: Colors.grey.shade700,
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              email,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            if (isPro)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('PRO', style: TextStyle(color: Colors.white)),
              ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.cake_outlined),
              title: const Text('Date of Birth'),
              subtitle: Text(dob.isNotEmpty ? dob : 'Not provided'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: Text(about.isNotEmpty ? about : 'No information provided'),
            ),
          ],
        ),
      ),
    );
  }
}
