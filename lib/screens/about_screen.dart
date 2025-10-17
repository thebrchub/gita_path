import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
// removed TapGestureRecognizer usage in favor of inline GestureDetector WidgetSpan
import '../theme/app_theme.dart';
import '../widgets/custom_header.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String appVersion = '1.0.0';
  // no recognizers needed when using WidgetSpan + GestureDetector

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildAppLogoSection(),
                      const SizedBox(height: 24),
                      _buildVersionCard(),
                      const SizedBox(height: 16),
                      _buildCreditsCard(),
                      const SizedBox(height: 16),
                      _buildDeveloperCard(),
                      const SizedBox(height: 24),
                      _buildSocialMediaSection(),
                      const SizedBox(height: 24),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const CustomHeader(title: 'About');
  }

  Widget _buildAppLogoSection() {
    return Column(
      children: [
        Image.asset(
          'assets/images/splash_logo.png',
          width: 84,
          height: 84,
        ),
        const SizedBox(height: 16),
        Text(
          '॥ श्रीमद्भगवद्गीता ॥',
          style: AppTheme.devanagari(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.deepOrange.shade800,
          ).copyWith(
            shadows: [
              Shadow(
                color: Colors.white.withOpacity(0.5),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'GitaPath',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildVersionCard() {
    return _buildInfoCard(
      icon: Icons.info_outline,
      title: 'App Version',
      content: Text(
        appVersion,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
          height: 1.5,
        ),
      ),
      color: Colors.blue,
    );
  }

  Widget _buildCreditsContent() {
    // Use the same TextStyle approach as other sections (App Version, Developer Info)
    final defaultTextStyle = TextStyle(
      fontSize: 13,
      color: Colors.grey.shade600,
      height: 1.5,
      fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
    );

    final linkTextStyle = TextStyle(
      fontSize: 13,
      color: const Color(0xFF9C27B0),
      fontWeight: FontWeight.w600,
      // decoration: TextDecoration.underline,
      height: 1.5,
      fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
    );
    // helper to build an inline tappable link using a WidgetSpan so it flows with text
    Widget linkSpan(String text, String url) {
      return GestureDetector(
        onTap: () => _launchUrl(url),
        child: Text(text, style: linkTextStyle),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Built with devotion to share the eternal wisdom of the Bhagavad Gita with seekers worldwide.',
          style: defaultTextStyle,
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            style: defaultTextStyle,
            children: <InlineSpan>[
              const TextSpan(text: 'Bhagavad Gita text provided by '),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: linkSpan('Vedic Scriptures', 'https://vedicscriptures.github.io'),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            style: defaultTextStyle,
            children: <InlineSpan>[
              const TextSpan(text: 'Tanpura Sound Effect by '),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: linkSpan('Eduardo Agni', 'https://pixabay.com/users/ethnicsoundscapes-49325147/?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=313494'),
              ),
              const TextSpan(text: ' from '),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: linkSpan('Pixabay', 'https://pixabay.com//?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=313494'),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreditsCard() {
    return _buildInfoCard(
      icon: Icons.volunteer_activism,
      title: 'Credits',
      content: _buildCreditsContent(),
      color: Colors.purple,
    );
  }

  Widget _buildDeveloperCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.code, color: Colors.green.shade600, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Developer\'s Info',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Blazing Render Creation Hub LLP',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tech Team',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Passionate developers committed to spreading spiritual wisdom through technology.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required Widget content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 6),
                content,
              ],
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildSocialMediaSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      // decoration: BoxDecoration(
      //   color: Colors.white.withOpacity(0.6),
      //   borderRadius: BorderRadius.circular(16),
      //   border: Border.all(color: Colors.white.withOpacity(0.4)),
      // ),
      child: Column(
        children: [
          Text(
            'Follow Us',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildSocialButton(
                iconPath: 'assets/images/social_logos/instagram.png',
                url: 'https://instagram.com/gitapath',
              ),
              _buildSocialButton(
                iconPath: 'assets/images/social_logos/facebook.png',
                url: 'https://facebook.com/gitapath',
              ),
              _buildSocialButton(
                iconPath: 'assets/images/social_logos/youtube.png',
                url: 'https://youtube.com/@gitapath',
              ),
              _buildSocialButton(
                iconPath: 'assets/images/social_logos/twitter.png',
                url: 'https://twitter.com/gitapath',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
  required String iconPath,
  required String url,
}) {
  return GestureDetector(
    onTap: () => _launchUrl(url),
    child: Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Image.asset(
        iconPath,
        fit: BoxFit.contain,
      ),
    ),
  );
}

  Widget _buildFooter() {
    return Text(
      'Made with ❤️ for spiritual seekers',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade600,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    final bool can = await canLaunchUrl(uri);
    debugPrint('canLaunchUrl($url) => $can');
    if (!can) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
      return;
    }

    try {
      // Try external application first (preferred). If that doesn't work,
      // fall back to the platform default behavior.
      bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      debugPrint('launchUrl externalApplication returned: $launched');
      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        debugPrint('launchUrl platformDefault returned: $launched');
      }

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    } catch (e, st) {
      debugPrint('Error launching $url: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching $url')),
        );
      }
    }
  }
}