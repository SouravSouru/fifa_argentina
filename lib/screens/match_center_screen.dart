import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../data/app_data.dart';
import '../models/player_model.dart';
import '../widgets/glass_card.dart';
import '../widgets/particles.dart';

class MatchCenterScreen extends StatefulWidget {
  const MatchCenterScreen({super.key});

  @override
  State<MatchCenterScreen> createState() => _MatchCenterScreenState();
}

class _MatchCenterScreenState extends State<MatchCenterScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scoreController;
  late AnimationController _statsController;
  late AnimationController _energyController;
  late AnimationController _entranceController;

  late Animation<double> _pulseMult;
  late Animation<double> _scoreScale;
  late Animation<double> _statsAnim;
  late Animation<double> _fadeIn;
  late Animation<double> _energyWave;

  bool _isScoreAnimated = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _statsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _energyController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseMult = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scoreScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.elasticOut),
    );

    _statsAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _statsController, curve: Curves.easeOutCubic),
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    _energyWave = Tween<double>(begin: 0, end: 1).animate(_energyController);

    _entranceController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _statsController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _scoreController.forward();
        setState(() => _isScoreAnimated = true);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scoreController.dispose();
    _statsController.dispose();
    _energyController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final match = AppData.currentMatch;

    return Scaffold(
      backgroundColor: AppColors.stadiumDark,
      body: Stack(
        children: [
          // Energy wave background
          AnimatedBuilder(
            animation: _energyWave,
            builder: (context, child) {
              return CustomPaint(
                painter: _EnergyWavePainter(progress: _energyWave.value),
                size: MediaQuery.of(context).size,
              );
            },
          ),

          // Particles
          const Positioned.fill(
            child: ParticleField(
              particleCount: 70,
              primaryColor: AppColors.skyBlue,
              secondaryColor: AppColors.statGreen,
              maxSize: 3,
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Header
                    _buildMatchHeader(match),
                    const SizedBox(height: 20),

                    // Score board
                    _buildScoreBoard(match),
                    const SizedBox(height: 24),

                    // Live timeline
                    _buildTimeline(match),
                    const SizedBox(height: 20),

                    // Stats section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildPossessionWheel(match),
                          const SizedBox(height: 16),
                          _buildStatRow(
                            'Shots',
                            match.homeShots,
                            match.awayShots,
                          ),
                          _buildStatRow(
                            'Corners',
                            match.homeCorners,
                            match.awayCorners,
                          ),
                          _buildStatRow('Fouls', 8, 12),
                          _buildStatRow('Yellow Cards', 1, 1),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Goals timeline
                    _buildGoalsTimeline(match),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchHeader(match) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        borderRadius: 16,
        opacity: 0.08,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.competition,
                  style: GoogleFonts.inter(
                    color: AppColors.silver.withOpacity(0.6),
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  match.venue,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseMult,
                  builder: (context, child) => Opacity(
                    opacity: _pulseMult.value,
                    child: child,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.statGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.statGreen.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.statGreen,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'LIVE  ${AppData.currentMatch.minute}\'',
                          style: GoogleFonts.inter(
                            color: AppColors.statGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBoard(match) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.skyBlue.withOpacity(0.2),
              blurRadius: 40,
              spreadRadius: -5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.skyBlue.withOpacity(0.18),
                    AppColors.darkNavy.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.skyBlue.withOpacity(0.25),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Home team
                  Expanded(child: _buildTeamScore(
                    flag: match.homeFlag,
                    name: match.homeTeam,
                    score: match.homeScore,
                    isHome: true,
                    isWinning: match.homeScore > match.awayScore,
                  )),

                  // VS divider
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _scoreScale,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scoreScale.value,
                            child: child,
                          );
                        },
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [AppColors.skyBlue, AppColors.electricBlue],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds),
                          child: Text(
                            '${match.homeScore} - ${match.awayScore}',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 46,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -2,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Full Time',
                        style: GoogleFonts.inter(
                          color: AppColors.silver.withOpacity(0.5),
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),

                  // Away team
                  Expanded(child: _buildTeamScore(
                    flag: match.awayFlag,
                    name: match.awayTeam,
                    score: match.awayScore,
                    isHome: false,
                    isWinning: match.awayScore > match.homeScore,
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamScore({
    required String flag,
    required String name,
    required int score,
    required bool isHome,
    required bool isWinning,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(flag, style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 8),
        Text(
          name.toUpperCase(),
          style: GoogleFonts.inter(
            color: isWinning ? Colors.white : AppColors.silver.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        if (isWinning)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.statGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'WINNING',
              style: GoogleFonts.inter(
                color: AppColors.statGreen,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimeline(match) {
    return SizedBox(
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(2),
              ),
              child: AnimatedBuilder(
                animation: _statsAnim,
                builder: (context, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor:
                        (match.minute / 90.0 * _statsAnim.value).clamp(0, 1),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.skyBlue, AppColors.electricBlue],
                        ),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.skyBlue.withOpacity(0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Events on timeline
          ...match.events.map((event) {
            final position = event.minute / 90.0;
            return Positioned(
              left: 20 + (MediaQuery.of(context).size.width - 40) * position - 8,
              child: GestureDetector(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: event.type == 'goal'
                            ? (event.isHome
                                ? AppColors.skyBlue
                                : AppColors.statOrange)
                            : event.type == 'yellow'
                                ? Colors.amber
                                : Colors.red,
                        boxShadow: [
                          BoxShadow(
                            color: (event.type == 'goal'
                                    ? AppColors.skyBlue
                                    : Colors.amber)
                                .withOpacity(0.5),
                            blurRadius: 6,
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          event.type == 'goal'
                              ? '⚽'
                              : event.type == 'yellow'
                                  ? '🟨'
                                  : '🟥',
                          style: const TextStyle(fontSize: 8),
                        ),
                      ),
                    ),
                    Text(
                      '${event.minute}\'',
                      style: GoogleFonts.inter(
                        color: AppColors.silver.withOpacity(0.5),
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPossessionWheel(match) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      opacity: 0.08,
      child: Row(
        children: [
          // Pie chart placeholder
          AnimatedBuilder(
            animation: _statsAnim,
            builder: (context, child) {
              return SizedBox(
                width: 80,
                height: 80,
                child: CustomPaint(
                  painter: _PossessionPainter(
                    homeFraction: match.homePossession / 100.0,
                    progress: _statsAnim.value,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POSSESSION',
                  style: GoogleFonts.inter(
                    color: AppColors.skyBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${match.homePossession}%',
                          style: GoogleFonts.inter(
                            color: AppColors.skyBlue,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(
                                color: AppColors.skyBlue.withOpacity(0.5),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          match.homeTeam,
                          style: GoogleFonts.inter(
                            color: AppColors.silver.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${match.awayPossession}%',
                          style: GoogleFonts.inter(
                            color: AppColors.statOrange,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          match.awayTeam,
                          style: GoogleFonts.inter(
                            color: AppColors.silver.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int home, int away) {
    final total = (home + away).toDouble();
    final homeFrac = total == 0 ? 0.5 : home / total;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Home value
          SizedBox(
            width: 36,
            child: Text(
              '$home',
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                color: AppColors.skyBlue,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Bar
          Expanded(
            child: AnimatedBuilder(
              animation: _statsAnim,
              builder: (context, child) {
                return Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.statOrange.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor:
                          (homeFrac * _statsAnim.value).clamp(0, 1),
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.skyBlue, AppColors.electricBlue],
                          ),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.skyBlue.withOpacity(0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          // Away value
          SizedBox(
            width: 36,
            child: Text(
              '$away',
              style: GoogleFonts.inter(
                color: AppColors.statOrange,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Label
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: AppColors.silver.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsTimeline(match) {
    final goals = match.events.where((e) => e.type == 'goal').toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        borderRadius: 20,
        opacity: 0.08,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GOAL EVENTS',
              style: GoogleFonts.inter(
                color: AppColors.skyBlue,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            ...goals.map((event) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: event.isHome
                              ? AppColors.skyBlue.withOpacity(0.15)
                              : AppColors.statOrange.withOpacity(0.15),
                          border: Border.all(
                            color: event.isHome
                                ? AppColors.skyBlue.withOpacity(0.4)
                                : AppColors.statOrange.withOpacity(0.4),
                          ),
                        ),
                        child: const Center(
                          child: Text('⚽', style: TextStyle(fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.playerName,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              event.isHome
                                  ? match.homeTeam
                                  : match.awayTeam,
                              style: GoogleFonts.inter(
                                color: AppColors.silver.withOpacity(0.5),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Text(
                          '${event.minute}\'',
                          style: GoogleFonts.inter(
                            color: AppColors.silver,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _PossessionPainter extends CustomPainter {
  final double homeFraction;
  final double progress;

  const _PossessionPainter({
    required this.homeFraction,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Background circle
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = Colors.white.withOpacity(0.05),
    );

    // Home arc
    final homeAngle = homeFraction * 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      homeAngle,
      false,
      Paint()
        ..color = AppColors.skyBlue
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Away arc
    final awayAngle = (1 - homeFraction) * 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + homeAngle,
      awayAngle,
      false,
      Paint()
        ..color = AppColors.statOrange.withOpacity(0.7)
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Center label
    final textPainter = TextPainter(
      text: TextSpan(
        text: '⚽',
        style: const TextStyle(fontSize: 18),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _PossessionPainter oldDelegate) =>
      oldDelegate.homeFraction != homeFraction ||
      oldDelegate.progress != progress;
}

class _EnergyWavePainter extends CustomPainter {
  final double progress;

  const _EnergyWavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 3; i++) {
      final offset = (progress + i / 3) % 1.0;
      final y = size.height * (0.3 + offset * 0.7);
      final opacity = (1 - offset) * 0.06;

      final paint = Paint()
        ..color = AppColors.skyBlue.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      final path = Path();
      path.moveTo(0, y);
      for (double x = 0; x <= size.width; x += 10) {
        final wave =
            math.sin((x / size.width * math.pi * 4) + progress * math.pi * 2) *
                20;
        path.lineTo(x, y + wave);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EnergyWavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
