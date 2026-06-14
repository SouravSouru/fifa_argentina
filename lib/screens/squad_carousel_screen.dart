import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../data/app_data.dart';
import '../models/player_model.dart';
import '../widgets/player_card.dart';
import '../widgets/glass_card.dart';
import '../widgets/particles.dart';

class SquadCarouselScreen extends StatefulWidget {
  final Function(PlayerModel)? onPlayerSelected;

  const SquadCarouselScreen({super.key, this.onPlayerSelected});

  @override
  State<SquadCarouselScreen> createState() => _SquadCarouselScreenState();
}

class _SquadCarouselScreenState extends State<SquadCarouselScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _entranceController;
  late AnimationController _lightController;
  late Animation<double> _fadeIn;
  late Animation<double> _lightProgress;

  int _currentIndex = 0;
  double _pageOffset = 0;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      viewportFraction: 0.62,
      initialPage: 1,
    );

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _lightController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    _lightProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _lightController, curve: Curves.easeInOut),
    );

    _pageController.addListener(() {
      setState(() {
        _pageOffset = _pageController.page ?? 0;
        _currentIndex = _pageOffset.round().clamp(0, AppData.squad.length - 1);
      });
    });

    _entranceController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entranceController.dispose();
    _lightController.dispose();
    super.dispose();
  }

  PlayerModel get _currentPlayer => AppData.squad[_currentIndex];

  Color get _currentAccent {
    if (_currentPlayer.isCaptain) return AppColors.gold;
    if (_currentPlayer.isStarPlayer) return AppColors.electricBlue;
    return AppColors.skyBlue;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.stadiumDark,
      body: Stack(
        children: [
          // Dynamic color background tied to current player
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 0.9,
                colors: [
                  _currentAccent.withOpacity(0.1),
                  AppColors.stadiumDark,
                ],
              ),
            ),
          ),

          // Particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _lightProgress,
              builder: (context, child) => CustomPaint(
                painter: StadiumLightPainter(
                  progress: _lightProgress.value,
                  primaryColor: _currentAccent,
                ),
              ),
            ),
          ),

          const Positioned.fill(
            child: ParticleField(
              particleCount: 50,
              maxSize: 2,
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 20),

                  // Player count indicator
                  _buildPageIndicator(),
                  const SizedBox(height: 24),

                  // 3D Carousel
                  SizedBox(
                    height: size.height * 0.42,
                    child: _buildCarousel(),
                  ),
                  const SizedBox(height: 28),

                  // Player detail panel
                  Expanded(
                    child: _buildPlayerDetail(),
                  ),
                ],
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SQUAD',
                style: GoogleFonts.inter(
                  color: AppColors.skyBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
              Text(
                'All Players',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Text(
              '${AppData.squad.length} PLAYERS',
              style: GoogleFonts.inter(
                color: AppColors.silver,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: AppData.squad.asMap().entries.map((e) {
        final isActive = e.key == _currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 24 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? _currentAccent
                : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: _currentAccent.withOpacity(0.5),
                      blurRadius: 8,
                    )
                  ]
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCarousel() {
    return PageView.builder(
      controller: _pageController,
      itemCount: AppData.squad.length,
      physics: const BouncingScrollPhysics(),
      onPageChanged: (idx) => setState(() => _currentIndex = idx),
      itemBuilder: (context, index) {
        final player = AppData.squad[index];
        final offset = (index - _pageOffset).abs();
        final scale = (1 - offset * 0.15).clamp(0.75, 1.0);
        final opacity = (1 - offset * 0.35).clamp(0.4, 1.0);
        final rotateY = (index - _pageOffset) * 0.12;
        final isCenter = index == _currentIndex;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(rotateY)
            ..scale(scale),
          child: Opacity(
            opacity: opacity,
            child: PlayerCardVertical(
              player: player,
              isCenter: isCenter,
              width: 220,
              height: double.infinity,
              onTap: () {
                if (isCenter) {
                  widget.onPlayerSelected?.call(player);
                } else {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerDetail() {
    final player = _currentPlayer;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      child: Padding(
        key: ValueKey(player.id),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and position
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        '${player.position} • ${player.club} • Age ${player.age}',
                        style: GoogleFonts.inter(
                          color: AppColors.silver.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => widget.onPlayerSelected?.call(player),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _currentAccent,
                          _currentAccent.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _currentAccent.withOpacity(0.3),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Text(
                      'Profile →',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Horizontal stats
            Row(
              children: [
                Expanded(
                    child: _StatCard(
                        label: 'Goals',
                        value: '${player.goals}',
                        color: AppColors.statOrange)),
                const SizedBox(width: 10),
                Expanded(
                    child: _StatCard(
                        label: 'Assists',
                        value: '${player.assists}',
                        color: AppColors.skyBlue)),
                const SizedBox(width: 10),
                Expanded(
                    child: _StatCard(
                        label: 'Matches',
                        value: '${player.matches}',
                        color: AppColors.statPurple)),
                const SizedBox(width: 10),
                Expanded(
                    child: _StatCard(
                        label: 'Rating',
                        value: player.rating.toStringAsFixed(1),
                        color: _currentAccent,
                        isHighlighted: true)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isHighlighted;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(isHighlighted ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(isHighlighted ? 0.35 : 0.15),
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 12,
                )
              ]
            : null,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(color: color.withOpacity(0.4), blurRadius: 8),
              ],
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.silver.withOpacity(0.5),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
