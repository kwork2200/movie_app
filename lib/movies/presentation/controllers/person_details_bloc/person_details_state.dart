import 'package:equatable/equatable.dart';

import '../../../../core/utils/enums.dart';
import '../../../domain/entities/person_details.dart';

class PersonDetailsState extends Equatable {
  final PersonDetails? personDetails;
  final RequestStatus status;
  final String message;

  const PersonDetailsState({
    this.personDetails,
    this.status = RequestStatus.loading,
    this.message = '',
  });

  PersonDetailsState copyWith({
    PersonDetails? personDetails,
    RequestStatus? status,
    String? message,
  }) {
    return PersonDetailsState(
      personDetails: personDetails ?? this.personDetails,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [personDetails, status, message];
}
