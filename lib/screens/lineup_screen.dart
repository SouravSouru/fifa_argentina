import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../data/app_data.dart';
import '../models/player_model.dart';
import '../widgets/particles.dart';
import '../widgets/glass_card.dart';
import '../widgets/player_card.dart';

class LineupScreen extends StatefulWidget {
  final VoidCallback? onPlayerTap;
  final Function(PlayerModel)? onSelectPlayer;

  const LineupScreen({
    super.key,
    this.onPlayerTap,
    this.onSelectPlayer,
  });

  @override
  State<LineupScreen> createState() => _LineupScreenState();
}

class _LineupScreenState extends State<LineupScreen>
    with TickerProviderStateMixin {
  late AnimationController _fieldController;
  late AnimationController _entranceController;
  late Animation<double> _fieldGlow;
  late Animation<double> _fadeAnim;

  int? _hoveredPlayerIndex;
  String _selectedFormation = AppData.currentFormation;
  PlayerModel? _selectedPlayer;

  @override
  void initState() {
    super.initState();

    _fieldController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fieldGlow = Tween<double>(begin: 0.5, end: 0.9).animate(
      CurvedAnimation(parent: _fieldController, curve: Curves.easeInOut),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _fieldController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  // Formation positions for 4-3-3 (normalized 0-1 on field)
  List<Map<String, dynamic>> get _formationPositions {
    // [x, y, playerIndex] — y=0 is top (GK end), y=1 is bottom (attack)
    switch (_selectedFormation) {
      case '4-3-3':
        return [
          {'x': 0.5, 'y': 0.08, 'idx': 3}, // GK
          {'x': 0.12, 'y': 0.28, 'idx': 4}, // RB
          {'x': 0.36, 'y': 0.25, 'idx': 8}, // CB
          {'x': 0.64, 'y': 0.25, 'idx': 9}, // CB
          {'x': 0.88, 'y': 0.28, 'idx': 10}, // LB
          {'x': 0.25, 'y': 0.52, 'idx': 5}, // CM
          {'x': 0.5, 'y': 0.48, 'idx': 6}, // CDM
          {'x': 0.75, 'y': 0.52, 'idx': 7}, // CM
          {'x': 0.12, 'y': 0.78, 'idx': 1}, // LW
          {'x': 0.5, 'y': 0.82, 'idx': 2}, // ST
          {'x': 0.88, 'y': 0.78, 'idx': 0}, // RW (Messi)
        ];
      case '4-2-3-1':
        return [
          {'x': 0.5, 'y': 0.08, 'idx': 3},
          {'x': 0.12, 'y': 0.28, 'idx': 4},
          {'x': 0.36, 'y': 0.25, 'idx': 8},
          {'x': 0.64, 'y': 0.25, 'idx': 9},
          {'x': 0.88, 'y': 0.28, 'idx': 10},
          {'x': 0.33, 'y': 0.48, 'idx': 5},
          {'x': 0.67, 'y': 0.48, 'idx': 6},
          {'x': 0.18, 'y': 0.68, 'idx': 1},
          {'x': 0.5, 'y': 0.65, 'idx': 7},
          {'x': 0.82, 'y': 0.68, 'idx': 0},
          {'x': 0.5, 'y': 0.85, 'idx': 2},
        ];
      default:
        return [
          {'x': 0.5, 'y': 0.08, 'idx': 3},
          {'x': 0.12, 'y': 0.28, 'idx': 4},
          {'x': 0.36, 'y': 0.25, 'idx': 8},
          {'x': 0.64, 'y': 0.25, 'idx': 9},
          {'x': 0.88, 'y': 0.28, 'idx': 10},
          {'x': 0.25, 'y': 0.52, 'idx': 5},
          {'x': 0.5, 'y': 0.48, 'idx': 6},
          {'x': 0.75, 'y': 0.52, 'idx': 7},
          {'x': 0.12, 'y': 0.78, 'idx': 1},
          {'x': 0.5, 'y': 0.82, 'idx': 2},
          {'x': 0.88, 'y': 0.78, 'idx': 0},
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: Stack(
        children: [
          // Subtle particles
          const Positioned.fill(
            child: ParticleField(
              particleCount: 30,
              primaryColor: AppColors.skyBlue,
              secondaryColor: AppColors.electricBlue,
              maxSize: 2,
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Formation selector
                  _buildFormationSelector(),

                  const SizedBox(height: 12),

                  // Football field with players
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildFieldWithPlayers(size),
                    ),
                  ),

                  // Selected player info
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) => SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                          parent: anim, curve: Curves.easeOut)),
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: _selectedPlayer != null
                        ? _buildSelectedPlayerPanel(_selectedPlayer!)
                        : const SizedBox(key: ValueKey('empty'), height: 16),
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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LINEUP',
                style: GoogleFonts.inter(
                  color: AppColors.skyBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
              Text(
                'Starting XI',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const GlowDot(color: AppColors.statGreen),
              const SizedBox(width: 6),
              Text(
                'CONFIRMED',
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
      ),
    );
  }

  Widget _buildFormationSelector() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: AppData.formations.length,
        itemBuilder: (context, i) {
          final f = AppData.formations[i];
          final isSelected = f == _selectedFormation;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedFormation = f;
              _selectedPlayer = null;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [AppColors.skyBlue, AppColors.deepBlue],
                      )
                    : null,
                color: isSelected ? null : Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.skyBlue.withOpacity(0.6)
                      : Colors.white.withOpacity(0.1),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.skyBlue.withOpacity(0.3),
                          blurRadius: 12,
                        )
                      ]
                    : null,
              ),
              child: Text(
                f,
                style: GoogleFonts.inter(
                  color: isSelected
                      ? Colors.white
                      : AppColors.silver.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFieldWithPlayers(Size size) {
    return AnimatedBuilder(
      animation: _fieldGlow,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.skyBlue.withOpacity(0.08),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Field
                Positioned.fill(
                  child: CustomPaint(
                    painter: FootballFieldPainter(
                        glowOpacity: _fieldGlow.value),
                  ),
                ),

                // Player dots
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: _formationPositions.asMap().entries.map((e) {
                          final pos = e.value;
                          final idx = pos['idx'] as int;
                          if (idx >= AppData.squad.length) {
                            return const SizedBox.shrink();
                          }
                          final player = AppData.squad[idx];
                          final x =
                              (pos['x'] as double) * constraints.maxWidth;
                          final y =
                              (pos['y'] as double) * constraints.maxHeight;
                          final isSelected =
                              _selectedPlayer?.id == player.id;
                          final isHovered = _hoveredPlayerIndex == e.key;

                          return Positioned(
                            left: x - 22,
                            top: y - 22,
                            child: _PlayerDot(
                              player: player,
                              isSelected: isSelected,
                              isHovered: isHovered,
                              onTap: () {
                                setState(() {
                                  _selectedPlayer = isSelected
                                      ? null
                                      : player;
                                });
                                if (!isSelected) {
                                  widget.onSelectPlayer?.call(player);
                                }
                              },
                              onHover: (hovering) {
                                setState(() {
                                  _hoveredPlayerIndex =
                                      hovering ? e.key : null;
                                });
                              },
                              animationDelay: e.key * 80,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedPlayerPanel(PlayerModel player) {
    return Container(
      key: ValueKey(player.id),
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        opacity: 0.12,
        glowColor: AppColors.skyBlue,
        child: Row(
          children: [
            PlayerAvatar(player: player, size: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    player.name,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${player.position} • ${player.club}',
                    style: GoogleFonts.inter(
                      color: AppColors.silver.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MiniStat(
                        label: 'Goals', value: '${player.goals}'),
                    const SizedBox(width: 12),
                    _MiniStat(
                        label: 'Assists', value: '${player.assists}'),
                    const SizedBox(width: 12),
                    _MiniStat(
                      label: 'Rating',
                      value: player.rating.toStringAsFixed(1),
                      highlight: true,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: widget.onPlayerTap,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.skyBlue.withOpacity(0.15),
                  border: Border.all(
                    color: AppColors.skyBlue.withOpacity(0.4),
                  ),
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded,
                    color: AppColors.skyBlue, size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _MiniStat({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            color: highlight ? AppColors.skyBlue : Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.silver.withOpacity(0.5),
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

class _PlayerDot extends StatefulWidget {
  final PlayerModel player;
  final bool isSelected;
  final bool isHovered;
  final VoidCallback onTap;
  final Function(bool) onHover;
  final int animationDelay;

  const _PlayerDot({
    required this.player,
    required this.isSelected,
    required this.isHovered,
    required this.onTap,
    required this.onHover,
    this.animationDelay = 0,
  });

  @override
  State<_PlayerDot> createState() => _PlayerDotState();
}

class _PlayerDotState extends State<_PlayerDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0, 0.4, curve: Curves.easeOut)),
    );
    Future.delayed(
        Duration(milliseconds: widget.animationDelay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _positionColor {
    switch (widget.player.positionCode) {
      case 'GK':
        return const Color(0xFFFFAA00);
      case 'CB':
      case 'RB':
      case 'LB':
        return AppColors.deepBlue;
      case 'CDM':
      case 'CM':
        return AppColors.skyBlue;
      default:
        return AppColors.electricBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnim,
          child: Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => widget.onHover(true),
        onExit: (_) => widget.onHover(false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isSelected
                  ? AppColors.skyBlue
                  : _positionColor.withOpacity(0.85),
              border: Border.all(
                color: widget.isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.4),
                width: widget.isSelected ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (widget.isSelected
                          ? AppColors.skyBlue
                          : _positionColor)
                      .withOpacity(widget.isSelected || widget.isHovered
                          ? 0.7
                          : 0.3),
                  blurRadius: widget.isSelected ? 20 : 8,
                  spreadRadius: widget.isSelected ? 2 : 0,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.player.number,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                Text(
                  widget.player.shortName.split(' ').last
                      .substring(0, widget.player.shortName.split(' ').last.length.clamp(0, 3))
                      .toUpperCase(),
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 6,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
