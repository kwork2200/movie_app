import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../services/ad_service.dart';
import '../../../services/remote_config_service.dart';

/// Manager for Interstitial Ads with real-time Remote Config updates
class InterstitialAdManager {
  static InterstitialAdManager? _instance;
  static InterstitialAdManager get instance => _instance ??= InterstitialAdManager._();

  InterstitialAdManager._() {
    // Listen to Remote Config changes
    _configSubscription = RemoteConfigService.instance.configUpdates.listen((_) {
      _handleConfigUpdate();
    });
  }

  InterstitialAd? _interstitialAd;
  bool _isAdLoading = false;
  int _screenCounter = 0;
  int _backCounter = 0;
  StreamSubscription? _configSubscription;
  
  void _handleConfigUpdate() {
    final shouldShow = AdService.instance.shouldShowInterstitialAds;
    
    // If ads were disabled via Remote Config
    if (!shouldShow) {
      print('🚫 Interstitial ads disabled via Remote Config');
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _isAdLoading = false;
      _backCounter = 0;
    }
    // If ads were enabled via Remote Config
    else {
      print('📢 Interstitial ads enabled via Remote Config');
      if (_interstitialAd == null && !_isAdLoading) {
        loadAd();
      }
    }
  }

  /// Get ad frequency from Remote Config
  int get _adFrequency => AdService.instance.interstitialAdFrequency;

  /// Load the interstitial ad
  Future<void> loadAd() async {
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
            print('✅ Interstitial ad loaded');

            // Set up callbacks
            _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _interstitialAd = null;
                loadAd(); // Preload next ad
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                print('❌ Failed to show interstitial ad: $error');
                ad.dispose();
                _interstitialAd = null;
                loadAd(); // Try to load again
              },
            );
          },
          onAdFailedToLoad: (error) {
            print('❌ Interstitial ad failed to load: $error');
            _isAdLoading = false;
            _interstitialAd = null;
          },
        ),
      );
    } catch (e) {
      print('❌ Error loading interstitial ad: $e');
      _isAdLoading = false;
    }
  }

  /// Show the interstitial ad if loaded and frequency met
  Future<void> showAdIfAvailable() async {
    // Check Remote Config flag first
    if (!AdService.instance.shouldShowInterstitialAds) {
      print('⏭️ Interstitial ads disabled in Remote Config');
      return;
    }

    _screenCounter++;
    
    if (_screenCounter % _adFrequency != 0) {
      print('⏭️ Skipping ad (counter: $_screenCounter, frequency: $_adFrequency)');
      return;
    }

    if (_interstitialAd != null) {
      await _interstitialAd!.show();
      _screenCounter = 0;
    } else {
      print('⚠️ Interstitial ad not ready yet');
      await loadAd();
    }
  }

  /// Show interstitial ad on back navigation (system back / screen back arrow)
  Future<void> showAdOnBack() async {
    if (!AdService.instance.shouldShowInterstitialAds) {
      print('⏭️ Interstitial ads disabled in Remote Config (back)');
      return;
    }

    _backCounter++;

    if (_backCounter % _adFrequency != 0) {
      print('⏭️ Skipping back-nav ad (counter: $_backCounter, frequency: $_adFrequency)');
      return;
    }

    if (_interstitialAd != null) {
      print('📺 Showing interstitial ad on back navigation');
      await _interstitialAd!.show();
      _backCounter = 0;
    } else {
      print('⚠️ Interstitial ad not ready yet (back)');
      await loadAd();
    }
  }

  /// Dispose the ad and clean up resources
  void dispose() {
    _configSubscription?.cancel();
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
