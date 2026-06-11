import 'package:dio/dio.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/error_message_model.dart';
import '../models/search_result_item_model.dart';

abstract class SearchRemoteDataSource {
  Future<List<SearchResultItemModel>> search(String title);
}

class SearchRemoteDataSourceImpl extends SearchRemoteDataSource {
  final Dio dio;

  SearchRemoteDataSourceImpl(this.dio);

  @override
  Future<List<SearchResultItemModel>> search(String title) async {
    try {
      final response = await dio.get(
        ApiConstants.searchShowsPath,
        queryParameters: {'q': title},
      );

      if (response.statusCode == 200) {
        final List results = response.data as List;
        return results
            .map((e) => SearchResultItemModel.fromJson(e['show']))
            .toList();
      } else {
        throw ServerException(
          errorMessageModel: ErrorMessageModel(
            statusCode: response.statusCode ?? 500,
            statusMessage: 'Search failed',
            success: false,
          ),
        );
      }
    } catch (e) {
      throw ServerException(
        errorMessageModel: ErrorMessageModel(
          statusCode: 500,
          statusMessage: 'Search failed: $e',
          success: false,
        ),
      );
    }
  }
}
