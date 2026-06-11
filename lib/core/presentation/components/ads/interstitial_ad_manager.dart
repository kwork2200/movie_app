import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../services/ad_service.dart';
import '../../../services/remote_config_service.dart';

/// Manager for Interstitial Ads with real-time Remote Config updates
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
  int _screenCounter = 0;
  StreamSubscription? _configSubscription;

  void _handleConfigUpdate() {
    final shouldShow = AdService.instance.shouldShowInterstitialAds;
    if (!shouldShow) {
      print('🚫 Interstitial ads disabled via Remote Config');
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _isAdLoading = false;
    } else {
      print('📢 Interstitial ads enabled via Remote Config');
      if (_interstitialAd == null && !_isAdLoading) {
        loadAd();
      }
    }
  }

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

  /// Show interstitial ad on screen enter (with frequency control)
  Future<void> showAdIfAvailable() async {
    if (!AdService.instance.shouldShowInterstitialAds) return;

    _screenCounter++;
    if (_screenCounter % _adFrequency != 0) {
      print('⏭️ Skipping ad (counter: $_screenCounter, frequency: $_adFrequency)');
      return;
    }

    if (_interstitialAd == null) {
      print('⚠️ Interstitial ad not ready yet');
      await loadAd();
      return;
    }

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
        print('❌ Failed to show interstitial ad: $error');
        ad.dispose();
        _interstitialAd = null;
        loadAd();
        if (!completer.isCompleted) completer.complete();
      },
    );
    await _interstitialAd!.show();
    await completer.future;
  }

  /// Show interstitial ad on back navigation — ALWAYS shows if ad is ready.
  /// Waits for the ad to be fully dismissed before returning,
  /// so the caller pops the route only after the user closes the ad.
  Future<void> showAdOnBack() async {
    if (!AdService.instance.shouldShowInterstitialAds) {
      print('⏭️ Interstitial ads disabled (back)');
      return;
    }

    if (_interstitialAd == null) {
      print('⚠️ Interstitial ad not ready (back) — navigating without ad');
      // Kick off a load for next time
      loadAd();
      return;
    }

    print('📺 Showing interstitial ad on back navigation');
    final completer = Completer<void>();

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadAd(); // Preload for next screen
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('❌ Failed to show interstitial ad on back: $error');
        ad.dispose();
        _interstitialAd = null;
        loadAd();
        if (!completer.isCompleted) completer.complete();
      },
    );

    await _interstitialAd!.show();
    await completer.future; // Wait until user closes the ad, then pop
  }

  void dispose() {
    _configSubscription?.cancel();
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
