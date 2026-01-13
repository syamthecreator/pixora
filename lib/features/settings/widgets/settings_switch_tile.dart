import 'package:flutter/material.dart';
import 'package:pixora/core/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../controller/settings_controller.dart';

class SettingsSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String settingKey;
  final bool defaultValue;

  const SettingsSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.settingKey,
    this.defaultValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();
    final value = controller.getValue(settingKey, defaultValue: defaultValue);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ],
            ),
          ),

          /// CUSTOM SWITCH
          Switch(
            value: value,
            onChanged: (v) => controller.toggle(settingKey, v),

            /// Track fill color
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.kPrimaryColour.withValues(alpha: 0.18);
              }
              return AppColors.kInactiveOptionColour;
            }),

            /// Track border
            trackOutlineColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.transparent;
              }
              return AppColors.kInactiveOptionColour;
            }),

            trackOutlineWidth: WidgetStateProperty.all(1.5),

            /// Thumb color
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.kPrimaryColour;
              }
              return Colors.white24;
            }),

            /// Remove ripple
            overlayColor: WidgetStateProperty.all(Colors.transparent),

            /// Compact size
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
