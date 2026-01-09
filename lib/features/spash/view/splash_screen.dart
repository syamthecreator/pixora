import 'package:flutter/material.dart';
import 'package:pixora/core/constants/app_images.dart';
import 'package:pixora/features/spash/models/splash_brand_model.dart';
import 'package:pixora/features/spash/widgets/splash_text.dart';

import '../controller/splash_controller.dart';
import '../widgets/splash_logo.dart';
import '../widgets/shimmer_loader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late SplashController controller;

  final brand = const SplashBrandModel(
    title: 'PIXORA',
    subtitle: 'Create. Capture. Inspire.',
    logoUrl: AppImages.logo,
  );

  @override
  void initState() {
    super.initState();

    controller = SplashController();
    controller.init(this);

    controller.navigateFromSplashScreen(context);
  }

  @override
  void dispose() {
    controller.disposeAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            controller.pulseController!,
            controller.rotateController!,
          ]),
          builder: (_, _) {
            return Opacity(
              opacity: controller.fade.value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SplashLogo(
                    scale: controller.scale,
                    rotation: controller.rotation,
                    logoUrl: brand.logoUrl,
                  ),
                  const SizedBox(height: 40),
                  SplashText(brand: brand),
                  const SizedBox(height: 50),
                  const DotLoader(dotSize: 10, spacing: 4),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
