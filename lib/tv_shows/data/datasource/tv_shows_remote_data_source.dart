import 'package:dio/dio.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/error_message_model.dart';
import '../models/season_details_model.dart';
import '../models/tv_show_details_model.dart';
import '../models/tv_show_model.dart';

abstract class TVShowsRemoteDataSource {
  Future<List<TVShowModel>> getOnAirTVShows();
  Future<List<TVShowModel>> getPopularTVShows();
  Future<List<TVShowModel>> getTopRatedTVShows();
  Future<List<List<TVShowModel>>> getTVShows();
  Future<TVShowDetailsModel> getTVShowDetails(int id);
  Future<SeasonDetailsModel> getSeasonDetails(int id, int seasonNumber);
  Future<List<TVShowModel>> getAllPopularTVShows(int page);
  Future<List<TVShowModel>> getAllTopRatedTVShows(int page);
}

class TVShowsRemoteDataSourceImpl extends TVShowsRemoteDataSource {
  final Dio dio;

  TVShowsRemoteDataSourceImpl(this.dio);

  // Helper method to fetch show by TVmaze ID
  Future<TVShowModel?> _getShowById(int showId) async {
    try {
      final response = await dio.get(ApiConstants.showDetailsPath(showId));
      
      if (response.statusCode == 200) {
        return TVShowModel.fromJson(response.data);
      } else {
        // Return null instead of throwing to allow other requests to continue
        return null;
      }
    } catch (e) {
      // Return null instead of throwing to allow other requests to continue
      return null;
    }
  }

  @override
  Future<List<TVShowModel>> getOnAirTVShows() async {
    try {
      // Use show index with page 1 to get different shows than movies
      final response = await dio.get(
        ApiConstants.showsIndexPath,
        queryParameters: {'page': 1},
      );
      
      if (response.statusCode == 200) {
        final List shows = response.data as List;
        // Take first 10 shows
        return shows
            .take(10)
            .map((show) => TVShowModel.fromJson(show))
            .toList();
      } else {
        throw ServerException(
          errorMessageModel: ErrorMessageModel(
            statusCode: response.statusCode ?? 500,
            statusMessage: 'Failed to fetch on air shows',
            success: false,
          ),
        );
      }
    } catch (e) {
      throw ServerException(
        errorMessageModel: ErrorMessageModel(
          statusCode: 500,
          statusMessage: 'Failed to fetch on air shows: $e',
          success: false,
        ),
      );
    }
  }

  @override
  Future<List<TVShowModel>> getPopularTVShows() async {
    try {
      // Fetch shows using predefined popular show IDs
      // Use Future.wait with eagerError: false to continue even if some fail
      final results = await Future.wait(
        ApiConstants.popularShowIds.map((id) => _getShowById(id)),
        eagerError: false,
      );
      // Filter out any null results from failed requests
      return results.whereType<TVShowModel>().toList();
    } catch (e) {
      // If all requests fail, return empty list instead of throwing
      return [];
    }
  }

  @override
  Future<List<TVShowModel>> getTopRatedTVShows() async {
    try {
      // Fetch shows using predefined top rated show IDs
      // Use Future.wait with eagerError: false to continue even if some fail
      final results = await Future.wait(
        ApiConstants.topRatedShowIds.map((id) => _getShowById(id)),
        eagerError: false,
      );
      // Filter out any null results from failed requests
      return results.whereType<TVShowModel>().toList();
    } catch (e) {
      // If all requests fail, return empty list instead of throwing
      return [];
    }
  }

  @override
  Future<List<List<TVShowModel>>> getTVShows() async {
    final response = Future.wait([
      getOnAirTVShows(),
      getPopularTVShows(),
      getTopRatedTVShows(),
    ], eagerError: true);
    return response;
  }

  @override
  Future<TVShowDetailsModel> getTVShowDetails(int id) async {
    try {
      final response = await dio.get(
        ApiConstants.showDetailsPath(id),
        queryParameters: {'embed[]': ['cast', 'episodes', 'seasons']},
      );
      
      if (response.statusCode == 200) {
        return TVShowDetailsModel.fromJson(response.data);
      } else {
        throw ServerException(
          errorMessageModel: ErrorMessageModel(
            statusCode: response.statusCode ?? 500,
            statusMessage: 'Failed to fetch show details',
            success: false,
          ),
        );
      }
    } catch (e) {
      throw ServerException(
        errorMessageModel: ErrorMessageModel(
          statusCode: 500,
          statusMessage: 'Failed to fetch show details: $e',
          success: false,
        ),
      );
    }
  }

  @override
  Future<SeasonDetailsModel> getSeasonDetails(int id, int seasonNumber) async {
    try {
      // First get the show to find the season ID
      final showResponse = await dio.get(ApiConstants.showSeasonsPath(id));
      
      if (showResponse.statusCode == 200) {
        final List seasons = showResponse.data as List;
        final season = seasons.firstWhere(
          (s) => s['number'] == seasonNumber,
          orElse: () => null,
        );
        
        if (season == null) {
          throw ServerException(
            errorMessageModel: ErrorMessageModel(
              statusCode: 404,
              statusMessage: 'Season not found',
              success: false,
            ),
          );
        }
        
        // Get episodes for this season
        final episodesResponse = await dio.get(
          ApiConstants.seasonEpisodesPath(season['id']),
        );
        
        if (episodesResponse.statusCode == 200) {
          return SeasonDetailsModel.fromJson({
            ...season,
            'episodes': episodesResponse.data,
          });
        } else {
          throw ServerException(
            errorMessageModel: ErrorMessageModel(
              statusCode: episodesResponse.statusCode ?? 500,
              statusMessage: 'Failed to fetch season episodes',
              success: false,
            ),
          );
        }
      } else {
        throw ServerException(
          errorMessageModel: ErrorMessageModel(
            statusCode: showResponse.statusCode ?? 500,
            statusMessage: 'Failed to fetch seasons',
            success: false,
          ),
        );
      }
    } catch (e) {
      throw ServerException(
        errorMessageModel: ErrorMessageModel(
          statusCode: 500,
          statusMessage: 'Failed to fetch season details: $e',
          success: false,
        ),
      );
    }
  }

  @override
  Future<List<TVShowModel>> getAllPopularTVShows(int page) async {
    try {
      // TVmaze has a show index endpoint with pagination
      final response = await dio.get(
        ApiConstants.showsIndexPath,
        queryParameters: {'page': page},
      );
      
      if (response.statusCode == 200) {
        return List<TVShowModel>.from(
          (response.data as List).map((e) => TVShowModel.fromJson(e)),
        );
      } else {
        throw ServerException(
          errorMessageModel: ErrorMessageModel(
            statusCode: response.statusCode ?? 500,
            statusMessage: 'Failed to fetch shows',
            success: false,
          ),
        );
      }
    } catch (e) {
      throw ServerException(
        errorMessageModel: ErrorMessageModel(
          statusCode: 500,
          statusMessage: 'Failed to fetch shows: $e',
          success: false,
        ),
      );
    }
  }

  @override
  Future<List<TVShowModel>> getAllTopRatedTVShows(int page) async {
    // TVmaze doesn't have a separate top rated endpoint
    // Return the same as popular for now
    return getAllPopularTVShows(page);
  }
}
