import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../domain/entities/media.dart';
import '../network/api_constants.dart';
import '../presentation/components/overview_section.dart';
import '../presentation/components/section_listview.dart';
import '../presentation/components/section_listview_card.dart';
import '../presentation/components/section_title.dart';
import '../presentation/components/ads/interstitial_ad_manager.dart';
import '../presentation/components/ads/qureka_interstitial.dart';
import '../resources/app_colors.dart';
import '../resources/app_routes.dart';
import '../resources/app_strings.dart';
import '../resources/app_values.dart';
import '../services/ad_service.dart';
import '../services/fb_ad_service.dart';
import '../services/remote_config_service.dart';

Future<bool> showManagedInterstitialAd(BuildContext context, {bool alwaysShow = false}) async {
  try {
    final bool googleEnabled = AdService.instance.shouldShowInterstitialAds;
    final bool facebookEnabled = FbAdService.instance.shouldShowInterstitialAds;
    final bool thirdPartyEnabled = RemoteConfigService.instance.showThirdPartyInterstitialAds && ENABLE_THIRD_PARTY_ADS;

    if (!googleEnabled && !facebookEnabled && thirdPartyEnabled) {
      debugPrint('🎯 Both Google & Facebook ads disabled - trying third-party ad');
      
      if (alwaysShow) {
        if (context.mounted) {
          await showQurekaInterstitialAd(context);
          return true;
        }
      } else {
        final shouldShow = await InterstitialAdManager.instance.showAdIfAvailable();
        if (shouldShow && context.mounted) {
          await showQurekaInterstitialAd(context);
          return true;
        }
      }
      return false;
    }
    if (alwaysShow) {
      await InterstitialAdManager.instance.showAdAlways();
      return true;
    } else {
      final shouldShow = await InterstitialAdManager.instance.showAdIfAvailable();
      return shouldShow;
    }
  } catch (e) {
    debugPrint('❌ Error in showManagedInterstitialAd: $e');
    return false;
  }
}

String getDate(String? date) {
  if (date == null || date.isEmpty) {
    return '';
  }

  final vals = date.split('-');
  String year = vals[0];
  int monthNb = int.parse(vals[1]);
  String day = vals[2];

  String month = '';

  switch (monthNb) {
    case 1:
      month = 'Jan';
      break;
    case 2:
      month = 'Feb';
      break;
    case 3:
      month = 'Mar';
      break;
    case 4:
      month = 'Apr';
      break;
    case 5:
      month = 'May';
      break;
    case 6:
      month = 'Jun';
      break;
    case 7:
      month = 'Jul';
      break;
    case 8:
      month = 'Aug';
      break;
    case 9:
      month = 'Sep';
      break;
    case 10:
      month = 'Oct';
      break;
    case 11:
      month = 'Nov';
      break;
    case 12:
      month = 'Dec';
      break;
    default:
      break;
  }

  return '$month $day, $year';
}

String getPosterUrl(String? path) {
  if (path != null && path.isNotEmpty) {
    if (path.startsWith('http')) {
      return path;
    }
    return ApiConstants.basePosterUrl + path;
  } else {
    return ApiConstants.moviePlaceHolder;
  }
}

String getBackdropUrl(String? path) {
  if (path != null && path.isNotEmpty) {
    if (path.startsWith('http')) {
      return path;
    }
    return ApiConstants.baseBackdropUrl + path;
  } else {
    return ApiConstants.moviePlaceHolder;
  }
}

String getStillUrl(String? path) {
  if (path != null && path.isNotEmpty) {
    if (path.startsWith('http')) {
      return path;
    }
    return ApiConstants.baseStillUrl + path;
  } else {
    return ApiConstants.stillPlaceHolder;
  }
}

String getLength(int? runtime) {
  if (runtime == null || runtime == 0) {
    return '';
  }
  if (runtime < 60) {
    return '${runtime}m';
  }
  if (runtime % 60 == 0) {
    return '${runtime ~/ 60}h';
  }
  return '${runtime ~/ 60}h ${runtime % 60}m';
}

String getVotesCount(int voteCount) {
  if (voteCount < 1000) {
    return '($voteCount)';
  }
  return '(${voteCount ~/ 1000}k)';
}

String getProfileImageUrl(Map<String, dynamic> json) {
  if (json['profile_path'] != null) {
    String path = json['profile_path'];
    // Check if it's already a full URL
    if (path.startsWith('http')) {
      return path;
    }
    return ApiConstants.baseProfileUrl + path;
  } else {
    return ApiConstants.castPlaceHolder;
  }
}

String getElapsedTime(String date) {
  DateTime reviewDate = DateTime.parse(date);
  DateTime today = DateTime.now();

  Duration diff = today.difference(reviewDate);
  if (diff.inDays >= 365) {
    int years = diff.inDays ~/ 365;
    return '${years}y';
  } else if (diff.inDays >= 30) {
    int months = diff.inDays ~/ 30;
    return '${months}mo';
  } else if (diff.inDays >= 7) {
    int weeks = diff.inDays ~/ 7;
    return '${weeks}w';
  } else if (diff.inDays >= 1) {
    return '${diff.inDays}d';
  } else if (diff.inHours >= 1) {
    int hours = diff.inHours ~/ 24;
    return '${hours}h';
  } else if (diff.inMinutes >= 1) {
    int minutes = diff.inDays ~/ 60;
    return '${minutes}min';
  } else {
    return 'Now';
  }
}

