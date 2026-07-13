import 'package:flutter/material.dart';
import 'package:new_movie_app/tv_shows/presentation/components/season_card.dart';

import '../../../core/resources/app_values.dart';
import '../../domain/entities/season.dart';

class SeasonsSection extends StatelessWidget {
  const SeasonsSection({
    super.key,
    required this.seasons,
    required this.tmdbID,
  });

  final List<Season> seasons;
  final int tmdbID;

  @override
  Widget build(BuildContext context) {
    if (seasons.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'No seasons available',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return SizedBox(
      height: AppSize.s280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
        physics: const BouncingScrollPhysics(),
        itemCount: seasons.length,
        itemBuilder: (context, index) => SeasonCard(
          season: seasons[index],
          tvShowId: tmdbID,
        ),
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSize.s12),
      ),
    );
  }
}
