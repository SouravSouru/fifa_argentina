// player_3d_slider_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Stage 2 of the Semi-Final showcase flow.
// Scaffold wrapper that hosts the PlayerShowcaseSlider carousel.
// Shown after SemiFinalIntroScreen via Navigator.push (fade+slide route).
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../data/app_data.dart';
import '../widgets/player_showcase_slider.dart';

class Player3dSliderScreen extends StatefulWidget {
  const Player3dSliderScreen({super.key});

  @override
  State<Player3dSliderScreen> createState() => _Player3dSliderScreenState();
}

class _Player3dSliderScreenState extends State<Player3dSliderScreen>
    with SingleTickerProviderStateMixin {
  // Subtle background parallax animation
  late AnimationController _bgCtrl;
  late Animation<double> _bgAnim;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _bgAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_bgCtrl);
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.stadiumDark,
      body: AnimatedBuilder(
        animation: _bgAnim,
        builder: (context, child) {
          return Stack(
            children: [
              // ── Animated background ──────────────────────────────────────
              _AnimatedBackground(progress: _bgAnim.value),

              // ── Foreground content ────────────────────────────────────────
              child!,
            ],
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              // ── Header row ──────────────────────────────────────────────
              _buildHeader(context),

              const SizedBox(height: 6),

              // ── "11 PLAYERS" subtitle line ──────────────────────────────
              _buildSubtitle(),

              const SizedBox(height: 10),

              // ── 3D Coverflow carousel ────────────────────────────────────
              const Expanded(
                child: PlayerShowcaseSlider(
                  players: AppData.semiFinalSquad,
                ),
              ),

              // ── Swipe hint + indicator dots ──────────────────────────────
              _buildFooter(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).pop();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
                border: Border.all(color: Colors.white.withOpacity(0.11)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),

          const Spacer(),

          // Centre title
          Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.skyBlue, AppColors.electricBlue],
                ).createShader(bounds),
                child: Text(
                  'SEMI FINAL SQUAD',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 3.0,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'FIFA WORLD CUP 2026',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: AppColors.silver.withOpacity(0.5),
                  letterSpacing: 2.2,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Symmetry placeholder (same width as back button)
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // ── Subtitle line ────────────────────────────────────────────────────────────
  Widget _buildSubtitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _gradientLine(toRight: false),
        const SizedBox(width: 10),
        const Text('🇦🇷', style: TextStyle(fontSize: 13)),
        const SizedBox(width: 6),
        Text(
          '11 PLAYERS',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.silver.withOpacity(0.45),
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(width: 6),
        const Text('🇦🇷', style: TextStyle(fontSize: 13)),
        const SizedBox(width: 10),
        _gradientLine(toRight: true),
      ],
    );
  }

  Widget _gradientLine({required bool toRight}) {
    return Container(
      width: 28,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: toRight
              ? [AppColors.skyBlue.withOpacity(0.5), Colors.transparent]
              : [Colors.transparent, AppColors.skyBlue.withOpacity(0.5)],
        ),
      ),
    );
  }

  // ── Footer — swipe hint ──────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.swipe_rounded,
            color: AppColors.silver.withOpacity(0.28),
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(
            'Swipe or tap to explore',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.silver.withOpacity(0.28),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slowly breathing background: radial gradient shifts subtly over time
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedBackground extends StatelessWidget {
  final double progress; // 0.0 → 1.0 (looped)

  const _AnimatedBackground({required this.progress});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Radial centre drifts slowly between two positions
    final cx = lerpDouble(-0.2, 0.2, progress)!;
    final cy = lerpDouble(-0.8, -0.6, math.sin(progress * math.pi))!;

    return Stack(
      children: [
        // Base dark gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0C1F3C),
                Color(0xFF070D1A),
                Color(0xFF050A12),
              ],
            ),
          ),
        ),

        // Breathing radial glow
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(cx, cy),
              radius: 1.1,
              colors: [
                AppColors.skyBlue.withOpacity(0.12),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // Subtle diagonal stripes (reused Albiceleste motif)
        CustomPaint(
          size: size,
          painter: _BgStripePainter(),
        ),
      ],
    );
  }
}

class _BgStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.015)
      ..strokeWidth = 40
      ..style = PaintingStyle.stroke;

    for (int i = -4; i < 16; i++) {
      final x = i * 60.0;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BgStripePainter old) => false;
}
