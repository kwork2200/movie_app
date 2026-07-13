import 'dart:developer';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';

class InterstitialAdManager {
  InterstitialAd? _interstitialAd1;
  InterstitialAd? _interstitialAd2;
  InterstitialAd? _interstitialAd3;

  bool interstitialReady1 = false;
  bool interstitialReady2 = false;
  bool interstitialReady3 = false;

  void createInterstitialAd1() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId1,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          log('Interstitial Ad 1 loaded.');
          _interstitialAd1 = ad;
          interstitialReady1 = true;
          _interstitialAd1!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          log('Interstitial Ad 1 failed to load: $error');
          interstitialReady1 = false;
          _interstitialAd1 = null;
          createInterstitialAd1();
        },
      ),
    );
  }

  void createInterstitialAd2() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId2,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          log('Interstitial Ad 2 loaded.');
          _interstitialAd2 = ad;
          interstitialReady2 = true;
          _interstitialAd2!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          log('Interstitial Ad 2 failed to load: $error');
          interstitialReady2 = false;
          _interstitialAd2 = null;
          createInterstitialAd2();
        },
      ),
    );
  }

  void createInterstitialAd3() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId3,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          log('Interstitial Ad 3 loaded.');
          _interstitialAd3 = ad;
          interstitialReady3 = true;
          _interstitialAd3!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          log('Interstitial Ad 3 failed to load: $error');
          interstitialReady3 = false;
          _interstitialAd3 = null;
          createInterstitialAd3();
        },
      ),
    );
  }

  void showInterstitialAd1() {
    if (_interstitialAd1 == null) {
      log('Warning: attempt to show interstitial ad 1 before loaded.');
      return;
    }
    _interstitialAd1!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          log('Interstitial ad 1 onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        log('Interstitial ad 1 onAdDismissedFullScreenContent.');
        ad.dispose();
        createInterstitialAd1();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        log('Interstitial ad 1 onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createInterstitialAd1();
      },
    );
    _interstitialAd1!.show();
    _interstitialAd1 = null;
  }

  void showInterstitialAd2() {
    if (_interstitialAd2 == null) {
      log('Warning: attempt to show interstitial ad 2 before loaded.');
      return;
    }
    _interstitialAd2!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          log('Interstitial ad 2 onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        log('Interstitial ad 2 onAdDismissedFullScreenContent.');
        ad.dispose();
        createInterstitialAd2();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        log('Interstitial ad 2 onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createInterstitialAd2();
      },
    );
    _interstitialAd2!.show();
    _interstitialAd2 = null;
  }

  void showInterstitialAd3() {
    if (_interstitialAd3 == null) {
      log('Warning: attempt to show interstitial ad 3 before loaded.');
      return;
    }
    _interstitialAd3!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          log('Interstitial ad 3 onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        log('Interstitial ad 3 onAdDismissedFullScreenContent.');
        ad.dispose();
        createInterstitialAd3();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        log('Interstitial ad 3 onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createInterstitialAd3();
      },
    );
    _interstitialAd3!.show();
    _interstitialAd3 = null;
  }

  void dispose() {
    _interstitialAd1?.dispose();
    _interstitialAd2?.dispose();
    _interstitialAd3?.dispose();
  }
}
