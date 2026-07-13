import 'package:flutter/material.dart';
import 'package:new_movie_app/core/presentation/components/slider_card_image.dart';

import '../../domain/entities/media.dart';
import '../../resources/app_colors.dart';
import '../../resources/app_constants.dart';
import '../../resources/app_values.dart';
import '../../utils/functions.dart';

class SliderCard extends StatefulWidget {
  const SliderCard({
    super.key,
    required this.media,
    required this.itemIndex,
  });

  final Media media;
  final int itemIndex;

  @override
  State<SliderCard> createState() => _SliderCardState();
}

class _SliderCardState extends State<SliderCard> {
  bool _isNavigating = false;

  Future<void> _handleTap() async {
    if (_isNavigating) {
      debugPrint('⚠️ Navigation already in progress');
      return;
    }

    setState(() {
      _isNavigating = true;
    });

    try {
      await navigateToDetailsView(context, widget.media);
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: _isNavigating ? null : _handleTap,
      child: Stack(
        children: [
          SliderCardImage(imageUrl: widget.media.backdropUrl),
          Padding(
            padding: const EdgeInsets.only(
              right: AppPadding.p16,
              left: AppPadding.p16,
              bottom: AppPadding.p10,
            ),
            child: SizedBox(
              height: size.height * 0.55,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.media.title,
                    maxLines: 2,
                    style: textTheme.titleMedium,
                  ),
                  Text(
                    widget.media.releaseDate,
                    style: textTheme.bodyLarge,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppPadding.p4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(
                        AppConstants.carouselSliderItemsCount,
                            (indexDot) {
                          return Container(
                            margin: const EdgeInsets.only(right: AppMargin.m10),
                            width: indexDot == widget.itemIndex
                                ? AppSize.s30
                                : AppSize.s6,
                            height: AppSize.s6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppSize.s6),
                              color: indexDot == widget.itemIndex
                                  ? AppColors.primary
                                  : AppColors.inactiveColor,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
