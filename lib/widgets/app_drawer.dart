import 'package:flutter/material.dart';
import '../screens/chapterlistscreen.dart';
import '../screens/askkrishnascreen.dart';
import '../screens/donationscreen.dart';
import '../screens/login_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/terms_of_service_screen.dart';
import '../screens/about_screen.dart';
import '../screens/contact_us_screen.dart';
import '../screens/help_faq_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/google_auth_service.dart';
import '../screens/user_profile_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  // Mock user data - will be replaced with actual data from backend
  bool isLoggedIn = false; // TODO: Get from SharedPreferences
  bool isPremium = false; // TODO: Get from backend
  String userName = 'Guest User';
  String userEmail = '';
  String userPhoto = '';
  String userAbout = '';
  bool isPro = false;
  int bookmarkCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Check auth status
    try {
      final signedIn = await GoogleAuthService.isSignedIn();
      if (!mounted) return;
      setState(() {
        isLoggedIn = signedIn;
      });

      if (signedIn) {
        try {
          final profile = await ApiService.getUserProfile();
          if (!mounted) return;
          setState(() {
            userName = profile['name'] ?? userName;
            userEmail = profile['email'] ?? userEmail;
            userPhoto = profile['profilePicture'] ?? userPhoto;
            userAbout = profile['about'] ?? userAbout;
            isPro = profile['pro'] == true;
            isPremium = isPro;
          });
        } catch (e) {
          // If fetching profile failed or backend doesn't have details,
          // try to decode stored auth token (JWT) which may contain user claims.
          try {
            final claims = await GoogleAuthService.getUserFromAuthToken();
            if (claims != null && mounted) {
              setState(() {
                userName = claims['name'] ?? userName;
                userEmail = claims['email'] ?? userEmail;
                userPhoto = claims['picture'] ?? claims['profilePicture'] ?? userPhoto;
                userAbout = claims['about'] ?? userAbout;
                isPro = claims['pro'] == true || claims['is_pro'] == true;
                isPremium = isPro;
              });
            }
          } catch (err) {
            // ignore
          }
          // If still missing, try reading persisted Google profile fields
          try {
            final prefs = await SharedPreferences.getInstance();
            final storedName = prefs.getString('user_name') ?? '';
            final storedEmail = prefs.getString('user_email') ?? '';
            final storedPhoto = prefs.getString('user_photo') ?? '';
            final storedDob = prefs.getString('user_dob') ?? '';
            final storedAbout = prefs.getString('user_about') ?? '';
            final storedPro = prefs.getBool('user_pro') ?? false;
            if (mounted && (storedName.isNotEmpty || storedEmail.isNotEmpty || storedPhoto.isNotEmpty || storedDob.isNotEmpty || storedAbout.isNotEmpty || storedPro)) {
              setState(() {
                if (storedName.isNotEmpty) userName = storedName;
                if (storedEmail.isNotEmpty) userEmail = storedEmail;
                if (storedPhoto.isNotEmpty) userPhoto = storedPhoto;
                if (storedAbout.isNotEmpty) userAbout = storedAbout;
                isPro = storedPro;
                isPremium = isPro;
              });
            }
          } catch (e) {
            // ignore
          }
        }
      }
    } catch (e) {
      // print('Error checking sign-in: $e');
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Clear user data and call backend logout
              // final prefs = await SharedPreferences.getInstance();
              // await prefs.clear();
              
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
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
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // User Profile Header
            _buildUserHeader(),

            const SizedBox(height: 8),

            // Main Menu Section
            _buildSectionTitle('Main Menu'),
            _buildMenuItem(
              icon: Icons.home_rounded,
              title: 'Home',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildMenuItem(
              icon: Icons.menu_book_rounded,
              title: 'Study Gita',
              subtitle: '18 Chapters • 700 Verses',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChapterListScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.psychology_rounded,
              title: 'Ask Krishna AI',
              subtitle: 'Get AI Guidance',
              badge: isPremium ? null : 'PRO',
              badgeColor: Colors.amber,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AskKrishnaScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.bookmark_rounded,
              title: 'My Favorites',
              subtitle: '$bookmarkCount saved verses',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to favorites screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Favorites coming soon!')),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.history_rounded,
              title: 'Reading History',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History coming soon!')),
                );
              },
            ),

            const Divider(height: 24),

            // Settings Section
            _buildSectionTitle('Settings'),
            // _buildMenuItem(
            //   icon: Icons.language_rounded,
            //   title: 'Language',
            //   subtitle: 'English',
            //   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            //   onTap: () {
            //     Navigator.pop(context);
            //     _showLanguageDialog();
            //   },
            // ),
            _buildMenuItem(
              icon: Icons.palette_rounded,
              title: 'Theme',
              subtitle: 'Light Mode',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _showThemeDialog();
              },
            ),
            _buildMenuItem(
              icon: Icons.notifications_rounded,
              title: 'Notifications',
              subtitle: 'Daily verse reminder',
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Save preference
                },
                activeColor: Colors.deepOrange.shade700,
              ),
              onTap: null,
            ),
            // _buildMenuItem(
            //   icon: Icons.text_fields_rounded,
            //   title: 'Text Size',
            //   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            //   onTap: () {
            //     Navigator.pop(context);
            //     _showTextSizeDialog();
            //   },
            // ),

            const Divider(height: 24),

            // Premium Section
            if (!isPremium) ...[
              _buildSectionTitle('Premium'),
              _buildMenuItem(
                icon: Icons.workspace_premium_rounded,
                title: 'Upgrade to Premium',
                subtitle: 'Unlock unlimited AI guidance',
                badge: 'NEW',
                badgeColor: Colors.amber,
                gradient: LinearGradient(
                  colors: [Colors.amber.shade100, Colors.orange.shade50],
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to subscription screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Premium plans coming soon!')),
                  );
                },
              ),
            ] else ...[
              _buildSectionTitle('Premium'),
              _buildMenuItem(
                icon: Icons.card_membership_rounded,
                title: 'My Subscription',
                subtitle: 'Premium Member',
                trailing: Icon(Icons.verified, color: Colors.amber.shade700, size: 20),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Show subscription details
                },
              ),
            ],

            const Divider(height: 24),

            // Support Section
            _buildSectionTitle('Support'),
            _buildMenuItem(
              icon: Icons.volunteer_activism_rounded,
              title: 'Donate',
              subtitle: 'Support Dharma',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DonationScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.mail_rounded,
              title: 'Contact Us',
              subtitle: 'support@gitaai.app',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ContactUsScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.star_rounded,
              title: 'Rate Us',
              subtitle: 'Share your feedback',
              onTap: () {
                Navigator.pop(context);
                // TODO: Open Play Store
              },
            ),
            _buildMenuItem(
              icon: Icons.share_rounded,
              title: 'Share App',
              subtitle: 'Spread the wisdom',
              onTap: () {
                Navigator.pop(context);
                // TODO: Share app link
              },
            ),

            const Divider(height: 24),

            // Info Section
            _buildSectionTitle('Information'),
            _buildMenuItem(
              icon: Icons.info_rounded,
              title: 'About',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.privacy_tip_rounded,
              title: 'Privacy Policy',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.description_rounded,
              title: 'Terms of Service',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.help_rounded,
              title: 'Help & FAQs',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpFaqScreen()),
                );
              },
            ),

            const Divider(height: 24),

            // Logout
            if (isLoggedIn)
              _buildMenuItem(
                icon: Icons.logout_rounded,
                title: 'Logout',
                textColor: Colors.red.shade700,
                onTap: _handleLogout,
              ),

            const SizedBox(height: 16),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Made with ❤️ for Dharma',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepOrange.shade700,
            Colors.orange.shade500,
          ],
        ),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: userPhoto.isEmpty
            ? Icon(
                Icons.person,
                size: 40,
                color: Colors.deepOrange.shade700,
              )
            : ClipOval(
                child: Image.network(
                  userPhoto,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.deepOrange.shade700,
                    );
                  },
                ),
              ),
      ),
      accountName: Row(
        children: [
          Text(
            userName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isPremium) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'PRO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ],
      ),
      accountEmail: Text(
        isLoggedIn ? userEmail : 'Tap to sign in',
        style: TextStyle(
          fontSize: 13,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
      onDetailsPressed: () {
        Navigator.pop(context);
        if (!isLoggedIn) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserProfileScreen()),
          );
        }
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.deepOrange.shade700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    String? badge,
    Color? badgeColor,
    Color? textColor,
    Widget? trailing,
    VoidCallback? onTap,
    Gradient? gradient,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: gradient != null
          ? BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: gradient != null
                ? Colors.white.withOpacity(0.4)
                : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: textColor ?? Colors.deepOrange.shade700,
            size: 22,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? Colors.grey.shade800,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor ?? Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              )
            : null,
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }


  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Apply theme
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Apply theme
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('Auto (System)'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Apply theme
              },
            ),
          ],
        ),
      ),
    );
  }


  
}