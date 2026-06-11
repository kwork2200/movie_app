
import 'package:dartz/dartz.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/error/failure.dart';
import '../../../core/resources/app_strings.dart';
import '../../domain/entities/search_result_item.dart';
import '../../domain/repository/search_repository.dart';
import '../datasource/search_remote_data_source.dart';

class SearchRepositoryImpl extends SearchRepository {
  final SearchRemoteDataSource _searchRemoteDataSource;

  SearchRepositoryImpl(this._searchRemoteDataSource);

  @override
  Future<Either<Failure, List<SearchResultItem>>> search(String title) async {
    try {
      final result = await _searchRemoteDataSource.search(title);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.errorMessageModel.statusMessage));
    } catch (_) {
      return Left(ServerFailure(AppStrings.unknownError));
    }
  }
}
