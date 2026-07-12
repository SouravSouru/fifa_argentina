// player_showcase_slider.dart
// ─────────────────────────────────────────────────────────────────────────────
// Reusable 3D coverflow carousel widget.
//
// Architecture:
//  • PageController(viewportFraction: 0.68) drives scroll physics + snapping.
//  • Each card wraps its own AnimatedBuilder(animation: _pageController) so
//    transforms are computed per-frame with zero setState rebuilds (60fps).
//  • Matrix4..setEntry(3, 2, 0.001)..rotateY(delta * 0.45) gives genuine
//    perspective — not a scale trick.
//  • Opacity + ImageFilter.blur applied per-delta for depth cueing.
//  • Parallax: player image translates by delta*-18px opposite to rotation.
//  • Center card: animated glow pulse + jersey-number bounce (SpringSimulation
//    driven via AnimationController + TweenSequence).
//  • HapticFeedback.selectionClick() fires on each page-index change.
//  • Tap on a side card calls PageController.animateToPage with easeOutCubic.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/player_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public widget — takes a List<PlayerModel>, fully reusable.
// ─────────────────────────────────────────────────────────────────────────────
class PlayerShowcaseSlider extends StatefulWidget {
  final List<PlayerModel> players;

  const PlayerShowcaseSlider({super.key, required this.players});

  @override
  State<PlayerShowcaseSlider> createState() => _PlayerShowcaseSliderState();
}

class _PlayerShowcaseSliderState extends State<PlayerShowcaseSlider>
    with TickerProviderStateMixin {
  // ── Scroll controller — 0.68 viewport fraction creates the coverflow peek ──
  late PageController _pageCtrl;

  // Tracks the last snapped-to page index for haptic + bounce triggers
  int _lastCenter = 0;

  // ── Glow pulse: loops on center card shadow + gradient border ──────────────
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  // ── Jersey number bounce: plays on each card-change ──────────────────────
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();

    _pageCtrl = PageController(viewportFraction: 0.68, initialPage: 0);

    // Glow loops with a soft ease-in-out
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    // Bounce sequence: grow → overshoot → settle back to 1.0
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    );

    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.38),
        weight: 28,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.38, end: 0.88),
        weight: 22,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.88, end: 1.06),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.06, end: 1.0),
        weight: 20,
      ),
    ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.linear));

    // Listen for page-index changes (haptic + bounce)
    _pageCtrl.addListener(_handlePageChange);
  }

  void _handlePageChange() {
    if (!_pageCtrl.hasClients) return;
    final center = _pageCtrl.page?.round() ?? 0;
    if (center != _lastCenter) {
      _lastCenter = center;
      HapticFeedback.selectionClick();
      _bounceCtrl.forward(from: 0.0); // restart bounce from zero
    }
  }

  @override
  void dispose() {
    _pageCtrl
      ..removeListener(_handlePageChange)
      ..dispose();
    _glowCtrl.dispose();
    _bounceCtrl.dispose();
    super.dispose();
  }

  // Tap-to-center: smooth animated jump
  void _jumpToPage(int index) {
    _pageCtrl.animateToPage(
      index,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageCtrl,
      itemCount: widget.players.length,
      // Each card has its own AnimatedBuilder so only that card rebuilds
      // per frame — no parent setState needed.
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: Listenable.merge([_pageCtrl, _glowCtrl, _bounceCtrl]),
          builder: (context, _) => _buildCard(index),
        );
      },
    );
  }

  // ── Per-card 3D transform ───────────────────────────────────────────────────
  Widget _buildCard(int index) {
    // Safe read of current scroll position
    final page = _pageCtrl.hasClients
        ? (_pageCtrl.page ?? index.toDouble())
        : index.toDouble();

    // delta: negative = card is to the right, positive = to the left of center
    final delta = page - index;
    final absD = delta.abs().clamp(0.0, 1.0);

    // ── Transform values ─────────────────────────────────────────────────────
    final scale = lerpDouble(0.76, 1.0, 1.0 - absD)!;
    final opacity = lerpDouble(0.40, 1.0, 1.0 - absD)!;
    final blurSigma = lerpDouble(3.5, 0.0, 1.0 - absD)!;

    // Y-rotation: 0.45 rad ≈ 26° at full offset
    final rotateY = delta * 0.45;

    // Parallax: image shifts opposite to card rotation direction
    final parallaxShift = delta * -16.0;

    final isCenter = _lastCenter == index;

    // ── Matrix4 with genuine perspective ────────────────────────────────────
    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective coefficient
      ..rotateY(rotateY); // Y-axis 3D rotation

    // ── Assemble card ────────────────────────────────────────────────────────
    Widget card = Transform(
      transform: transform,
      alignment: Alignment.center,
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: _PlayerCard(
            player: widget.players[index],
            isCenter: isCenter,
            parallaxShift: parallaxShift,
            glowAnim: _glowAnim,
            bounceAnim: isCenter ? _bounceAnim : null,
            onTap: isCenter ? null : () => _jumpToPage(index),
          ),
        ),
      ),
    );

    // Apply blur only when meaningfully off-center (perf-friendly threshold)
    if (blurSigma > 0.4) {
      card = ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: blurSigma,
          sigmaY: blurSigma,
          tileMode: TileMode.decal,
        ),
        child: card,
      );
    }

    return card;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single player card widget
