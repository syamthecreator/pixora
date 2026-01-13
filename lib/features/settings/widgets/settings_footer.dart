import 'package:flutter/material.dart';
import 'package:pixora/core/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../controller/settings_controller.dart';

class SettingsFooter extends StatelessWidget {
  const SettingsFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.kPrimaryColour.withValues(alpha: 0.18),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () {
            context.read<SettingsController>().restoreDefaults();
          },
          child: Text(
            "Restore defaults",
            style: TextStyle(color: AppColors.kPrimaryColour),
          ),
        ),
      ),
    );
  }
}
