// semi_final_intro_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Stage 1 of the 3D showcase flow.
// Cinematic reveal: Argentina crest + "SEMI FINAL" gold shimmer + particles.
// Auto-transitions to Player3dSliderScreen after 5 seconds, or on tap/swipe.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import 'player_3d_slider_screen.dart';

class SemiFinalIntroScreen extends StatefulWidget {
  const SemiFinalIntroScreen({super.key});

  @override
  State<SemiFinalIntroScreen> createState() => _SemiFinalIntroScreenState();
}

class _SemiFinalIntroScreenState extends State<SemiFinalIntroScreen>
    with TickerProviderStateMixin {
  // ── Master sequencer (3.5 s) drives all intro animations via Interval ──────
  late AnimationController _sequenceCtrl;

  // Phase 0–0.25: background fades in
  late Animation<double> _bgOpacity;
  // Phase 0.2–0.55: crest scales in with elastic overshoot
  late Animation<double> _crestScale;
  late Animation<double> _crestOpacity;
  // Phase 0.45–0.78: "SEMI FINAL" shimmer sweep
  late Animation<double> _shimmerPos;
  // Phase 0.6–0.82: subtext fades in
  late Animation<double> _subtextOpacity;
  // Phase 0.75–1.0: CTA fades + slides in
  late Animation<double> _ctaOpacity;
  late Animation<Offset> _ctaSlide;

  // ── Independent looping controllers ─────────────────────────────────────────
  late AnimationController _particleCtrl; // drives the floating particles
  late AnimationController _glowCtrl; // drives the crest & button glow pulse
  late Animation<double> _glowAnim;

  // Guard against double navigation
  bool _navigated = false;

  // Particles initialized once per widget lifetime
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    // ── Build particle list ──────────────────────────────────────────────────
    final rand = math.Random(42);
    for (int i = 0; i < 45; i++) {
      _particles.add(
        _Particle(
          x: rand.nextDouble(),
          yStart: rand.nextDouble(),
          speed: 0.04 + rand.nextDouble() * 0.10,
          radius: 1.2 + rand.nextDouble() * 3.2,
          opacity: 0.25 + rand.nextDouble() * 0.55,
          phase: rand.nextDouble(),
          isGold: rand.nextDouble() < 0.28,
        ),
      );
    }

    // ── Sequence controller ──────────────────────────────────────────────────
    _sequenceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _bgOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _sequenceCtrl,
        curve: const Interval(0.00, 0.25, curve: Curves.easeIn),
      ),
    );

    _crestScale = Tween<double>(begin: 0.05, end: 1.0).animate(
      CurvedAnimation(
        parent: _sequenceCtrl,
        curve: const Interval(0.18, 0.55, curve: Curves.elasticOut),
      ),
    );

    _crestOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _sequenceCtrl,
        curve: const Interval(0.18, 0.38, curve: Curves.easeIn),
      ),
    );

    // Shimmer travels from -0.5 to 1.5 (off-screen left → off-screen right)
    _shimmerPos = Tween<double>(begin: -0.5, end: 1.5).animate(
      CurvedAnimation(
        parent: _sequenceCtrl,
        curve: const Interval(0.45, 0.78, curve: Curves.easeInOut),
      ),
    );

    _subtextOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _sequenceCtrl,
        curve: const Interval(0.60, 0.82, curve: Curves.easeIn),
      ),
    );

    _ctaOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _sequenceCtrl,
        curve: const Interval(0.75, 1.00, curve: Curves.easeIn),
      ),
    );

    _ctaSlide = Tween<Offset>(begin: const Offset(0.0, 0.6), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _sequenceCtrl,
            curve: const Interval(0.75, 1.00, curve: Curves.easeOutCubic),
          ),
        );

    // ── Looping controllers ──────────────────────────────────────────────────
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(
      begin: 0.45,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    // ── Start ────────────────────────────────────────────────────────────────
    _sequenceCtrl.forward();

    // Auto-navigate after 5 s (ample time to enjoy the intro)
    Future.delayed(const Duration(milliseconds: 5000), () {
      if (mounted && !_navigated) _navigateToSlider();
    });
  }

  @override
  void dispose() {
    _sequenceCtrl.dispose();
    _particleCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────
  void _navigateToSlider() {
    if (_navigated) return;
    _navigated = true;
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(_buildSliderRoute());
  }

  PageRoute<void> _buildSliderRoute() {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondary) =>
          const Player3dSliderScreen(),
      transitionsBuilder: (context, animation, secondary, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.07),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 650),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.stadiumDark,

      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_sequenceCtrl.value > 0.45) _navigateToSlider();
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _sequenceCtrl,
            _particleCtrl,
            _glowCtrl,
          ]),
          builder: (context, _) {
            return Stack(
              children: [
                _BackgroundLayer(opacity: _bgOpacity.value, size: size),

                Opacity(
                  opacity: (_sequenceCtrl.value * 4.0).clamp(0.0, 1.0),
                  child: CustomPaint(
                    size: size,
                    painter: _ParticlePainter(
                      particles: _particles,
                      progress: _particleCtrl.value,
                    ),
                  ),
                ),

                CustomPaint(
                  size: size,
                  painter: _LightRayPainter(
                    intensity: _ctaOpacity.value * _glowAnim.value * 0.35,
                  ),
                ),

                // 4. Foreground content (crest + text + CTA)
                _buildContent(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: Column(
        children: [
          const Spacer(flex: 2),

          // ── Argentina crest ──────────────────────────────────────────────
          Opacity(
            opacity: _crestOpacity.value,
            child: Transform.scale(
              scale: _crestScale.value,
              child: _buildCrest(),
            ),
          ),

          const SizedBox(height: 28),

          // ── "SEMI FINAL" shimmer text ─────────────────────────────────────
          _buildShimmerTitle(),

          const SizedBox(height: 12),

          // ── Decorative divider ────────────────────────────────────────────
          Opacity(opacity: _subtextOpacity.value, child: _buildDivider()),

          const SizedBox(height: 14),

          // ── Subtitle lines ────────────────────────────────────────────────
          Opacity(opacity: _subtextOpacity.value, child: _buildSubtexts()),

          const Spacer(flex: 3),

          // ── CTA button ────────────────────────────────────────────────────
          SlideTransition(
            position: _ctaSlide,
            child: Opacity(
              opacity: _ctaOpacity.value,
              child: _buildCtaButton(),
            ),
          ),

          const SizedBox(height: 8),

          // ── Tap-anywhere hint ─────────────────────────────────────────────
          Opacity(
            opacity: _ctaOpacity.value * 0.5,
            child: Text(
              'or tap anywhere to continue',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppColors.silver.withOpacity(0.4),
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Argentina crest ─────────────────────────────────────────────────────────
  Widget _buildCrest() {
    return Container(
      width: 148,
      height: 148,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.skyBlue.withOpacity(0.35 * _glowAnim.value),
            blurRadius: 70 * _glowAnim.value,
            spreadRadius: 12,
          ),
          BoxShadow(
            color: AppColors.gold.withOpacity(0.18 * _glowAnim.value),
            blurRadius: 50,
            spreadRadius: 6,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment(-0.3, -0.3),
            radius: 1.1,
            colors: [Color(0xFF1E4A88), Color(0xFF0C2244)],
          ),
          border: Border.all(
            color: AppColors.gold.withOpacity(0.65),
            width: 2.5,
          ),
        ),
        child: ClipOval(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Subtle inner glow ring
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.06),
                    width: 1,
                  ),
                ),
              ),
              const Text('🇦🇷', style: TextStyle(fontSize: 74)),
            ],
          ),
        ),
      ),
    );
  }

  // ── "SEMI FINAL" with animated shimmer sweep ─────────────────────────────────
  Widget _buildShimmerTitle() {
    final pos = _shimmerPos.value; // -0.5 → 1.5

    return ShaderMask(
      shaderCallback: (bounds) {
        // Shimmer band: bright white highlight sweeping over gold base
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            Color(0xFFFFB800), // warm gold
            Color(0xFFFFD700), // bright gold
            Color(0xFFFFFFFF), // white highlight
            Color(0xFFFFE55C), // gold shimmer
            Color(0xFFFF8C00), // deep gold
          ],
          stops: [
            (pos - 0.45).clamp(0.0, 1.0),
            (pos - 0.15).clamp(0.0, 1.0),
            pos.clamp(0.0, 1.0),
            (pos + 0.15).clamp(0.0, 1.0),
            (pos + 0.45).clamp(0.0, 1.0),
          ],
        ).createShader(bounds);
      },
      child: Text(
        'SEMI FINAL',
        style: GoogleFonts.inter(
          fontSize: 56,
          fontWeight: FontWeight.w900,
          color: Colors.white, // ShaderMask overrides this
          letterSpacing: 7,
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, AppColors.gold],
            ),
          ),
        ),
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.gold,
          ),
        ),
        Container(
          width: 40,
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gold, Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubtexts() {
    return Column(
      children: [
        Text(
          'FIFA WORLD CUP 2026',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.silver.withOpacity(0.75),
            letterSpacing: 3.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'LA ALBICELESTE — SQUAD READY',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.skyBlue.withOpacity(0.65),
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }

  // ── CTA button with animated glow ────────────────────────────────────────────
  Widget _buildCtaButton() {
    return GestureDetector(
      onTap: _navigateToSlider,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: const LinearGradient(
            colors: [AppColors.skyBlue, AppColors.electricBlue],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.skyBlue.withOpacity(0.45 * _glowAnim.value),
              blurRadius: 24,
              spreadRadius: 3,
            ),
            BoxShadow(
              color: AppColors.electricBlue.withOpacity(0.2 * _glowAnim.value),
              blurRadius: 40,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'VIEW SQUAD',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 2.5,
              ),
            ),
            const SizedBox(width: 14),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background: gradient + Albiceleste diagonal stripe motif
// ─────────────────────────────────────────────────────────────────────────────
class _BackgroundLayer extends StatelessWidget {
  final double opacity;
  final Size size;

  const _BackgroundLayer({required this.opacity, required this.size});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Stack(
        children: [
          // Deep navy gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0E2040),
                  Color(0xFF070E1C),
                  Color(0xFF050A12),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Diagonal stripes — Argentina flag motif
          CustomPaint(size: size, painter: _StripePainter()),
          // Top radial glow (sky-blue tint at the top)
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, -1.0),
                radius: 1.2,
                colors: [Color(0x2274C0E8), Colors.transparent],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painters
// ─────────────────────────────────────────────────────────────────────────────

/// Subtle Albiceleste diagonal stripe pattern (white on dark)
class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.022)
      ..strokeWidth = 48
      ..style = PaintingStyle.stroke;

    for (int i = -6; i < 18; i++) {
      final x = i * 55.0;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height * 0.9, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StripePainter old) => false;
}

/// Floating orb particles driven by [progress] in [0, 1]
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  const _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Particles drift upward; wrap around vertically
      final yFrac =
          ((p.yStart - progress * p.speed - p.phase) % 1.0 + 1.0) % 1.0;
      // Slight sinusoidal horizontal drift
      final xFrac =
          p.x + math.sin((progress * 1.8 + p.phase) * math.pi * 2) * 0.025;

      final pixelX = xFrac * size.width;
      final pixelY = yFrac * size.height;

      // Fade in near top, fade out near very top (loop transition)
      final edgeFade =
          (yFrac * 6).clamp(0.0, 1.0) * ((1.0 - yFrac) * 6).clamp(0.0, 1.0);
      final alpha = ((p.opacity * edgeFade) * 255).round().clamp(0, 255);

      final paint = Paint()
        ..color = p.isGold
            ? Color.fromARGB(alpha, 255, 215, 0)
            : Color.fromARGB(alpha, 116, 192, 232)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.radius * 0.7);

      canvas.drawCircle(Offset(pixelX, pixelY), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

/// Radial light rays emanating from the crest position
class _LightRayPainter extends CustomPainter {
  final double intensity;

  const _LightRayPainter({required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity < 0.01) return;

    final center = Offset(size.width / 2, size.height * 0.38);
    final paint = Paint();

    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * math.pi * 2;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + math.cos(angle) * size.width * 1.2,
          center.dy + math.sin(angle) * size.height * 1.2,
        )
        ..lineTo(
          center.dx + math.cos(angle + 0.12) * size.width * 1.2,
          center.dy + math.sin(angle + 0.12) * size.height * 1.2,
        )
        ..close();

      final rect = Rect.fromCircle(center: center, radius: size.width);
      paint.shader = RadialGradient(
        colors: [
          AppColors.skyBlue.withOpacity(0.06 * intensity),
          Colors.transparent,
        ],
      ).createShader(rect);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_LightRayPainter old) => old.intensity != intensity;
}

// ─────────────────────────────────────────────────────────────────────────────
// Data class for a single particle
// ─────────────────────────────────────────────────────────────────────────────
class _Particle {
  final double x;
  final double yStart;
  final double speed;
  final double radius;
  final double opacity;
  final double phase;
  final bool isGold;

  const _Particle({
    required this.x,
    required this.yStart,
    required this.speed,
    required this.radius,
    required this.opacity,
    required this.phase,
    required this.isGold,
  });
}
