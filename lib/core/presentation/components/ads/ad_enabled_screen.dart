import 'package:flutter/material.dart';
import '../../../utils/functions.dart';
import 'hybrid_banner_ad_widget.dart';

/// Wrapper widget that adds banner ads to any screen
class AdEnabledScreen extends StatefulWidget {
  final Widget child;
  final bool showBanner;
  final bool showInterstitialOnEnter;

  const AdEnabledScreen({
    super.key,
    required this.child,
    this.showBanner = true,
    this.showInterstitialOnEnter = true,
  });

  @override
  State<AdEnabledScreen> createState() => _AdEnabledScreenState();
}

class _AdEnabledScreenState extends State<AdEnabledScreen> {
  @override
  void initState() {
    super.initState();

    if (widget.showInterstitialOnEnter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showManagedInterstitialAd(context, alwaysShow: false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: widget.child),
        if (widget.showBanner)
          SafeArea(
            top: false,
            child: const HybridBannerAdWidget (),
          ),
      ],
    );
  }
}
