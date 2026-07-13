import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../onboarding/data/services/onboarding_storage_service.dart';
import 'ad_service.dart';
import 'fb_ad_service.dart';
import 'network_service.dart';
import '../presentation/components/ads/interstitial_ad_manager.dart';
import '../../movies/data/datasource/movies_remote_data_source.dart';
import '../../movies/data/datasource/person_remote_data_source.dart';
import '../../movies/data/repository/movies_repository_impl.dart';
import '../../movies/data/repository/person_repository_impl.dart';
import '../../movies/domain/repository/movies_repository.dart';
import '../../movies/domain/repository/person_repository.dart';
import '../../movies/domain/usecases/get_all_popular_movies_usecase.dart';
import '../../movies/domain/usecases/get_all_top_rated_movies_usecase.dart';
import '../../movies/domain/usecases/get_movie_details_usecase.dart';
import '../../movies/domain/usecases/get_movies_usecase.dart';
import '../../movies/domain/usecases/get_person_details_usecase.dart';
import '../../movies/presentation/controllers/movie_details_bloc/movie_details_bloc.dart';
import '../../movies/presentation/controllers/movies_bloc/movies_bloc.dart';
import '../../movies/presentation/controllers/person_details_bloc/person_details_bloc.dart';
import '../../movies/presentation/controllers/popular_movies_bloc/popular_movies_bloc.dart';
import '../../movies/presentation/controllers/top_rated_movies_bloc/top_rated_movies_bloc.dart';
import '../../search/data/datasource/search_remote_data_source.dart';
import '../../search/data/repository/search_repository_impl.dart';
import '../../search/domain/repository/search_repository.dart';
import '../../search/domain/usecases/search_usecase.dart';
import '../../search/presentation/controllers/search_bloc/search_bloc.dart';
import '../../tv_shows/data/datasource/tv_shows_remote_data_source.dart';
import '../../tv_shows/data/repository/tv_shows_repository_impl.dart';
import '../../tv_shows/domain/repository/tv_shows_repository.dart';
import '../../tv_shows/domain/usecases/get_all_popular_tv_shows_usecase.dart';
import '../../tv_shows/domain/usecases/get_all_top_rated_tv_shows_usecase.dart';
import '../../tv_shows/domain/usecases/get_season_details_usecase.dart';
import '../../tv_shows/domain/usecases/get_tv_show_details_usecase.dart';
import '../../tv_shows/domain/usecases/get_tv_shows_usecase.dart';
import '../../tv_shows/presentation/controllers/popular_tv_shows_bloc/popular_tv_shows_bloc.dart';
import '../../tv_shows/presentation/controllers/top_rated_tv_shows_bloc/top_rated_tv_shows_bloc.dart';
import '../../tv_shows/presentation/controllers/tv_show_details_bloc/tv_show_details_bloc.dart';
import '../../tv_shows/presentation/controllers/tv_shows_bloc/tv_shows_bloc.dart';
import '../../watchlist/data/datasource/watchlist_local_data_source.dart';
import '../../watchlist/data/models/watchlist_item_model.dart';
import '../../watchlist/data/repository/watchlist_repository_impl.dart';
import '../../watchlist/domain/repository/watchlist_repository.dart';
import '../../watchlist/domain/usecases/add_watchlist_item_usecase.dart';
import '../../watchlist/domain/usecases/get_watchlist_items_usecase.dart';
import '../../watchlist/domain/usecases/is_bookmarked_usecase.dart';
import '../../watchlist/domain/usecases/remove_watchlist_item_usecase.dart';
import '../../watchlist/presentation/controllers/watchlist_bloc/watchlist_bloc.dart';
import '../network/api_constants.dart';

final sl = GetIt.instance;

class ServiceLocator {
  ServiceLocator._();

