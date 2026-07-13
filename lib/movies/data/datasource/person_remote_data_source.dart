import 'package:dio/dio.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/error_message_model.dart';
import '../models/person_details_model.dart';

abstract class PersonRemoteDataSource {
  Future<PersonDetailsModel> getPersonDetails(int personId);
}

class PersonRemoteDataSourceImpl extends PersonRemoteDataSource {
  final Dio dio;

  PersonRemoteDataSourceImpl(this.dio);

  @override
  Future<PersonDetailsModel> getPersonDetails(int personId) async {
    try {
      // Fetch person details
      final detailsResponse = await dio.get(ApiConstants.personDetailsPath(personId));
      
      if (detailsResponse.statusCode != 200) {
        throw ServerException(
          errorMessageModel: ErrorMessageModel(
            statusCode: detailsResponse.statusCode ?? 500,
            statusMessage: 'Failed to load person details',
            success: false,
          ),
        );
      }

      // Fetch cast credits
      final creditsResponse = await dio.get(ApiConstants.personCastCreditsPath(personId));
      
      final List<dynamic> castCredits = creditsResponse.statusCode == 200 
          ? creditsResponse.data as List<dynamic>
          : [];

      return PersonDetailsModel.fromJson(detailsResponse.data, castCredits);
    } on DioException catch (e) {
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(
          e.response?.data ?? {'status_message': 'Network error'},
        ),
      );
    } catch (e) {
      throw ServerException(
        errorMessageModel: ErrorMessageModel(
          statusCode: 500,
          statusMessage: e.toString(),
          success: false,
        ),
      );
    }
  }
}
