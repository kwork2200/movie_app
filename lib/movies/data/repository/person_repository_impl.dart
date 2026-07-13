import 'package:dartz/dartz.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/error/failure.dart';
import '../../../core/resources/app_strings.dart';
import '../../domain/entities/person_details.dart';
import '../../domain/repository/person_repository.dart';
import '../datasource/person_remote_data_source.dart';

class PersonRepositoryImpl extends PersonRepository {
  final PersonRemoteDataSource _personRemoteDataSource;

  PersonRepositoryImpl(this._personRemoteDataSource);

  @override
  Future<Either<Failure, PersonDetails>> getPersonDetails(int personId) async {
    try {
      final result = await _personRemoteDataSource.getPersonDetails(personId);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.errorMessageModel.statusMessage));
    } catch (_) {
      return Left(ServerFailure(AppStrings.unknownError));
    }
  }
}
