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
import '../controllers/popular_tv_shows_bloc/popular_tv_shows_bloc.dart';
import '../../../core/presentation/components/ads/ad_enabled_screen.dart';
import '../../../core/presentation/components/ads/native_ad_widget.dart';

class PopularTVShowsView extends StatelessWidget {
  const PopularTVShowsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<PopularTVShowsBloc>()..add(GetPopularTVShowsEvent()),
      child: Scaffold(
        appBar: const CustomAppBar(
          title: AppStrings.popularShows,
        ),
        body: AdEnabledScreen(
          child: BlocBuilder<PopularTVShowsBloc, PopularTVShowsState>(
            builder: (context, state) {
              switch (state.status) {
                case GetAllRequestStatus.loading:
                  return const LoadingIndicator();
                case GetAllRequestStatus.loaded:
                  return PopularTVShowsWidget(tvShows: state.tvShows);
                case GetAllRequestStatus.error:
                  return ErrorScreen(
                    onTryAgainPressed: () {
                      context
                          .read<PopularTVShowsBloc>()
                          .add(GetPopularTVShowsEvent());
                    },
                  );
                case GetAllRequestStatus.fetchMoreError:
                  return PopularTVShowsWidget(tvShows: state.tvShows);
              }
            },
          ),
        ),
      ),
    );
  }
}

class PopularTVShowsWidget extends StatelessWidget {
  const PopularTVShowsWidget({
    super.key,
    required this.tvShows,
  });

  final List<Media> tvShows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Native Ad at top
        HybridNativeAdWidget(adKey: 'popular_tv_shows'),
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
              context.read<PopularTVShowsBloc>().add(FetchMorePopularTVShowsEvent());
            },
          ),
        ),
      ],
    );
  }
}
