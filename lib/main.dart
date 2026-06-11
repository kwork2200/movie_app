import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:new_movie_app/tv_shows/presentation/controllers/tv_shows_bloc/tv_shows_bloc.dart';
import 'package:new_movie_app/watchlist/data/models/watchlist_item_model.dart';
import 'package:new_movie_app/watchlist/presentation/controllers/watchlist_bloc/watchlist_bloc.dart';

import 'core/resources/app_router.dart';
import 'core/resources/app_strings.dart';
import 'core/resources/app_theme.dart';
import 'core/services/service_locator.dart';
import 'core/services/remote_config_service.dart';
import 'core/presentation/components/network_aware_widget.dart';
import 'movies/presentation/controllers/movies_bloc/movies_bloc.dart';
import 'movies/presentation/controllers/movies_bloc/movies_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load();

  // Initialize Firebase
  await Firebase.initializeApp();
  print('✅ Firebase initialized');

  // Initialize Remote Config
  await RemoteConfigService.instance.initialize();
  print('✅ Remote Config initialized');

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(WatchlistItemModelAdapter());
  await Hive.openBox<WatchlistItemModel>('items');

  // Initialize Services (includes AdService)
  await ServiceLocator.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<MoviesBloc>()..add(GetMoviesEvent()),
        ),
        BlocProvider(
          create: (context) => sl<TVShowsBloc>()..add(GetTVShowsEvent()),
        ),
        BlocProvider(
          create: (context) =>
              sl<WatchlistBloc>()..add(GetWatchListItemsEvent()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAwareWidget(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: AppStrings.appTitle,
        theme: // main.dart ya app_theme.dart
        ThemeData(
          scaffoldBackgroundColor: const Color(0xFF090C14),
          primaryColor: const Color(0xFFE8B84B),
          colorScheme: ColorScheme.dark(
            background: const Color(0xFF090C14),
            surface: const Color(0xFF0F1422),
            primary: const Color(0xFFE8B84B),
            secondary: const Color(0xFFC084FC),
          ),
          fontFamily: 'DMSans',
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
