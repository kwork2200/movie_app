import 'package:flutter/material.dart';
import 'dart:async';
import '../../../services/ad_service.dart';
import '../../../services/fb_ad_service.dart';
import '../../../services/remote_config_service.dart';
import 'native_ad_widget.dart';
import 'fb_native_ad_widget.dart';
import 'third_party_image_ad.dart';

class HybridNativeAdWidget extends StatefulWidget {
  final double height;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final String? adKey;

  const HybridNativeAdWidget({
    super.key,
    this.height = 150,
    this.margin,
    this.padding,
    this.adKey,
  });

  @override
  State<HybridNativeAdWidget> createState() => _HybridNativeAdWidgetState();
}

class _HybridNativeAdWidgetState extends State<HybridNativeAdWidget> {
  StreamSubscription? _configSubscription;
  bool _useFacebookAds = false;
  bool _showGoogleAds = false;
  bool _showFacebookAds = false;

  @override
  void initState() {
    super.initState();
    _updateAdPreferences();
    _configSubscription = RemoteConfigService.instance.configUpdates.listen((_) {
      _updateAdPreferences();
    });
  }

  void _updateAdPreferences() {
    setState(() {
      _useFacebookAds = RemoteConfigService.instance.useFacebookAds;
      _showGoogleAds = _getGoogleAdVisibility();
      _showFacebookAds = _getFacebookAdVisibility();
      
      print('🔀 HybridNativeAd [${widget.adKey}]: Google=$_showGoogleAds, FB=$_showFacebookAds');
    });
  }

  bool _getGoogleAdVisibility() {
    switch (widget.adKey) {
      case 'language_selection':
        return AdService.instance.shouldShowNativeAdLanguageSelection;
      case 'login_signup':
        return AdService.instance.shouldShowNativeAdLoginSignup;
      case 'profile_setup':
        return AdService.instance.shouldShowNativeAdProfileSetup;
      case 'movies_home_1':
        return AdService.instance.shouldShowNativeAdMoviesHome1;
      case 'movies_home_2':
        return AdService.instance.shouldShowNativeAdMoviesHome2;
      case 'movies_home_3':
        return AdService.instance.shouldShowNativeAdMoviesHome3;
      case 'tv_shows_home':
        return AdService.instance.shouldShowNativeAdTVShowsHome;
      case 'search':
        return AdService.instance.shouldShowNativeAdSearch;
      case 'watchlist':
        return AdService.instance.shouldShowNativeAdWatchlist;
      case 'popular_movies':
        return AdService.instance.shouldShowNativeAdPopularMovies;
      case 'top_rated_movies':
        return AdService.instance.shouldShowNativeAdTopRatedMovies;
      case 'movie_details':
        return AdService.instance.shouldShowNativeAdMovieDetails;
      case 'popular_tv_shows':
        return AdService.instance.shouldShowNativeAdPopularTVShows;
      case 'top_rated_tv_shows':
        return AdService.instance.shouldShowNativeAdTopRatedTVShows;
      case 'tv_show_details':
        return AdService.instance.shouldShowNativeAdTVShowDetails;
      default:
        return AdService.instance.shouldShowNativeAds;
    }
  }

  bool _getFacebookAdVisibility() {
    switch (widget.adKey) {
      case 'language_selection':
        return FbAdService.instance.shouldShowNativeAdLanguageSelection;
      case 'login_signup':
        return FbAdService.instance.shouldShowNativeAdLoginSignup;
      case 'profile_setup':
        return FbAdService.instance.shouldShowNativeAdProfileSetup;
      case 'movies_home_1':
        return FbAdService.instance.shouldShowNativeAdMoviesHome1;
      case 'movies_home_2':
        return FbAdService.instance.shouldShowNativeAdMoviesHome2;
      case 'movies_home_3':
        return FbAdService.instance.shouldShowNativeAdMoviesHome3;
      case 'tv_shows_home':
        return FbAdService.instance.shouldShowNativeAdTVShowsHome;
      case 'search':
        return FbAdService.instance.shouldShowNativeAdSearch;
      case 'watchlist':
        return FbAdService.instance.shouldShowNativeAdWatchlist;
      case 'popular_movies':
        return FbAdService.instance.shouldShowNativeAdPopularMovies;
      case 'top_rated_movies':
        return FbAdService.instance.shouldShowNativeAdTopRatedMovies;
      case 'movie_details':
        return FbAdService.instance.shouldShowNativeAdMovieDetails;
      case 'popular_tv_shows':
        return FbAdService.instance.shouldShowNativeAdPopularTVShows;
      case 'top_rated_tv_shows':
        return FbAdService.instance.shouldShowNativeAdTopRatedTVShows;
      case 'tv_show_details':
        return FbAdService.instance.shouldShowNativeAdTVShowDetails;
      default:
        return FbAdService.instance.shouldShowNativeAds;
    }
  }

  @override
  void dispose() {
    _configSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Priority 1: Try Google Ads first if enabled
    if (_showGoogleAds) {
      return NativeAdWidget(
        height: 300,
        adKey: widget.adKey,
          size: NativeAdSize.small
      );
    }

    if (_showFacebookAds) {
      return FbNativeAdWidget(
        height: widget.height,
        margin: widget.margin,
        padding: widget.padding,
        adKey: widget.adKey,
      );
    }

    final showThirdPartyAd = RemoteConfigService.instance.showThirdPartyNativeAds;
    if (showThirdPartyAd) {
      return ThirdPartyImageAd(
        height: widget.height,
        margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
        padding: widget.padding,
        isNativeSize: true,
      );
    }
    return const SizedBox.shrink();
  }
}
