import 'package:dartz/dartz.dart';

import '../../../core/domain/entities/media_details.dart';
import '../../../core/domain/usecase/base_use_case.dart';
import '../../../core/error/failure.dart';
import '../repository/tv_shows_repository.dart';

class GetTVShowDetailsUseCase extends BaseUseCase<MediaDetails, int> {
  final TVShowsRepository _tvShowsRepository;

  GetTVShowDetailsUseCase(this._tvShowsRepository);
  @override
  Future<Either<Failure, MediaDetails>> call(int p) async {
    return await _tvShowsRepository.getTVShowDetails(p);
  }
}
