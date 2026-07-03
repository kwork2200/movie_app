import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/domain/entities/media.dart';
import '../../../core/presentation/components/ads/hybrid_native_ad_widget.dart';
import '../../../core/presentation/components/custom_app_bar.dart';
import '../../../core/presentation/components/error_screen.dart';
import '../../../core/presentation/components/loading_indicator.dart';
import '../../../core/presentation/components/vertical_listview_card.dart';
import '../../../core/resources/app_strings.dart';
import '../../../core/resources/app_values.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/utils/enums.dart';
import '../components/empty_watchlist_text.dart';
import '../controllers/watchlist_bloc/watchlist_bloc.dart';
import '../../../core/presentation/components/ads/ad_enabled_screen.dart';
import '../../../core/presentation/components/ads/native_ad_widget.dart';

class WatchlistView extends StatelessWidget {
  const WatchlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<WatchlistBloc>()..add(GetWatchListItemsEvent()),
      child: Scaffold(
        appBar: const CustomAppBar(title: AppStrings.watchlist),
        body: AdEnabledScreen(
          child: BlocBuilder<WatchlistBloc, WatchlistState>(
            builder: (context, state) {
              if (state.status == WatchlistRequestStatus.loading) {
                return const LoadingIndicator();
              } else if (state.status == WatchlistRequestStatus.loaded) {
                return WatchlistWidget(items: state.items);
              } else if (state.status == WatchlistRequestStatus.empty) {
                return const EmptyWatchlistText();
              } else {
                return ErrorScreen(
                  onTryAgainPressed: () {
                    context.read<WatchlistBloc>().add(GetWatchListItemsEvent());
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class WatchlistWidget extends StatelessWidget {
  const WatchlistWidget({super.key, required this.items});

  final List<Media> items;
  static const int _adIndex = 1;

  @override
  Widget build(BuildContext context) {
    final int itemCount = items.length + 1; // Always add one ad

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.separated(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index == _adIndex) {
            return const HybridNativeAdWidget(
              adKey: 'watchlist',
              // size: NativeAdSize.small,
              height: AppSize.s175,
            );
          }

          final mediaIndex = index > _adIndex ? index - 1 : index;

          return VerticalListViewCard(
            media: items[mediaIndex],
          );
        },
        separatorBuilder: (_, __) =>
        const SizedBox(height: AppSize.s10),
      ),
    );
  }
}
