import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../onboarding/presentation/screens/splash_screen.dart';
import '../../onboarding/presentation/screens/language_selection_screen.dart';
import '../../movies/presentation/views/movie_details_view.dart';
import '../presentation/screens/info_screen.dart';
import '../../movies/presentation/views/movies_view.dart';
import '../../movies/presentation/views/popular_movies_view.dart';
import '../../movies/presentation/views/top_rated_movies_view.dart';
import '../../search/presentation/views/search_view.dart';
import '../../tv_shows/presentation/views/popular_tv_shows_view.dart';
import '../../tv_shows/presentation/views/top_rated_tv_shows_view.dart';
import '../../tv_shows/presentation/views/tv_show_details_view.dart';
import '../../tv_shows/presentation/views/tv_shows_view.dart';
import '../../watchlist/presentation/views/watchlist_view.dart';
import '../presentation/pages/main_page.dart';
import '../presentation/screens/remote_config_debug_screen.dart';
import 'app_routes.dart';


const String splashPath = '/';
const String infoPath = '/info';
const String languageSelectionPath = '/language-selection';
const String moviesPath = '/movies';
const String movieDetailsPath = 'movieDetails/:movieId';
const String popularMoviesPath = 'popularMovies';
const String topRatedMoviesPath = 'topRatedMovies';
const String tvShowsPath = '/tvShows';
const String tvShowDetailsPath = 'tvShowDetails/:tvShowId';
const String popularTVShowsPath = 'popularTVShows';
const String topRatedTVShowsPath = 'topRatedTVShows';
const String searchPath = '/search';
const String watchlistPath = '/watchlist';
const String remoteConfigDebugPath = '/remote-config-debug';

class AppRouter {
  AppRouter._();

  static GoRouter router = GoRouter(
    initialLocation: splashPath,
    routes: [
      // Splash Screen
      GoRoute(
        path: splashPath,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SplashScreen()),
      ),
      // Info Screen (standalone, not in shell route)
      GoRoute(
        path: infoPath,
        pageBuilder: (context, state) =>
            const CupertinoPage(child: InfoScreen()),
      ),
      // Language Selection Screen
      GoRoute(
        path: languageSelectionPath,
        pageBuilder: (context, state) =>
            const CupertinoPage(child: LanguageSelectionScreen()),
      ),
      // Remote Config Debug Screen
      GoRoute(
        path: remoteConfigDebugPath,
        pageBuilder: (context, state) =>
            const CupertinoPage(child: RemoteConfigDebugScreen()),
      ),
      // Main App Shell
      ShellRoute(
        builder: (context, state, child) => MainPage(child: child),
        routes: [
          GoRoute(
            name: AppRoutes.moviesRoute,
            path: moviesPath,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: MoviesView()),
            routes: [
              GoRoute(
                name: AppRoutes.movieDetailsRoute,
                path: movieDetailsPath,
                pageBuilder: (context, state) => CupertinoPage(
                  child: MovieDetailsView(
                    movieId: int.parse(state.pathParameters['movieId']!),
                  ),
                ),
              ),
              GoRoute(
                name: AppRoutes.popularMoviesRoute,
                path: popularMoviesPath,
                pageBuilder: (context, state) =>
                    const CupertinoPage(child: PopularMoviesView()),
              ),
              GoRoute(
                name: AppRoutes.topRatedMoviesRoute,
                path: topRatedMoviesPath,
                pageBuilder: (context, state) =>
                    const CupertinoPage(child: TopRatedMoviesView()),
              ),
            ],
          ),
          GoRoute(
            name: AppRoutes.tvShowsRoute,
            path: tvShowsPath,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TVShowsView()),
            routes: [
              GoRoute(
                name: AppRoutes.tvShowDetailsRoute,
                path: tvShowDetailsPath,
                pageBuilder: (context, state) => CupertinoPage(
                  child: TVShowDetailsView(
                    tvShowId: int.parse(state.pathParameters['tvShowId']!),
                  ),
                ),
              ),
              GoRoute(
                name: AppRoutes.popularTvShowsRoute,
                path: popularTVShowsPath,
                pageBuilder: (context, state) =>
                    const CupertinoPage(child: PopularTVShowsView()),
              ),
              GoRoute(
                name: AppRoutes.topRatedTvShowsRoute,
                path: topRatedTVShowsPath,
                pageBuilder: (context, state) =>
                    const CupertinoPage(child: TopRatedTVShowsView()),
              ),
            ],
          ),
          GoRoute(
            name: AppRoutes.searchRoute,
            path: searchPath,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SearchView()),
          ),
          GoRoute(
            name: AppRoutes.watchlistRoute,
            path: watchlistPath,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: WatchlistView()),
          ),
        ],
      ),
    ],
  );
}
