import 'package:dartz/dartz.dart';


import '../../../core/domain/entities/media.dart';
import '../../../core/domain/usecase/base_use_case.dart';
import '../../../core/error/failure.dart';
import '../repository/movies_repository.dart';

class GetAllPopularMoviesUseCase extends BaseUseCase<List<Media>, int> {
  final MoviesRespository _moviesRespository;

  GetAllPopularMoviesUseCase(this._moviesRespository);

  @override
  Future<Either<Failure, List<Media>>> call(int p) async {
    return await _moviesRespository.getAllPopularMovies(p);
  }
}
