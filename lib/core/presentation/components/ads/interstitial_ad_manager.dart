import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../services/ad_service.dart';
import '../../../services/fb_ad_service.dart';
import '../../../services/remote_config_service.dart';

/// Manager for Interstitial Ads with real-time Remote Config updates
/// Supports both Google Ads and Facebook Ads with fallback logic
class InterstitialAdManager {
  static InterstitialAdManager? _instance;
  static InterstitialAdManager get instance => _instance ??= InterstitialAdManager._();

  InterstitialAdManager._() {
    _configSubscription = RemoteConfigService.instance.configUpdates.listen((_) {
      _handleConfigUpdate();
    });
  }

  InterstitialAd? _interstitialAd;
  bool _isAdLoading = false;
  bool _isFbAdLoaded = false;
  int _screenCounter = 0;
  StreamSubscription? _configSubscription;

  void _handleConfigUpdate() {
    final shouldShow = AdService.instance.shouldShowInterstitialAds;
    final shouldShowFb = FbAdService.instance.shouldShowInterstitialAds;
    
    if (!shouldShow && !shouldShowFb) {
      print('🚫 All interstitial ads disabled via Remote Config');
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _isAdLoading = false;
      _isFbAdLoaded = false;
    } else {
      print('📢 Interstitial ads enabled via Remote Config');
      // Load both if enabled
      if (shouldShowFb && !_isFbAdLoaded) {
        _loadFacebookAd();
      }
      if (shouldShow && _interstitialAd == null && !_isAdLoading) {
        loadAd();
      }
    }
  }

  bool get _useFacebookAds => RemoteConfigService.instance.useFacebookAds;

  int get _adFrequency => AdService.instance.interstitialAdFrequency;

  /// Load the interstitial ad - Prioritize Google Ads first, then Facebook as fallback
  Future<void> loadAd() async {
    // Priority 1: Try loading Google Ads if enabled
    if (AdService.instance.shouldShowInterstitialAds) {
      if (_isAdLoading || _interstitialAd != null) {
        print('⏭️ Google ad already loading or loaded');
      } else {
        _loadGoogleAd();
      }
    } else {
      print('⏭️ Google ads disabled via Remote Config');
    }
    
    // Priority 2: Also load Facebook Ads as fallback if enabled
    if (FbAdService.instance.shouldShowInterstitialAds) {
      if (!_isFbAdLoaded) {
        _loadFacebookAd();
      } else {
        print('⏭️ Facebook ad already loaded');
      }
    } else {
      print('⏭️ Facebook ads disabled via Remote Config');
    }
  }

