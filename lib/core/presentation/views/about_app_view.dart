import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import '../../resources/app_colors.dart';
import '../../resources/app_values.dart';
import '../../../ads/interstitial_ad_manager.dart';

class AboutAppView extends StatefulWidget {
  const AboutAppView({super.key});

  @override
  State<AboutAppView> createState() => _AboutAppViewState();
}

class _AboutAppViewState extends State<AboutAppView> {
  late InterstitialAdManager _interstitialAdManager;
  bool _interstitialShown = false;

  @override
  void initState() {
    super.initState();
    _initializeInterstitialAd();
  }

  void _initializeInterstitialAd() async {
    log('Initializing Interstitial Ad on About screen');
    
    // Initialize Interstitial Ad Manager
    _interstitialAdManager = InterstitialAdManager();
    _interstitialAdManager.createInterstitialAd1();

    // Wait for interstitial ad to load (give it 2-3 seconds)
    await Future.delayed(Duration(seconds: 2));

    if (!mounted || _interstitialShown) return;

    // Show Interstitial Ad (App Open Ad already shown by global manager)
    if (_interstitialAdManager.interstitialReady1) {
      log('Showing Interstitial Ad on About screen');
      _interstitialAdManager.showInterstitialAd1();
      _interstitialShown = true;
    } else {
      log('Interstitial Ad not ready yet');
    }
  }

  @override
  void dispose() {
    _interstitialAdManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About App',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppPadding.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppPadding.p24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.2),
                      AppColors.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppSize.s24),
                ),
                child: const Icon(
                  Icons.movie_creation_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSize.s32),

            // App Name
            Center(
              child: Text(
                'OnStream',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: AppSize.s8),

            // Version
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p16,
                  vertical: AppPadding.p8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppSize.s20),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Version 1.0.0',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSize.s32),

            // Divider
            const Divider(color: AppColors.secondaryText, height: 1),
            const SizedBox(height: AppSize.s24),

            // Main Description
            _InfoText(
              text:
                  'Our app is designed to provide a simple and user-friendly browsing experience for entertainment lovers. You can discover movies, TV series content through categorized listings and easy navigation.',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s24),

            // Key Features
            _SectionTitle(title: 'Key Features:', textTheme: textTheme),
            const SizedBox(height: AppSize.s12),
            _InfoText(
              text:
                  'Browse entertainment content with a clean and simple interface\nLightweight app with fast performance\nWorks on multiple Android devices',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s24),

            // Important Information
            _SectionTitle(title: 'Important Information:', textTheme: textTheme),
            const SizedBox(height: AppSize.s12),
            _InfoText(
              text:
                  'Our app, OnStream is not associated with or related to the Youcine Tv in any way. ONstream is an independent application and is not affiliated with, endorsed by, or sponsored by any third-party app, brand, or streaming service.',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s24),

            // Discover Movies Differently
            _SectionTitle(
                title: 'Discover Movies Differently with Onstream',
                textTheme: textTheme),
            const SizedBox(height: AppSize.s12),
            _InfoText(
              text:
                  'Whether you\'re searching for the perfect movie for tonight or rediscovering a timeless classic, Onstream transforms how you explore entertainment. With powerful AI that understands your personality, smart recommendations, deep content insights, and intuitive viewing-management tools, your movie and TV experience becomes more personal, intelligent, and inspiring.',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s16),
            _InfoText(
              text:
                  'Onstream isn\'t just another movie app—it\'s your personal entertainment companion. Discover hidden gems, track your habits, and dive into stories that truly match your vibe.',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s24),

            // Why You'll Love Onstream
            _SectionTitle(title: 'Why You\'ll Love Onstream', textTheme: textTheme),
            const SizedBox(height: AppSize.s16),

            // AI Movie Matcher
            _FeatureTitle(
              text: '– AI Movie Matcher',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s8),
            _InfoText(
              text:
                  'Let our intelligent AI analyze your taste and personality to suggest the perfect movie or series—especially when you don\'t know what to watch next.',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s16),

            // Custom Watchlists
            _FeatureTitle(
              text: '– Custom Watchlists',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s8),
            _InfoText(
              text:
                  'Save favorites, organize your must-watch list, and keep all your movie nights perfectly planned.',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s16),

            // Curated Collections
            _FeatureTitle(
              text: '– Curated Collections',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s8),
            _InfoText(
              text:
                  'Explore themed selections by mood, genre, personality, or trending topics—meticulously tailored just for you.',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s16),

            // Nearby Cinemas
            _FeatureTitle(
              text: '– Nearby Cinemas',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s8),
            _InfoText(
              text:
                  'Find cinemas near your location instantly and check showtimes in a single tap.',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s16),

            // Fun Movie Quiz
            _FeatureTitle(
              text: '– Fun Movie Quiz',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s8),
            _InfoText(
              text:
                  'Challenge your movie knowledge with engaging trivia and unlock new discoveries along the way.',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s16),

            // Smart Movie Planner
            _FeatureTitle(
              text: '– Smart Movie Planner',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s8),
            _InfoText(
              text:
                  'Plan what to watch and when. Perfect for scheduling movie nights, binge weekends, or personal watch goals.',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s16),

            // Detailed Movie & Series Info
            _FeatureTitle(
              text: '– Detailed Movie & Series Info',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s8),
            _InfoText(
              text:
                  'Access cast details, ratings, reviews, summaries, trailers, and everything you need before choosing the next title.',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s24),

            // Elevate Your Movie Nights
            _SectionTitle(
                title: 'Elevate Your Movie Nights', textTheme: textTheme),
            const SizedBox(height: AppSize.s12),
            _InfoText(
              text:
                  'Download Onstream today and unlock a world of stories crafted around your personality, mood, and unique taste—all in one beautifully designed app.',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s40),

            // Copyright
            Center(
              child: Column(
                children: [
                  Text(
                    '© 2024 OnStream',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: AppSize.s8),
                  Text(
                    'All Rights Reserved',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSize.s32),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final TextTheme textTheme;

  const _SectionTitle({
    required this.title,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class _InfoText extends StatelessWidget {
  final String text;
  final TextTheme textTheme;

  const _InfoText({
    required this.text,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: textTheme.bodyLarge?.copyWith(
        color: Colors.white70,
        height: 1.6,
      ),
    );
  }
}

class _FeatureTitle extends StatelessWidget {
  final String text;
  final TextTheme textTheme;

  const _FeatureTitle({
    required this.text,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: textTheme.bodyLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        height: 1.5,
      ),
    );
  }
}
