import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/enums.dart';
import '../../../domain/usecases/get_person_details_usecase.dart';
import 'person_details_event.dart';
import 'person_details_state.dart';

class PersonDetailsBloc extends Bloc<PersonDetailsEvent, PersonDetailsState> {
  final GetPersonDetailsUseCase _getPersonDetailsUseCase;

  PersonDetailsBloc(this._getPersonDetailsUseCase)
      : super(const PersonDetailsState()) {
    on<GetPersonDetailsEvent>(_getPersonDetails);
  }

  Future<void> _getPersonDetails(
    GetPersonDetailsEvent event,
    Emitter<PersonDetailsState> emit,
  ) async {
    emit(state.copyWith(status: RequestStatus.loading));

    final result = await _getPersonDetailsUseCase(event.personId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: RequestStatus.error,
          message: failure.message,
        ),
      ),
      (personDetails) => emit(
        state.copyWith(
          personDetails: personDetails,
          status: RequestStatus.loaded,
        ),
      ),
    );
  }
}
