import 'dart:developer';
import 'package:flutter/material.dart';
import 'app_open_ad_manager.dart';

class AppLifecycleReactor with WidgetsBindingObserver {
  final AppOpenAdManager appOpenAdManager;

  AppLifecycleReactor({required this.appOpenAdManager});

  void listenToAppStateChanges() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log('App Lifecycle State: $state');
    
    // DO NOT show app open ad automatically on app resume
    // App open ads will be shown only on info screen
    
    // Load ad when app goes to background to be ready for info screen
    if (state == AppLifecycleState.paused) {
      log('App paused - preloading App Open Ad for info screen');
      if (!appOpenAdManager.isAdAvailable) {
        appOpenAdManager.loadAd();
      }
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
