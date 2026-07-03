import 'package:flutter/services.dart';
import 'remote_config_service.dart';

/// Service to manage Facebook Audience Network ads via Platform Channel
class FbAdService {
  static FbAdService? _instance;
  static FbAdService get instance => _instance ??= FbAdService._();

  FbAdService._();

  bool _isInitialized = false;
  static const platform = MethodChannel('com.example.new_movie_app/facebook_ads');

  /// Initialize Facebook Audience Network SDK with test device
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      print('🔧 Facebook test device hash: 6a456e1f-e23f-4a75-9e17-f8fa9481c4e4');
      print('📝 Add this device to Facebook Business Manager as test device');
      
      _isInitialized = true;
      print('✅ Facebook Ad Service initialized successfully');
    } catch (e) {
      print('❌ Facebook Ad Service initialization failed: $e');
    }
  }

  /// Get Banner Ad Unit ID from Remote Config
  String get bannerAdUnitId {
    return RemoteConfigService.instance.fbBannerAdUnitId;
  }

  /// Get Interstitial Ad Unit ID from Remote Config
  String get interstitialAdUnitId {
    return RemoteConfigService.instance.fbInterstitialAdUnitId;
  }

  /// Get Native Ad Unit ID from Remote Config
  String get nativeAdUnitId {
    return RemoteConfigService.instance.fbNativeAdUnitId;
  }

  /// Check if Facebook ads should be used
  bool get useFacebookAds {
    return RemoteConfigService.instance.useFacebookAds;
  }

  /// Check if banner ads should be shown (from Remote Config)
  bool get shouldShowBannerAds {
    return RemoteConfigService.instance.showFbBannerAds;
  }

  /// Check if native ads should be shown (from Remote Config)
  bool get shouldShowNativeAds {
    return RemoteConfigService.instance.showFbNativeAds;
  }

  // Screen-specific native ad getters (with master switch check)
  bool get shouldShowNativeAdLanguageSelection {
    return shouldShowNativeAds && RemoteConfigService.instance.showFbNativeAdLanguageSelection;
  }

  bool get shouldShowNativeAdLoginSignup {
    return shouldShowNativeAds && RemoteConfigService.instance.showFbNativeAdLoginSignup;
  }

  bool get shouldShowNativeAdProfileSetup {
    return shouldShowNativeAds && RemoteConfigService.instance.showFbNativeAdProfileSetup;
  }

  bool get shouldShowNativeAdMoviesHome1 {
    return shouldShowNativeAds && RemoteConfigService.instance.showFbNativeAdMoviesHome1;
  }

  bool get shouldShowNativeAdMoviesHome2 {
    return shouldShowNativeAds && RemoteConfigService.instance.showFbNativeAdMoviesHome2;
  }

  bool get shouldShowNativeAdMoviesHome3 {
    return shouldShowNativeAds && RemoteConfigService.instance.showFbNativeAdMoviesHome3;
  }

  bool get shouldShowNativeAdTVShowsHome {
    return shouldShowNativeAds && RemoteConfigService.instance.showFbNativeAdTVShowsHome;
  }

  bool get shouldShowNativeAdSearch {
    return shouldShowNativeAds && RemoteConfigService.instance.showFbNativeAdSearch;
  }

  bool get shouldShowNativeAdWatchlist {
    return shouldShowNativeAds && RemoteConfigService.instance.showFbNativeAdWatchlist;
  }

  bool get shouldShowNativeAdPopularMovies {
    return shouldShowNativeAds && RemoteConfigService.instance.showFbNativeAdPopularMovies;
  }

  bool get shouldShowNativeAdTopRatedMovies {
    return shouldShowNativeAds && RemoteConfigService.instance.showFbNativeAdTopRatedMovies;
  }

  bool get shouldShowNativeAdMovieDetails {
    return shouldShowNativeAds && RemoteConfigService.instance.showFbNativeAdMovieDetails;
  }

  bool get shouldShowNativeAdPopularTVShows {
    return shouldShowNativeAds && RemoteConfigService.instance.showFbNativeAdPopularTVShows;
  }

  bool get shouldShowNativeAdTopRatedTVShows {
    return shouldShowNativeAds && RemoteConfigService.instance.showFbNativeAdTopRatedTVShows;
  }

  bool get shouldShowNativeAdTVShowDetails {
    return shouldShowNativeAds && RemoteConfigService.instance.showFbNativeAdTVShowDetails;
  }

  /// Check if interstitial ads should be shown (from Remote Config)
  bool get shouldShowInterstitialAds {
    return RemoteConfigService.instance.showFbInterstitialAds;
  }

  /// Load an Interstitial Ad via Platform Channel
  Future<bool> loadInterstitialAd() async {
    try {
      final result = await platform.invokeMethod('loadFbInterstitial', {
        'placementId': interstitialAdUnitId,
      });
      if (result == true) {
        print('✅ FB Interstitial ad loaded');
        return true;
      } else {
        print('❌ FB Interstitial ad failed to load');
        return false;
      }
    } catch (e) {
      print('❌ Error loading FB interstitial ad: $e');
      return false;
    }
  }

  /// Show loaded Interstitial Ad via Platform Channel
  Future<bool> showInterstitialAd() async {
    try {
      final result = await platform.invokeMethod('showFbInterstitial');
      if (result == true) {
        print('✅ FB Interstitial ad shown');
        return true;
      } else {
        print('❌ FB Interstitial ad failed to show');
        return false;
      }
    } catch (e) {
      print('❌ Error showing FB interstitial ad: $e');
      return false;
    }
  }

  /// Destroy Interstitial Ad via Platform Channel
  Future<bool> destroyInterstitialAd() async {
    try {
      final result = await platform.invokeMethod('destroyFbInterstitial');
      return result ?? false;
    } catch (e) {
      print('❌ Error destroying FB interstitial ad: $e');
      return false;
    }
  }

  /// Load a Banner Ad via Platform Channel
  Future<bool> loadBannerAd() async {
    try {
      final result = await platform.invokeMethod('loadFbBanner', {
        'placementId': bannerAdUnitId,
      });
      if (result == true) {
        print('✅ FB Banner ad loaded');
        return true;
      } else {
        print('❌ FB Banner ad failed to load');
        return false;
      }
    } catch (e) {
      print('❌ Error loading FB banner ad: $e');
      return false;
    }
  }

  /// Destroy Banner Ad via Platform Channel
  Future<bool> destroyBannerAd() async {
    try {
      final result = await platform.invokeMethod('destroyFbBanner');
      return result ?? false;
    } catch (e) {
      print('❌ Error destroying FB banner ad: $e');
      return false;
    }
  }

  /// Load a Native Ad via Platform Channel
  Future<Map<String, dynamic>?> loadNativeAd() async {
    try {
      final result = await platform.invokeMethod('loadFbNative', {
        'placementId': nativeAdUnitId,
      });
      if (result != null && result is Map) {
        print('✅ FB Native ad loaded');
        return Map<String, dynamic>.from(result);
      } else {
        print('❌ FB Native ad failed to load');
        return null;
      }
    } catch (e) {
      print('❌ Error loading FB native ad: $e');
      return null;
    }
  }

  /// Destroy Native Ad via Platform Channel
  Future<bool> destroyNativeAd() async {
    try {
      final result = await platform.invokeMethod('destroyFbNative');
      return result ?? false;
    } catch (e) {
      print('❌ Error destroying FB native ad: $e');
      return false;
    }
  }

  /// Dispose method
  void dispose() {
    _isInitialized = false;
  }
}
