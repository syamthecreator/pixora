import 'package:flutter/material.dart';
import 'package:pixora/core/theme/app_colors.dart';
import 'package:pixora/features/settings/controller/settings_controller.dart';

class QuickSettingsSheet extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onMoreSettings;
  final SettingsController settingsController;
  const QuickSettingsSheet({
    super.key,
    required this.onClose,
    required this.onMoreSettings,
    required this.settingsController,
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(top: 60),
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.35,
        decoration: BoxDecoration(
          color: AppColors.sheetBackground,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(28),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderSection(onClose: onClose, onMoreSettings: onMoreSettings),
            const SizedBox(height: 20),
            _RatioSection(controller: settingsController),
            const SizedBox(height: 14),
            _TimerSection(controller: settingsController),
            const SizedBox(height: 14),
            _ToggleGridSection(controller: settingsController),
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
          icon: const Icon(Icons.close, color: Colors.white),
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
              color: AppColors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: AppColors.white, size: 22),
        ],
      ),
    );
  }
}

class _RatioSection extends StatelessWidget {
  final SettingsController controller;
  const _RatioSection({required this.controller});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return _SettingsOptionRow(
          items: const ["1:1", "4:3", "16:9", "Full"],
          selectedIndex: controller.getRatioIndex(),
          onItemSelected: controller.selectRatio,
        );
      },
    );
  }
}

class _TimerSection extends StatelessWidget {
  final SettingsController controller;
  const _TimerSection({required this.controller});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return _SettingsOptionRow(
          items: const ["Off", "3s", "5s", "10s"],
          selectedIndex: controller.getTimerIndex(),
          onItemSelected: controller.selectTimer,
        );
      },
    );
  }
}

class _ToggleGridSection extends StatelessWidget {
  final SettingsController controller;
  const _ToggleGridSection({required this.controller});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _ToggleTile(
              label: "Grid lines",
              isActive: controller.gridLines,
              onTap: controller.toggleGridLines,
            ),
    
            _ToggleTile(
              label: "Watermark",
              isActive: controller.watermark,
              onTap: controller.toggleWatermark,
            ),
            _ToggleTile(
              label: "HDR",
              isActive: controller.hdr,
              onTap: controller.toggleHDR,
            ),
          ],
        );
      },
    );
  }
}

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
          color: isActive ? AppColors.activeOption : AppColors.inactiveOption,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.black : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _ToggleTile({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tileWidth = (screenWidth - 60) / 3;
    return SizedBox(
      width: tileWidth,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? AppColors.activeOption : AppColors.inactiveOption,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.black : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
