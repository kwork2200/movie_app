import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/components/error_text.dart';
import '../../../core/presentation/components/loading_indicator.dart';
import '../../../core/resources/app_values.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/utils/enums.dart';
import '../controllers/tv_show_details_bloc/tv_show_details_bloc.dart';
import '../components/episodes_widget.dart';

class SeasonDetailsView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TVShowDetailsBloc>()
        ..add(GetSeasonDetailsEvent(id: tvShowId, seasonNumber: seasonNumber)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(seasonName),
        ),
        body: BlocBuilder<TVShowDetailsBloc, TVShowDetailsState>(
          builder: (context, state) {
            switch (state.seasonDetailsStatus) {
              case RequestStatus.loading:
                return const LoadingIndicator();
              case RequestStatus.loaded:
                return EpisodesWidget(episodes: state.seasonDetails!.episodes);
              case RequestStatus.error:
                return const ErrorText();
            }
          },
        ),
      ),
    );
  }
}
