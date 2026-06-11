import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/service_locator.dart';
import '../../data/services/onboarding_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _orbController;
  late AnimationController _fadeController;
  late AnimationController _dotsController;

  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;
  late List<Animation<double>> _dotAnims;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToNextScreen();
  }

  void _setupAnimations() {
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _dotAnims = List.generate(3, (i) {
      return Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(
          parent: _dotsController,
          curve: Interval(i * 0.2, 0.6 + i * 0.2, curve: Curves.easeInOut),
        ),
      );
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fadeController.forward();
    });
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    
    // Check if onboarding is complete
    final storage = sl<OnboardingStorageService>();
    final isOnboardingComplete = storage.isOnboardingComplete();
    final hasLanguage = storage.getSelectedLanguage() != null;
    
    if (isOnboardingComplete && hasLanguage) {
      // User has completed onboarding, go to home
      context.go('/movies');
    } else {
      // First time user, go to info screen
      context.go('/info');
    }
  }

  @override
  void dispose() {
    _orbController.dispose();
    _fadeController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090C14),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [
              Color(0xFF100A20),
              Color(0xFF090C14),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background subtle glow
            Positioned(
              top: -80,
              left: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFC084FC).withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              right: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFE8B84B).withOpacity(0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: AnimatedBuilder(
                  animation: _slideAnim,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnim.value),
                      child: child,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Spinning orb
                      _buildSpinningOrb(),
                      const SizedBox(height: 36),

                      // App title
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFE8B84B), Color(0xFFC084FC)],
                        ).createShader(bounds),
                        child: Text(
                          'CINEPLEX',
                          style: GoogleFonts.bebasNeue(
                            fontSize: 54,
                            letterSpacing: 8,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'YOUR ENTERTAINMENT HUB',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          letterSpacing: 4,
                          color: const Color(0xFF8892AA),
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 72),

                      // Animated dots
                      _buildDotsLoader(),
                    ],
                  ),
                ),
              ),
            ),

            // Version label
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Text(
                  'v1.0.0',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: const Color(0xFF8892AA).withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpinningOrb() {
    return SizedBox(
      width: 148,
      height: 148,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Container(
            width: 148,
            height: 148,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE8B84B).withOpacity(0.15),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
                BoxShadow(
                  color: const Color(0xFFC084FC).withOpacity(0.1),
                  blurRadius: 60,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),

          // Spinning gradient ring
          AnimatedBuilder(
            animation: _orbController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _orbController.value * 2 * math.pi,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Color(0xFFE8B84B),
                        Color(0xFFC084FC),
                        Color(0xFF6366F1),
                        Color(0xFFE8B84B),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Inner dark circle
          Container(
            width: 126,
            height: 126,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF0F1422),
            ),
          ),

          // Icon
          const Icon(
            Icons.movie_creation_outlined,
            size: 52,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildDotsLoader() {
    final colors = [
      const Color(0xFFE8B84B),
      const Color(0xFFC084FC),
      const Color(0xFFE8B84B),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _dotAnims[i],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors[i].withOpacity(_dotAnims[i].value),
              ),
            );
          },
        );
      }),
    );
  }
}