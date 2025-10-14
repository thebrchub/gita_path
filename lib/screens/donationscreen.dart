import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  int selectedAmount = 0;
  final TextEditingController customAmountController = TextEditingController();
  final List<int> quickAmounts = [50, 100, 250, 500, 1000];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Support Dharma"),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, Colors.deepOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 50,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Thank You for Your Support! 🙏",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "100% of donations go towards:\n• App development & maintenance\n• Charity & seva activities\n• Spreading Gita's wisdom",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Quick amount selection
              Text(
                "Select Amount",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: quickAmounts.map((amount) {
                  final isSelected = selectedAmount == amount;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedAmount = amount;
                        customAmountController.clear();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        "₹$amount",
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Custom amount
              Text(
                "Or Enter Custom Amount",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              
              TextField(
                controller: customAmountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  prefixText: "₹ ",
                  hintText: "Enter amount",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedAmount = int.tryParse(value) ?? 0;
                  });
                },
              ),
              
              const SizedBox(height: 32),
              
              // Impact message
              if (selectedAmount > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getImpactMessage(selectedAmount),
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Donate button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: selectedAmount > 0 ? () => _processDonation() : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    selectedAmount > 0
                        ? "Donate ₹$selectedAmount"
                        : "Select Amount to Continue",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Trust indicators
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lock, size: 16, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          "Secure Payment via UPI/Cards",
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.verified, size: 16, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          "100% Transparent Usage",
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getImpactMessage(int amount) {
    if (amount >= 1000) {
      return "Your generous contribution helps us serve thousands!";
    } else if (amount >= 500) {
      return "Amazing! This helps us add more language support.";
    } else if (amount >= 100) {
      return "Thank you! This keeps our servers running.";
    } else {
      return "Every contribution matters and is deeply appreciated!";
    }
  }

  void _processDonation() {
    // TODO: Integrate Razorpay or UPI payment gateway
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.payment, color: AppColors.primary),
            const SizedBox(width: 12),
            const Text("Payment Gateway"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Amount: ₹$selectedAmount"),
            const SizedBox(height: 16),
            const Text(
              "Payment integration will be added soon!\n\nOptions:\n• UPI (Google Pay, PhonePe, Paytm)\n• Cards\n• Net Banking",
              textAlign: TextAlign.center,
            ),
          ],
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
  void dispose() {
    customAmountController.dispose();
    super.dispose();
  }
}