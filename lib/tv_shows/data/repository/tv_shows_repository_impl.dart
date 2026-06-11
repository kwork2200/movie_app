
import 'package:dartz/dartz.dart';

import '../../../core/domain/entities/media.dart';
import '../../../core/domain/entities/media_details.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/error/failure.dart';
import '../../../core/resources/app_strings.dart';
import '../../domain/entities/season_details.dart';
import '../../domain/repository/tv_shows_repository.dart';
import '../../domain/usecases/get_season_details_usecase.dart';
import '../datasource/tv_shows_remote_data_source.dart';

class TVShowsRepositoryImpl extends TVShowsRepository {
  final TVShowsRemoteDataSource _tvShowsRemoteDataSource;

  TVShowsRepositoryImpl(this._tvShowsRemoteDataSource);

  @override
  Future<Either<Failure, List<List<Media>>>> getTVShows() async {
    try {
      final result = await _tvShowsRemoteDataSource.getTVShows();
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.errorMessageModel.statusMessage));
    } catch (_) {
      return Left(ServerFailure(AppStrings.unknownError));
    }
  }

  @override
  Future<Either<Failure, MediaDetails>> getTVShowDetails(int id) async {
    try {
      final result = await _tvShowsRemoteDataSource.getTVShowDetails(id);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.errorMessageModel.statusMessage));
    } catch (_) {
      return Left(ServerFailure(AppStrings.unknownError));
    }
  }

  @override
  Future<Either<Failure, SeasonDetails>> getSeasonDetails(
    SeasonDetailsParams params,
  ) async {
    try {
      final result = await _tvShowsRemoteDataSource.getSeasonDetails(
        params.id,
        params.seasonNumber,
      );
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.errorMessageModel.statusMessage));
    } catch (_) {
      return Left(ServerFailure(AppStrings.unknownError));
    }
  }

  @override
  Future<Either<Failure, List<Media>>> getAllPopularTVShows(int page) async {
    try {
      final result = await _tvShowsRemoteDataSource.getAllPopularTVShows(page);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.errorMessageModel.statusMessage));
    } catch (_) {
      return Left(ServerFailure(AppStrings.unknownError));
    }
  }

  @override
  Future<Either<Failure, List<Media>>> getAllTopRatedTVShows(int page) async {
    try {
      final result = await _tvShowsRemoteDataSource.getAllTopRatedTVShows(page);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.errorMessageModel.statusMessage));
    } catch (_) {
      return Left(ServerFailure(AppStrings.unknownError));
    }
  }
}
