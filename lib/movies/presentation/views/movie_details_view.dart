import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../core/domain/entities/media.dart';
import '../../../core/domain/entities/media_details.dart';
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

class MovieDetailsView extends StatelessWidget {
  final int movieId;

  const MovieDetailsView({
    super.key,
    required this.movieId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<MovieDetailsBloc>()..add(GetMovieDetailsEvent(movieId)),
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
            BlocBuilder<MovieDetailsBloc, MovieDetailsState>(
              builder: (context, state) {
                if (state.status != RequestStatus.loaded) {
                  return const SizedBox.shrink();
                }
                final mediaDetails = state.movieDetails!;
                
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
                          .add(GetMovieDetailsEvent(movieId));
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: NativeAdWidget(adKey: 'movie_details'),
          ),
          _getCast(movieDetails.cast),
          _getReviews(movieDetails.reviews),
          _getSimilarSection(movieDetails.similar, popularMovies),
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: AppStrings.similar),
          SectionListView(
            height: AppSize.s240,
            itemCount: moviesList.length,
            itemBuilder: (context, index) =>
                SectionListViewCard(media: moviesList[index]),
          ),
        ],
      );
    }
    return const SizedBox();
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
