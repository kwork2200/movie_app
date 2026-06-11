import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import '../../../core/domain/entities/media.dart';
import '../../../core/domain/entities/media_details.dart';
import '../../../core/presentation/components/details_card.dart';
import '../../../core/presentation/components/error_screen.dart';
import '../../../core/presentation/components/loading_indicator.dart';
import '../../../core/presentation/components/section_title.dart';
import '../../../core/presentation/components/section_listview.dart';
import '../../../core/presentation/components/section_listview_card.dart';
import '../../../core/resources/app_strings.dart';
import '../../../core/resources/app_values.dart';
import '../../../core/resources/app_colors.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/services/remote_config_service.dart';
import '../../../core/utils/enums.dart';
import '../../../core/utils/functions.dart';
import '../../../watchlist/presentation/controllers/watchlist_bloc/watchlist_bloc.dart';
import '../components/episode_card.dart';
import '../components/seasons_section.dart';
import '../components/tv_show_card_details.dart';
import '../controllers/tv_show_details_bloc/tv_show_details_bloc.dart';
import '../controllers/tv_shows_bloc/tv_shows_bloc.dart';
import '../../../core/presentation/components/ads/ad_enabled_screen.dart';
import '../../../core/presentation/components/ads/native_ad_widget.dart';
import '../../../core/presentation/components/ads/interstitial_ad_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class TVShowDetailsView extends StatelessWidget {
  const TVShowDetailsView({
    super.key,
    required this.tvShowId,
  });

  final int tvShowId;

  Future<void> _handleBack(BuildContext context) async {
    await InterstitialAdManager.instance.showAdOnBack();
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<TVShowDetailsBloc>()..add(GetTVShowDetailsEvent(tvShowId)),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          await _handleBack(context);
        },
        child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(
              top: AppPadding.p12,
              left: AppPadding.p16,
            ),
            child: InkWell(
              onTap: () => _handleBack(context),
              child: Container(
                padding: const EdgeInsets.all(AppPadding.p8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.iconContainerColor,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.secondaryText,
                  size: AppSize.s20,
                ),
              ),
            ),
          ),
          actions: [
            BlocBuilder<TVShowDetailsBloc, TVShowDetailsState>(
              builder: (context, state) {
                if (state.tvShowDetailsStatus != RequestStatus.loaded) {
                  return const SizedBox.shrink();
                }
                final mediaDetails = state.tvShowDetails!;
                
                // Check bookmark status on load
                context.read<WatchlistBloc>().add(
                  CheckBookmarkEvent(tmdbId: mediaDetails.tmdbID),
                );
                
                return Padding(
                  padding: const EdgeInsets.only(
                    top: AppPadding.p12,
                    right: AppPadding.p16,
                  ),
                  child: InkWell(
                    onTap: () {
                      mediaDetails.isBookmarked
                          ? context.read<WatchlistBloc>().add(
                              RemoveWatchListItemEvent(mediaDetails.id!),
                            )
                          : context.read<WatchlistBloc>().add(
                              AddWatchListItemEvent(
                                media: Media.fromMediaDetails(mediaDetails),
                              ),
                            );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppPadding.p8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.iconContainerColor,
                      ),
                      child: BlocConsumer<WatchlistBloc, WatchlistState>(
                        listener: (context, state) {
                          final action = state.actionStatus;
                          if (action == BookmarkStatus.added) {
                            mediaDetails.id = state.id;
                            mediaDetails.isBookmarked = true;
                          } else if (action == BookmarkStatus.removed) {
                            mediaDetails.id = null;
                            mediaDetails.isBookmarked = false;
                          } else if (action == BookmarkStatus.exists &&
                              state.id != -1) {
                            mediaDetails.id = state.id;
                            mediaDetails.isBookmarked = true;
                          }
                        },
                        builder: (context, state) {
                          return Icon(
                            Icons.bookmark_rounded,
                            color: mediaDetails.isBookmarked
                                ? AppColors.primary
                                : AppColors.secondaryText,
                            size: AppSize.s20,
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: AdEnabledScreen(
          child: BlocBuilder<TVShowDetailsBloc, TVShowDetailsState>(
            builder: (context, state) {
              switch (state.tvShowDetailsStatus) {
                case RequestStatus.loading:
                  return const LoadingIndicator();
                case RequestStatus.loaded:
                  return TVShowDetailsWidget(tvShowDetails: state.tvShowDetails!);
                case RequestStatus.error:
                  return ErrorScreen(
                    onTryAgainPressed: () {
                      context
                          .read<TVShowDetailsBloc>()
                          .add(GetTVShowDetailsEvent(tvShowId));
                    },
                  );
              }
            },
          ),
        ),
      ),  // PopScope
    ));
  }
}

class TVShowDetailsWidget extends StatelessWidget {
  const TVShowDetailsWidget({
    super.key,
    required this.tvShowDetails,
  });

  final MediaDetails tvShowDetails;

  @override
  Widget build(BuildContext context) {
    // Access the TV shows bloc from parent context
    final tvShowsBloc = context.read<TVShowsBloc>();
    final popularShows = tvShowsBloc.state.status == RequestStatus.loaded 
        ? tvShowsBloc.state.tvShows[1] 
        : <Media>[];
    final topRatedShows = tvShowsBloc.state.status == RequestStatus.loaded 
        ? tvShowsBloc.state.tvShows[2] 
        : <Media>[];
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailsCard(
            mediaDetails: tvShowDetails,
            detailsWidget: TVShowCardDetails(
              genres: tvShowDetails.genres,
              lastEpisode: tvShowDetails.lastEpisodeToAir!,
              seasons: tvShowDetails.seasons!,
            ),
          ),
          getOverviewSection(tvShowDetails.overview),
          // Native Ad after overview (TV Show Details) k
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: NativeAdWidget(adKey: 'tv_show_details',height: AppSize.s175, size: NativeAdSize.small),
          ),
          const SectionTitle(title: AppStrings.lastEpisodeOnAir),
          EpisodeCard(episode: tvShowDetails.lastEpisodeToAir!),
          const SectionTitle(title: AppStrings.seasons),
          SeasonsSection(
            tmdbID: tvShowDetails.tmdbID,
            seasons: tvShowDetails.seasons!,
          ),
          _getSimilarSection(tvShowDetails.similar, popularShows),
          _getMostViewedSection(topRatedShows),
          const SizedBox(height: AppSize.s8),
        ],
      ),
    );
  }
  
  Widget _getSimilarSection(List<Media>? similar, List<Media> popularShows) {
    // Use similar shows if available, otherwise use popular shows
    final showsList = (similar != null && similar.isNotEmpty) 
        ? similar 
        : popularShows;
    
    if (showsList.isNotEmpty) {
      final items = _buildItemsWithAds(showsList);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: AppStrings.similar),
          SizedBox(
            height: AppSize.s240,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSize.s10),
              itemBuilder: (context, index) => items[index],
            ),
          ),
        ],
      );
    }
    return const SizedBox();
  }
  
  Widget _getMostViewedSection(List<Media> topRatedShows) {
    if (topRatedShows.isNotEmpty) {
      final items = _buildItemsWithAds(topRatedShows);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Most Viewed'),
          SizedBox(
            height: AppSize.s240,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSize.s10),
              itemBuilder: (context, index) => items[index],
            ),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  /// Builds a flat list: every 2 media cards are followed by a native ad card.
  List<Widget> _buildItemsWithAds(List<Media> mediaList) {
    final List<Widget> items = [];
    for (int i = 0; i < mediaList.length; i++) {
      items.add(SectionListViewCard(media: mediaList[i]));
      if ((i + 1) % 2 == 0) {
        items.add(const _InlineTVNativeAdCard());
      }
    }
    return items;
  }
}

