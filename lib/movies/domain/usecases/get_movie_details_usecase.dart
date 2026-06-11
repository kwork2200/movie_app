import 'package:dartz/dartz.dart';


import '../../../core/domain/entities/media_details.dart';
import '../../../core/domain/usecase/base_use_case.dart';
import '../../../core/error/failure.dart';
import '../repository/movies_repository.dart';

class GetMoviesDetailsUseCase extends BaseUseCase<MediaDetails, int> {
  final MoviesRespository _moviesRespository;

  GetMoviesDetailsUseCase(this._moviesRespository);

  @override
  Future<Either<Failure, MediaDetails>> call(int p) async {
    return await _moviesRespository.getMovieDetails(p);
  }
}
