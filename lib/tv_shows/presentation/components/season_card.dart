import 'package:flutter/material.dart';

import '../../../core/presentation/components/image_with_shimmer.dart';
import '../../../core/resources/app_values.dart';
import '../../domain/entities/season.dart';
import '../views/season_details_view.dart';

class SeasonCard extends StatelessWidget {
  const SeasonCard({super.key, required this.season, required this.tvShowId});

  final Season season;
  final int tvShowId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SeasonDetailsView(
              tvShowId: tvShowId,
              seasonNumber: season.seasonNumber,
              seasonName: season.name,
            ),
          ),
        );
      },
      child: SizedBox(
        width: AppSize.s160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSize.s8),
              child: ImageWithShimmer(
                imageUrl: season.posterUrl,
                width: AppSize.s160,
                height: AppSize.s200,
              ),
            ),
            const SizedBox(height: AppSize.s8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    season.name,
                    style: textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSize.s4),
                  Text(
                    '${season.episodeCount} episodes',
                    style: textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (season.airDate.isNotEmpty) ...[
                    const SizedBox(height: AppSize.s2),
                    Text(
                      season.airDate,
                      style: textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
