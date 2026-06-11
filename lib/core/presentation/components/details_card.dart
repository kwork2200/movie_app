import 'package:flutter/material.dart';
import 'package:new_movie_app/core/presentation/components/slider_card_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/media_details.dart';
import '../../resources/app_colors.dart';
import '../../resources/app_values.dart';

class DetailsCard extends StatelessWidget {
  const DetailsCard({
    required this.mediaDetails,
    required this.detailsWidget,
    super.key,
  });

  final MediaDetails mediaDetails;
  final Widget detailsWidget;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        SliderCardImage(imageUrl: mediaDetails.backdropUrl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
          child: SizedBox(
            height: size.height * 0.6,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppPadding.p8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mediaDetails.title,
                          maxLines: 2,
                          style: textTheme.titleMedium,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: AppPadding.p4,
                            bottom: AppPadding.p6,
                          ),
                          child: detailsWidget,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rate_rounded,
                              color: AppColors.ratingIconColor,
                              size: AppSize.s18,
                            ),
                            Text(
                              '${mediaDetails.voteAverage} ',
                              style: textTheme.bodyMedium,
                            ),
                            Text(
                              mediaDetails.voteCount,
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (mediaDetails.trailerUrl.isNotEmpty) ...[
                    InkWell(
                      onTap: () async {
                        final url = Uri.parse(mediaDetails.trailerUrl);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                      child: Container(
                        height: AppSize.s40,
                        width: AppSize.s40,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
