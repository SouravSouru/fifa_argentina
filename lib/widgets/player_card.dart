import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/player_model.dart';
import 'glass_card.dart';

/// Position-based accent color for a player
Color playerAccentColor(PlayerModel player) {
  switch (player.positionCode) {
    case 'GK':
      return const Color(0xFFFFAA00);
    case 'CB':
    case 'RB':
    case 'LB':
      return AppColors.deepBlue;
    case 'CDM':
    case 'CM':
      return AppColors.skyBlue;
    case 'LW':
    case 'RW':
    case 'ST':
      return AppColors.electricBlue;
    default:
      return AppColors.skyBlue;
  }
}

/// Circular player avatar — shows portrait image with glow ring
class PlayerAvatar extends StatelessWidget {
  final PlayerModel player;
  final double size;
  final bool showGlow;
  final bool showNumber;

  const PlayerAvatar({
    super.key,
    required this.player,
    this.size = 60,
    this.showGlow = true,
    this.showNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = playerAccentColor(player);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Glow ring
        if (showGlow)
          Container(
            width: size + 6,
            height: size + 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.45),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),

        // Portrait image clipped to circle with gradient overlay
        ClipOval(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: accent.withOpacity(0.5),
                width: 1.8,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Player portrait
                Image.asset(
                  player.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, st) => _FallbackAvatar(
                    player: player,
                    size: size,
                    accent: accent,
                  ),
                ),

                // Bottom gradient overlay for text readability
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: size * 0.35,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.65),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Captain star badge
                if (player.isCaptain)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: size * 0.25,
                      height: size * 0.25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withOpacity(0.6),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.star_rounded,
                          color: Colors.white,
                          size: size * 0.15,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Number badge (optional overlay)
        if (showNumber)
          Positioned(
            bottom: -4,
            right: -4,
            child: Container(
              width: size * 0.32,
              height: size * 0.32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent,
                border: Border.all(
                  color: AppColors.stadiumDark,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  player.number,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: size * 0.1,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Fallback avatar when image fails to load
class _FallbackAvatar extends StatelessWidget {
  final PlayerModel player;
  final double size;
  final Color accent;

  const _FallbackAvatar({
    required this.player,
    required this.size,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withOpacity(0.7),
            accent.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              player.number,
              style: GoogleFonts.inter(
                fontSize: size * 0.28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              player.positionCode,
              style: GoogleFonts.inter(
                fontSize: size * 0.14,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.7),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// FIFA Ultimate Team style horizontal player card with portrait
class PlayerCardHorizontal extends StatefulWidget {
  final PlayerModel player;
  final VoidCallback? onTap;
  final bool isSelected;

  const PlayerCardHorizontal({
    super.key,
    required this.player,
    this.onTap,
    this.isSelected = false,
  });

  @override
  State<PlayerCardHorizontal> createState() => _PlayerCardHorizontalState();
}

class _PlayerCardHorizontalState extends State<PlayerCardHorizontal>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnim;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = playerAccentColor(widget.player);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnim,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isSelected
                        ? [
                            AppColors.skyBlue.withOpacity(0.3),
                            AppColors.deepBlue.withOpacity(0.2),
                          ]
                        : [
                            Colors.white.withOpacity(_isHovered ? 0.1 : 0.07),
                            Colors.white.withOpacity(0.02),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isSelected
                        ? AppColors.skyBlue.withOpacity(0.6)
                        : Colors.white.withOpacity(_isHovered ? 0.2 : 0.08),
                    width: widget.isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: widget.isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.skyBlue.withOpacity(0.2),
                            blurRadius: 20,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    // Portrait avatar
                    PlayerAvatar(
                      player: widget.player,
                      size: 54,
                      showNumber: true,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.player.shortName,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.player.isCaptain)
                                Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: AppColors.gold.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Text(
                                    'C',
                                    style: GoogleFonts.inter(
                                      color: AppColors.gold,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.player.positionCode,
                                  style: GoogleFonts.inter(
                                    color: accent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.player.club,
                                  style: GoogleFonts.inter(
                                    color: AppColors.silver.withOpacity(0.8),
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.player.rating.toStringAsFixed(1),
                          style: GoogleFonts.inter(
                            color: AppColors.skyBlue,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        Text(
                          'OVR',
                          style: GoogleFonts.inter(
                            color: AppColors.silver.withOpacity(0.6),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Large vertical player card for carousel with portrait photo
class PlayerCardVertical extends StatefulWidget {
  final PlayerModel player;
  final double width;
  final double height;
  final bool isCenter;
  final VoidCallback? onTap;

  const PlayerCardVertical({
    super.key,
    required this.player,
    this.width = 200,
    this.height = 280,
    this.isCenter = false,
    this.onTap,
  });

  @override
  State<PlayerCardVertical> createState() => _PlayerCardVerticalState();
}

class _PlayerCardVerticalState extends State<PlayerCardVertical>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Color get _cardGlow => widget.player.isCaptain
      ? AppColors.gold
      : widget.player.isStarPlayer
          ? AppColors.electricBlue
          : AppColors.skyBlue;

  @override
  Widget build(BuildContext context) {
    final accent = playerAccentColor(widget.player);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _cardGlow.withOpacity(widget.isCenter ? 0.4 : 0.1),
              blurRadius: widget.isCenter ? 48 : 16,
              spreadRadius: widget.isCenter ? 4 : 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Use actual rendered size — widget.height may be double.infinity
              // when the card is inside an unbounded parent.
              final cardH = constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : (widget.height.isFinite ? widget.height : 280.0);
              final cardW = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : (widget.width.isFinite ? widget.width : 200.0);

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Full-bleed portrait image as card background
                  Image.asset(
                    widget.player.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            accent.withOpacity(0.3),
                            AppColors.cardDark,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Glass overlay gradient (bottom)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.3, 0.75, 1.0],
                          colors: [
                            Colors.transparent,
                            AppColors.stadiumDark.withOpacity(0.7),
                            AppColors.stadiumDark.withOpacity(0.97),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Glow border
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _cardGlow.withOpacity(widget.isCenter ? 0.45 : 0.15),
                          width: widget.isCenter ? 1.5 : 1.0,
                        ),
                      ),
                    ),
                  ),

                  // Shimmer — uses cardH/cardW (always finite) not widget.height/width
                  Positioned(
                    top: -cardH,
                    left: -cardW,
                    width: cardW * 0.6,
                    height: cardH * 3,
                    child: AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: -0.5,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(
                                      0.05 * _shimmerController.value),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Content overlay (top badge + bottom info)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top: Number + Captain badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _cardGlow.withOpacity(0.25),
                                border: Border.all(
                                  color: _cardGlow.withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  widget.player.number,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            if (widget.player.isCaptain)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.gold.withOpacity(0.5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star_rounded,
                                        color: AppColors.gold, size: 11),
                                    const SizedBox(width: 3),
                                    Text(
                                      'C',
                                      style: GoogleFonts.inter(
                                        color: AppColors.gold,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        const Spacer(),

                        // Bottom: Name + position + stats
                        Text(
                          widget.player.shortName.toUpperCase(),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            shadows: const [
                              Shadow(color: Colors.black54, blurRadius: 8),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: _cardGlow.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.player.positionCode,
                                style: GoogleFonts.inter(
                                  color: _cardGlow,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                widget.player.club,
                                style: GoogleFonts.inter(
                                  color: AppColors.silver.withOpacity(0.7),
                                  fontSize: 10,
                                  shadows: const [
                                    Shadow(color: Colors.black54, blurRadius: 6),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _StatPill(
                                label: 'G',
                                value: '${widget.player.goals}'),
                            _StatPill(
                                label: 'A',
                                value: '${widget.player.assists}'),
                            _StatPill(
                              label: 'OVR',
                              value: widget.player.rating.toStringAsFixed(1),
                              isHighlighted: true,
                              highlightColor: _cardGlow,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;
  final Color highlightColor;

  const _StatPill({
    required this.label,
    required this.value,
    this.isHighlighted = false,
    this.highlightColor = AppColors.skyBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            color: isHighlighted ? highlightColor : Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: (isHighlighted ? highlightColor : Colors.black)
                    .withOpacity(0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.silver.withOpacity(0.6),
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