/// A native ad card sized to fit inside the horizontal Similar/Most Viewed rows.
/// Width: ~160px. Height: constrained by the parent SizedBox (AppSize.s240).
class _InlineTVNativeAdCard extends StatefulWidget {
  const _InlineTVNativeAdCard();

  @override
  State<_InlineTVNativeAdCard> createState() => _InlineTVNativeAdCardState();
}

class _InlineTVNativeAdCardState extends State<_InlineTVNativeAdCard> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _hasError = false;
  StreamSubscription? _sub;
  bool _shouldShow = false;

  @override
  void initState() {
    super.initState();
    _shouldShow = AdService.instance.shouldShowNativeAdTVShowDetails;
    if (_shouldShow) _load();

    _sub = RemoteConfigService.instance.configUpdates.listen((_) {
      if (!mounted) return;
      final newVal = AdService.instance.shouldShowNativeAdTVShowDetails;
      if (newVal != _shouldShow) {
        setState(() => _shouldShow = newVal);
        if (newVal && !_isAdLoaded && !_hasError) {
          _load();
        } else if (!newVal) {
          _nativeAd?.dispose();
          _nativeAd = null;
          setState(() => _isAdLoaded = false);
        }
      }
    });
  }

  void _load() {
    _nativeAd = AdService.instance.createNativeAd(
      onAdLoaded: (ad) {
        if (mounted) setState(() => _isAdLoaded = true);
      },
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
        if (mounted) setState(() => _hasError = true);
      },
    );
    _nativeAd?.load();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShow || _hasError || !_isAdLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: AppSize.s160,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppSize.s8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSize.s8),
          child: AdWidget(ad: _nativeAd!),
        ),
      ),
    );
  }
}
