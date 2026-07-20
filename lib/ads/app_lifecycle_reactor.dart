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
    
    // Load ad when app goes to background to be ready for next resume
    if (state == AppLifecycleState.paused) {
      log('App paused - preloading App Open Ad');
      if (!appOpenAdManager.isAdAvailable) {
        appOpenAdManager.loadAd();
      }
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
