import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import '../../../core/domain/entities/media.dart';
import '../../../core/domain/entities/media_details.dart';
import '../../../core/presentation/components/ads/hybrid_native_ad_widget.dart';
import '../../../core/presentation/components/details_card.dart';
import '../../../core/presentation/components/error_screen.dart';
import '../../../core/presentation/components/loading_indicator.dart';
import '../../../core/presentation/components/section_listview.dart';
import '../../../core/presentation/components/section_listview_card.dart';
import '../../../core/presentation/components/section_title.dart';
import '../../../core/resources/app_strings.dart';
import '../../../core/resources/app_values.dart';
import '../../../core/resources/app_colors.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/services/remote_config_service.dart';
import '../../../core/utils/enums.dart';
import '../../../core/utils/functions.dart';
import '../../../watchlist/presentation/controllers/watchlist_bloc/watchlist_bloc.dart';
import '../../domain/entities/cast.dart';
import '../../domain/entities/review.dart';
import '../components/cast_card.dart';
import '../components/movie_card_details.dart';
import '../components/review_card.dart';
import '../controllers/movie_details_bloc/movie_details_bloc.dart';
import '../controllers/movies_bloc/movies_bloc.dart';
import '../../../core/presentation/components/ads/ad_enabled_screen.dart';
import '../../../core/presentation/components/ads/native_ad_widget.dart';
import '../../../core/presentation/components/ads/interstitial_ad_manager.dart';
import '../../../core/presentation/components/ads/fb_native_ad_widget.dart';
import '../../../core/services/fb_ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MovieDetailsView extends StatefulWidget {
  final int movieId;

  const MovieDetailsView({
    super.key,
    required this.movieId,
  });

  @override
  State<MovieDetailsView> createState() => _MovieDetailsViewState();
}

class _MovieDetailsViewState extends State<MovieDetailsView> {
  @override
  void initState() {
    super.initState();
    InterstitialAdManager.instance.loadAd();
  }

  Future<void> _handleBack(BuildContext context) async {
    await InterstitialAdManager.instance.showAdOnBack();
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<MovieDetailsBloc>()..add(GetMovieDetailsEvent(widget.movieId)),
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
            BlocBuilder<MovieDetailsBloc, MovieDetailsState>(
              builder: (context, state) {
                if (state.status != RequestStatus.loaded) {
                  return const SizedBox.shrink();
                }
                final mediaDetails = state.movieDetails!;
                
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
          showInterstitialOnEnter: false,
          child: BlocBuilder<MovieDetailsBloc, MovieDetailsState>(
            builder: (context, state) {
              switch (state.status) {
                case RequestStatus.loading:
                  return const LoadingIndicator();
                case RequestStatus.loaded:
                  return MovieDetailsWidget(movieDetails: state.movieDetails!);
                case RequestStatus.error:
                  return ErrorScreen(
                    onTryAgainPressed: () {
                      context
                          .read<MovieDetailsBloc>()
                          .add(GetMovieDetailsEvent(widget.movieId));
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

class MovieDetailsWidget extends StatelessWidget {
  const MovieDetailsWidget({
    required this.movieDetails,
    super.key,
  });

  final MediaDetails movieDetails;

  @override
  Widget build(BuildContext context) {
    // Access the movies bloc from parent context
    final moviesBloc = context.read<MoviesBloc>();
    final popularMovies = moviesBloc.state.status == RequestStatus.loaded 
        ? moviesBloc.state.movies[1] 
        : <Media>[];
    final topRatedMovies = moviesBloc.state.status == RequestStatus.loaded 
        ? moviesBloc.state.movies[2] 
        : <Media>[];
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailsCard(
            mediaDetails: movieDetails,
            detailsWidget: MovieCardDetails(movieDetails: movieDetails),
          ),
          getOverviewSection(movieDetails.overview),
          // Native Ad after overview (Movie Details)
          HybridNativeAdWidget(adKey: 'movie_details',height: 160),
          _getCast(movieDetails.cast),
          _getReviews(movieDetails.reviews),
          _getSimilarSection(movieDetails.similar, popularMovies),
          _getMostViewedSection(topRatedMovies),
          const SizedBox(height: AppSize.s8),
        ],
      ),
    );
  }

  Widget _getSimilarSection(List<Media>? similar, List<Media> popularMovies) {
    // Use similar movies if available, otherwise use popular movies
    final moviesList = (similar != null && similar.isNotEmpty) 
        ? similar 
        : popularMovies;
    
    if (moviesList.isNotEmpty) {
      // Build items list with a native ad placeholder after every 2 cards
      final items = _buildItemsWithAds(moviesList);
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
              itemBuilder: (context, index) => Center(child: items[index]),
            ),
          ),
        ],
      );
    }
    return const SizedBox();
  }
  
  Widget _getMostViewedSection(List<Media> topRatedMovies) {
    if (topRatedMovies.isNotEmpty) {
      final items = _buildItemsWithAds(topRatedMovies);
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
              itemBuilder: (context, index) => Center(child: items[index]),
            ),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  /// Builds a flat list of widgets: every 2 media cards are followed by a
  /// native ad card of the same height (AppSize.s240) and a comfortable width.
  List<Widget> _buildItemsWithAds(List<Media> mediaList) {
    final List<Widget> items = [];
    for (int i = 0; i < mediaList.length; i++) {
      items.add(SectionListViewCard(media: mediaList[i]));
      // Insert ad after every 2nd card (index 1, 3, 5 …)
      if ((i + 1) % 2 == 0) {
        items.add(const _InlineNativeAdCard());
      }
    }
    return items;
  }
}

Widget _getCast(List<Cast>? cast) {
  if (cast != null && cast.isNotEmpty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: AppStrings.cast),
        const SizedBox(height: 8),
        SectionListView(
          height: AppSize.s175,
          itemCount: cast.length,
          itemBuilder: (context, index) => CastCard(
            cast: cast[index],
          ),
        ),
      ],
    );
  } else {
    return const SizedBox();
  }
}

