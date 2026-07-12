import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/app_colors.dart';
import 'core/app_theme.dart';
import 'data/app_data.dart';
import 'models/player_model.dart';
import 'screens/hero_screen.dart';
import 'screens/lineup_screen.dart';
import 'screens/player_showcase_screen.dart';
import 'screens/squad_carousel_screen.dart';
import 'screens/match_center_screen.dart';
import 'screens/semi_final_intro_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.stadiumDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ArgentinaApp());
}

class ArgentinaApp extends StatelessWidget {
  const ArgentinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Argentina FC — World Cup 2026',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with TickerProviderStateMixin {
  int _currentTab = 0;
  PlayerModel? _selectedPlayer;

  // Page controller for liquid transitions
  late PageController _pageController;
  late AnimationController _navBarController;
  late Animation<double> _navBarAnim;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _navBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _navBarAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _navBarController, curve: Curves.easeOut),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _navBarController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _navBarController.dispose();
    super.dispose();
  }

  void _navigateTo(int tab) {
    if (tab == _currentTab) return;
    HapticFeedback.selectionClick();
    setState(() => _currentTab = tab);
    _pageController.animateToPage(
      tab,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _openPlayerProfile(PlayerModel player) {
    setState(() => _selectedPlayer = player);
    Navigator.of(context).push(
      _buildPageRoute(
        PlayerShowcaseScreen(player: player),
      ),
    );
  }

  PageRoute _buildPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondary, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.stadiumDark,
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Screen 1 - Hero
          HeroScreen(
            onNavigateToSquad: () => _navigateTo(2),
            onNavigateToMatch: () => _navigateTo(4),
          ),

          // Screen 2 - Lineup
          LineupScreen(
            onPlayerTap: () {
              if (_selectedPlayer != null) {
                _openPlayerProfile(_selectedPlayer!);
              } else {
                _openPlayerProfile(AppData.squad.first);
              }
            },
            onSelectPlayer: (player) {
              setState(() => _selectedPlayer = player);
            },
          ),

          // Screen 3 - Squad Carousel
          SquadCarouselScreen(
            onPlayerSelected: _openPlayerProfile,
          ),

          // Screen 4 - Player Showcase (default to Messi)
          PlayerShowcaseScreen(
            player: _selectedPlayer ?? AppData.squad.first,
          ),

          // Screen 5 - Match Center
          const MatchCenterScreen(),

          // Screen 6 - Semi-Final Intro (embedded so bottom nav stays visible)
          const SemiFinalIntroScreen(),
        ],
      ),
      bottomNavigationBar: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(_navBarAnim),
        child: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.cardDark.withOpacity(0.85),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppColors.skyBlue.withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isActive: _currentTab == 0,
                  onTap: () => _navigateTo(0),
                ),
                _NavItem(
                  icon: Icons.sports_soccer_rounded,
                  label: 'Lineup',
                  isActive: _currentTab == 1,
                  onTap: () => _navigateTo(1),
                ),
                _NavItem(
                  icon: Icons.group_rounded,
                  label: 'Squad',
                  isActive: _currentTab == 2,
                  onTap: () => _navigateTo(2),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Player',
                  isActive: _currentTab == 3,
                  onTap: () => _navigateTo(3),
                ),
                _NavItem(
                  icon: Icons.live_tv_rounded,
                  label: 'Match',
                  isActive: _currentTab == 4,
                  hasLive: true,
                  onTap: () => _navigateTo(4),
                ),
                _NavItem(
                  icon: Icons.emoji_events_rounded,
                  label: 'Semi-Final',
                  isActive: _currentTab == 5,
                  hasLive: false,
                  onTap: () => _navigateTo(5),
                ),
              ].map((item) => Expanded(child: item)).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool hasLive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.hasLive = false,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
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
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: SizedBox(
          // No fixed width — parent Expanded distributes space evenly
          height: 68,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? AppColors.skyBlue.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: widget.isActive
                      ? [
                          BoxShadow(
                            color: AppColors.skyBlue.withOpacity(0.3),
                            blurRadius: 12,
                          )
                        ]
                      : null,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      widget.icon,
                      color: widget.isActive
                          ? AppColors.skyBlue
                          : AppColors.silver.withOpacity(0.4),
                      size: 22,
                    ),
                    if (widget.hasLive)
                      Positioned(
                        top: -3,
                        right: -3,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.statGreen,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.statGreen.withOpacity(0.6),
                                blurRadius: 4,
                              )
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.inter(
                  color: widget.isActive
                      ? AppColors.skyBlue
                      : AppColors.silver.withOpacity(0.35),
                  fontSize: 9,
                  fontWeight: widget.isActive
                      ? FontWeight.w700
                      : FontWeight.w500,
                  letterSpacing: 0.3,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
