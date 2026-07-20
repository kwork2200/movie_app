import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_movie_app/tv_shows/presentation/controllers/tv_shows_bloc/tv_shows_bloc.dart';
import 'package:new_movie_app/watchlist/data/models/watchlist_item_model.dart';
import 'package:new_movie_app/watchlist/presentation/controllers/watchlist_bloc/watchlist_bloc.dart';

import 'core/resources/app_router.dart';
import 'core/resources/app_strings.dart';
import 'core/services/service_locator.dart';
import 'core/services/remote_config_service.dart';
import 'core/services/dns_detector_service.dart';
import 'core/presentation/components/network_aware_widget.dart';
import 'movies/presentation/controllers/movies_bloc/movies_bloc.dart';
import 'movies/presentation/controllers/movies_bloc/movies_event.dart';
import 'ads/app_open_ad_manager.dart';
import 'ads/app_lifecycle_reactor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load();
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
  await RemoteConfigService.instance.initialize();
  await DnsDetectorService().initialize();
  await Hive.initFlutter();
  Hive.registerAdapter(WatchlistItemModelAdapter());
  await Hive.openBox<WatchlistItemModel>('items');
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _wasInBackground = false;
  DateTime? _lastPausedTime;
  static const Duration _backgroundThreshold = Duration(seconds: 2);
  
  late AppLifecycleReactor _appLifecycleReactor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppOpenAdManager.instance;

    _appLifecycleReactor = AppLifecycleReactor(
      appOpenAdManager: AppOpenAdManager.instance,
    );
    _appLifecycleReactor.listenToAppStateChanges();
    
    print('✅ Global App Open Ad Manager initialized');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appLifecycleReactor.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    print('🔵 App lifecycle state: $state');
    if (state == AppLifecycleState.paused) {
      _wasInBackground = true;
      _lastPausedTime = DateTime.now();
      print('🔴 App going to background at ${_lastPausedTime}');
    }
    if (state == AppLifecycleState.resumed && _wasInBackground && _lastPausedTime != null) {
      final pauseDuration = DateTime.now().difference(_lastPausedTime!);
      print('🟢 App resumed after ${pauseDuration.inSeconds} seconds');
      if (pauseDuration >= _backgroundThreshold) {
        print('✅ App was in background long enough - showing ad and navigating to movies view');
        _showAdAndNavigate();
      } else {
        print('⏭️ Quick resume - skipping navigation');
      }
      _wasInBackground = false;
      _lastPausedTime = null;
    }
  }

  void _showAdAndNavigate() async {
    if (!mounted) {
      print('⚠️ Cannot show ad - widget not mounted');
      return;
    }

    // Set flag to skip interstitial ads on next screen
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('skip_interstitial_on_next_screen', true);
    print('✅ Set skip interstitial flag for next screen');
    
    AppOpenAdManager.instance.showAdIfAvailable(
      onAdDismissed: () {
        print('✅ Ad dismissed, navigating to movies view');
        if (mounted) {
          _navigateToMoviesView();
        }
      },
    );
    
    // Navigate after timeout if ad doesn't show
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _navigateToMoviesView();
      }
    });
  }

  void _navigateToMoviesView() {
    if (!mounted) {
      print('⚠️ Cannot navigate - widget not mounted');
      return;
    }
    try {
      final router = AppRouter.router;
      router.go('/movies');
      print('📍 Navigated to movies view');
    } catch (e) {
      print('❌ Navigation error: $e');
    }
  }

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