// ─────────────────────────────────────────────────────────────────────────────
class _PlayerCard extends StatelessWidget {
  final PlayerModel player;
  final bool isCenter;
  final double parallaxShift; // horizontal px offset for player image
  final Animation<double> glowAnim; // drives outer shadow + border pulse
  final Animation<double>? bounceAnim; // jersey number scale bounce
  final VoidCallback? onTap; // null for center card (PageView handles drag)

  const _PlayerCard({
    required this.player,
    required this.isCenter,
    required this.parallaxShift,
    required this.glowAnim,
    this.bounceAnim,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 18.0),
        child: _CardShell(
          isCenter: isCenter,
          glowAnim: glowAnim,
          child: Stack(
            children: [
              // ── Subtle gradient shimmer border (center only) ─────────────
              if (isCenter) _GradientBorderOverlay(glowAnim: glowAnim),

              // ── Player photograph with parallax ───────────────────────────
              _PlayerImage(
                imageUrl: player.imageUrl,
                parallaxShift: parallaxShift,
              ),

              // ── Bottom info gradient + name/club ─────────────────────────
              _InfoPanel(player: player),

              // ── Large jersey number (decorative, bottom-right) ────────────
              _JerseyNumber(
                number: player.number,
                bounceAnim: bounceAnim,
              ),

              // ── Position code chip (top-right) ───────────────────────────
              _PositionChip(code: player.positionCode),

              // ── Captain badge (top-left, conditional) ─────────────────────
              if (player.isCaptain) const _CaptainBadge(),

              // ── Star player glow ring on card edge (center only) ─────────
              if (isCenter && player.isStarPlayer)
                _StarGlowRing(glowAnim: glowAnim),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card outer shell — glassmorphism container with conditional glow shadow
// ─────────────────────────────────────────────────────────────────────────────
class _CardShell extends StatelessWidget {
  final bool isCenter;
  final Animation<double> glowAnim;
  final Widget child;

  const _CardShell({
    required this.isCenter,
    required this.glowAnim,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: isCenter
            ? [
                // Primary sky-blue glow pulsing with glowAnim
                BoxShadow(
                  color: AppColors.skyBlue
                      .withOpacity(0.32 * glowAnim.value),
                  blurRadius: 48 * glowAnim.value,
                  spreadRadius: 6,
                ),
                // Subtle gold halo
                BoxShadow(
                  color: AppColors.gold
                      .withOpacity(0.12 * glowAnim.value),
                  blurRadius: 64,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.55),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isCenter
                  ? [
                      const Color(0xFF1C3F6E).withOpacity(0.96),
                      const Color(0xFF0B2040).withOpacity(0.98),
                    ]
                  : [
                      const Color(0xFF121E30).withOpacity(0.92),
                      const Color(0xFF080F1E).withOpacity(0.96),
                    ],
            ),
            border: Border.all(
              color: isCenter
                  ? AppColors.skyBlue.withOpacity(0.45 * glowAnim.value)
                  : Colors.white.withOpacity(0.07),
              width: isCenter ? 1.5 : 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated gradient border shimmer for center card
// ─────────────────────────────────────────────────────────────────────────────
class _GradientBorderOverlay extends StatelessWidget {
  final Animation<double> glowAnim;

  const _GradientBorderOverlay({required this.glowAnim});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.skyBlue.withOpacity(0.18 * glowAnim.value),
                AppColors.gold.withOpacity(0.08 * glowAnim.value),
                AppColors.electricBlue.withOpacity(0.12 * glowAnim.value),
                Colors.transparent,
              ],
              stops: const [0.0, 0.35, 0.65, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Player image with bottom-fade mask and horizontal parallax
// ─────────────────────────────────────────────────────────────────────────────
class _PlayerImage extends StatelessWidget {
  final String imageUrl;
  final double parallaxShift;

  const _PlayerImage({
    required this.imageUrl,
    required this.parallaxShift,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      // Leave 140px for the info panel at the bottom
      bottom: 130,
      child: Transform.translate(
        // Parallax: image drifts slightly opposite to the card's 3D lean
        offset: Offset(parallaxShift, 0),
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white, Colors.transparent],
            stops: [0.0, 0.60, 1.0],
          ).createShader(bounds),
          blendMode: BlendMode.dstIn,
          child: Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.cardDark,
              child: Icon(
                Icons.person_rounded,
                size: 90,
                color: AppColors.silver.withOpacity(0.2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom info panel — name + club on a gradient scrim
// ─────────────────────────────────────────────────────────────────────────────
class _InfoPanel extends StatelessWidget {
  final PlayerModel player;

  const _InfoPanel({required this.player});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 32, 18, 22),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color(0xF5050A12), Color(0x00050A12)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              player.shortName.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.2,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              player.club,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.silver.withOpacity(0.55),
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Large decorative jersey number (bottom-right) with optional bounce
// ─────────────────────────────────────────────────────────────────────────────
class _JerseyNumber extends StatelessWidget {
  final String number;
  final Animation<double>? bounceAnim;

  const _JerseyNumber({required this.number, this.bounceAnim});

  @override
  Widget build(BuildContext context) {
    final text = Text(
      number,
      style: GoogleFonts.inter(
        fontSize: 80,
        fontWeight: FontWeight.w900,
        // Gold at low opacity so it reads as watermark
        color: AppColors.gold.withOpacity(0.14),
        height: 1.0,
      ),
    );

    return Positioned(
      bottom: 12,
      right: 10,
      child: bounceAnim != null
          ? ScaleTransition(
              scale: bounceAnim!,
              alignment: Alignment.bottomRight,
              child: text,
            )
          : text,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Position code pill — top-right corner
// ─────────────────────────────────────────────────────────────────────────────
class _PositionChip extends StatelessWidget {
  final String code;

  const _PositionChip({required this.code});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 14,
      right: 14,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.skyBlue.withOpacity(0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.skyBlue.withOpacity(0.38),
          ),
        ),
        child: Text(
          code,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.skyBlue,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Captain ⭐ badge — top-left corner
// ─────────────────────────────────────────────────────────────────────────────
class _CaptainBadge extends StatelessWidget {
  const _CaptainBadge();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 14,
      left: 14,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.gold.withOpacity(0.92),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 9)),
            const SizedBox(width: 3),
            Text(
              'CAP',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pulsing glow ring around the card edge — star player / center card only
// ─────────────────────────────────────────────────────────────────────────────
class _StarGlowRing extends StatelessWidget {
  final Animation<double> glowAnim;

  const _StarGlowRing({required this.glowAnim});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppColors.gold.withOpacity(0.25 * glowAnim.value),
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}
