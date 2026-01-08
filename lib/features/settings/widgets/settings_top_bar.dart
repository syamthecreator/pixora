import 'package:flutter/material.dart';

class SettingsTopBar extends StatelessWidget {
  final String title;

  const SettingsTopBar({
    super.key,
    this.title = "More settings",
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          /// BACK BUTTON
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),

          const SizedBox(width: 4),

          /// TITLE
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
