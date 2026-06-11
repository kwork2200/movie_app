import 'package:dartz/dartz.dart';


import '../../../core/domain/usecase/base_use_case.dart';
import '../../../core/error/failure.dart';
import '../repository/watchlist_repository.dart';

class RemoveWatchlistItemUseCase extends BaseUseCase<Unit, int> {
  final WatchlistRepository _watchlistRepository;

  RemoveWatchlistItemUseCase(this._watchlistRepository);

  @override
  Future<Either<Failure, Unit>> call(int p) async {
    return await _watchlistRepository.removeWatchListItem(p);
  }
}
