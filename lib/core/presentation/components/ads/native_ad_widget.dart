import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';
import '../../../services/ad_service.dart';
import '../../../services/remote_config_service.dart';

/// Reusable Native Ad Widget with real-time Remote Config updates
/// Note: Native ads require platform-specific factory setup
/// This widget will gracefully hide if native ads can't load
class NativeAdWidget extends StatefulWidget {
  final double height;
  final String? adKey; // Screen-specific key like 'login_signup', 'movies_home_1', etc.

  const NativeAdWidget({super.key, this.height = 300, this.adKey});

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _hasError = false;
  StreamSubscription? _configSubscription;
  bool _shouldShowAds = false;

  @override
  void initState() {
    super.initState();
    _shouldShowAds = _getAdVisibility();

    if (_shouldShowAds) {
      _loadNativeAd();
    }
    
    // Listen to Remote Config changes
    _configSubscription = RemoteConfigService.instance.configUpdates.listen((_) {
      _handleConfigUpdate();
    });
  }
  
  bool _getAdVisibility() {
    switch (widget.adKey) {
      case 'language_selection':
        return AdService.instance.shouldShowNativeAdLanguageSelection;
      case 'login_signup':
        return AdService.instance.shouldShowNativeAdLoginSignup;
      case 'profile_setup':
        return AdService.instance.shouldShowNativeAdProfileSetup;
      case 'movies_home_1':
        return AdService.instance.shouldShowNativeAdMoviesHome1;
      case 'movies_home_2':
        return AdService.instance.shouldShowNativeAdMoviesHome2;
      case 'movies_home_3':
        return AdService.instance.shouldShowNativeAdMoviesHome3;
      case 'tv_shows_home':
        return AdService.instance.shouldShowNativeAdTVShowsHome;
      case 'search':
        return AdService.instance.shouldShowNativeAdSearch;
      case 'watchlist':
        return AdService.instance.shouldShowNativeAdWatchlist;
      case 'popular_movies':
        return AdService.instance.shouldShowNativeAdPopularMovies;
      case 'top_rated_movies':
        return AdService.instance.shouldShowNativeAdTopRatedMovies;
      case 'movie_details':
        return AdService.instance.shouldShowNativeAdMovieDetails;
      case 'popular_tv_shows':
        return AdService.instance.shouldShowNativeAdPopularTVShows;
      case 'top_rated_tv_shows':
        return AdService.instance.shouldShowNativeAdTopRatedTVShows;
      case 'tv_show_details':
        return AdService.instance.shouldShowNativeAdTVShowDetails;
      default:
        return AdService.instance.shouldShowNativeAds;
    }
  }
  
  void _handleConfigUpdate() {
    final newValue = _getAdVisibility();
    
    // If value changed
    if (newValue != _shouldShowAds) {
      setState(() {
        _shouldShowAds = newValue;
      });
      
      if (_shouldShowAds) {
        print('📢 Native ads ${widget.adKey ?? 'default'} enabled via Remote Config');
        _loadNativeAd();
      } else {
        // Ads disabled, dispose current ad
        print('🚫 Native ads ${widget.adKey ?? 'default'} disabled via Remote Config');
        _nativeAd?.dispose();
        _nativeAd = null;
        setState(() {
          _isAdLoaded = false;
          _hasError = false;
        });
      }
    }
  }

  void _loadNativeAd() {
    try {
      _nativeAd = AdService.instance.createNativeAd(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _hasError = false;
            });
            print('✅ Native ad ${widget.adKey ?? 'default'} loaded');
          }
        },
        onAdFailedToLoad: (ad, error) {
          print('⚠️ Native ad ${widget.adKey ?? 'default'} failed to load: $error');
          if (mounted) {
            setState(() {
              _hasError = true;
            });
          }
          ad.dispose();
        },
      );
      _nativeAd?.load();
    } catch (e) {
      print('⚠️ Native ad ${widget.adKey ?? 'default'} error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _configSubscription?.cancel();
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShowAds) {
      return const SizedBox.shrink();
    }

    if (_hasError || !_isAdLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: widget.height < 100 ? EdgeInsets.zero : const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1)),
      ),
      height: widget.height,
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
