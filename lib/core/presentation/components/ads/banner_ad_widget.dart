import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';
import '../../../services/ad_service.dart';
import '../../../services/remote_config_service.dart';

/// Reusable Banner Ad Widget with real-time Remote Config updates
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  StreamSubscription? _configSubscription;
  bool _shouldShowAds = false;

  @override
  void initState() {
    super.initState();
    _shouldShowAds = AdService.instance.shouldShowBannerAds;
    
    // Load ad if enabled
    if (_shouldShowAds) {
      _loadBannerAd();
    }
    
    // Listen to Remote Config changes
    _configSubscription = RemoteConfigService.instance.configUpdates.listen((_) {
      _handleConfigUpdate();
    });
  }
  
  void _handleConfigUpdate() {
    final newValue = AdService.instance.shouldShowBannerAds;
    
    // If value changed
    if (newValue != _shouldShowAds) {
      setState(() {
        _shouldShowAds = newValue;
      });
      
      if (_shouldShowAds) {
        // Ads enabled, load ad
        print('📢 Banner ads enabled via Remote Config');
        _loadBannerAd();
      } else {
        // Ads disabled, dispose current ad
        print('🚫 Banner ads disabled via Remote Config');
        _bannerAd?.dispose();
        _bannerAd = null;
        setState(() {
          _isAdLoaded = false;
        });
      }
    }
  }

  void _loadBannerAd() {
    _bannerAd = AdService.instance.createBannerAd(
      onAdLoaded: (ad) {
        if (mounted) {
          setState(() {
            _isAdLoaded = true;
          });
        }
        print('✅ Banner ad loaded');
      },
      onAdFailedToLoad: (ad, error) {
        print('❌ Banner ad failed to load: $error');
        ad.dispose();
      },
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _configSubscription?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check Remote Config flag (real-time)
    if (!_shouldShowAds) {
      return const SizedBox.shrink();
    }

    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!,),
    );
  }
}
