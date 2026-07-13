import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import '../entities/person_details.dart';

abstract class PersonRepository {
  Future<Either<Failure, PersonDetails>> getPersonDetails(int personId);
}
