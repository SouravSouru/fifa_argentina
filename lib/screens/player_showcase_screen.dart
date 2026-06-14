import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/player_model.dart';
import '../widgets/glass_card.dart';
import '../widgets/player_card.dart';
import '../widgets/particles.dart';

class PlayerShowcaseScreen extends StatefulWidget {
  final PlayerModel player;

  const PlayerShowcaseScreen({super.key, required this.player});

  @override
  State<PlayerShowcaseScreen> createState() => _PlayerShowcaseScreenState();
}

class _PlayerShowcaseScreenState extends State<PlayerShowcaseScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _rotateController;
  late AnimationController _pulseController;
  late AnimationController _counterController;

  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  late Animation<double> _rotateY;
  late Animation<double> _pulseGlow;
  late Animation<double> _counterAnim;

  bool _showAchievements = false;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _counterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    _rotateY = Tween<double>(begin: 0, end: 1).animate(_rotateController);

    _pulseGlow = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _counterAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _counterController, curve: Curves.easeOutCubic),
    );

    _entranceController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _counterController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    _counterController.dispose();
    super.dispose();
  }

  Color get _accentColor {
    if (widget.player.isCaptain) return AppColors.gold;
    if (widget.player.isStarPlayer) return AppColors.electricBlue;
    return AppColors.skyBlue;
  }

  Map<String, int> get _displayStats {
    final stats = widget.player.stats;
    // For GK, map diving/handling etc. to display labels
    if (widget.player.positionCode == 'GK') {
      return {
        'Diving': stats['diving'] ?? 90,
        'Handling': stats['handling'] ?? 88,
        'Kicking': stats['kicking'] ?? 80,
        'Reflexes': stats['reflexes'] ?? 92,
        'Positioning': stats['positioning'] ?? 92,
      };
    }
    return {
      'Pace': stats['pace'] ?? 80,
      'Shooting': stats['shooting'] ?? 80,
      'Passing': stats['passing'] ?? 80,
      'Dribbling': stats['dribbling'] ?? 80,
      'Defending': stats['defending'] ?? 50,
      'Physical': stats['physical'] ?? 75,
    };
  }

  Color _statColor(String key) {
    switch (key.toLowerCase()) {
      case 'pace':
        return AppColors.statGreen;
      case 'shooting':
        return AppColors.statOrange;
      case 'passing':
        return AppColors.skyBlue;
      case 'dribbling':
        return AppColors.electricBlue;
      case 'defending':
        return AppColors.deepBlue;
      case 'physical':
        return AppColors.statPurple;
      case 'diving':
        return AppColors.statGreen;
      case 'handling':
        return AppColors.skyBlue;
      case 'reflexes':
        return AppColors.statOrange;
      case 'positioning':
        return AppColors.electricBlue;
      default:
        return AppColors.skyBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.stadiumDark,
      body: Stack(
        children: [
          // Background glow for player accent color
          AnimatedBuilder(
            animation: _pulseGlow,
            builder: (context, child) {
              return Positioned(
                top: -100,
                left: 0,
                right: 0,
                child: Container(
                  height: 400,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topCenter,
                      radius: 0.9,
                      colors: [
                        _accentColor.withOpacity(0.12 * _pulseGlow.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Particles
          const Positioned.fill(
            child: ParticleField(
              particleCount: 40,
              maxSize: 2.5,
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
                    _buildHeader(),
                    const SizedBox(height: 24),

                    // 3D rotating card
                    SlideTransition(
                      position: _slideUp,
                      child: _buildRotatingCard(),
                    ),
                    const SizedBox(height: 28),

                    // Key stats row
                    SlideTransition(
                      position: _slideUp,
                      child: _buildKeyStatsRow(),
                    ),
                    const SizedBox(height: 24),

                    // Stat bars
                    SlideTransition(
                      position: _slideUp,
                      child: _buildStatBars(),
                    ),
                    const SizedBox(height: 24),

                    // Achievements toggle
                    _buildAchievementsSection(),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          // Player position badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _accentColor.withOpacity(0.4),
              ),
            ),
            child: Text(
              widget.player.positionCode,
              style: GoogleFonts.inter(
                color: _accentColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${widget.player.number} ${widget.player.name.toUpperCase()}',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.player.club,
                  style: GoogleFonts.inter(
                    color: AppColors.silver.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (widget.player.isCaptain)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withOpacity(0.15),
                border:
                    Border.all(color: AppColors.gold.withOpacity(0.4)),
              ),
              child: const Icon(Icons.star_rounded,
                  color: AppColors.gold, size: 18),
            ),
        ],
      ),
    );
  }

  Widget _buildRotatingCard() {
    return GestureDetector(
      onTap: () => setState(() => _isFlipped = !_isFlipped),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: AnimatedBuilder(
          animation: _rotateY,
          builder: (context, child) {
            final angle = _isFlipped ? 3.14159 : _rotateY.value * 0.12;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withOpacity(0.45),
                      blurRadius: 48,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // ── FRONT FACE: Full portrait photo ──
                      if (!_isFlipped) ...[
                        Image.asset(
                          widget.player.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, e, st) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  _accentColor.withOpacity(0.4),
                                  AppColors.darkNavy,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Bottom glass overlay
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      AppColors.stadiumDark.withOpacity(0.95),
                                    ],
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            widget.player.name.toUpperCase(),
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -0.5,
                                              height: 1,
                                              shadows: [const Shadow(color: Colors.black87, blurRadius: 8)],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '🇦🇷  ${widget.player.position}  •  ${widget.player.club}',
                                            style: GoogleFonts.inter(
                                              color: AppColors.silver.withOpacity(0.8),
                                              fontSize: 11,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Tap to see stats →',
                                            style: GoogleFonts.inter(
                                              color: _accentColor.withOpacity(0.7),
                                              fontSize: 10,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // OVR badge
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [_accentColor, _accentColor.withOpacity(0.5)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(color: _accentColor.withOpacity(0.5), blurRadius: 16),
                                        ],
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              widget.player.rating.toStringAsFixed(1),
                                              style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w900,
                                                height: 1,
                                              ),
                                            ),
                                            Text(
                                              'OVR',
                                              style: GoogleFonts.inter(
                                                color: Colors.white.withOpacity(0.7),
                                                fontSize: 8,
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
                              ),
                            ),
                          ),
                        ),
                        // Top: Number badge
                        Positioned(
                          top: 14, left: 14,
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _accentColor.withOpacity(0.25),
                              border: Border.all(color: _accentColor.withOpacity(0.6), width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                '#${widget.player.number}',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],

                      // ── BACK FACE: Stats grid ──
                      if (_isFlipped) ...[
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _accentColor.withOpacity(0.2),
                                AppColors.darkNavy,
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            children: [
                              Text(
                                'PLAYER STATS',
                                style: GoogleFonts.inter(
                                  color: _accentColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.player.shortName,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Expanded(
                                child: GridView.count(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 2.2,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: _displayStats.entries.map((e) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            e.key.toUpperCase(),
                                            style: GoogleFonts.inter(
                                              color: AppColors.silver.withOpacity(0.6),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          Text(
                                            '${e.value}',
                                            style: GoogleFonts.inter(
                                              color: _statColor(e.key),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              shadows: [Shadow(color: _statColor(e.key).withOpacity(0.4), blurRadius: 8)],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              Text(
                                'Tap to flip back →',
                                style: GoogleFonts.inter(
                                  color: _accentColor.withOpacity(0.5),
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Glow border always visible
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: _accentColor.withOpacity(0.35),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildKeyStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _AnimatedCounter(
              label: 'Goals',
              targetValue: widget.player.goals.toDouble(),
              color: AppColors.statOrange,
              animation: _counterAnim,
              isInteger: true,
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: Colors.white.withOpacity(0.08),
          ),
          Expanded(
            child: _AnimatedCounter(
              label: 'Assists',
              targetValue: widget.player.assists.toDouble(),
              color: AppColors.skyBlue,
              animation: _counterAnim,
              isInteger: true,
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: Colors.white.withOpacity(0.08),
          ),
          Expanded(
            child: _AnimatedCounter(
              label: 'Matches',
              targetValue: widget.player.matches.toDouble(),
              color: AppColors.statPurple,
              animation: _counterAnim,
              isInteger: true,
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: Colors.white.withOpacity(0.08),
          ),
          Expanded(
            child: _AnimatedCounter(
              label: 'Rating',
              targetValue: widget.player.rating,
              color: _accentColor,
              animation: _counterAnim,
              isInteger: false,
              decimals: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBars() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        borderRadius: 20,
        opacity: 0.08,
        glowColor: _accentColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ATTRIBUTES',
              style: GoogleFonts.inter(
                color: _accentColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            ..._displayStats.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: AnimatedStatBar(
                  label: e.key,
                  value: e.value,
                  color: _statColor(e.key),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(
                () => _showAchievements = !_showAchievements),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              borderRadius: 16,
              opacity: 0.08,
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_rounded,
                      color: AppColors.gold, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'ACHIEVEMENTS (${widget.player.achievements.length})',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _showAchievements ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.silver, size: 22),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            child: _showAchievements
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: widget.player.achievements
                          .asMap()
                          .entries
                          .map((e) => _AchievementTile(
                                achievement: e.value,
                                index: e.key,
                              ))
                          .toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCounter extends StatelessWidget {
  final String label;
  final double targetValue;
  final Color color;
  final Animation<double> animation;
  final bool isInteger;
  final int decimals;

  const _AnimatedCounter({
    required this.label,
    required this.targetValue,
    required this.color,
    required this.animation,
    required this.isInteger,
    this.decimals = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = targetValue * animation.value;
        return Column(
          children: [
            Text(
              isInteger
                  ? '${value.round()}'
                  : value.toStringAsFixed(decimals),
              style: GoogleFonts.inter(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(color: color.withOpacity(0.5), blurRadius: 12),
                ],
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                color: AppColors.silver.withOpacity(0.5),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final String achievement;
  final int index;

  const _AchievementTile({required this.achievement, required this.index});

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.emoji_events_rounded,
      Icons.military_tech_rounded,
      Icons.workspace_premium_rounded,
      Icons.stars_rounded,
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icons[index % icons.length],
            color: AppColors.gold,
            size: 18,
          ),
          const SizedBox(width: 12),
          Text(
            achievement,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
