
import 'package:dartz/dartz.dart';


import '../../../core/domain/entities/media.dart';
import '../../../core/domain/usecase/base_use_case.dart';
import '../../../core/error/failure.dart';
import '../repository/tv_shows_repository.dart';

class GetTVShowsUseCase extends BaseUseCase<List<List<Media>>, NoParameters> {
  final TVShowsRepository _tvShowsRepository;

  GetTVShowsUseCase(this._tvShowsRepository);

  @override
  Future<Either<Failure, List<List<Media>>>> call(NoParameters p) async {
    return await _tvShowsRepository.getTVShows();
  }
}
