import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pixora/core/theme/app_colors.dart';
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
        onHorizontalDragEnd: _handleSwipeEnd,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildBackground(),
            _buildOverlayGradient(),
            _buildForegroundContent(),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Gesture ─────────────────────────

  void _handleSwipeEnd(DragEndDetails details) {
    if (details.primaryVelocity != null && details.primaryVelocity! < -300) {
      anim.continueFlowFromWelcome(context);
    }
  }

  // ───────────────────────── Layers ─────────────────────────

  Widget _buildBackground() {
    return WelcomeBackground(fade: anim.fade, scale: anim.scale);
  }

  Widget _buildOverlayGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.15),
            Colors.black.withValues(alpha: 0.35),
          ],
        ),
      ),
    );
  }

  Widget _buildForegroundContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelcomeTopBar(fade: anim.fade),
            const Spacer(),
            WelcomeContentSection(fade: anim.fade, onTap: _continueFlow),
            const SizedBox(height: 20),
            _buildSwipeGlassCard(),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Glass Swipe ─────────────────────────

  Widget _buildSwipeGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: _glassDecoration,
          child: WelcomeSwipeIndicator(
            controller: anim.arrowController,
            arrowOpacity: anim.arrowOpacity,
            onCompleted: _continueFlow,
          ),
        ),
      ),
    );
  }

  // ───────────────────────── Helpers ─────────────────────────

  void _continueFlow() {
    anim.continueFlowFromWelcome(context);
  }

  BoxDecoration get _glassDecoration => BoxDecoration(
    color: AppColors.neonPurple.withValues(alpha: 0.10),
    borderRadius: BorderRadius.circular(32),
    border: Border.all(
      color: AppColors.neonPurple.withValues(alpha: 0.35),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.neonPurple.withValues(alpha: 0.18),
        blurRadius: 24,
        spreadRadius: 2,
      ),
    ],
  );
}
