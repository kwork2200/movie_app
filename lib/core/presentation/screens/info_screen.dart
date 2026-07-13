import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../ads/app_open_ad_manager.dart';
import '../components/ads/ad_enabled_screen.dart';
import '../components/ads/interstitial_ad_manager.dart';
import '../components/ads/qureka_interstitial.dart';
import '../../services/ad_service.dart';
import '../../services/fb_ad_service.dart';
import '../../services/remote_config_service.dart';
import '../../utils/functions.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  bool _isAdProcessing = true;

  @override
  void initState() {
    super.initState();
    _showAdsSequentially();
  }

  Future<void> _showAdsSequentially() async {
    try {
      print('🎬 InfoScreen: Phase 1 - App Open Ad');
      await Future.any([
        _tryShowAppOpenAd(),
        Future.delayed(const Duration(seconds: 5)),
      ]);
      await Future.delayed(const Duration(milliseconds: 800));
      await Future.any([
        _tryShowInterstitialAd(),
        Future.delayed(const Duration(seconds: 3)),
      ]);
      
      print('🎬 InfoScreen: All ads complete, displaying screen');
      
    } catch (e) {
      print('❌ InfoScreen: Critical error in ad sequence: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isAdProcessing = false;
        });
      }
    }
  }

  Future<void> _tryShowAppOpenAd() async {
    try {
      final appOpenManager = AppOpenAdManager.instance;
      
      print('🎬 InfoScreen: Checking App Open Ad...');
      
      for (int i = 0; i < 6; i++) {
        if (appOpenManager.isAdAvailable) {
          print('🎬 InfoScreen: App Open Ad is ready! Showing now...');
          final completer = Completer<void>();
          
          appOpenManager.showAdIfAvailable(
            onAdDismissed: () {
              print('✅ InfoScreen: App Open Ad dismissed - moving to next ad');
              if (!completer.isCompleted) completer.complete();
            },
          );
          
          await Future.any([
            completer.future,
            Future.delayed(const Duration(seconds: 15)),
          ]);
          await Future.delayed(const Duration(milliseconds: 500));
          print('✅ InfoScreen: App Open Ad phase complete');
          return;
        }
        
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      print('⏭️ InfoScreen: App Open Ad not ready after 3s, proceeding to next ad');
      
    } catch (e) {
      print('❌ InfoScreen: Error in _tryShowAppOpenAd: $e');
    }
  }

  Future<void> _tryShowInterstitialAd() async {
    try {
      final manager = InterstitialAdManager.instance;
      
      print('🎬 InfoScreen: Checking Interstitial Ad...');
      
      final bool googleEnabled = AdService.instance.shouldShowInterstitialAds;
      final bool facebookEnabled = FbAdService.instance.shouldShowInterstitialAds;
      final bool thirdPartyEnabled = RemoteConfigService.instance.showThirdPartyInterstitialAds && ENABLE_THIRD_PARTY_ADS;
      
      if (!googleEnabled && !facebookEnabled && thirdPartyEnabled && mounted) {
        print('🎬 InfoScreen: Showing third-party interstitial ad (both Google & Facebook disabled)');
        try {
          await showManagedInterstitialAd(context, alwaysShow: true);
          print('✅ InfoScreen: Third-party ad shown successfully');
          return;
        } catch (e) {
          print('❌ InfoScreen: Error showing third-party ad: $e');
          return;
        }
      }
      for (int i = 0; i < 4; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (manager.isAdReady) {
          print('🎬 InfoScreen: Interstitial Ad is ready! Showing now...');
          try {
            await showManagedInterstitialAd(context, alwaysShow: true);
            print('✅ InfoScreen: Interstitial Ad shown successfully');
            return;
          } catch (e) {
            print('❌ InfoScreen: Error showing interstitial ad: $e');
            return;
          }
        }
      }
      manager.loadAd();
      
    } catch (e) {
      print('❌ InfoScreen: Error in _tryShowInterstitialAd: $e');
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdProcessing) {
      return Scaffold(
        backgroundColor: const Color(0xFF090C14),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFFE8B84B),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Loading...',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: const Color(0xFF8892AA),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return AdEnabledScreen(
      child: Scaffold(
        backgroundColor: const Color(0xFF090C14),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Info',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFE8B84B).withOpacity(0.2),
                      const Color(0xFFC084FC).withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE8B84B).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.movie_outlined,
                      size: 64,
                      color: const Color(0xFFE8B84B),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Watch New Movie',
                      style: GoogleFonts.dmSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Discover latest movies and shows',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: const Color(0xFF8892AA),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to language selection screen
                        context.go('/language-selection');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8B84B),
                        foregroundColor: const Color(0xFF090C14),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Browse Movies',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildActionTile(
                icon: Icons.star_outline,
                title: 'Rate Us',
                subtitle: 'Help us improve with your feedback',
                color: const Color(0xFFC084FC),
                onTap: () {
                  _launchURL('https://play.google.com/store/apps');
                },
              ),
              const SizedBox(height: 16),
              _buildActionTile(
                icon: Icons.share_outlined,
                title: 'Share',
                subtitle: 'Share this app with your friends',
                color: const Color(0xFF6366F1),
                onTap: () {
                  _launchURL('https://play.google.com/store/apps');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1422),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: const Color(0xFF8892AA),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
