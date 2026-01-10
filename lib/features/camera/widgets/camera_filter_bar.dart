import 'package:flutter/material.dart';
import 'package:pixora/core/theme/app_colors.dart';
import 'package:pixora/features/camera/models/filter_model.dart';
import 'package:provider/provider.dart';

import '../controller/camera_controller.dart';
import 'camera_overlays.dart';

class CameraFilterBar extends StatelessWidget {
  const CameraFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FilterCarousel();
  }
}

class _FilterCarousel extends StatelessWidget {
  const _FilterCarousel();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CameraControllerX>();

    return SizedBox(
      height: 150,
      child: PageView.builder(
        controller: controller.filterPageController,
        clipBehavior: Clip.none,
        onPageChanged: controller.changeFilter,
        itemCount: FilterModelList.filters.length,
        itemBuilder: (context, index) {
          return _FilterItem(
            index: index,
            filter: FilterModelList.filters[index],
            isActive: index == controller.selectedFilter,
            controller: controller,
          );
        },
      ),
    );
  }
}

class _FilterItem extends StatelessWidget {
  final int index;
  final FilterModel filter;
  final bool isActive;
  final CameraControllerX controller;

  const _FilterItem({
    required this.index,
    required this.filter,
    required this.isActive,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FilterImage(imagePath: filter.image, isActive: isActive),
          const SizedBox(height: 8),
          _FilterLabel(name: filter.name, isActive: isActive),
        ],
      ),
    );
  }

  void _onTap() {
    controller.filterPageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

class _FilterImage extends StatelessWidget {
  final String imagePath;
  final bool isActive;

  const _FilterImage({required this.imagePath, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isActive ? 1.18 : 0.85,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: CameraOverlayWidget.glassContainer(
        borderRadius: 50,
        child: Container(
          width: 58,
          height: 58,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.neonPurple.withValues(alpha: 0.18): Colors.white24,
              width: 2,
            ),
          ),
          child: ClipOval(child: Image.asset(imagePath, fit: BoxFit.cover)),
        ),
      ),
    );
  }
}

class _FilterLabel extends StatelessWidget {
  final String name;
  final bool isActive;

  const _FilterLabel({required this.name, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isActive ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: Text(
        name.toUpperCase(),
        style: const TextStyle(
          color: AppColors.neonPurple,
          fontSize: 11,
          letterSpacing: 1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
