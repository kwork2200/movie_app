import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import '../../../core/domain/usecase/base_use_case.dart';
import '../entities/person_details.dart';
import '../repository/person_repository.dart';

class GetPersonDetailsUseCase extends BaseUseCase<PersonDetails, int> {
  final PersonRepository _personRepository;

  GetPersonDetailsUseCase(this._personRepository);

  @override
  Future<Either<Failure, PersonDetails>> call(int p) async {
    return await _personRepository.getPersonDetails(p);
  }
}
