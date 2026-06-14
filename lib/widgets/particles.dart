import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Floating animated particle system for stadium atmosphere
class ParticleField extends StatefulWidget {
  final int particleCount;
  final Color primaryColor;
  final Color secondaryColor;
  final double maxSize;
  final double minSize;

  const ParticleField({
    super.key,
    this.particleCount = 60,
    this.primaryColor = AppColors.skyBlue,
    this.secondaryColor = AppColors.electricBlue,
    this.maxSize = 4,
    this.minSize = 1,
  });

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField>
    with TickerProviderStateMixin {
  late List<_Particle> _particles;
  late AnimationController _controller;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _initParticles();
  }

  void _initParticles() {
    _particles = List.generate(widget.particleCount, (i) {
      return _Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: widget.minSize +
            _random.nextDouble() * (widget.maxSize - widget.minSize),
        speed: 0.003 + _random.nextDouble() * 0.008,
        drift: (_random.nextDouble() - 0.5) * 0.002,
        opacity: 0.2 + _random.nextDouble() * 0.6,
        color: _random.nextBool()
            ? widget.primaryColor
            : widget.secondaryColor,
        phase: _random.nextDouble() * math.pi * 2,
        twinkleSpeed: 0.5 + _random.nextDouble() * 2,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            time: _controller.value * 20,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  double x;
  double y;
  final double size;
  final double speed;
  final double drift;
  final double opacity;
  final Color color;
  final double phase;
  final double twinkleSpeed;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.drift,
    required this.opacity,
    required this.color,
    required this.phase,
    required this.twinkleSpeed,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double time;

  _ParticlePainter({required this.particles, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Update position
      double y = (p.y - p.speed * time) % 1.0;
      if (y < 0) y += 1;
      double x = (p.x + p.drift * math.sin(time + p.phase)) % 1.0;

      // Twinkle effect
      final twinkle =
          0.5 + 0.5 * math.sin(time * p.twinkleSpeed + p.phase);
      final currentOpacity = p.opacity * twinkle;

      final paint = Paint()
        ..color = p.color.withOpacity(currentOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.8);

      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}

/// Animated Argentina flag with wave effect
class ArgentinaFlagPainter extends CustomPainter {
  final double waveProgress;
  final double glowIntensity;

  const ArgentinaFlagPainter({
    required this.waveProgress,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background (light blue stripes + white center)
    final bluePaint = Paint()
      ..color = AppColors.skyBlue.withOpacity(0.9);
    final whitePaint = Paint()..color = AppColors.pureWhite.withOpacity(0.95);

    // Top blue stripe
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h / 3), bluePaint);
    // White center
    canvas.drawRect(Rect.fromLTWH(0, h / 3, w, h / 3), whitePaint);
    // Bottom blue stripe
    canvas.drawRect(Rect.fromLTWH(0, 2 * h / 3, w, h / 3), bluePaint);

    // Sun of May in center
    _drawSun(canvas, Offset(w / 2, h / 2), h * 0.22, glowIntensity);
  }

  void _drawSun(Canvas canvas, Offset center, double radius, double glow) {
    final goldGlow = Paint()
      ..color = AppColors.gold.withOpacity(glow * 0.4)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16);

    canvas.drawCircle(center, radius * 1.5, goldGlow);

    final facePaint = Paint()..color = AppColors.gold;
    canvas.drawCircle(center, radius * 0.55, facePaint);

    // Sun rays
    const rayCount = 16;
    for (int i = 0; i < rayCount; i++) {
      final angle = (i * math.pi * 2) / rayCount;
      final isLong = i % 2 == 0;
      final inner = radius * 0.65;
      final outer = isLong ? radius * 1.1 : radius * 0.88;
      final width = isLong ? 4.5 : 3.0;

      final rayPaint = Paint()
        ..color = AppColors.gold
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(
            center.dx + inner * math.cos(angle),
            center.dy + inner * math.sin(angle)),
        Offset(
            center.dx + outer * math.cos(angle),
            center.dy + outer * math.sin(angle)),
        rayPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ArgentinaFlagPainter oldDelegate) =>
      oldDelegate.waveProgress != waveProgress ||
      oldDelegate.glowIntensity != glowIntensity;
}

/// Animated Argentina Flag Widget
class ArgentinaFlag extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ArgentinaFlag({
    super.key,
    this.width = 80,
    this.height = 54,
    this.borderRadius = 6,
  });

  @override
  State<ArgentinaFlag> createState() => _ArgentinaFlagState();
}

class _ArgentinaFlagState extends State<ArgentinaFlag>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _waveAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _waveAnim = Tween<double>(begin: 0, end: 1).animate(_controller);
    _glowAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: CustomPaint(
              painter: ArgentinaFlagPainter(
                waveProgress: _waveAnim.value,
                glowIntensity: _glowAnim.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Stadium background lighting effect
class StadiumLightPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;

  const StadiumLightPainter({
    required this.progress,
    this.primaryColor = AppColors.skyBlue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Volumetric light cone from top
    _drawLightCone(canvas, size, Offset(size.width * 0.3, 0),
        AppColors.skyBlue.withOpacity(0.06 + progress * 0.04));
    _drawLightCone(canvas, size, Offset(size.width * 0.7, 0),
        AppColors.electricBlue.withOpacity(0.04 + progress * 0.03));

    // Stadium floor glow
    final groundGlow = Paint()
      ..shader = RadialGradient(
        center: Alignment.bottomCenter,
        radius: 1.5,
        colors: [
          primaryColor.withOpacity(0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(
        Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.4),
        groundGlow);
  }

  void _drawLightCone(Canvas canvas, Size size, Offset origin, Color color) {
    final path = Path()
      ..moveTo(origin.dx, origin.dy)
      ..lineTo(origin.dx - size.width * 0.4, size.height)
      ..lineTo(origin.dx + size.width * 0.4, size.height)
      ..close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color, Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant StadiumLightPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Football field painter for lineup screen
class FootballFieldPainter extends CustomPainter {
  final double glowOpacity;

  const FootballFieldPainter({this.glowOpacity = 0.6});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Pitch green base
    final pitchPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0A2E12),
          const Color(0xFF0D3A17),
          const Color(0xFF0A2E12),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(12)),
      pitchPaint,
    );

    // Alternating stripes
    final stripe1 = Paint()..color = const Color(0xFF0E3319).withOpacity(0.7);
    final stripeW = w / 8;
    for (int i = 0; i < 8; i++) {
      if (i.isEven) {
        canvas.drawRect(
          Rect.fromLTWH(i * stripeW, 0, stripeW, h),
          stripe1,
        );
      }
    }

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(glowOpacity * 0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final glowLinePaint = Paint()
      ..color = AppColors.skyBlue.withOpacity(glowOpacity * 0.15)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // Outer boundary
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.04, h * 0.02, w * 0.92, h * 0.96),
          const Radius.circular(4)),
      linePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.04, h * 0.02, w * 0.92, h * 0.96),
          const Radius.circular(4)),
      glowLinePaint,
    );

    // Center line
    canvas.drawLine(Offset(w * 0.04, h / 2), Offset(w * 0.96, h / 2), linePaint);
    canvas.drawLine(Offset(w * 0.04, h / 2), Offset(w * 0.96, h / 2), glowLinePaint);

    // Center circle
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.14, linePaint);
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.14, glowLinePaint);
    canvas.drawCircle(Offset(w / 2, h / 2), 3,
        Paint()..color = Colors.white.withOpacity(glowOpacity * 0.8));

    // Penalty areas (top)
    canvas.drawRect(
      Rect.fromLTWH(w * 0.25, h * 0.02, w * 0.5, h * 0.18),
      linePaint,
    );
    // Penalty areas (bottom)
    canvas.drawRect(
      Rect.fromLTWH(w * 0.25, h * 0.80, w * 0.5, h * 0.18),
      linePaint,
    );

    // Goal areas (top)
    canvas.drawRect(
      Rect.fromLTWH(w * 0.36, h * 0.02, w * 0.28, h * 0.08),
      linePaint,
    );
    // Goal areas (bottom)
    canvas.drawRect(
      Rect.fromLTWH(w * 0.36, h * 0.90, w * 0.28, h * 0.08),
      linePaint,
    );

    // Penalty spots
    canvas.drawCircle(Offset(w / 2, h * 0.12),
        2.5, Paint()..color = Colors.white.withOpacity(0.7));
    canvas.drawCircle(Offset(w / 2, h * 0.88),
        2.5, Paint()..color = Colors.white.withOpacity(0.7));
  }

  @override
  bool shouldRepaint(covariant FootballFieldPainter oldDelegate) =>
      oldDelegate.glowOpacity != glowOpacity;
}
