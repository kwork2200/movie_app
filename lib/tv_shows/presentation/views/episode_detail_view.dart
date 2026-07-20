import 'package:flutter/material.dart';
import '../../../core/presentation/components/ads/ad_enabled_screen.dart';
import '../../../core/presentation/components/ads/hybrid_native_ad_widget.dart';
import '../../../core/presentation/components/image_with_shimmer.dart';
import '../../../core/presentation/components/ads/interstitial_ad_manager.dart';
import '../../../core/presentation/components/ads/third_party_image_ad.dart';
import '../../../core/presentation/components/ads/qureka_interstitial.dart';
import '../../../core/resources/app_strings.dart';
import '../../../core/resources/app_values.dart';
import '../../../core/utils/functions.dart';
import '../../domain/entities/episode.dart';

class EpisodeDetailView extends StatefulWidget {
  const EpisodeDetailView({
    super.key,
    required this.episode,
  });

  final Episode episode;

  @override
  State<EpisodeDetailView> createState() => _EpisodeDetailViewState();
}

class _EpisodeDetailViewState extends State<EpisodeDetailView> {
  @override
  void initState() {
    super.initState();
    InterstitialAdManager.instance.loadAd();
    // Show interstitial ad when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInterstitialAd();
    });
  }

  Future<void> _showInterstitialAd() async {
    await InterstitialAdManager.instance.showAdIfAvailable();
  }

  Future<void> _handleBack(BuildContext context) async {
    await showManagedInterstitialAd(context, alwaysShow: true);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final imageUrl = widget.episode.stillPath.isEmpty 
        ? 'assets/images/episode_default.png' 
        : widget.episode.stillPath;
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBack(context);
      },
      child: Scaffold(
        body: AdEnabledScreen(
          child: CustomScrollView(
            slivers: [
              // App Bar with back button
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      ImageWithShimmer(
                        imageUrl: imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Episode details content
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppPadding.p16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppStrings.episode} ${widget.episode.number}',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSize.s8),
                        Text(
                          widget.episode.name,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSize.s16),
                        _buildDetailRow(
                          context,
                          'Season',
                          '${widget.episode.season}',
                        ),
                        _buildDetailRow(
                          context,
                          'Runtime',
                          widget.episode.runtime,
                        ),
                        _buildDetailRow(
                          context,
                          'Air Date',
                          widget.episode.airDate,
                        ),
                      ],
                    ),
                  ),
                  const HybridNativeAdWidget(
                    adKey: 'tv_show_details',
                    height: 175,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppPadding.p16),
                    child: Column(children: [
                      // Additional content placeholder
                      Text(
                        'Episode Overview',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSize.s8),
                      Text(
                        'No overview available for this episode.',
                        style: textTheme.bodyMedium,
                      ),

                    ],),
                  ),
                ],
              ),
            ),
          ],
                ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSize.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
