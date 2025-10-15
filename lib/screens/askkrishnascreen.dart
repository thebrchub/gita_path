import 'package:flutter/material.dart';
import 'dart:math';
import '../theme/colors.dart';

class AskKrishnaScreen extends StatefulWidget {
  const AskKrishnaScreen({super.key});

  @override
  State<AskKrishnaScreen> createState() => _AskKrishnaScreenState();
}

class _AskKrishnaScreenState extends State<AskKrishnaScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> chat = [];
  bool loading = false;
  late AnimationController _glowController;

  // Simulate user status (change to true when payment is done)
  bool isPremiumUser = false;
  int dailyQuestionsLeft = 5; // Free tier: 5 questions per day
  final int maxFreeQuestions = 5;

  @override
  void initState() {
    super.initState();
    _loadUserStatus();
    
    // Glow animation for Krishna icon
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _loadUserStatus() async {
    // TODO: Load from SharedPreferences or backend
    setState(() {
      isPremiumUser = false;
      dailyQuestionsLeft = 5;
    });
  }

  void sendMessage() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;

    // Check if user can ask questions
    if (!isPremiumUser && dailyQuestionsLeft <= 0) {
      _showUpgradeDialog();
      return;
    }

    setState(() {
      chat.add({'role': 'user', 'text': question});
      loading = true;
      if (!isPremiumUser) dailyQuestionsLeft--;
    });
    _controller.clear();
    _scrollToBottom();

    // TODO: Replace with actual AI API call (Gemini/Claude)
    await Future.delayed(const Duration(seconds: 2));
    final answer = getMockGitaAnswer(question);

    setState(() {
      chat.add({'role': 'ai', 'text': answer});
      loading = false;
    });
    _scrollToBottom();
  }

  String getMockGitaAnswer(String question) {
    final lowerQ = question.toLowerCase();

    if (lowerQ.contains("anger") || lowerQ.contains("angry")) {
      return "🕉️ Krishna teaches in Bhagavad Gita 2.63:\n\n\"From anger comes delusion; from delusion, loss of memory; from loss of memory, destruction of intelligence; and when intelligence is destroyed, one perishes.\"\n\n💡 Practice:\n• Pause before reacting\n• Practice deep breathing\n• Remember the bigger picture\n• Cultivate self-awareness through meditation";
    } else if (lowerQ.contains("fear") || lowerQ.contains("afraid") || lowerQ.contains("scared")) {
      return "🕉️ In Bhagavad Gita 16.1-3, Krishna describes the divine qualities:\n\n\"Fearlessness, purity of heart, steadfastness in knowledge and yoga, charity, self-control...\"\n\n💡 To overcome fear:\n• Trust in the divine plan\n• Focus on your dharma (duty)\n• Remember: The soul is eternal\n• Build courage through small steps";
    } else if (lowerQ.contains("stress") || lowerQ.contains("anxiety") || lowerQ.contains("worried")) {
      return "🕉️ Krishna's wisdom from BG 2.47:\n\n\"You have a right to perform your prescribed duty, but you are not entitled to the fruits of action.\"\n\n💡 Stress relief through Gita:\n• Do your best, let go of results\n• Live in the present moment\n• Practice karma yoga\n• Trust in divine timing";
    } else if (lowerQ.contains("purpose") || lowerQ.contains("meaning")) {
      return "🕉️ On life's purpose, Krishna teaches (BG 3.19):\n\n\"Therefore, without being attached to the fruits of activities, one should act as a matter of duty.\"\n\n💡 Finding your purpose:\n• Discover your svadharma\n• Serve others selflessly\n• Use your unique talents for good\n• Align actions with higher values";
    } else {
      return "🕉️ Krishna's eternal wisdom from Bhagavad Gita:\n\n\"Perform your duty with a steady mind, without attachment to success or failure. This equanimity is called yoga.\" (BG 2.48)\n\n💡 Remember:\n• Everything happens for your growth\n• You're never alone - divine guidance is always available\n• Focus on your actions, not results\n• Keep learning and evolving\n\nFeel free to ask me more specific questions!";
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFFF5E6),
                Colors.orange.shade50,
                Colors.blue.shade50,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.workspace_premium,
                  color: Colors.amber.shade700,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Unlock Unlimited Wisdom",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "You've used all your free questions for today",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              _buildBenefit("✨ Unlimited AI conversations"),
              _buildBenefit("💾 Save conversation history"),
              _buildBenefit("🎯 Priority responses"),
              _buildBenefit("🔮 Advanced insights from Gita"),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amber.shade200,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "₹",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange.shade700,
                          ),
                        ),
                        Text(
                          "99",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange.shade700,
                            height: 1.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "/month",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "or ₹499/year (Save 58%!)",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        "Maybe Later",
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showPaymentComingSoon();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade600,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Upgrade Now",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentComingSoon() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Coming Soon!"),
        content: const Text(
          "Payment integration will be available in the next update.\n\nWe're integrating Google Play Billing for seamless and secure payments.",
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
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
        child: Column(
          children: [
            // Elegant AppBar
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.4),
                    Colors.white.withOpacity(0.2),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.deepOrange.shade700),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Animated Krishna icon
                  // AnimatedBuilder(
                  //   animation: _glowController,
                  //   builder: (context, child) {
                  //     return Container(
                  //       padding: const EdgeInsets.all(10),
                  //       decoration: BoxDecoration(
                  //         shape: BoxShape.circle,
                  //         color: Colors.white.withOpacity(0.3),
                  //         boxShadow: [
                  //           BoxShadow(
                  //             color: Colors.orange.shade200.withOpacity(
                  //               0.3 + _glowController.value * 0.4,
                  //             ),
                  //             blurRadius: 20,
                  //             spreadRadius: 3,
                  //           ),
                  //         ],
                  //       ),
                  //       // child: Icon(
                  //       //   Icons.psychology,
                  //       //   color: Colors.deepOrange.shade600,
                  //       //   size: 28,
                  //       // ),
                  //     );
                  //   },
                  // ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ask Krishna",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange.shade800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Divine Guidance Powered by AI",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isPremiumUser)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.deepOrange.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        "$dailyQuestionsLeft/$maxFreeQuestions",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange.shade700,
                        ),
                      ),
                    ),
                  if (isPremiumUser)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.workspace_premium,
                        color: Colors.amber.shade700,
                        size: 24,
                      ),
                    ),
                ],
              ),
            ),

            // Info banner for free users
            if (!isPremiumUser)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.deepOrange.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "$dailyQuestionsLeft free questions remaining today",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber.shade400, Colors.orange.shade400],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: GestureDetector(
                        onTap: _showUpgradeDialog,
                        child: Text(
                          "Upgrade",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Chat area
            Expanded(
              child: chat.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: chat.length,
                      itemBuilder: (context, index) {
                        final msg = chat[index];
                        final isUser = msg['role'] == 'user';
                        return _buildChatBubble(msg, isUser);
                      },
                    ),
            ),

            // Loading indicator
            if (loading)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.deepOrange.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      "Krishna is contemplating...",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),

            // Input area
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Ask Krishna anything...",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                            letterSpacing: 0.2,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepOrange.shade600,
                          Colors.orange.shade500,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepOrange.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                      onPressed: sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 8 * sin(_glowController.value * 2 * pi)),
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.orange.withOpacity(0.2 + _glowController.value * 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.shade200.withOpacity(0.4),
                              blurRadius: 25,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.psychology,
                          size: 50,
                          color: Colors.deepOrange.shade600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              "नमस्ते सखे!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange.shade800,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "I Am Here to Guide You",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.deepOrange.shade700,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: Text(
                "Ask me anything about life, and I'll share Krishna's wisdom from the Bhagavad Gita",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.6,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 36),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip("How to manage anger?"),
                _buildSuggestionChip("Dealing with fear"),
                _buildSuggestionChip("Finding life purpose"),
                _buildSuggestionChip("Work-life balance"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(Map<String, String> msg, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: isUser
              ? LinearGradient(
                  colors: [
                    Colors.deepOrange.shade600,
                    Colors.orange.shade500,
                  ],
                )
              : null,
          color: isUser ? null : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 20),
          ),
          border: isUser
              ? null
              : Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1,
                ),
          boxShadow: [
            BoxShadow(
              color: isUser
                  ? Colors.deepOrange.withOpacity(0.2)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          msg['text'] ?? '',
          style: TextStyle(
            color: isUser ? Colors.white : Colors.grey.shade800,
            fontSize: 15,
            height: 1.6,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return InkWell(
      onTap: () {
        _controller.text = text;
        sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.deepOrange.shade200,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.deepOrange.shade700,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _glowController.dispose();
    super.dispose();
  }
}