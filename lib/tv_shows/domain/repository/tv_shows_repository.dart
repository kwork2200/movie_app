import 'package:dartz/dartz.dart';


import '../../../core/domain/entities/media.dart';
import '../../../core/domain/entities/media_details.dart';
import '../../../core/error/failure.dart';
import '../entities/season_details.dart';
import '../usecases/get_season_details_usecase.dart';

abstract class TVShowsRepository {
  Future<Either<Failure, List<List<Media>>>> getTVShows();
  Future<Either<Failure, MediaDetails>> getTVShowDetails(int id);
  Future<Either<Failure, SeasonDetails>> getSeasonDetails(
    SeasonDetailsParams params,
  );
  Future<Either<Failure, List<Media>>> getAllPopularTVShows(int page);
  Future<Either<Failure, List<Media>>> getAllTopRatedTVShows(int page);
}
