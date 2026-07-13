import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_helper.dart';

class AppOpenAdManager {
  static AppOpenAdManager? _instance;
  static AppOpenAdManager get instance => _instance ??= AppOpenAdManager._();

  AppOpenAdManager._() {
    loadAd();
  }

  final Duration maxCacheDuration = Duration(hours: 4);
  DateTime? _appOpenLoadTime;
  AppOpenAd? _appOpenAd;
  bool appopenredy = false;
  Function()? onAdDismissedCallback;

  void loadAd() {
    if (_appOpenAd != null) return;
    AppOpenAd.load(
      adUnitId: AdHelper.appOpenUnitId,
      request: AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          print('✅ AppOpenAd loaded successfully');
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('❌ AppOpenAd failed to load: $error');
          _appOpenAd = null;
        },
      ),
    );
  }

  bool get isAdAvailable => _appOpenAd != null;

  void showAdIfAvailable({Function()? onAdDismissed}) {
    onAdDismissedCallback = onAdDismissed;

    if (!isAdAvailable) {
      onAdDismissedCallback?.call();
      loadAd();
      return;
    }
    if (appopenredy) {
      return;
    }
    if (_appOpenLoadTime != null &&
        DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      _appOpenAd!.dispose();
      _appOpenAd = null;
      onAdDismissedCallback?.call();
      loadAd();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        appopenredy = true;
        print('📺 AppOpenAd showing');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('❌ AppOpenAd failed to show: $error');
        appopenredy = false;
        ad.dispose();
        _appOpenAd = null;
        onAdDismissedCallback?.call();
        loadAd();
      },
      onAdDismissedFullScreenContent: (ad) {
        print('✅ AppOpenAd dismissed');
        appopenredy = false;
        ad.dispose();
        _appOpenAd = null;
        onAdDismissedCallback?.call();
        loadAd();
      },
    );
    _appOpenAd!.show();
  }

  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }
}