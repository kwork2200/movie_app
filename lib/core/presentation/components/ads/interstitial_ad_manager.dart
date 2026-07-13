import 'dart:async';
import 'package:flutter/material.dart';
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

  /// Get current screen counter for external frequency checks
  int get screenCounter => _screenCounter;

  /// Reset screen counter (used after showing third-party ads)
  void resetCounter() {
    _screenCounter = 0;
  }

  /// Check if frequency allows showing ad (without incrementing counter)
  bool shouldShowAdByFrequency() {
    return (_screenCounter + 1) % _adFrequency == 0;
  }

  /// Increment counter manually (for third-party ads)
  void incrementCounter() {
    _screenCounter++;
  }

  /// Check if any ad (Google or Facebook) is ready to show
  bool get isAdReady {
    final googleReady = AdService.instance.shouldShowInterstitialAds && _interstitialAd != null;
    final facebookReady = FbAdService.instance.shouldShowInterstitialAds && _isFbAdLoaded;
    return googleReady || facebookReady;
  }

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
  /// Priority: 1. Google Ads (if enabled), 2. Facebook Ads (fallback), 3. Third-party (if both disabled)
  /// Falls back to third-party ads if both networks are disabled
  /// 
  /// Returns true if ad should be shown (including third-party ads)
  /// Caller should handle third-party ad display if both Google/Facebook are disabled
  Future<bool> showAdIfAvailable() async {
    try {
      debugPrint('🎯 showAdIfAvailable called');
      
      // Check if ANY ad network is enabled
      final bool googleEnabled = AdService.instance.shouldShowInterstitialAds;
      final bool facebookEnabled = FbAdService.instance.shouldShowInterstitialAds;
      
      // Increment counter FIRST for all ad types (Google, Facebook, Third-party)
      _screenCounter++;
      
      if (!googleEnabled && !facebookEnabled) {
        print('🚫 Both Google and Facebook ads disabled, checking third-party ad frequency');
        if (_screenCounter % _adFrequency != 0) {
          print('⏭️ Skipping third-party ad (counter: $_screenCounter, frequency: $_adFrequency)');
          return false; // Don't show ad
        }
        print('✅ Third-party ad frequency check passed');
        _screenCounter = 0;
        // Return true to indicate caller should show third-party ad
        return true;
      }

      if (_screenCounter % _adFrequency != 0) {
        print('⏭️ Skipping ad (counter: $_screenCounter, frequency: $_adFrequency)');
        return false;
      }

      debugPrint('📺 Ad frequency check passed, attempting to show ad');

      // Priority 1: If Google Ads are DISABLED, only show Facebook Ads
      if (!googleEnabled) {
        if (facebookEnabled && _isFbAdLoaded) {
          print('📺 Showing Facebook interstitial ad (Google ads disabled)');
          try {
            await FbAdService.instance.showInterstitialAd();
            _isFbAdLoaded = false;
            _screenCounter = 0;
            _loadFacebookAd(); // Preload next ad
            debugPrint('✅ Facebook ad completed successfully');
            return true;
          } catch (e) {
            debugPrint('❌ Facebook ad error: $e');
            _isFbAdLoaded = false;
            _screenCounter = 0;
            return false;
          }
        } else {
          print('⚠️ Facebook ad not ready, loading...');
          _screenCounter = 0;
          await loadAd();
          return false;
        }
      }

      // Priority 2: Google Ads are ENABLED - try Google first
      if (googleEnabled && _interstitialAd != null) {
        print('📺 Showing Google interstitial ad (Priority 1)');
        final completer = Completer<void>();
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            debugPrint('✅ Google ad dismissed');
            ad.dispose();
            _interstitialAd = null;
            _screenCounter = 0;
            loadAd(); // Preload next ad
            if (!completer.isCompleted) completer.complete(true);
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            print('❌ Failed to show Google interstitial ad: $error');
            ad.dispose();
            _interstitialAd = null;
            _screenCounter = 0;
            // Try Facebook fallback if available
            if (facebookEnabled && _isFbAdLoaded) {
              print('🔄 Google failed, falling back to Facebook ad');
              FbAdService.instance.showInterstitialAd().then((_) {
                _isFbAdLoaded = false;
                _loadFacebookAd();
              }).catchError((e) {
                print('❌ Facebook fallback also failed: $e');
                _isFbAdLoaded = false;
              });
            }
            loadAd();
            if (!completer.isCompleted) completer.complete(true);
          },
        );
        await _interstitialAd!.show();
        await completer.future;
        debugPrint('✅ Google ad flow completed');
        return true;
      }

      // Priority 3: Google not ready/failed, try Facebook as fallback (only if Facebook is enabled)
      if (facebookEnabled && _isFbAdLoaded) {
        print('📺 Showing Facebook interstitial ad (Google not ready, using fallback)');
        try {
          await FbAdService.instance.showInterstitialAd();
          _isFbAdLoaded = false;
          _screenCounter = 0;
          loadAd(); // Load both Google and Facebook for next time
          debugPrint('✅ Facebook ad completed successfully');
          return true;
        } catch (e) {
          debugPrint('❌ Facebook ad error: $e');
          _isFbAdLoaded = false;
          _screenCounter = 0;
          loadAd();
          return false;
        }
      }

      // Priority 4: No ads ready, load for next time
      print('⚠️ No ads ready (Google enabled: $googleEnabled, FB enabled: $facebookEnabled), loading...');
      _screenCounter = 0;
      await loadAd();
      return false;
      
    } catch (e) {
      debugPrint('❌ Critical error in showAdIfAvailable: $e');
      // Reset counter so next time it tries again
      _screenCounter = 0;
      return false;
    }
  }

  /// Show interstitial ad on back navigation — ALWAYS shows if ad is ready.
  /// Priority: 1. Google Ads (if enabled), 2. Facebook Ads (fallback), 3. Third-party (if both disabled)
  /// Waits for the ad to be fully dismissed before returning.
  /// 
  /// Returns true if third-party ad should be shown by caller (when both Google/Facebook disabled)
  Future<bool> showAdOnBack() async {
    final bool googleEnabled = AdService.instance.shouldShowInterstitialAds;
    final bool facebookEnabled = FbAdService.instance.shouldShowInterstitialAds;
    
    if (!googleEnabled && !facebookEnabled) {
      print('🚫 Both Google and Facebook ads disabled, caller should show third-party ad on back');
      return true;
    }

    if (!googleEnabled) {
      if (facebookEnabled && _isFbAdLoaded) {
        print('📺 Showing Facebook interstitial ad on back (Google ads disabled)');
        await FbAdService.instance.showInterstitialAd();
        _isFbAdLoaded = false;
        _loadFacebookAd(); // Preload for next time
        return false;
      } else {
        print('⚠️ Facebook ad not ready (back), loading...');
        loadAd();
        return false;
      }
    }

    // Priority 2: Google Ads are ENABLED - try Google first
    if (googleEnabled && _interstitialAd != null) {
      print('📺 Showing Google interstitial ad on back navigation (Priority 1)');
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
          if (facebookEnabled && _isFbAdLoaded) {
            print('🔄 Google failed, falling back to Facebook ad');
            FbAdService.instance.showInterstitialAd().then((_) {
              _isFbAdLoaded = false;
              _loadFacebookAd();
            }).catchError((e) {
              print('❌ Facebook fallback also failed: $e');
              _isFbAdLoaded = false;
            });
          }
          loadAd();
          if (!completer.isCompleted) completer.complete();
        },
      );

      await _interstitialAd!.show();
      await completer.future;
      return false;
    }

    // Priority 3: Google not ready/failed, try Facebook as fallback (only if Facebook is enabled)
    if (facebookEnabled && _isFbAdLoaded) {
      print('📺 Showing Facebook interstitial ad on back (Google not ready, using fallback)');
      await FbAdService.instance.showInterstitialAd();
      _isFbAdLoaded = false;
      loadAd(); // Load both for next time
      return false;
    }

    // No ads ready
    print('⚠️ No interstitial ad ready (back) — navigating without ad');
    loadAd(); // Load for next time
    return false;
  }

  /// Show interstitial ad ALWAYS without frequency control (for specific screens)
  /// Priority: 1. Google Ads (if enabled), 2. Facebook Ads (fallback), 3. Third-party (if both disabled)
  /// This is useful for screens where you want to always show an ad regardless of frequency
  /// 
  /// Returns true if third-party ad should be shown by caller (when both Google/Facebook disabled)
  Future<bool> showAdAlways() async {
    try {
      print('🎯 Attempting to show ad ALWAYS (no frequency control)');
      
      final bool googleEnabled = AdService.instance.shouldShowInterstitialAds;
      final bool facebookEnabled = FbAdService.instance.shouldShowInterstitialAds;
      
      if (!googleEnabled && !facebookEnabled) {
        print('🚫 Both Google and Facebook ads disabled, caller should show third-party ad');
        // Return true to indicate caller should show third-party ad
        return true;
      }

      // Priority 1: If Google Ads are DISABLED, only show Facebook Ads
      if (!googleEnabled) {
        print('🔄 Google Ads disabled, checking Facebook Ads...');
        if (facebookEnabled && _isFbAdLoaded) {
          print('📺 Showing Facebook interstitial ad ALWAYS (Google ads disabled)');
          try {
            await FbAdService.instance.showInterstitialAd();
            _isFbAdLoaded = false;
            _loadFacebookAd(); // Preload next ad
            return false;
          } catch (e) {
            print('❌ Error showing Facebook ad: $e');
            _isFbAdLoaded = false;
            return false;
          }
        } else {
          print('⚠️ Facebook ad not ready, loading...');
          await loadAd();
          return false;
        }
      }

      // Priority 2: Google Ads are ENABLED - try Google first
      if (googleEnabled && _interstitialAd != null) {
        print('📺 Showing Google interstitial ad ALWAYS (Priority 1)');
        try {
          final completer = Completer<void>();
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              loadAd();
              if (!completer.isCompleted) completer.complete();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('❌ Failed to show Google interstitial ad: $error');
              ad.dispose();
              _interstitialAd = null;
              // Try Facebook fallback if available
              if (facebookEnabled && _isFbAdLoaded) {
                print('🔄 Google failed, falling back to Facebook ad');
                FbAdService.instance.showInterstitialAd().then((_) {
                  _isFbAdLoaded = false;
                  _loadFacebookAd();
                }).catchError((e) {
                  print('❌ Facebook fallback also failed: $e');
                  _isFbAdLoaded = false;
                });
              }
              loadAd();
              if (!completer.isCompleted) completer.complete();
            },
          );
          await _interstitialAd!.show();
          await completer.future;
          return false;
        } catch (e) {
          print('❌ Error showing Google ad: $e');
          _interstitialAd?.dispose();
          _interstitialAd = null;
          
          // Try Facebook fallback
          if (facebookEnabled && _isFbAdLoaded) {
            print('🔄 Falling back to Facebook ad after Google error');
            try {
              await FbAdService.instance.showInterstitialAd();
              _isFbAdLoaded = false;
              _loadFacebookAd();
              return false;
            } catch (fbError) {
              print('❌ Facebook fallback also failed: $fbError');
              _isFbAdLoaded = false;
            }
          }
        }
      }

      // Priority 3: Google not ready/failed, try Facebook as fallback (only if Facebook is enabled)
      if (facebookEnabled && _isFbAdLoaded) {
        print('📺 Showing Facebook interstitial ad ALWAYS (Google not ready, using fallback)');
        try {
          await FbAdService.instance.showInterstitialAd();
          _isFbAdLoaded = false;
          loadAd(); // Load both for next time
          return false;
        } catch (e) {
          print('❌ Error showing Facebook ad: $e');
          _isFbAdLoaded = false;
          loadAd();
        }
        return false;
      }

      // Priority 4: No ads ready, load for next time
      print('⚠️ No ads ready (Google enabled: $googleEnabled, FB enabled: $facebookEnabled), loading...');
      await loadAd();
      return false;
      
    } catch (e) {
      print('❌ Critical error in showAdAlways: $e');
      // Don't let ad errors crash the app
      // Just load for next time
      loadAd();
      return false;
    }
  }

  void dispose() {
    _configSubscription?.cancel();
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isFbAdLoaded = false;
    FbAdService.instance.destroyInterstitialAd();
  }
}
