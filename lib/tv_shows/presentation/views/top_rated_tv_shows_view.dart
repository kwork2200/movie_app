import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/domain/entities/media.dart';
import '../../../core/presentation/components/ads/hybrid_native_ad_widget.dart';
import '../../../core/presentation/components/custom_app_bar.dart';
import '../../../core/presentation/components/error_screen.dart';
import '../../../core/presentation/components/loading_indicator.dart';
import '../../../core/presentation/components/vertical_listview.dart';
import '../../../core/presentation/components/vertical_listview_card.dart';
import '../../../core/resources/app_strings.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/utils/enums.dart';
import '../controllers/top_rated_tv_shows_bloc/top_rated_tv_shows_bloc.dart';
import '../../../core/presentation/components/ads/ad_enabled_screen.dart';
import '../../../core/presentation/components/ads/native_ad_widget.dart';


class TopRatedTVShowsView extends StatelessWidget {
  const TopRatedTVShowsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<TopRatedTVShowsBloc>()..add(GetTopRatedTVShowsEvent()),
      child: Scaffold(
        appBar: const CustomAppBar(
          title: AppStrings.topRatedShows,
        ),
        body: AdEnabledScreen(
          child: BlocBuilder<TopRatedTVShowsBloc, TopRatedTVShowsState>(
            builder: (context, state) {
              switch (state.status) {
                case GetAllRequestStatus.loading:
                  return const LoadingIndicator();
                case GetAllRequestStatus.loaded:
                  return TopRatedTVShowsWidget(tvShows: state.tvShows);
                case GetAllRequestStatus.error:
                  return ErrorScreen(
                    onTryAgainPressed: () {
                      context
                          .read<TopRatedTVShowsBloc>()
                          .add(GetTopRatedTVShowsEvent());
                    },
                  );
                case GetAllRequestStatus.fetchMoreError:
                  return TopRatedTVShowsWidget(tvShows: state.tvShows);
              }
            },
          ),
        ),
      ),
    );
  }
}

class TopRatedTVShowsWidget extends StatelessWidget {
  const TopRatedTVShowsWidget({
    super.key,
    required this.tvShows,
  });

  final List<Media> tvShows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Native Ad at top
        HybridNativeAdWidget(adKey: 'top_rated_tv_shows'),
        Expanded(
          child: VerticalListView(
            itemCount: tvShows.length + 1,
            itemBuilder: (context, index) {
              if (index < tvShows.length) {
                return VerticalListViewCard(media: tvShows[index]);
              } else {
                return const LoadingIndicator();
              }
            },
            addEvent: () {
              context
                  .read<TopRatedTVShowsBloc>()
                  .add(FetchMoreTopRatedTVShowsEvent());
            },
          ),
        ),
      ],
    );
  }
}
