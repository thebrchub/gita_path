import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/chapter_card.dart';

class ChapterListScreen extends StatefulWidget {
  const ChapterListScreen({super.key});

  @override
  State<ChapterListScreen> createState() => _ChapterListScreenState();
}

class _ChapterListScreenState extends State<ChapterListScreen> 
    with SingleTickerProviderStateMixin {
  List<dynamic> chapters = [];
  bool loading = true;
  late AnimationController _breathingController;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    loadChapters();
  }

  Future<void> loadChapters() async {
    try {
      var data = await ApiService.getChapters();
      setState(() {
        chapters = data;
        loading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
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
              _buildHeader(),
              Expanded(
                child: loading
                    ? _buildLoadingState()
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 0),
                        physics: const BouncingScrollPhysics(),
                        itemCount: chapters.length + 1, // +1 for inspiration card
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _buildInspirationCard();
                          }
                          final ch = chapters[index - 1];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ChapterCard(
                              chapter: ch,
                              index: index - 1,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.deepOrange.shade700),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '18 अध्याय',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.deepOrange.shade800,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'The Eighteen Chapters',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.self_improvement,
              color: Colors.deepOrange.shade400,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspirationCard() {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_breathingController.value * 0.02),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade100.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.format_quote,
                  color: Colors.deepOrange.shade300,
                  size: 28,
                ),
                const SizedBox(height: 12),
                Text(
                  'योगस्थः कुरु कर्माणि',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepOrange.shade900,
                    letterSpacing: 0.8,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 1,
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.orange.shade300,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '"Established in yoga, perform action"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.5),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.deepOrange.shade400,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading sacred wisdom...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}