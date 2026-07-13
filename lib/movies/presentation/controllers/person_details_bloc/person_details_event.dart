import 'package:equatable/equatable.dart';

abstract class PersonDetailsEvent extends Equatable {
  const PersonDetailsEvent();

  @override
  List<Object?> get props => [];
}

class GetPersonDetailsEvent extends PersonDetailsEvent {
  final int personId;

  const GetPersonDetailsEvent(this.personId);

  @override
  List<Object?> get props => [personId];
}
