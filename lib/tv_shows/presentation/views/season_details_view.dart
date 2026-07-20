import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/components/ads/ad_enabled_screen.dart';
import '../../../core/presentation/components/ads/hybrid_native_ad_widget.dart';
import '../../../core/presentation/components/ads/interstitial_ad_manager.dart';
import '../../../core/presentation/components/error_text.dart';
import '../../../core/presentation/components/loading_indicator.dart';
import '../../../core/resources/app_values.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/utils/enums.dart';
import '../../../core/utils/functions.dart';
import '../controllers/tv_show_details_bloc/tv_show_details_bloc.dart';
import '../components/episodes_widget.dart';

class SeasonDetailsView extends StatefulWidget {
  const SeasonDetailsView({
    super.key,
    required this.tvShowId,
    required this.seasonNumber,
    required this.seasonName,
  });

  final int tvShowId;
  final int seasonNumber;
  final String seasonName;

  @override
  State<SeasonDetailsView> createState() => _SeasonDetailsViewState();
}

class _SeasonDetailsViewState extends State<SeasonDetailsView> {
  @override
  void initState() {
    super.initState();
    InterstitialAdManager.instance.loadAd();
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
    return BlocProvider(
      create: (context) => sl<TVShowDetailsBloc>()
        ..add(GetSeasonDetailsEvent(id: widget.tvShowId, seasonNumber: widget.seasonNumber)),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          await _handleBack(context);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text("Episodes"),
          ),
          body: BlocBuilder<TVShowDetailsBloc, TVShowDetailsState>(
            builder: (context, state) {
              switch (state.seasonDetailsStatus) {
                case RequestStatus.loading:
                  return const LoadingIndicator();
                case RequestStatus.loaded:
                  return AdEnabledScreen(
                    child: Column(
                      children: [
                        const HybridNativeAdWidget(
                          adKey: 'tv_show_details',
                          height: 175,
                        ),
                        Expanded(
                          child: EpisodesWidget(episodes: state.seasonDetails!.episodes),
                        ),
                      ],
                    ),
                  );
                case RequestStatus.error:
                  return const ErrorText();
              }
            },
          ),
        ),
      ),
    );
  }
}
