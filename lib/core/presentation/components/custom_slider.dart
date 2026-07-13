import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/media.dart';
import '../../resources/app_constants.dart';
import '../../resources/app_colors.dart';
import '../../resources/app_values.dart';
import 'slider_card.dart';

class CustomSlider extends StatelessWidget {
  final List<Media> items;
  final Widget Function(BuildContext context, int itemIndex, int) itemBuilder;
  
  const CustomSlider({
    required this.items,
    required this.itemBuilder,
    super.key,
  });

  static final List<String> _staticPosters = [
    'https://image.tmdb.org/t/p/w500/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg',
    'https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg',
    'https://image.tmdb.org/t/p/w500/jRXYjXNq0Cs2TcJjLkki24MLp7u.jpg',
    'https://image.tmdb.org/t/p/w500/9BBTo63ANSmhC4e6r62OJFuK2GL.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (items.isEmpty) {
      return CarouselSlider.builder(
        itemCount: AppConstants.carouselSliderItemsCount,
        options: CarouselOptions(
          viewportFraction: 1,
          height: size.height * 0.55,
          autoPlay: true,
        ),
        itemBuilder: (context, index, _) {
          return _StaticSliderCard(
            imageUrl: _staticPosters[index % _staticPosters.length],
            itemIndex: index,
          );
        },
      );
    }
    final itemCount = items.length < AppConstants.carouselSliderItemsCount
        ? items.length 
        : AppConstants.carouselSliderItemsCount;
    
    return CarouselSlider.builder(
      itemCount: itemCount,
      options: CarouselOptions(
        viewportFraction: 1,
        height: size.height * 0.55,
        autoPlay: true,
      ),
      itemBuilder: itemBuilder,
    );
  }
}

/// Static slider card for placeholder content
class _StaticSliderCard extends StatelessWidget {
  final String imageUrl;
  final int itemIndex;
  
  const _StaticSliderCard({
    required this.imageUrl,
    required this.itemIndex,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (rect) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.black,
                AppColors.black,
                AppColors.transparent,
              ],
              stops: [0.3, 0.5, 1],
            ).createShader(
              Rect.fromLTRB(0, 0, rect.width, rect.height),
            );
          },
          child: Image.network(
            imageUrl,
            height: size.height * 0.6,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: size.height * 0.6,
                width: double.infinity,
                color: AppColors.secondaryBackground,
                child:  Center(
                  child: Icon(
                    Icons.movie,
                    size: 100,
                    color: AppColors.iconColor,
                  ),
                ),
              );
            },
          ),
        ),
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
                  'Loading content...',
                  maxLines: 2,
                  style: textTheme.titleMedium,
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
                          width: indexDot == itemIndex
                              ? AppSize.s30
                              : AppSize.s6,
                          height: AppSize.s6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppSize.s6),
                            color: indexDot == itemIndex
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
    );
  }
}
