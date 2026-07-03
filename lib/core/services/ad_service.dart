import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'remote_config_service.dart';

/// Service to manage ads across the application
class AdService {
  static AdService? _instance;
  static AdService get instance => _instance ??= AdService._();

  AdService._();

  bool _isInitialized = false;

  /// Initialize Mobile Ads SDK with test device configuration
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final testDeviceIds = ['A005DDD7741B829644732D7CE178E6AD'];
      final requestConfiguration = RequestConfiguration(
        testDeviceIds: testDeviceIds,
      );
      MobileAds.instance.updateRequestConfiguration(requestConfiguration);
      await MobileAds.instance.initialize();
      _isInitialized = true;
    } catch (e) {
      print('❌ AdService initialization failed: $e');
    }
  }

  /// Get Banner Ad Unit ID from Remote Config
  String get bannerAdUnitId {
    return RemoteConfigService.instance.bannerAdUnitId;
  }

  /// Get Interstitial Ad Unit ID from Remote Config
  String get interstitialAdUnitId {
    return RemoteConfigService.instance.interstitialAdUnitId;
  }

  /// Get Native Ad Unit ID from Remote Config
  String get nativeAdUnitId {
    return RemoteConfigService.instance.nativeAdUnitId;
  }

  /// Check if banner ads should be shown (from Remote Config)
  bool get shouldShowBannerAds {
    return RemoteConfigService.instance.showBannerAds;
  }

  /// Check if native ads should be shown (from Remote Config)
  bool get shouldShowNativeAds {
    return RemoteConfigService.instance.showNativeAds;
  }

  // Screen-specific native ad getters
  bool get shouldShowNativeAdLanguageSelection {
    return RemoteConfigService.instance.showNativeAdLanguageSelection;
  }

  bool get shouldShowNativeAdLoginSignup {
    return RemoteConfigService.instance.showNativeAdLoginSignup;
  }

  bool get shouldShowNativeAdProfileSetup {
    return RemoteConfigService.instance.showNativeAdProfileSetup;
  }

  bool get shouldShowNativeAdMoviesHome1 {
    return RemoteConfigService.instance.showNativeAdMoviesHome1;
  }

  bool get shouldShowNativeAdMoviesHome2 {
    return RemoteConfigService.instance.showNativeAdMoviesHome1;
  }

  bool get shouldShowNativeAdMoviesHome3 {
    return RemoteConfigService.instance.showNativeAdMoviesHome1;
  }

  bool get shouldShowNativeAdTVShowsHome {
    return RemoteConfigService.instance.showNativeAdTVShowsHome;
  }

  bool get shouldShowNativeAdSearch {
    return RemoteConfigService.instance.showNativeAdSearch;
  }

  bool get shouldShowNativeAdWatchlist {
    return RemoteConfigService.instance.showNativeAdWatchlist;
  }

  bool get shouldShowNativeAdPopularMovies {
    return RemoteConfigService.instance.showNativeAdPopularMovies;
  }

  bool get shouldShowNativeAdTopRatedMovies {
    return RemoteConfigService.instance.showNativeAdTopRatedMovies;
  }

  bool get shouldShowNativeAdMovieDetails {
    return RemoteConfigService.instance.showNativeAdMovieDetails;
  }

  bool get shouldShowNativeAdPopularTVShows {
    return RemoteConfigService.instance.showNativeAdPopularTVShows;
  }

  bool get shouldShowNativeAdTopRatedTVShows {
    return RemoteConfigService.instance.showNativeAdTopRatedTVShows;
  }

  bool get shouldShowNativeAdTVShowDetails {
    return RemoteConfigService.instance.showNativeAdTVShowDetails;
  }

  /// Check if interstitial ads should be shown (from Remote Config)
  bool get shouldShowInterstitialAds {
    return RemoteConfigService.instance.showInterstitialAds;
  }

  /// Get interstitial ad frequency from Remote Config
  int get interstitialAdFrequency {
    return RemoteConfigService.instance.interstitialAdFrequency;
  }

  /// Load a Banner Ad
  BannerAd createBannerAd({
    required Function(Ad ad) onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
    AdSize? size,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: size ?? AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }

  /// Load an Interstitial Ad
  Future<InterstitialAd?> loadInterstitialAd() async {
    try {
      InterstitialAd? interstitialAd;
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            interstitialAd = ad;
            print('✅ Interstitial ad loaded');
          },
          onAdFailedToLoad: (error) {
            print('❌ Interstitial ad failed to load: $error');
          },
        ),
      );
      return interstitialAd;
    } catch (e) {
      print('❌ Error loading interstitial ad: $e');
      return null;
    }
  }

  /// Load a Native Ad
  NativeAd createNativeAd({
    required Function(Ad ad) onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
    String factoryId = 'nativeAd',

  }) {
    return NativeAd(
      adUnitId: nativeAdUnitId,
      // factoryId: 'listTile',
      factoryId: factoryId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }

  /// Dispose method
  void dispose() {
    _isInitialized = false;
  }
}
