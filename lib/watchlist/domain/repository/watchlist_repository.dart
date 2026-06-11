import 'package:dartz/dartz.dart';
import '../../../core/domain/entities/media.dart';
import '../../../core/error/failure.dart';

abstract class WatchlistRepository {
  Future<Either<Failure, List<Media>>> getWatchListItems();
  Future<Either<Failure, int>> addWatchListItem(Media media);
  Future<Either<Failure, Unit>> removeWatchListItem(int index);
  Future<Either<Failure, int>> isBookmarked(int tmdbId);
}
