import 'package:dio/dio.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/error_message_model.dart';
import '../models/movie_details_model.dart';
import '../models/movie_model.dart';

abstract class MoviesRemoteDataSource {
  Future<List<MovieModel>> getNowPlayingMovies();
  Future<List<MovieModel>> getPopularMovies();
  Future<List<MovieModel>> getTopRatedMovies();
  Future<List<List<MovieModel>>> getMovies();
  Future<MovieDetailsModel> getMovieDetails(int movieId);
  Future<List<MovieModel>> getAllPopularMovies(int page);
  Future<List<MovieModel>> getAllTopRatedMovies(int page);
}

class MoviesRemoteDataSourceImpl extends MoviesRemoteDataSource {
  final Dio dio;

  MoviesRemoteDataSourceImpl(this.dio);

  // Helper method to fetch show by TVmaze ID
  Future<MovieModel?> _getShowById(int showId) async {
    try {
      final response = await dio.get(ApiConstants.showDetailsPath(showId));
      
      if (response.statusCode == 200) {
        return MovieModel.fromJson(response.data);
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
  Future<List<MovieModel>> getNowPlayingMovies() async {
    try {
      // Use show index with page 0 to get recent shows
      final response = await dio.get(
        ApiConstants.showsIndexPath,
        queryParameters: {'page': 0},
      );
      
      if (response.statusCode == 200) {
        final List shows = response.data as List;
        // Take first 10 shows
        return shows
            .take(10)
            .map((show) => MovieModel.fromJson(show))
            .toList();
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
  Future<List<MovieModel>> getPopularMovies() async {
    try {
      // Fetch shows using predefined popular show IDs
      // Use Future.wait with eagerError: false to continue even if some fail
      final results = await Future.wait(
        ApiConstants.popularShowIds.map((id) => _getShowById(id)),
        eagerError: false,
      );
      // Filter out any null results from failed requests
      return results.whereType<MovieModel>().toList();
    } catch (e) {
      // If all requests fail, return empty list instead of throwing
      return [];
    }
  }

  @override
  Future<List<MovieModel>> getTopRatedMovies() async {
    try {
      // Fetch shows using predefined top rated show IDs
      // Use Future.wait with eagerError: false to continue even if some fail
      final results = await Future.wait(
        ApiConstants.topRatedShowIds.map((id) => _getShowById(id)),
        eagerError: false,
      );
      // Filter out any null results from failed requests
      return results.whereType<MovieModel>().toList();
    } catch (e) {
      // If all requests fail, return empty list instead of throwing
      return [];
    }
  }

  @override
  Future<List<List<MovieModel>>> getMovies() async {
    final response = Future.wait([
      getNowPlayingMovies(),
      getPopularMovies(),
      getTopRatedMovies(),
    ], eagerError: true);
    return response;
  }

  @override
  Future<MovieDetailsModel> getMovieDetails(int movieId) async {
    try {
      final response = await dio.get(
        ApiConstants.showDetailsPath(movieId),
        queryParameters: {'embed[]': ['cast', 'episodes']},
      );
      
      if (response.statusCode == 200) {
        return MovieDetailsModel.fromJson(response.data);
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
  Future<List<MovieModel>> getAllPopularMovies(int page) async {
    try {
      // TVmaze has a show index endpoint with pagination
      final response = await dio.get(
        ApiConstants.showsIndexPath,
        queryParameters: {'page': page},
      );
      
      if (response.statusCode == 200) {
        return List<MovieModel>.from(
          (response.data as List).map((e) => MovieModel.fromJson(e)),
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
  Future<List<MovieModel>> getAllTopRatedMovies(int page) async {
    // TVmaze doesn't have a separate top rated endpoint
    // Return the same as popular for now
    return getAllPopularMovies(page);
  }
}
