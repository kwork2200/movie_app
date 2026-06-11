import 'package:dartz/dartz.dart';

import '../../../core/domain/entities/media.dart';
import '../../../core/domain/entities/media_details.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/error/failure.dart';
import '../../../core/resources/app_strings.dart';
import '../../domain/repository/movies_repository.dart';
import '../datasource/movies_remote_data_source.dart';


class MoviesRepositoryImpl extends MoviesRespository {
  final MoviesRemoteDataSource _moviesRemoteDataSource;

  MoviesRepositoryImpl(this._moviesRemoteDataSource);

  @override
  Future<Either<Failure, MediaDetails>> getMovieDetails(int movieId) async {
    try {
      final result = await _moviesRemoteDataSource.getMovieDetails(movieId);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.errorMessageModel.statusMessage));
    } catch (_) {
      return Left(ServerFailure(AppStrings.unknownError));
    }
  }

  @override
  Future<Either<Failure, List<List<Media>>>> getMovies() async {
    try {
      final result = await _moviesRemoteDataSource.getMovies();
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.errorMessageModel.statusMessage));
    } catch (_) {
      return Left(ServerFailure(AppStrings.unknownError));
    }
  }

  @override
  Future<Either<Failure, List<Media>>> getAllPopularMovies(int page) async {
    try {
      final result = await _moviesRemoteDataSource.getAllPopularMovies(page);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.errorMessageModel.statusMessage));
    } catch (_) {
      return Left(ServerFailure(AppStrings.unknownError));
    }
  }

  @override
  Future<Either<Failure, List<Media>>> getAllTopRatedMovies(int page) async {
    try {
      final result = await _moviesRemoteDataSource.getAllTopRatedMovies(page);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.errorMessageModel.statusMessage));
    } catch (_) {
      return Left(ServerFailure(AppStrings.unknownError));
    }
  }
}
