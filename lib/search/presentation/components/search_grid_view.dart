import 'package:flutter/material.dart';

import '../../../core/presentation/components/ads/hybrid_native_ad_widget.dart';
import '../../../core/presentation/components/ads/native_ad_widget.dart';
import '../../../core/resources/app_values.dart';
import '../../domain/entities/search_result_item.dart';
import 'grid_view_card.dart';
class SearchGridView extends StatelessWidget {
  const SearchGridView({
    super.key,
    required this.results,
  });

  final List<SearchResultItem> results;

  @override
  Widget build(BuildContext context) {
    const int itemsPerSection = 6; // 2 rows × 3 columns

    final sections = <List<SearchResultItem>>[];

    for (int i = 0; i < results.length; i += itemsPerSection) {
      sections.add(
        results.sublist(
          i,
          (i + itemsPerSection > results.length)
              ? results.length
              : i + itemsPerSection,
        ),
      );
    }

    return Expanded(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          for (int sectionIndex = 0;
          sectionIndex < sections.length;
          sectionIndex++) ...[
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return GridViewCard(
                      item: sections[sectionIndex][index],
                    );
                  },
                  childCount: sections[sectionIndex].length,
                ),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.55,
                ),
              ),
            ),

            // Full width ad after every 6 items section
            if (sectionIndex != sections.length - 1)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom : 5 ),
                  child: HybridNativeAdWidget(
                    adKey: 'search',
                    height: AppSize.s150,
                      // size: NativeAdSize.small
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}