  /// Load Google Interstitial Ad
  Future<void> _loadGoogleAd() async {
    if (_isAdLoading || _interstitialAd != null) return;
    _isAdLoading = true;
    
    try {
      await InterstitialAd.load(
        adUnitId: AdService.instance.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isAdLoading = false;
            print('✅ Google Interstitial ad loaded');
          },
          onAdFailedToLoad: (error) {
            print('❌ Google Interstitial ad failed to load: $error');
            _isAdLoading = false;
            _interstitialAd = null;
            // Fallback to Facebook Ads if not already loaded
            if (FbAdService.instance.shouldShowInterstitialAds && !_isFbAdLoaded) {
              print('🔄 Google ads failed, loading Facebook ads as fallback');
              _loadFacebookAd();
            }
          },
        ),
      );
    } catch (e) {
      print('❌ Error loading Google interstitial ad: $e');
      _isAdLoading = false;
      // Fallback to Facebook Ads if not already loaded
      if (FbAdService.instance.shouldShowInterstitialAds && !_isFbAdLoaded) {
        print('🔄 Google ads error, loading Facebook ads as fallback');
        _loadFacebookAd();
      }
    }
  }

  /// Load Facebook Interstitial Ad
  Future<void> _loadFacebookAd() async {
    if (_isFbAdLoaded) return;
    try {
      final loaded = await FbAdService.instance.loadInterstitialAd();
      _isFbAdLoaded = loaded;
      if (loaded) {
        print('✅ Facebook Interstitial ad loaded');
      }
    } catch (e) {
      print('❌ Error loading Facebook interstitial ad: $e');
      _isFbAdLoaded = false;
    }
  }

  /// Show interstitial ad on screen enter (with frequency control)
  /// Priority: 1. Google Ads (if loaded), 2. Facebook Ads (fallback), 3. Load for next time
  Future<void> showAdIfAvailable() async {
    // Check if ANY ad network is enabled
    if (!AdService.instance.shouldShowInterstitialAds && !FbAdService.instance.shouldShowInterstitialAds) {
      print('🚫 All interstitial ads disabled');
      return;
    }

    _screenCounter++;
    if (_screenCounter % _adFrequency != 0) {
      print('⏭️ Skipping ad (counter: $_screenCounter, frequency: $_adFrequency)');
      return;
    }

    // Priority 1: Try Google Ads first if enabled and loaded
    if (AdService.instance.shouldShowInterstitialAds && _interstitialAd != null) {
      print('📺 Showing Google interstitial ad');
      final completer = Completer<void>();
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          _screenCounter = 0;
          loadAd();
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('❌ Failed to show Google interstitial ad: $error');
          ad.dispose();
          _interstitialAd = null;
          // Try Facebook fallback if available
          if (_isFbAdLoaded && FbAdService.instance.shouldShowInterstitialAds) {
            print('🔄 Falling back to Facebook ad');
            FbAdService.instance.showInterstitialAd();
            _isFbAdLoaded = false;
          }
          _screenCounter = 0;
          loadAd();
          if (!completer.isCompleted) completer.complete();
        },
      );
      await _interstitialAd!.show();
      await completer.future;
      return;
    }

    // Priority 2: Use Facebook Ads if Google is not available
    if (FbAdService.instance.shouldShowInterstitialAds && _isFbAdLoaded) {
      print('📺 Showing Facebook interstitial ad (Google not available)');
      await FbAdService.instance.showInterstitialAd();
      _isFbAdLoaded = false;
      _screenCounter = 0;
      _loadFacebookAd(); // Preload next ad
      return;
    }

    // Priority 3: Load ads if not ready
    print('⚠️ No ads ready, loading...');
    await loadAd();
  }

  /// Show interstitial ad on back navigation — ALWAYS shows if ad is ready.
  /// Priority: 1. Google Ads (if loaded), 2. Facebook Ads (fallback)
  /// Waits for the ad to be fully dismissed before returning.
  Future<void> showAdOnBack() async {
    if (!AdService.instance.shouldShowInterstitialAds && !FbAdService.instance.shouldShowInterstitialAds) {
      print('⏭️ All interstitial ads disabled (back)');
      return;
    }

    // Priority 1: Try Google Ads first if available
    if (AdService.instance.shouldShowInterstitialAds && _interstitialAd != null) {
      print('📺 Showing Google interstitial ad on back navigation');
      final completer = Completer<void>();

      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          loadAd(); // Preload for next screen
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('❌ Failed to show Google interstitial ad on back: $error');
          ad.dispose();
          _interstitialAd = null;
          // Try Facebook fallback if available
          if (_isFbAdLoaded && FbAdService.instance.shouldShowInterstitialAds) {
            print('🔄 Falling back to Facebook ad');
            FbAdService.instance.showInterstitialAd();
            _isFbAdLoaded = false;
          }
          loadAd();
          if (!completer.isCompleted) completer.complete();
        },
      );

      await _interstitialAd!.show();
      await completer.future;
      return;
    }

    // Priority 2: Try Facebook Ads if Google is not available
    if (FbAdService.instance.shouldShowInterstitialAds && _isFbAdLoaded) {
      print('📺 Showing Facebook interstitial ad on back navigation (Google not available)');
      await FbAdService.instance.showInterstitialAd();
      _isFbAdLoaded = false;
      _loadFacebookAd(); // Preload for next time
      return;
    }

    // No ads ready
    print('⚠️ No interstitial ad ready (back) — navigating without ad');
    loadAd(); // Load for next time
  }

  void dispose() {
    _configSubscription?.cancel();
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isFbAdLoaded = false;
    FbAdService.instance.destroyInterstitialAd();
  }
}
