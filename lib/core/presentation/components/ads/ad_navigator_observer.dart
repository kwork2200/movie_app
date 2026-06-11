import 'package:flutter/material.dart';
import 'interstitial_ad_manager.dart';

/// NavigatorObserver that shows an interstitial ad on every back navigation.
/// This covers:
///   - System back button (Android hardware / gesture)
///   - AppBar back arrow (leading back button)
///   - GoRouter context.pop() / context.go() to a parent route
class AdNavigatorObserver extends NavigatorObserver {
  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    // Only show ad when popping to an actual screen (not dialogs / bottom sheets)
    if (route.settings.name != null || previousRoute != null) {
      print('🔙 Back navigation detected – triggering interstitial check');
      InterstitialAdManager.instance.showAdOnBack();
    }
  }
}
