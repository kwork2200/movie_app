import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/service_locator.dart';
import '../../data/services/onboarding_storage_service.dart';
import '../../../core/presentation/components/ads/ad_enabled_screen.dart';
import '../../../core/presentation/components/ads/native_ad_widget.dart';
import '../../../core/resources/app_values.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedLanguage;
  bool _isLoading = false;

  late AnimationController _fadeController;
  late List<Animation<double>> _itemAnims;

  // Design constants
  static const Color _bg = Color(0xFF090C14);
  static const Color _card = Color(0xFF151B2E);
  static const Color _border = Color(0xFF1E2840);
  static const Color _gold = Color(0xFFE8B84B);
  static const Color _purple = Color(0xFFC084FC);
  static const Color _muted = Color(0xFF8892AA);
  static const Color _text = Color(0xFFF1F5FF);

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧', 'native': 'English'},
    {'code': 'hi', 'name': 'Hindi', 'flag': '🇮🇳', 'native': 'हिंदी'},
    {'code': 'es', 'name': 'Spanish', 'flag': '🇪🇸', 'native': 'Español'},
    {'code': 'fr', 'name': 'French', 'flag': '🇫🇷', 'native': 'Français'},
    {'code': 'de', 'name': 'German', 'flag': '🇩🇪', 'native': 'Deutsch'},
    {'code': 'pt', 'name': 'Portuguese', 'flag': '🇧🇷', 'native': 'Português'},
    {'code': 'zh', 'name': 'Chinese', 'flag': '🇨🇳', 'native': '中文'},
    {'code': 'ja', 'name': 'Japanese', 'flag': '🇯🇵', 'native': '日本語'},
    {'code': 'ko', 'name': 'Korean', 'flag': '🇰🇷', 'native': '한국어'},
    {'code': 'ar', 'name': 'Arabic', 'flag': '🇸🇦', 'native': 'العربية'},
  ];

  @override
  void initState() {
    super.initState();
    final storage = sl<OnboardingStorageService>();
    _selectedLanguage = storage.getSelectedLanguage();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _itemAnims = List.generate(_languages.length, (i) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: Interval(
            i * 0.06,
            (i * 0.06 + 0.4).clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleGetStarted() async {
    if (_selectedLanguage == null) {
      _showSnackBar('Please select a language', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final storage = sl<OnboardingStorageService>();
    await storage.saveLanguage(_selectedLanguage!);
    await storage.setOnboardingComplete(true);

    if (!mounted) return;
    setState(() => _isLoading = false);
    _showSnackBar('Welcome to Cineplex! 🎬');
    context.go('/movies');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.celebration_outlined,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(message, style: GoogleFonts.dmSans(color: Colors.white)),
          ],
        ),
        backgroundColor: isError ? const Color(0xFF991B1B) : const Color(0xFF15803D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: AdEnabledScreen(
        child: Stack(
          children: [
            // Background glows
            Positioned(
              top: -50,
              left: -50,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _purple.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _gold.withOpacity(0.07),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildHero(),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                      itemCount: _languages.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              AnimatedBuilder(
                                animation: _itemAnims[index],
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _itemAnims[index].value,
                                    child: Transform.translate(
                                      offset: Offset(
                                        0,
                                        20 * (1 - _itemAnims[index].value),
                                      ),
                                      child: child,
                                    ),
                                  );
                                },
                                child: _buildLanguageItem(_languages[index]),
                              ),

                              if ((index + 1) % 2 == 0)
                                NativeAdWidget(
                                  height: AppSize.s175,
                                  adKey: 'language_selection',
                                  size: NativeAdSize.small,
                                ),
                            ],

                          );
                        }
                    ),
                  ),
                  _buildBottomSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(3, (i) {
              return Expanded(
                child: Container(
                  height: 3,
                  margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: i <= 1 ? _gold : _purple,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: _muted,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Language',
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _text,
                ),
              ),
              const Spacer(),
              Text(
                'Step 3/3',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: _muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        children: [
          Row(
            children: [

              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: _purple.withOpacity(0.12),
                  border: Border.all(color: _purple.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: Color(0xFFC084FC),
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Your Language',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You can change this in settings anytime',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageItem(Map<String, String> language) {
    final isSelected = _selectedLanguage == language['code'];

    return GestureDetector(
      onTap: () => setState(() => _selectedLanguage = language['code']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected ? _gold.withOpacity(0.07) : _card,
          border: Border.all(
            color: isSelected ? _gold.withOpacity(0.6) : _border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Flag
            Text(
              language['flag']!,
              style: const TextStyle(fontSize: 26),
            ),
            const SizedBox(width: 14),

            // Names
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language['native']!,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? _gold : _text,
                    ),
                  ),
                  Text(
                    language['name']!,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ),

            // Check indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _gold : Colors.transparent,
                border: Border.all(
                  color: isSelected ? _gold : _border,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(
                Icons.check_rounded,
                color: Colors.black,
                size: 14,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      decoration: BoxDecoration(
        color: _bg,
        border: Border(
          top: BorderSide(color: _border.withOpacity(0.5)),
        ),
      ),
      child: Column(
        children: [
          // Selected language pill
          if (_selectedLanguage != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Selected: ',
                  style: GoogleFonts.dmSans(color: _muted, fontSize: 13),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  decoration: BoxDecoration(
                    color: _gold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _gold.withOpacity(0.3)),
                  ),
                  child: Text(
                    _languages.firstWhere(
                          (l) => l['code'] == _selectedLanguage,
                      orElse: () => {'native': ''},
                    )['native']!,
                    style: GoogleFonts.dmSans(
                      color: _gold,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          GestureDetector(
            onTap: _isLoading ? null : _handleGetStarted,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 47,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: _selectedLanguage != null
                    ? const LinearGradient(
                  colors: [Color(0xFFE8B84B), Color(0xFFD4A032)],
                )
                    : null,
                color: _selectedLanguage == null ? _border : null,
                boxShadow: _selectedLanguage != null
                    ? [
                  BoxShadow(
                    color: _gold.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
                    : null,
              ),
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2.5,
                  ),
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Get Started',
                      style: GoogleFonts.dmSans(
                        color: _selectedLanguage != null
                            ? Colors.black
                            : _muted,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (_selectedLanguage != null) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.rocket_launch_rounded,
                        color: Colors.black,
                        size: 18,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
