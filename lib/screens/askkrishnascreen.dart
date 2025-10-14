import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AskKrishnaScreen extends StatefulWidget {
  const AskKrishnaScreen({super.key});

  @override
  State<AskKrishnaScreen> createState() => _AskKrishnaScreenState();
}

class _AskKrishnaScreenState extends State<AskKrishnaScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> chat = [];
  bool loading = false;
  
  // Simulate user status (change to true when payment is done)
  bool isPremiumUser = false;
  int dailyQuestionsLeft = 5; // Free tier: 5 questions per day
  final int maxFreeQuestions = 5;

  @override
  void initState() {
    super.initState();
    _loadUserStatus();
  }

  Future<void> _loadUserStatus() async {
    // TODO: Load from SharedPreferences or backend
    // Check if user has premium subscription
    // Check how many free questions used today
    setState(() {
      // Mock data for now
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
    final answer = await _getAIResponse(question);

    setState(() {
      chat.add({'role': 'ai', 'text': answer});
      loading = false;
    });
    _scrollToBottom();
  }

  Future<String> _getAIResponse(String question) async {
    // TODO: Integrate Gemini API
    // For now, using mock responses
    return getMockGitaAnswer(question);
  }

  String getMockGitaAnswer(String question) {
    final lowerQ = question.toLowerCase();
    
    if (lowerQ.contains("anger") || lowerQ.contains("angry")) {
      return "🕉️ Krishna teaches in Bhagavad Gita 2.63:\n\n\"From anger comes delusion; from delusion, loss of memory; from loss of memory, destruction of intelligence; and when intelligence is destroyed, one perishes.\"\n\n💡 Practice:\n• Pause before reacting\n• Practice deep breathing\n• Remember the bigger picture\n• Cultivate self-awareness through meditation";
    } else if (lowerQ.contains("fear") || lowerQ.contains("afraid") || lowerQ.contains("scared")) {
      return "🕉️ In Bhagavad Gita 16.1-3, Krishna describes the divine qualities:\n\n\"Fearlessness, purity of heart, steadfastness in knowledge and yoga, charity, self-control...\"\n\n💡 To overcome fear:\n• Trust in the divine plan\n• Focus on your dharma (duty)\n• Remember: The soul is eternal\n• Build courage through small steps";
    } else if (lowerQ.contains("stress") || lowerQ.contains("anxiety") || lowerQ.contains("worried")) {
      return "🕉️ Krishna's wisdom from BG 2.47:\n\n\"You have a right to perform your prescribed duty, but you are not entitled to the fruits of action. Never consider yourself the cause of the results, nor be attached to not doing your duty.\"\n\n💡 Stress relief through Gita:\n• Do your best, let go of results\n• Live in the present moment\n• Practice karma yoga (selfless action)\n• Trust in divine timing";
    } else if (lowerQ.contains("purpose") || lowerQ.contains("meaning")) {
      return "🕉️ On life's purpose, Krishna teaches (BG 3.19):\n\n\"Therefore, without being attached to the fruits of activities, one should act as a matter of duty, for by working without attachment one attains the Supreme.\"\n\n💡 Finding your purpose:\n• Discover your svadharma (true calling)\n• Serve others selflessly\n• Use your unique talents for good\n• Align actions with higher values";
    } else if (lowerQ.contains("decision") || lowerQ.contains("confused") || lowerQ.contains("choice")) {
      return "🕉️ Krishna guides Arjuna in making decisions (BG 18.63):\n\n\"Thus I have explained to you knowledge still more confidential. Deliberate on this fully, and then do what you wish to do.\"\n\n💡 Making wise decisions:\n• Gather complete information\n• Consider dharma (righteousness)\n• Think of long-term consequences\n• Listen to your inner wisdom\n• Seek guidance when needed";
    } else if (lowerQ.contains("relationship") || lowerQ.contains("love")) {
      return "🕉️ On relationships, Krishna teaches (BG 12.13-14):\n\n\"One who is not envious but is a kind friend to all, who is not affected by honor and dishonor, equal in happiness and distress, forgiving...\"\n\n💡 Healthy relationships:\n• Practice compassion and kindness\n• Let go of expectations\n• Accept others as they are\n• Communicate with love and respect\n• Remember: We're all souls on a journey";
    } else if (lowerQ.contains("work") || lowerQ.contains("job") || lowerQ.contains("career")) {
      return "🕉️ Krishna's teaching on work (BG 3.8-9):\n\n\"Perform your prescribed duty, for doing so is better than not working. One cannot even maintain one's physical body without work.\"\n\n💡 Sacred approach to work:\n• Do your duty with excellence\n• Work as worship (karma yoga)\n• Stay detached from results\n• Find meaning in service\n• Balance work with spiritual growth";
    } else {
      return "🕉️ Krishna's eternal wisdom from Bhagavad Gita:\n\n\"Perform your duty with a steady mind, without attachment to success or failure. This equanimity is called yoga.\" (BG 2.48)\n\n💡 Remember:\n• Everything happens for your growth\n• You're never alone - divine guidance is always available\n• Focus on your actions, not results\n• Keep learning and evolving\n\nFeel free to ask me more specific questions about your situation!";
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
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber),
            const SizedBox(width: 8),
            const Text("Upgrade to Premium"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "You've used all your free questions for today!",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text("Premium Benefits:"),
            const SizedBox(height: 8),
            _buildBenefit("✨ Unlimited AI conversations"),
            _buildBenefit("💾 Save conversation history"),
            _buildBenefit("🎯 Priority responses"),
            _buildBenefit("🔮 Advanced insights from Gita"),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: Column(
                children: [
                  const Text(
                    "₹99/month or ₹499/year",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Save 58% with yearly plan!",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Maybe Later"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSubscriptionOptions();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black87,
            ),
            child: const Text("Upgrade Now"),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _showSubscriptionOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Choose Your Plan",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Monthly plan
            _buildPlanCard(
              title: "Monthly Plan",
              price: "₹99",
              period: "/month",
              features: ["Unlimited questions", "Priority support", "All features"],
              isPopular: false,
            ),
            const SizedBox(height: 16),
            
            // Yearly plan (recommended)
            _buildPlanCard(
              title: "Yearly Plan",
              price: "₹499",
              period: "/year",
              savings: "Save ₹689",
              features: ["Everything in Monthly", "2 months FREE", "Best value!"],
              isPopular: true,
            ),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Integrate Google Play billing
                  Navigator.pop(context);
                  _showPaymentComingSoon();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Continue to Payment",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Secure payment via Google Play",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    String? savings,
    required List<String> features,
    required bool isPopular,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPopular ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPopular ? AppColors.primary : Colors.grey.shade300,
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "BEST VALUE",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              Text(
                period,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              if (savings != null) ...[
                const SizedBox(width: 8),
                Text(
                  savings,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.check, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(f, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _showPaymentComingSoon() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Coming Soon!"),
        content: const Text(
          "Payment integration will be available in the next update.\n\nWe're integrating Google Play Billing for seamless and secure payments.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ask Krishna AI"),
        backgroundColor: AppColors.primary,
        actions: [
          if (!isPremiumUser)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "$dailyQuestionsLeft/$maxFreeQuestions left",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          if (isPremiumUser)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(Icons.workspace_premium, color: Colors.amber),
            ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          if (!isPremiumUser)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.amber.shade50,
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Free tier: $dailyQuestionsLeft questions left today. Upgrade for unlimited!",
                      style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                    ),
                  ),
                  TextButton(
                    onPressed: _showUpgradeDialog,
                    child: const Text("Upgrade", style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          
          Expanded(
            child: chat.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.psychology,
                          size: 80,
                          color: AppColors.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Ask Krishna Anything!",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            "Get guidance based on Bhagavad Gita's timeless wisdom",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildSuggestionChip("How to manage anger?"),
                            _buildSuggestionChip("Dealing with fear"),
                            _buildSuggestionChip("Finding life purpose"),
                          ],
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: chat.length,
                    itemBuilder: (context, index) {
                      final msg = chat[index];
                      final isUser = msg['role'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(14),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isUser
                                ? AppColors.primary.withOpacity(0.9)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            msg['text'] ?? '',
                            style: TextStyle(
                              color: isUser ? Colors.white : AppColors.textDark,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          if (loading)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const CircularProgressIndicator(strokeWidth: 2),
                  const SizedBox(width: 12),
                  Text(
                    "Krishna is thinking...",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask Krishna anything...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}