import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const CustomHeader({
    super.key,
    required this.title,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.deepOrange.shade700),
                onPressed: onBack ?? () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          thickness: 1,
          height: 1,
          color: Colors.deepOrange.shade100,
        ),
      ],
    );
  }
}
