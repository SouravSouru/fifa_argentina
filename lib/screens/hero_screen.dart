import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../data/app_data.dart';
import '../widgets/particles.dart';
import '../widgets/glass_card.dart';
import '../widgets/player_card.dart';

class HeroScreen extends StatefulWidget {
  final VoidCallback? onNavigateToSquad;
  final VoidCallback? onNavigateToMatch;

  const HeroScreen({
    super.key,
    this.onNavigateToSquad,
    this.onNavigateToMatch,
  });

  @override
  State<HeroScreen> createState() => _HeroScreenState();
}

class _HeroScreenState extends State<HeroScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _lightController;

  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;
  late Animation<double> _floatY;
  late Animation<double> _pulseScale;
  late Animation<double> _lightProgress;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _lightController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _floatY = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _pulseScale = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _lightProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _lightController, curve: Curves.easeInOut),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    _lightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.stadiumDark,
      body: Stack(
        children: [
          // Stadium volumetric light background
          AnimatedBuilder(
            animation: _lightProgress,
            builder: (context, child) => CustomPaint(
              painter: StadiumLightPainter(progress: _lightProgress.value),
              size: size,
            ),
          ),

          // Particle field
          const Positioned.fill(
            child: ParticleField(
              particleCount: 80,
              primaryColor: AppColors.skyBlue,
              secondaryColor: AppColors.electricBlue,
            ),
          ),

          // Dark radial overlay for depth
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Colors.transparent,
                    AppColors.stadiumDark.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Top bar
                      _buildTopBar(),
                      const SizedBox(height: 40),

                      // Hero banner area
                      SlideTransition(
                        position: _slideIn,
                        child: _buildHeroBanner(size),
                      ),
                      const SizedBox(height: 32),

                      // Stats strip
                      _buildStatsStrip(),
                      const SizedBox(height: 32),

                      // Featured players
                      _buildFeaturedPlayers(),
                      const SizedBox(height: 32),

                      // Action buttons
                      _buildActionButtons(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ArgentinaFlag(width: 36, height: 24, borderRadius: 4),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ARGENTINA',
                  style: GoogleFonts.inter(
                    color: AppColors.skyBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                  ),
                ),
                Text(
                  'National Team',
                  style: GoogleFonts.inter(
                    color: AppColors.silver.withOpacity(0.7),
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            const GlowDot(color: AppColors.statGreen, size: 8),
            const SizedBox(width: 6),
            Text(
              'WORLD CUP 2026',
              style: GoogleFonts.inter(
                color: AppColors.statGreen,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroBanner(Size size) {
    return AnimatedBuilder(
      animation: _floatY,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatY.value * 0.3),
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        height: size.height * 0.42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.skyBlue.withOpacity(0.25),
              blurRadius: 50,
              spreadRadius: -10,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.skyBlue.withOpacity(0.22),
                    AppColors.deepBlue.withOpacity(0.14),
                    AppColors.stadiumDark.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.skyBlue.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Stack(
                children: [
                  // Background glow
                  Positioned(
                    top: -30,
                    right: -30,
                    child: AnimatedBuilder(
                      animation: _pulseScale,
                      builder: (context, child) => Transform.scale(
                        scale: _pulseScale.value,
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.skyBlue.withOpacity(0.15),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // World Cup trophy icon area
                  Positioned(
                    right: 20,
                    top: 20,
                    child: _buildTrophyBadge(),
                  ),

                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.gold.withOpacity(0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.emoji_events,
                                      color: AppColors.gold, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    '3× WORLD CHAMPIONS',
                                    style: GoogleFonts.inter(
                                      color: AppColors.gold,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              AppColors.pureWhite,
                              AppColors.skyBlue,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'LA\nALBICELESTE',
                            style: GoogleFonts.inter(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 0.95,
                              letterSpacing: -2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'FIFA World Cup 2026 • USA / Canada / Mexico',
                          style: GoogleFonts.inter(
                            color: AppColors.silver.withOpacity(0.8),
                            fontSize: 12,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrophyBadge() {
    return AnimatedBuilder(
      animation: _pulseScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseScale.value,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: AppColors.goldGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsStrip() {
    final stats = [
      {'label': 'Squad', 'value': '26', 'icon': Icons.people_rounded},
      {'label': 'Avg Age', 'value': '27.3', 'icon': Icons.calendar_today_rounded},
      {'label': 'Goals', 'value': '112', 'icon': Icons.sports_soccer_rounded},
      {
        'label': 'FIFA Rank',
        'value': '#1',
        'icon': Icons.leaderboard_rounded
      },
    ];

    return Row(
      children: stats
          .map((s) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 8),
                    borderRadius: 16,
                    opacity: 0.08,
                    child: Column(
                      children: [
                        Icon(
                          s['icon'] as IconData,
                          color: AppColors.skyBlue,
                          size: 18,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s['value'] as String,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          s['label'] as String,
                          style: GoogleFonts.inter(
                            color: AppColors.silver.withOpacity(0.6),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildFeaturedPlayers() {
    final featured = AppData.squad.where((p) => p.isStarPlayer).take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STAR PLAYERS',
              style: GoogleFonts.inter(
                color: AppColors.silver.withOpacity(0.6),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            GestureDetector(
              onTap: widget.onNavigateToSquad,
              child: Text(
                'View All →',
                style: GoogleFonts.inter(
                  color: AppColors.skyBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...featured.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PlayerCardHorizontal(
                player: p,
                isSelected: p.isCaptain,
              ),
            )),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _PremiumButton(
          label: 'VIEW SQUAD LINEUP',
          icon: Icons.sports_soccer,
          isPrimary: true,
          onTap: widget.onNavigateToSquad,
        ),
        const SizedBox(height: 12),
        _PremiumButton(
          label: 'MATCH CENTER — LIVE',
          icon: Icons.live_tv_rounded,
          isPrimary: false,
          hasLiveIndicator: true,
          onTap: widget.onNavigateToMatch,
        ),
      ],
    );
  }
}

class _PremiumButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final bool hasLiveIndicator;
  final VoidCallback? onTap;

  const _PremiumButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    this.hasLiveIndicator = false,
    this.onTap,
  });

  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? const LinearGradient(
                    colors: [AppColors.skyBlue, AppColors.deepBlue],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: widget.isPrimary
                ? null
                : Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isPrimary
                  ? AppColors.skyBlue.withOpacity(0.5)
                  : Colors.white.withOpacity(0.12),
              width: 1,
            ),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.skyBlue.withOpacity(0.35),
                      blurRadius: 20,
                      spreadRadius: -2,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.hasLiveIndicator) ...[
                const GlowDot(color: AppColors.statGreen, size: 8),
                const SizedBox(width: 10),
              ] else ...[
                Icon(widget.icon,
                    color: Colors.white,
                    size: 18),
                const SizedBox(width: 10),
              ],
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