  static Future<void> init() async {
    // Initialize Network Service first
    await NetworkService().initialize();
    
    // Initialize Ad Services
    await AdService.instance.initialize();
    await FbAdService.instance.initialize();
    
    // Preload first interstitial ad
    InterstitialAdManager.instance.loadAd();
    
    // Register SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
    
    // Register Onboarding Storage Service
    sl.registerLazySingleton<OnboardingStorageService>(
      () => OnboardingStorageService(sl()),
    );

    sl.registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          receiveTimeout: const Duration(seconds: 60),
          connectTimeout: const Duration(seconds: 60),
        ),
      ),
    );

    sl.registerLazySingleton<Box<WatchlistItemModel>>(
      () => Hive.box<WatchlistItemModel>('items'),
    );

    // Data source
    sl.registerLazySingleton<MoviesRemoteDataSource>(
      () => MoviesRemoteDataSourceImpl(sl()),
    );
    sl.registerLazySingleton<PersonRemoteDataSource>(
      () => PersonRemoteDataSourceImpl(sl()),
    );
    sl.registerLazySingleton<TVShowsRemoteDataSource>(
      () => TVShowsRemoteDataSourceImpl(sl()),
    );
    sl.registerLazySingleton<SearchRemoteDataSource>(
      () => SearchRemoteDataSourceImpl(sl()),
    );
    sl.registerLazySingleton<WatchlistLocalDataSource>(
      () => WatchlistLocalDataSourceImpl(sl()),
    );

    // Repository
    sl.registerLazySingleton<MoviesRespository>(
      () => MoviesRepositoryImpl(sl()),
    );
    sl.registerLazySingleton<PersonRepository>(
      () => PersonRepositoryImpl(sl()),
    );
    sl.registerLazySingleton<TVShowsRepository>(
      () => TVShowsRepositoryImpl(sl()),
    );
    sl.registerLazySingleton<SearchRepository>(
      () => SearchRepositoryImpl(sl()),
    );
    sl.registerLazySingleton<WatchlistRepository>(
      () => WatchListRepositoryImpl(sl()),
    );

    // Use Cases
    sl.registerLazySingleton(() => GetMoviesDetailsUseCase(sl()));
    sl.registerLazySingleton(() => GetMoviesUseCase(sl()));
    sl.registerLazySingleton(() =>
        GetAllPopularMoviesUseCase(sl()));
    sl.registerLazySingleton(() => GetAllTopRatedMoviesUseCase(sl()));
    sl.registerLazySingleton(() => GetPersonDetailsUseCase(sl()));
    sl.registerLazySingleton(() =>
        GetTVShowsUseCase(sl()));
    sl.registerLazySingleton(() =>
        GetTVShowDetailsUseCase(sl()));
    sl.registerLazySingleton(() =>
        GetSeasonDetailsUseCase(sl()));
    sl.registerLazySingleton(() =>
        GetAllPopularTVShowsUseCase(sl()));
    sl.registerLazySingleton(() => GetAllTopRatedTVShowsUseCase(sl()));
    sl.registerLazySingleton(() => SearchUseCase(sl()));
    sl.registerLazySingleton(() => GetWatchlistItemsUseCase(sl()));
    sl.registerLazySingleton(() => AddWatchlistItemUseCase(sl()));
    sl.registerLazySingleton(() => RemoveWatchlistItemUseCase(sl()));
    sl.registerLazySingleton(() => IsBookmarkedUseCase(sl()));

    // Bloc
    sl.registerFactory(() => MoviesBloc(sl()));
    sl.registerFactory(() => MovieDetailsBloc(sl()));
    sl.registerFactory(() => PersonDetailsBloc(sl()));
    sl.registerFactory(() =>

        PopularMoviesBloc(sl()));
    sl.registerFactory(() => TopRatedMoviesBloc(sl()));
    sl.registerFactory(() => TVShowsBloc(sl()));
    sl.registerFactory(() => TVShowDetailsBloc(sl(), sl()));
    sl.registerFactory(() => PopularTVShowsBloc(sl()));
    sl.registerFactory(() => TopRatedTVShowsBloc(sl()));
    sl.registerFactory(() => SearchBloc(sl()));
    sl.registerFactory(() => WatchlistBloc(sl(), sl(), sl(), sl()));
  }
}
