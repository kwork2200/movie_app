import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


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

class TVShowDetailsView extends StatelessWidget {
  const TVShowDetailsView({
    super.key,
    required this.tvShowId,
  });

  final int tvShowId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<TVShowDetailsBloc>()..add(GetTVShowDetailsEvent(tvShowId)),
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
              onTap: () {
                Navigator.of(context).pop();
              },
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
      ),
    );
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
          // Native Ad after overview (TV Show Details)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: NativeAdWidget(adKey: 'tv_show_details'),
          ),
          const SectionTitle(title: AppStrings.lastEpisodeOnAir),
          EpisodeCard(episode: tvShowDetails.lastEpisodeToAir!),
          const SectionTitle(title: AppStrings.seasons),
          SeasonsSection(
            tmdbID: tvShowDetails.tmdbID,
            seasons: tvShowDetails.seasons!,
          ),
          // Similar section - using popular shows if similar is empty
          _getSimilarSection(tvShowDetails.similar, popularShows),
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: AppStrings.similar),
          SectionListView(
            height: AppSize.s240,
            itemCount: showsList.length,
            itemBuilder: (context, index) =>
                SectionListViewCard(media: showsList[index]),
          ),
        ],
      );
    }
    return const SizedBox();
  }
}
