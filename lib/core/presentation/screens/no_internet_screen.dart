import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _blinkController;
  late AnimationController _bounceController;

  late Animation<double> _blinkAnim;
  late Animation<double> _bounceAnim;

  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _blinkAnim = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    _bounceAnim = Tween<double>(begin: 0.0, end: -6.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _blinkController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  // Animated pulse ring
  Widget _buildPulseRing(double baseSize, double delay) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final double progress =
        (((_pulseController.value) + delay) % 1.0);
        final double size = baseSize + (progress * baseSize * 0.8);
        final double opacity = (1.0 - progress) * 0.35;

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE8B84B).withOpacity(opacity),
              width: 1.5,
            ),
          ),
        );
      },
    );
  }

  // Background decorative dot
  Widget _buildBgDot({
    required double top,
    required double left,
    required double size,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFE8B84B).withOpacity(0.07),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // Check row item
  Widget _buildCheckRow(IconData icon, String label) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFFE8B84B).withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFFE8B84B)),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF090C14),
        body: Stack(
          children: [
            // Background dots
            _buildBgDot(top: 70, left: 24, size: 70),
            _buildBgDot(top: 140, left: 320, size: 44),
            _buildBgDot(top: 520, left: 18, size: 90),
            _buildBgDot(top: 620, left: 310, size: 55),

            // Top-left glow
            Positioned(
              top: -80,
              left: -60,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFE8B84B).withOpacity(0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Bottom-right glow
            Positioned(
              bottom: -40,
              right: -40,
              child: Container(
                width: 200,
                height: 200,
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

            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ─── Animated Icon Section ───
                        SizedBox(
                          width: 220,
                          height: 220,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              _buildPulseRing(130, 0.0),
                              _buildPulseRing(130, 0.4),

                              // Icon circle background
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFE8B84B)
                                      .withOpacity(0.13),
                                ),
                              ),

                              // Bouncing WiFi icon + Lock badge
                              AnimatedBuilder(
                                animation: _bounceAnim,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, _bounceAnim.value),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        const Icon(
                                          Icons.wifi_off_rounded,
                                          size: 52,
                                          color: Color(0xFFE8B84B),
                                        ),
                                        // Lock badge
                                        Positioned(
                                          bottom: -4,
                                          right: -6,
                                          child: Container(
                                            width: 22,
                                            height: 22,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFE8B84B),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.lock_rounded,
                                              size: 13,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ─── Glass Card ───
                        Container(
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.09),
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              // Title
                              Text(
                                'No Internet Connection',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Subtitle
                              Text(
                                "You're currently offline. Check your\nWi-Fi or mobile data and try reconnecting.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  height: 1.7,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Blinking status pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8B84B)
                                      .withOpacity(0.07),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: const Color(0xFFE8B84B)
                                        .withOpacity(0.18),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedBuilder(
                                      animation: _blinkAnim,
                                      builder: (context, child) {
                                        return Opacity(
                                          opacity: _blinkAnim.value,
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFE8B84B),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Waiting for connection...',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 13,
                                        color: const Color(0xFFB6BDC9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Divider
                              const Divider(
                                color: Color(0x17FFFFFF),
                                height: 1,
                              ),

                              const SizedBox(height: 20),

                              // Checklist
                              _buildCheckRow(
                                Icons.wifi_rounded,
                                'Check Wi-Fi or mobile data is on',
                              ),
                              const SizedBox(height: 10),
                              _buildCheckRow(
                                Icons.router_rounded,
                                'Try restarting your router',
                              ),
                              const SizedBox(height: 10),
                              _buildCheckRow(
                                Icons.airplanemode_active_rounded,
                                'Disable airplane mode if enabled',
                              ),

                              const SizedBox(height: 24),

                              // Try Again button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: _isRetrying
                                      ? null
                                      : () async {
                                    setState(
                                            () => _isRetrying = true);
                                    await Future.delayed(
                                      const Duration(seconds: 2),
                                    );
                                    if (mounted) {
                                      setState(
                                              () => _isRetrying = false);
                                    }
                                    // TODO: add real retry logic here
                                  },
                                  icon: _isRetrying
                                      ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                      : const Icon(Icons.refresh_rounded),
                                  label: Text(
                                    _isRetrying ? 'Checking...' : 'Try Again',
                                    style: GoogleFonts.dmSans(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE8B84B),
                                    foregroundColor: Colors.black,
                                    disabledBackgroundColor:
                                    const Color(0xFFE8B84B)
                                        .withOpacity(0.5),
                                    disabledForegroundColor:
                                    Colors.black54,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),

                        const SizedBox(height: 28),
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