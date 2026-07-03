import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../../services/fb_ad_service.dart';
import '../../../services/remote_config_service.dart';

/// Facebook Banner Ad Widget using Platform View
class FbBannerAdWidget extends StatefulWidget {
  const FbBannerAdWidget({super.key});

  @override
  State<FbBannerAdWidget> createState() => _FbBannerAdWidgetState();
}

class _FbBannerAdWidgetState extends State<FbBannerAdWidget> {
  StreamSubscription? _configSubscription;
  bool _shouldShowAds = false;

  @override
  void initState() {
    super.initState();
    _shouldShowAds = FbAdService.instance.shouldShowBannerAds;

    _configSubscription = RemoteConfigService.instance.configUpdates.listen((_) {
      _handleConfigUpdate();
    });
  }

  void _handleConfigUpdate() {
    final newValue = FbAdService.instance.shouldShowBannerAds;
    
    if (newValue != _shouldShowAds) {
      setState(() {
        _shouldShowAds = newValue;
      });
      
      if (_shouldShowAds) {
        print('📢 FB Banner ads enabled via Remote Config');
      } else {
        print('🚫 FB Banner ads disabled via Remote Config');
      }
    }
  }

  @override
  void dispose() {
    _configSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShowAds) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: 50,
      child: AndroidView(
        viewType: 'fb_banner_ad_view',
        creationParams: {
          'placementId': FbAdService.instance.bannerAdUnitId,
        },
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }
}
