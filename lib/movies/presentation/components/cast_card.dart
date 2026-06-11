import 'package:flutter/material.dart';
import '../../../core/presentation/components/image_with_shimmer.dart';
import '../../../core/resources/app_values.dart';
import '../../domain/entities/cast.dart';

class CastCard extends StatelessWidget {
  final Cast cast;

  const CastCard({
    required this.cast,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 85,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: ImageWithShimmer(
              imageUrl: cast.profileUrl,
              width: 80,
              height: 80,
              // fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            cast.name,
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}