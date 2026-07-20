import 'package:flutter/material.dart';

import '../../../core/presentation/components/image_with_shimmer.dart';
import '../../../core/resources/app_strings.dart';
import '../../../core/resources/app_values.dart';
import '../../domain/entities/episode.dart';
import '../views/episode_detail_view.dart';

class EpisodeCard extends StatelessWidget {
  const EpisodeCard({
    super.key,
    required this.episode,
  });

  final Episode episode;

  @override
  Widget build(BuildContext context) {
    if (episode == null) {
      return const SizedBox(
        height: 110,
        child: Center(
          child: Text(
            'No episode available',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }
    final textTheme = Theme.of(context).textTheme;
    final imageUrl = episode.stillPath.isEmpty 
        ? 'assets/images/episode_default.png' 
        : episode.stillPath;
    
    return Container(
      height: AppSize.s110,
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EpisodeDetailView(episode: episode),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: AppPadding.p8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSize.s8),
                child: ImageWithShimmer(
                  imageUrl: imageUrl,
                  width: AppSize.s150,
                  height: double.infinity,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppStrings.episode} ${episode.number}',
                  style: textTheme.bodyMedium,
                ),
                Text(
                  episode.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge,
                ),
                Text(
                  episode.airDate,
                  style: textTheme.bodyLarge,
                ),
                Text(
                  episode.runtime,
                  style: textTheme.bodyLarge,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
