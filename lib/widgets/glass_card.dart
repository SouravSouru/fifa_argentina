import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Premium frosted glass card with optional glow border
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurAmount;
  final Color? tintColor;
  final double opacity;
  final bool showGlowBorder;
  final Color? glowColor;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadows;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blurAmount = 20,
    this.tintColor,
    this.opacity = 0.12,
    this.showGlowBorder = true,
    this.glowColor,
    this.padding = const EdgeInsets.all(20),
    this.width,
    this.height,
    this.onTap,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGlow = glowColor ?? AppColors.skyBlue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: shadows ??
              [
                BoxShadow(
                  color: effectiveGlow.withOpacity(0.15),
                  blurRadius: 24,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: (tintColor ?? AppColors.skyBlue).withOpacity(opacity),
                borderRadius: BorderRadius.circular(borderRadius),
                border: showGlowBorder
                    ? Border.all(
                        color: effectiveGlow.withOpacity(0.25),
                        width: 1.0,
                      )
                    : null,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.03),
                  ],
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Glowing number display for stats
class GlowText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color glowColor;
  final double glowRadius;

  const GlowText({
    super.key,
    required this.text,
    this.style,
    this.glowColor = AppColors.electricBlue,
    this.glowRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(
        shadows: [
          Shadow(color: glowColor, blurRadius: glowRadius),
          Shadow(color: glowColor.withOpacity(0.5), blurRadius: glowRadius * 2),
        ],
      ),
    );
  }
}

/// Animated glowing circle dot
class GlowDot extends StatefulWidget {
  final Color color;
  final double size;

  const GlowDot({super.key, this.color = AppColors.statGreen, this.size = 8});

  @override
  State<GlowDot> createState() => _GlowDotState();
}

class _GlowDotState extends State<GlowDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
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
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(_animation.value),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_animation.value * 0.6),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Gradient stat bar with animated fill
class AnimatedStatBar extends StatefulWidget {
  final String label;
  final int value;
  final Color color;
  final bool animate;

  const AnimatedStatBar({
    super.key,
    required this.label,
    required this.value,
    this.color = AppColors.skyBlue,
    this.animate = true,
  });

  @override
  State<AnimatedStatBar> createState() => _AnimatedStatBarState();
}

class _AnimatedStatBarState extends State<AnimatedStatBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _animation = Tween<double>(begin: 0, end: widget.value / 100).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    if (widget.animate) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label.toUpperCase(),
                style: TextStyle(
                  color: AppColors.silver,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '${widget.value}',
                style: TextStyle(
                  color: widget.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                children: [
                  Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: _animation.value,
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.color.withOpacity(0.6),
                            widget.color,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withOpacity(0.5),
                            blurRadius: 6,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Tilt interaction widget for 3D card effect
class TiltCard extends StatefulWidget {
  final Widget child;
  final double maxTilt;
  final bool enableGlare;

  const TiltCard({
    super.key,
    required this.child,
    this.maxTilt = 8.0,
    this.enableGlare = true,
  });

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> {
  double _rotateX = 0;
  double _rotateY = 0;
  double _glareX = 0;
  double _glareY = 0;
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) {
        setState(() {
          _isHovering = false;
          _rotateX = 0;
          _rotateY = 0;
        });
      },
      onHover: (event) {
        if (!mounted) return;
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final size = box.size;
        final local = box.globalToLocal(event.position);
        setState(() {
          _rotateY = ((local.dx / size.width) - 0.5) * widget.maxTilt * 2;
          _rotateX = -((local.dy / size.height) - 0.5) * widget.maxTilt * 2;
          _glareX = local.dx / size.width;
          _glareY = local.dy / size.height;
        });
      },
      child: AnimatedContainer(
        duration: _isHovering
            ? const Duration(milliseconds: 50)
            : const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_rotateX * 3.14159 / 180)
          ..rotateY(_rotateY * 3.14159 / 180),
        child: Stack(
          children: [
            widget.child,
            if (widget.enableGlare && _isHovering)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(
                          _glareX * 2 - 1,
                          _glareY * 2 - 1,
                        ),
                        radius: 0.8,
                        colors: [
                          Colors.white.withOpacity(0.12),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
