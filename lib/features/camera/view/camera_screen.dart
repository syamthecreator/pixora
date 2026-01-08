import 'package:flutter/material.dart';
import 'package:pixora/core/theme/app_colors.dart';
import 'package:pixora/features/camera/widgets/camera_bottom_bar.dart';
import 'package:pixora/features/camera/widgets/camera_filter_bar.dart';
import 'package:pixora/features/camera/widgets/camera_overlays.dart';
import 'package:pixora/features/camera/widgets/camera_preview.dart';
import 'package:pixora/features/camera/widgets/camera_top_bar.dart';
import 'package:pixora/features/settings/controller/settings_controller.dart';
import 'package:provider/provider.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: const _CameraStack(),
    );
  }
}

class _CameraStack extends StatelessWidget {
  const _CameraStack();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return Stack(
      children: [
        _CameraPreviewLayout(settings: settings),
          CameraOverlayWidget.gridOverlay(divisions: 3, opacity: 0.08),
        CameraTopBar(
          onTapSettingsIcon: () => settings.showQuickSettings(context),
        ),
        const CameraFilterBar(),
        const CameraBottomBar(),
      ],
    );
  }
}

class _CameraPreviewLayout extends StatelessWidget {
  final SettingsController settings;

  const _CameraPreviewLayout({required this.settings});

  @override
  Widget build(BuildContext context) {
    if (settings.selectedCameraRatio == CameraRatio.full) {
      return const Positioned.fill(child: DebugCameraPreview());
    }

    return _NonFullRatioLayout(settings: settings);
  }
}

class _NonFullRatioLayout extends StatelessWidget {
  final SettingsController settings;

  const _NonFullRatioLayout({required this.settings});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final padding = mediaQuery.padding;

    final layoutData = _calculateLayoutData(settings, size, padding);

    return Positioned(
      top: padding.top + _Constants.topBarHeight,
      left: 0,
      right: 0,
      height: layoutData.previewHeight,
      child: AspectRatio(
        aspectRatio: layoutData.aspectRatio,
        child: const DebugCameraPreview(),
      ),
    );
  }

  _LayoutData _calculateLayoutData(
    SettingsController settings,
    Size screenSize,
    EdgeInsets padding,
  ) {
    final ratio = settings.selectedCameraRatio;
    final availableHeight = _calculateAvailableHeight(screenSize, padding);

    _getBottomControlsHeight(ratio);
    final aspectRatio = _getAspectRatio(ratio);
    final desiredHeight = _getDesiredHeight(ratio, screenSize, availableHeight);

    final previewHeight = desiredHeight > availableHeight
        ? availableHeight
        : desiredHeight;

    return _LayoutData(aspectRatio: aspectRatio, previewHeight: previewHeight);
  }

  double _calculateAvailableHeight(Size screenSize, EdgeInsets padding) {
    return screenSize.height -
        padding.top -
        padding.bottom -
        _Constants.topBarHeight -
        _getBottomControlsHeight(settings.selectedCameraRatio);
  }

  double _getBottomControlsHeight(CameraRatio ratio) {
    return switch (ratio) {
      CameraRatio.sixteenNine => 50,
      CameraRatio.fourThree => 0,
      CameraRatio.oneOne => 110,
      _ => 160,
    };
  }

  double _getAspectRatio(CameraRatio ratio) {
    return switch (ratio) {
      CameraRatio.sixteenNine => 16 / 9,
      CameraRatio.fourThree => 4 / 3,
      CameraRatio.oneOne => 1,
      _ => 16 / 9,
    };
  }

  double _getDesiredHeight(
    CameraRatio ratio,
    Size screenSize,
    double availableHeight,
  ) {
    return switch (ratio) {
      CameraRatio.sixteenNine => availableHeight,
      CameraRatio.fourThree => 510,
      CameraRatio.oneOne => screenSize.width,
      _ => availableHeight,
    };
  }
}

class _LayoutData {
  final double aspectRatio;
  final double previewHeight;

  const _LayoutData({required this.aspectRatio, required this.previewHeight});
}

class _Constants {
  static const double topBarHeight = 72;
}
