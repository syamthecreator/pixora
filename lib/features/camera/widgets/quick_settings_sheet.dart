import 'package:flutter/material.dart';
import 'package:pixora/core/theme/app_colors.dart';
import 'package:pixora/features/camera/controller/camera_controller.dart';
import 'package:pixora/features/settings/controller/settings_controller.dart';

class QuickSettingsSheet extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onMoreSettings;
  final SettingsController settingsController;
  final CameraControllerX cameraControllerX;

  const QuickSettingsSheet({
    super.key,
    required this.onClose,
    required this.onMoreSettings,
    required this.settingsController,
    required this.cameraControllerX,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.sheetBackground,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderSection(onClose: onClose, onMoreSettings: onMoreSettings),
            const SizedBox(height: 20),
            _RatioSection(controller: cameraControllerX),
            const SizedBox(height: 14),
            _TimerSection(controller: cameraControllerX),
            const SizedBox(height: 14),
            // _ToggleGridSection(
            //   controller: settingsController,
            //   controller2: cameraControllerX,
            // ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onMoreSettings;
  const _HeaderSection({required this.onClose, required this.onMoreSettings});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.close, color: AppColors.kWhiteColour),
          onPressed: onClose,
        ),
        const Spacer(),
        _MoreSettingsButton(onMoreSettings),
      ],
    );
  }
}

class _MoreSettingsButton extends StatelessWidget {
  final VoidCallback onMoreSettings;
  const _MoreSettingsButton(this.onMoreSettings);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onMoreSettings,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "More settings",
            style: TextStyle(
              color: AppColors.kWhiteColour,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: AppColors.kWhiteColour, size: 22),
        ],
      ),
    );
  }
}

class _RatioSection extends StatelessWidget {
  final CameraControllerX controller;
  const _RatioSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return _SettingsOptionRow(
          items: controller.availableRatios,
          selectedIndex: controller.getRatioIndex(),
          onItemSelected: (ratio) {
            controller.updateRatio(ratio);
          },
        );
      },
    );
  }
}

class _TimerSection extends StatelessWidget {
  final CameraControllerX controller;
  const _TimerSection({required this.controller});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return _SettingsOptionRow(
          items: controller.availableTimers,
          selectedIndex: controller.getTimerIndex(),
          onItemSelected: controller.selectTimer,
        );
      },
    );
  }
}

// class _ToggleGridSection extends StatelessWidget {
//   final SettingsController controller;
//   final CameraControllerX controller2;
//   const _ToggleGridSection({
//     required this.controller,
//     required this.controller2,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return ListenableBuilder(
//       listenable: controller,
//       builder: (context, _) {
//         return Wrap(
//           spacing: 12,
//           runSpacing: 12,
//           children: [
//             _ToggleTile(
//               label: "Grid lines",
//               isActive: controller2.gridLines,
//               onTap: controller2.toggleGridLines,
//             ),

//             _ToggleTile(
//               label: "Watermark",
//               isActive: controller.watermark,
//               onTap: controller.toggleWatermark,
//             ),
//             _ToggleTile(
//               label: "HDR",
//               isActive: controller.hdr,
//               onTap: controller.toggleHDR,
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

class _SettingsOptionRow extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<String> onItemSelected;
  const _SettingsOptionRow({
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final label = entry.value;
        final isActive = index == selectedIndex;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _OptionTile(
              label: label,
              isActive: isActive,
              onTap: () => onItemSelected(label),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _OptionTile({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.kPrimaryColour.withValues(alpha: 0.18)
              : AppColors.kInactiveOptionColour,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.kPrimaryColour : Colors.white60,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

// class _ToggleTile extends StatelessWidget {
//   final String label;
//   final bool isActive;
//   final VoidCallback onTap;
//   const _ToggleTile({
//     required this.label,
//     required this.isActive,
//     required this.onTap,
//   });
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final tileWidth = (screenWidth - 60) / 3;
//     return SizedBox(
//       width: tileWidth,
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 14),
//           decoration: BoxDecoration(
//             color: isActive
//                 ? AppColors.kPrimaryColour.withValues(alpha: 0.18)
//                 : AppColors.kInactiveOptionColour,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Center(
//             child: Text(
//               label,
//               style: TextStyle(
//                 color: isActive ? AppColors.kPrimaryColour : Colors.white60,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
