import 'dart:async';
import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Service to manage Firebase Remote Config for ads configuration
class RemoteConfigService {
  static RemoteConfigService? _instance;
  static RemoteConfigService get instance => _instance ??= RemoteConfigService._();

  RemoteConfigService._();

  late FirebaseRemoteConfig _remoteConfig;
  bool _isInitialized = false;
  
  final _configUpdateController = StreamController<void>.broadcast();
  
  /// Stream that emits whenever Remote Config is updated
  Stream<void> get configUpdates => _configUpdateController.stream;

  static const Map<String, dynamic> _defaults = {
    'show_banner_ads': true,
    'show_native_ads': true,
    
    'use_facebook_ads': false,
    'show_fb_banner_ads': true,
    'show_fb_native_ads': true,
    
    'show_third_party_banner_ads': true,
    'show_third_party_native_ads': true,
    'third_party_ad_url': 'http://1261.mark.qureka.com/',
    
    'show_third_party_interstitial_ads': true,
    'third_party_interstitial_ad_url_1': 'http://1261.mark.qureka.com/',
    'third_party_interstitial_ad_url_2': 'http://1261.mark.qureka.com/',
    'third_party_interstitial_ad_url_3': 'http://1261.mark.qureka.com/',
    
    'show_native_ad_language_selection': true,
    'show_native_ad_login_signup': true,
    'show_native_ad_profile_setup': true,
    'show_native_ad_movies_home_1': true,
    'show_native_ad_tv_shows_home': true,
    'show_native_ad_search': true,
    'show_native_ad_watchlist': true,
    'show_native_ad_popular_movies': true,
    'show_native_ad_top_rated_movies': true,
    'show_native_ad_movie_details': true,
    'show_native_ad_popular_tv_shows': true,
    'show_native_ad_top_rated_tv_shows': true,
    'show_native_ad_tv_show_details': true,
    
    'show_fb_native_ad_language_selection': true,
    'show_fb_native_ad_login_signup': true,
    'show_fb_native_ad_profile_setup': true,
    'show_fb_native_ad_movies_home_1': true,
    'show_fb_native_ad_movies_home_2': true,
    'show_fb_native_ad_movies_home_3': true,
    'show_fb_native_ad_tv_shows_home': true,
    'show_fb_native_ad_search': true,
    'show_fb_native_ad_watchlist': true,
    'show_fb_native_ad_popular_movies': true,
    'show_fb_native_ad_top_rated_movies': true,
    'show_fb_native_ad_movie_details': true,
    'show_fb_native_ad_popular_tv_shows': true,
    'show_fb_native_ad_top_rated_tv_shows': true,
    'show_fb_native_ad_tv_show_details': true,
    
    'show_interstitial_ads': true,
    'show_fb_interstitial_ads': true,
    'interstitial_ad_frequency': 3,
    'android_banner_ad_id': 'ca-app-pub-3940256099942544/6300978111',
    'android_interstitial_ad_id': 'ca-app-pub-3940256099942544/1033173712',
    'android_native_ad_id': 'ca-app-pub-3940256099942544/2247696110',
    'android_fb_banner_ad_id': 'IMG_16_9_APP_INSTALL#YOUR_PLACEMENT_ID',
    'android_fb_interstitial_ad_id': 'VID_HD_16_9_46S_APP_INSTALL#YOUR_PLACEMENT_ID',
    'android_fb_native_ad_id': 'IMG_16_9_APP_INSTALL#YOUR_PLACEMENT_ID',
  };

