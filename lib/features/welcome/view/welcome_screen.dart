import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pixora/features/welcome/controller/welcome_animation_controller.dart';
import 'package:pixora/features/welcome/widgets/welcome_background.dart';
import 'package:pixora/features/welcome/widgets/welcome_content.dart';
import 'package:pixora/features/welcome/widgets/welcome_swipe_indicator.dart';
import 'package:pixora/features/welcome/widgets/welcome_top_bar.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final WelcomeAnimationController anim;

  @override
  void initState() {
    super.initState();
    anim = WelcomeAnimationController(this);
  }

  @override
  void dispose() {
    anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (d) {
          if (d.primaryVelocity != null && d.primaryVelocity! < -300) {
            anim.continueFlowFromWelcome(context);
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            WelcomeBackground(fade: anim.fade, scale: anim.scale),
            Container(color: Colors.black.withValues(alpha: 0.18)),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WelcomeTopBar(fade: anim.fade),
                    const Spacer(),
                    WelcomeContentSection(
                      fade: anim.fade,
                      onTap: () => anim.continueFlowFromWelcome(context),
                    ),
                    const SizedBox(height: 20),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: WelcomeSwipeIndicator(
                            controller: anim.arrowController,
                            arrowOpacity: anim.arrowOpacity,
                            onCompleted: () =>
                                anim.continueFlowFromWelcome(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