String getGenres(List<dynamic> genres) {
  if (genres.isNotEmpty) {
    return genres.first['name'];
  } else {
    return '';
  }
}

String getAvatarUrl(String? path) {
  if (path != null) {
    if (path.startsWith('/https://www.gravatar.com/avatar')) {
      return path.substring(1);
    } else if (path.startsWith('http')) {
      // Already a full URL
      return path;
    } else {
      return ApiConstants.baseAvatarUrl + path;
    }
  } else {
    return ApiConstants.avatarPlaceHolder;
  }
}

String getTrailerUrl(Map<String, dynamic> json) {
  List videos = json['videos']['results'];
  if (videos.isNotEmpty) {
    List trailers = videos.where((e) => e['type'] == 'Trailer').toList();
    if (trailers.isNotEmpty) {
      return ApiConstants.baseVideoUrl + trailers.last['key'];
    } else {
      return '';
    }
  } else {
    return '';
  }
}
Future<void> navigateToDetailsView(BuildContext context, Media media) async {
  debugPrint('📍 Starting navigation for: ${media.title}');

  final isMovie = media.isMovie;
  final mediaId = media.tmdbID.toString();

  debugPrint('📍 Media type: ${isMovie ? "Movie" : "TV Show"}, ID: $mediaId');
  final GoRouter router = GoRouter.of(context);

  bool adShown = false;
  try {
    debugPrint('📺 Showing interstitial ad...');

    final bool googleEnabled = AdService.instance.shouldShowInterstitialAds;
    final bool facebookEnabled = FbAdService.instance.shouldShowInterstitialAds;
    final bool thirdPartyEnabled = RemoteConfigService.instance.showThirdPartyInterstitialAds && ENABLE_THIRD_PARTY_ADS;

    // Check if both Google and Facebook ads are disabled
    if (!googleEnabled && !facebookEnabled && thirdPartyEnabled) {
      debugPrint('🎯 Both Google & Facebook ads disabled - showing third-party interstitial ad with frequency control');

      // Increment counter for frequency control
      InterstitialAdManager.instance.incrementCounter();
      
      if (!InterstitialAdManager.instance.shouldShowAdByFrequency()) {
        debugPrint('⏭️ Skipping third-party ad (counter: ${InterstitialAdManager.instance.screenCounter}, frequency: ${AdService.instance.interstitialAdFrequency})');
      } else {
        // Reset counter and show ad
        InterstitialAdManager.instance.resetCounter();
        if (context.mounted) {
          debugPrint('✅ Showing third-party interstitial ad now');
          await showQurekaInterstitialAd(context);
          adShown = true;
          debugPrint('✅ Third-party ad dismissed, proceeding with navigation');
        }
      }
    } else if (googleEnabled || facebookEnabled) {
      // Show Google/Facebook ads
      debugPrint('📺 Attempting to show Google/Facebook interstitial ad');
      await InterstitialAdManager.instance.showAdIfAvailable();
      adShown = true;
      debugPrint('✅ Ad flow completed');
    } else {
      debugPrint('⚠️ All ads disabled - no ad to show');
    }
  } catch (e) {
    debugPrint('⚠️ Ad error: $e');
  }

  if (adShown) {
    await Future.delayed(const Duration(milliseconds: 500));
  }
  debugPrint('🚀 Preparing navigation...');
  try {
    debugPrint('🎯 Executing navigation');
    if (isMovie) {
      router.goNamed(
        AppRoutes.movieDetailsRoute,
        pathParameters: {'movieId': mediaId},
      );
      debugPrint('✅ Movie details navigation initiated');
    } else {
      router.goNamed(
        AppRoutes.tvShowDetailsRoute,
        pathParameters: {'tvShowId': mediaId},
      );
      debugPrint('✅ TV show details navigation initiated');
    }
  } catch (e) {
    debugPrint('❌ Navigation error: $e');
  }
}

Widget getSimilarSection(List<Media>? similar) {
  if (similar != null && similar.isNotEmpty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: AppStrings.similar),
        SectionListView(
          height: AppSize.s240,
          itemCount: similar.length,
          itemBuilder: (context, index) =>
              SectionListViewCard(media: similar[index]),
        ),
      ],
    );
  } else {
    return const SizedBox();
  }
}

Widget getOverviewSection(String overview) {
  if (overview.isNotEmpty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: AppStrings.story),
        OverviewSection(overview: overview),
      ],
    );
  } else {
    return const SizedBox();
  }
}

void showCustomBottomSheet(BuildContext context, Widget child) {
  final size = MediaQuery.of(context).size.height;
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.secondaryBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSize.s20)),
    ),
    builder: (context) {
      return SizedBox(height: size * 0.5, child: child);
    },
  );
}

void showSnackBar(BuildContext context, String content) {
  final snackBar = SnackBar(content: Text(content));
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
