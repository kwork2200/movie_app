import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../resources/app_router.dart';
import '../../resources/app_routes.dart';
import '../../resources/app_strings.dart';
import '../../resources/app_values.dart';
import '../components/ads/hybrid_native_ad_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.child});

  final Widget child;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    final bool isOnRoot = location.startsWith(moviesPath);
    return Scaffold(
      body: PopScope(
        canPop: !isOnRoot,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          final bool? shouldExit = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              backgroundColor: Colors.black,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSize.s12),
              ),
              title: const Text(
                'Exit App',
                style: TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Are you sure you want to exit?',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSize.s12),
                    const HybridNativeAdWidget(
                      height: AppSize.s175,
                      adKey: 'movies_home_1',
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Exit', style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
          );

          if (shouldExit == true) {
            SystemNavigator.pop();
          }
        },
        child: widget.child,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.black,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.black,
          selectedItemColor: const Color(0xFFE8B84B),
          unselectedItemColor: const Color(0xFF8892AA),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 11,
          ),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          enableFeedback: false,
          items: const [
            BottomNavigationBarItem(
              label: AppStrings.movies,
              icon: Icon(Icons.movie_creation_outlined, size: AppSize.s20),
              activeIcon: Icon(Icons.movie_creation_rounded, size: AppSize.s20),
            ),
            BottomNavigationBarItem(
              label: AppStrings.shows,
              icon: Icon(Icons.tv_outlined, size: AppSize.s20),
              activeIcon: Icon(Icons.tv_rounded, size: AppSize.s20),
            ),
            BottomNavigationBarItem(
              label: AppStrings.search,
              icon: Icon(Icons.search_outlined, size: AppSize.s20),
              activeIcon: Icon(Icons.search_rounded, size: AppSize.s20),
            ),
            BottomNavigationBarItem(
              label: AppStrings.watchlist,
              icon: Icon(Icons.bookmark_outline_rounded, size: AppSize.s20),
              activeIcon: Icon(Icons.bookmark_rounded, size: AppSize.s20),
            ),
          ],
          currentIndex: _getSelectedIndex(context),
          onTap: (index) => _onItemTapped(index, context),
        ),
      ),
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith(moviesPath)) {
      return 0;
    }
    if (location.startsWith(tvShowsPath)) {
      return 1;
    }
    if (location.startsWith(searchPath)) {
      return 2;
    }
    if (location.startsWith(watchlistPath)) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.goNamed(AppRoutes.moviesRoute);
        break;
      case 1:
        context.goNamed(AppRoutes.tvShowsRoute);
        break;
      case 2:
        context.goNamed(AppRoutes.searchRoute);
        break;
      case 3:
        context.goNamed(AppRoutes.watchlistRoute);
        break;
    }
  }
}