Widget _getReviews(List<Review>? reviews) {
  if (reviews != null && reviews.isNotEmpty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: AppStrings.reviews),
        SectionListView(
          height: AppSize.s175,
          itemCount: reviews.length,
          itemBuilder: (context, index) => ReviewCard(
            review: reviews[index],
          ),
        ),
      ],
    );
  } else {
    return const SizedBox();
  }
}

/// A native ad card sized to fit inside the horizontal Similar/Most Viewed rows.
/// Width: ~160px (wider than a movie card so the ad has room to render properly).
/// Height: constrained by the parent SizedBox (AppSize.s240).
class _InlineNativeAdCard extends StatefulWidget {
  const _InlineNativeAdCard();

  @override
  State<_InlineNativeAdCard> createState() => _InlineNativeAdCardState();
}

class _InlineNativeAdCardState extends State<_InlineNativeAdCard> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _hasError = false;
  StreamSubscription? _sub;
  bool _shouldShowGoogle = false;
  bool _shouldShowFacebook = false;
  bool _useGoogleAds = true;

  @override
  void initState() {
    super.initState();
    _updateAdSettings();
    if (_shouldShowGoogle || _shouldShowFacebook) _load();

    _sub = RemoteConfigService.instance.configUpdates.listen((_) {
      if (!mounted) return;
      final oldShowGoogle = _shouldShowGoogle;
      final oldShowFacebook = _shouldShowFacebook;
      final oldUseGoogle = _useGoogleAds;
      
      _updateAdSettings();
      
      if (oldShowGoogle != _shouldShowGoogle || 
          oldShowFacebook != _shouldShowFacebook ||
          oldUseGoogle != _useGoogleAds) {
        setState(() {});
        
        // Reload ad if needed
        if ((_shouldShowGoogle || _shouldShowFacebook) && !_isAdLoaded && !_hasError) {
          _load();
        } else if (!_shouldShowGoogle && !_shouldShowFacebook) {
          _nativeAd?.dispose();
          _nativeAd = null;
          setState(() => _isAdLoaded = false);
        }
      }
    });
  }

  void _updateAdSettings() {
    final useFacebookAds = RemoteConfigService.instance.useFacebookAds;
    _useGoogleAds = !useFacebookAds;
    _shouldShowGoogle = _useGoogleAds && AdService.instance.shouldShowNativeAdMovieDetails;
    _shouldShowFacebook = useFacebookAds && FbAdService.instance.shouldShowNativeAdMovieDetails;
  }

  void _load() {
    if (_shouldShowGoogle && _useGoogleAds) {
      _nativeAd = AdService.instance.createNativeAd(
        factoryId: 'smallNativeAd',
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
  }

  @override
  void dispose() {
    _sub?.cancel();
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_shouldShowGoogle && !_hasError && _isAdLoaded && _nativeAd != null) {
      return SizedBox(
        width: AppSize.s160,
        height: AppSize.s70,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppSize.s8),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: AdWidget(ad: _nativeAd!),
        ),
      );
    }

    // Show Facebook Native Ad
    if (!_shouldShowFacebook) {
      return SizedBox(
        width: AppSize.s160,
        height: AppSize.s240,
        child: HybridNativeAdWidget(
            adKey: 'movie_details', height: AppSize.s175),
      );
    }

    return const SizedBox.shrink();
  }
}