  /// Initialize Remote Config
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        )
      );

      await _remoteConfig.setDefaults(_defaults);

      await _remoteConfig.fetchAndActivate();
      
      _remoteConfig.onConfigUpdated.listen((event) async {
        await _remoteConfig.activate();

        _configUpdateController.add(null);
      }, onError: (error) {
      });
      _isInitialized = true;
      _startPeriodicFetch();
    } catch (e) {
      print('❌ Remote Config initialization failed: $e');
      print('⚠️ Using default values');
    }
  }
  
  /// Start periodic fetching to detect changes quickly
  Timer? _fetchTimer;
  void _startPeriodicFetch() {
    _fetchTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        print('🔄 Checking for Remote Config updates...');
        final updated = await _remoteConfig.fetchAndActivate();
        if (updated) {
          print('✅ Remote Config updated via periodic fetch');
          _configUpdateController.add(null);
        } else {
          print('ℹ️ Remote Config already up-to-date');
        }
      } catch (e) {
        print('⚠️ Periodic fetch error: $e');
      }
    });
  }

  /// Force fetch latest config from server (useful for testing)
  Future<bool> fetchAndActivate() async {
    try {
      print('🔄 Manually fetching Remote Config...');
      final updated = await _remoteConfig.fetchAndActivate();
      if (updated) {
        print('✅ Remote Config fetched and activated');
        _configUpdateController.add(null);
        return true;
      } else {
        print('ℹ️ Remote Config already up to date');
        return false;
      }
    } catch (e) {
      print('❌ Failed to fetch Remote Config: $e');
      return false;
    }
  }
  
  /// Clean up resources
  void dispose() {
    _fetchTimer?.cancel();
    _configUpdateController.close();
  }

  /// Check if Facebook Ads should be used as primary/fallback
  bool get useFacebookAds {
    try {
      return _remoteConfig.getBool('use_facebook_ads');
    } catch (e) {
      print('⚠️ Error getting use_facebook_ads: $e');
      return _defaults['use_facebook_ads'] as bool;
    }
  }

  /// Check if third-party banner ads should be shown (fallback image ads)
  bool get showThirdPartyBannerAds {
    try {
      return _remoteConfig.getBool('show_third_party_banner_ads');
    } catch (e) {
      print('⚠️ Error getting show_third_party_banner_ads: $e');
      return _defaults['show_third_party_banner_ads'] as bool;
    }
  }

  /// Check if third-party native ads should be shown (fallback image ads)
  bool get showThirdPartyNativeAds {
    try {
      return _remoteConfig.getBool('show_third_party_native_ads');
    } catch (e) {
      print('⚠️ Error getting show_third_party_native_ads: $e');
      return _defaults['show_third_party_native_ads'] as bool;
    }
  }

  /// Get third-party ad click URL
  String get thirdPartyAdUrl {
    try {
      return _remoteConfig.getString('third_party_ad_url');
    } catch (e) {
      print('⚠️ Error getting third_party_ad_url: $e');
      return _defaults['third_party_ad_url'] as String;
    }
  }

  /// Check if third-party interstitial ads should be shown
  bool get showThirdPartyInterstitialAds {
    try {
      return _remoteConfig.getBool('show_third_party_interstitial_ads');
    } catch (e) {
      print('⚠️ Error getting show_third_party_interstitial_ads: $e');
      return _defaults['show_third_party_interstitial_ads'] as bool;
    }
  }

  /// Get third-party interstitial ad URL 1 (Qureka)
  String get thirdPartyInterstitialAdUrl1 {
    try {
      return _remoteConfig.getString('third_party_interstitial_ad_url_1');
    } catch (e) {
      print('⚠️ Error getting third_party_interstitial_ad_url_1: $e');
      return _defaults['third_party_interstitial_ad_url_1'] as String;
    }
  }

  /// Check if banner ads should be shown
  bool get showBannerAds {
    try {
      return _remoteConfig.getBool('show_banner_ads');
    } catch (e) {
      print('⚠️ Error getting show_banner_ads: $e');
      return _defaults['show_banner_ads'] as bool;
    }
  }

  bool get showFbBannerAds {
    try {
      return _remoteConfig.getBool('show_fb_banner_ads');
    } catch (e) {
      print('⚠️ Error getting show_fb_banner_ads: $e');
      return _defaults['show_fb_banner_ads'] as bool;
    }
  }

  bool get showNativeAds {
    try {
      return _remoteConfig.getBool('show_native_ads');
    } catch (e) {
      print('⚠️ Error getting show_native_ads: $e');
      return _defaults['show_native_ads'] as bool;
    }
  }

  bool get showFbNativeAds {
    try {
      return _remoteConfig.getBool('show_fb_native_ads');
    } catch (e) {
      print('⚠️ Error getting show_fb_native_ads: $e');
      return _defaults['show_fb_native_ads'] as bool;
    }
  }


  bool get showNativeAdLanguageSelection {
    try {
      return _remoteConfig.getBool('show_native_ad_language_selection');
    } catch (e) {
      return _defaults['show_native_ad_language_selection'] as bool;
    }
  }

  bool get showNativeAdLoginSignup {
    try {
      return _remoteConfig.getBool('show_native_ad_login_signup');
    } catch (e) {
      return _defaults['show_native_ad_login_signup'] as bool;
    }
  }

  bool get showNativeAdProfileSetup {
    try {
      return _remoteConfig.getBool('show_native_ad_profile_setup');
    } catch (e) {
      return _defaults['show_native_ad_profile_setup'] as bool;
    }
  }

  bool get showNativeAdMoviesHome1 {
    try {
      return _remoteConfig.getBool('show_native_ad_movies_home_1');
    } catch (e) {
      return _defaults['show_native_ad_movies_home_1'] as bool;
    }
  }

  // bool get showNativeAdMoviesHome2 {
  //   try {
  //     return _remoteConfig.getBool('show_native_ad_movies_home_2');
  //   } catch (e) {
  //     return _defaults['show_native_ad_movies_home_2'] as bool;
  //   }
  // }
  //
  // bool get showNativeAdMoviesHome3 {
  //   try {
  //     return _remoteConfig.getBool('show_native_ad_movies_home_3');
  //   } catch (e) {
  //     return _defaults['show_native_ad_movies_home_3'] as bool;
  //   }
  // }

  bool get showNativeAdTVShowsHome {
    try {
      return _remoteConfig.getBool('show_native_ad_tv_shows_home');
    } catch (e) {
      return _defaults['show_native_ad_tv_shows_home'] as bool;
    }
  }

  bool get showNativeAdSearch {
    try {
      return _remoteConfig.getBool('show_native_ad_search');
    } catch (e) {
      return _defaults['show_native_ad_search'] as bool;
    }
  }

  bool get showNativeAdWatchlist {
    try {
      return _remoteConfig.getBool('show_native_ad_watchlist');
    } catch (e) {
      return _defaults['show_native_ad_watchlist'] as bool;
    }
  }

  bool get showNativeAdPopularMovies {
    try {
      return _remoteConfig.getBool('show_native_ad_popular_movies');
    } catch (e) {
      return _defaults['show_native_ad_popular_movies'] as bool;
    }
  }

  bool get showNativeAdTopRatedMovies {
    try {
      return _remoteConfig.getBool('show_native_ad_top_rated_movies');
    } catch (e) {
      return _defaults['show_native_ad_top_rated_movies'] as bool;
    }
  }

  bool get showNativeAdMovieDetails {
    try {
      return _remoteConfig.getBool('show_native_ad_movie_details');
    } catch (e) {
      return _defaults['show_native_ad_movie_details'] as bool;
    }
  }

  bool get showNativeAdPopularTVShows {
    try {
      return _remoteConfig.getBool('show_native_ad_popular_tv_shows');
    } catch (e) {
      return _defaults['show_native_ad_popular_tv_shows'] as bool;
    }
  }

  bool get showNativeAdTopRatedTVShows {
    try {
      return _remoteConfig.getBool('show_native_ad_top_rated_tv_shows');
    } catch (e) {
      return _defaults['show_native_ad_top_rated_tv_shows'] as bool;
    }
  }

  bool get showNativeAdTVShowDetails {
    try {
      return _remoteConfig.getBool('show_native_ad_tv_show_details');
    } catch (e) {
      return _defaults['show_native_ad_tv_show_details'] as bool;
    }
  }

  // Facebook Native Ads - Screen-specific getters
  bool get showFbNativeAdLanguageSelection {
    try {
      return _remoteConfig.getBool('show_fb_native_ad_language_selection');
    } catch (e) {
      return _defaults['show_fb_native_ad_language_selection'] as bool;
    }
  }

  bool get showFbNativeAdLoginSignup {
    try {
      return _remoteConfig.getBool('show_fb_native_ad_login_signup');
    } catch (e) {
      return _defaults['show_fb_native_ad_login_signup'] as bool;
    }
  }

  bool get showFbNativeAdProfileSetup {
    try {
      return _remoteConfig.getBool('show_fb_native_ad_profile_setup');
    } catch (e) {
      return _defaults['show_fb_native_ad_profile_setup'] as bool;
    }
  }

  bool get showFbNativeAdMoviesHome1 {
    try {
      return _remoteConfig.getBool('show_fb_native_ad_movies_home_1');
    } catch (e) {
      return _defaults['show_fb_native_ad_movies_home_1'] as bool;
    }
  }

  bool get showFbNativeAdMoviesHome2 {
    try {
      return _remoteConfig.getBool('show_fb_native_ad_movies_home_2');
    } catch (e) {
      return _defaults['show_fb_native_ad_movies_home_2'] as bool;
    }
  }

  bool get showFbNativeAdMoviesHome3 {
    try {
      return _remoteConfig.getBool('show_fb_native_ad_movies_home_3');
    } catch (e) {
      return _defaults['show_fb_native_ad_movies_home_3'] as bool;
    }
  }

  bool get showFbNativeAdTVShowsHome {
    try {
      return _remoteConfig.getBool('show_fb_native_ad_tv_shows_home');
    } catch (e) {
      return _defaults['show_fb_native_ad_tv_shows_home'] as bool;
    }
  }

  bool get showFbNativeAdSearch {
    try {
      return _remoteConfig.getBool('show_fb_native_ad_search');
    } catch (e) {
      return _defaults['show_fb_native_ad_search'] as bool;
    }
  }

  bool get showFbNativeAdWatchlist {
    try {
      return _remoteConfig.getBool('show_fb_native_ad_watchlist');
    } catch (e) {
      return _defaults['show_fb_native_ad_watchlist'] as bool;
    }
  }

  bool get showFbNativeAdPopularMovies {
    try {
      return _remoteConfig.getBool('show_fb_native_ad_popular_movies');
    } catch (e) {
      return _defaults['show_fb_native_ad_popular_movies'] as bool;
    }
  }

  bool get showFbNativeAdTopRatedMovies {
    try {
      return _remoteConfig.getBool('show_fb_native_ad_top_rated_movies');
    } catch (e) {
      return _defaults['show_fb_native_ad_top_rated_movies'] as bool;
    }
  }

  bool get showFbNativeAdMovieDetails {
    try {
      return _remoteConfig.getBool('show_fb_native_ad_movie_details');
    } catch (e) {
      return _defaults['show_fb_native_ad_movie_details'] as bool;
    }
  }

  bool get showFbNativeAdPopularTVShows {
    try {
      return _remoteConfig.getBool('show_fb_native_ad_popular_tv_shows');
    } catch (e) {
      return _defaults['show_fb_native_ad_popular_tv_shows'] as bool;
    }
  }

  bool get showFbNativeAdTopRatedTVShows {
    try {
      return _remoteConfig.getBool('show_fb_native_ad_top_rated_tv_shows');
    } catch (e) {
      return _defaults['show_fb_native_ad_top_rated_tv_shows'] as bool;
    }
  }

  bool get showFbNativeAdTVShowDetails {
    try {
      return _remoteConfig.getBool('show_fb_native_ad_tv_show_details');
    } catch (e) {
      return _defaults['show_fb_native_ad_tv_show_details'] as bool;
    }
  }

  /// Check if interstitial ads should be shown
  bool get showInterstitialAds {
    try {
      return _remoteConfig.getBool('show_interstitial_ads');
    } catch (e) {
      print('⚠️ Error getting show_interstitial_ads: $e');
      return _defaults['show_interstitial_ads'] as bool;
    }
  }

  bool get showFbInterstitialAds {
    try {
      return _remoteConfig.getBool('show_fb_interstitial_ads');
    } catch (e) {
      print('⚠️ Error getting show_fb_interstitial_ads: $e');
      return _defaults['show_fb_interstitial_ads'] as bool;
    }
  }


  /// Get interstitial ad frequency (show after X screens)
  int get interstitialAdFrequency {
    try {
      final frequency = _remoteConfig.getInt('interstitial_ad_frequency');
      return frequency > 0 ? frequency : 3; // Minimum 1
    } catch (e) {
      print('⚠️ Error getting interstitial_ad_frequency: $e');
      return _defaults['interstitial_ad_frequency'] as int;
    }
  }


  String get bannerAdUnitId {
    try {
      if (Platform.isAndroid) {
        return _remoteConfig.getString('android_banner_ad_id');
      } else if (Platform.isIOS) {
        return _remoteConfig.getString('ios_banner_ad_id');
      }
    } catch (e) {
      print('⚠️ Error getting banner ad unit ID: $e');
    }
    
    if (Platform.isAndroid) {
      return _defaults['android_banner_ad_id'] as String;
    } else if (Platform.isIOS) {
      return _defaults['ios_banner_ad_id'] as String;
    }
    throw UnsupportedError('Unsupported platform');
  }

  String get interstitialAdUnitId {
    try {
      if (Platform.isAndroid) {
        return _remoteConfig.getString('android_interstitial_ad_id');
      } else if (Platform.isIOS) {
        return _remoteConfig.getString('ios_interstitial_ad_id');
      }
    } catch (e) {
      print('⚠️ Error getting interstitial ad unit ID: $e');
    }
    
    if (Platform.isAndroid) {
      return _defaults['android_interstitial_ad_id'] as String;
    } else if (Platform.isIOS) {
      return _defaults['ios_interstitial_ad_id'] as String;
    }
    throw UnsupportedError('Unsupported platform');
  }

  String get nativeAdUnitId {
    try {
      if (Platform.isAndroid) {
        return _remoteConfig.getString('android_native_ad_id');
      } else if (Platform.isIOS) {
        return _remoteConfig.getString('ios_native_ad_id');
      }
    } catch (e) {
      print('⚠️ Error getting native ad unit ID: $e');
    }
    
    if (Platform.isAndroid) {
      return _defaults['android_native_ad_id'] as String;
    } else if (Platform.isIOS) {
      return _defaults['ios_native_ad_id'] as String;
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Facebook Ad Unit IDs
  String get fbBannerAdUnitId {
    try {
      if (Platform.isAndroid) {
        return _remoteConfig.getString('android_fb_banner_ad_id');
      } else if (Platform.isIOS) {
        return _remoteConfig.getString('ios_fb_banner_ad_id');
      }
    } catch (e) {
      print('⚠️ Error getting FB banner ad unit ID: $e');
    }
    
    if (Platform.isAndroid) {
      return _defaults['android_fb_banner_ad_id'] as String;
    } else if (Platform.isIOS) {
      return _defaults['ios_fb_banner_ad_id'] as String;
    }
    throw UnsupportedError('Unsupported platform');
  }

  String get fbInterstitialAdUnitId {
    try {
      if (Platform.isAndroid) {
        return _remoteConfig.getString('android_fb_interstitial_ad_id');
      } else if (Platform.isIOS) {
        return _remoteConfig.getString('ios_fb_interstitial_ad_id');
      }
    } catch (e) {
      print('⚠️ Error getting FB interstitial ad unit ID: $e');
    }
    
    if (Platform.isAndroid) {
      return _defaults['android_fb_interstitial_ad_id'] as String;
    } else if (Platform.isIOS) {
      return _defaults['ios_fb_interstitial_ad_id'] as String;
    }
    throw UnsupportedError('Unsupported platform');
  }

  String get fbNativeAdUnitId {
    try {
      if (Platform.isAndroid) {
        return _remoteConfig.getString('android_fb_native_ad_id');
      } else if (Platform.isIOS) {
        return _remoteConfig.getString('ios_fb_native_ad_id');
      }
    } catch (e) {
      print('⚠️ Error getting FB native ad unit ID: $e');
    }
    
    if (Platform.isAndroid) {
      return _defaults['android_fb_native_ad_id'] as String;
    } else if (Platform.isIOS) {
      return _defaults['ios_fb_native_ad_id'] as String;
    }
    throw UnsupportedError('Unsupported platform');
  }


  /// Get all config values (useful for debugging)
  Map<String, dynamic> getAllValues() {
    return {
      'show_banner_ads': showBannerAds,
      'show_native_ads': showNativeAds,
      'show_native_ad_language_selection': showNativeAdLanguageSelection,
      'show_native_ad_login_signup': showNativeAdLoginSignup,
      'show_native_ad_profile_setup': showNativeAdProfileSetup,
      'show_native_ad_movies_home_1': showNativeAdMoviesHome1,
      'show_native_ad_tv_shows_home': showNativeAdTVShowsHome,
      'show_native_ad_search': showNativeAdSearch,
      'show_native_ad_watchlist': showNativeAdWatchlist,
      'show_native_ad_popular_movies': showNativeAdPopularMovies,
      'show_native_ad_top_rated_movies': showNativeAdTopRatedMovies,
      'show_native_ad_movie_details': showNativeAdMovieDetails,
      'show_native_ad_popular_tv_shows': showNativeAdPopularTVShows,
      'show_native_ad_top_rated_tv_shows': showNativeAdTopRatedTVShows,
      'show_native_ad_tv_show_details': showNativeAdTVShowDetails,
      'show_interstitial_ads': showInterstitialAds,
      'interstitial_ad_frequency': interstitialAdFrequency,
      'banner_ad_unit_id': bannerAdUnitId,
      'interstitial_ad_unit_id': interstitialAdUnitId,
      'native_ad_unit_id': nativeAdUnitId,
    };
  }
}
