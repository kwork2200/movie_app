import '../../../core/network/api_constants.dart';
import '../../domain/entities/cast.dart';

class CastModel extends Cast {
  const CastModel({
    required super.id,
    required super.name,
    required super.profileUrl,
    required super.gender,
  });

  factory CastModel.fromJson(Map<String, dynamic> json) {
    final person = json['person'] ?? json;
    final character = json['character'];
    final id = person['id'] as int? ?? 0;
    
    String profileUrl = ApiConstants.castPlaceHolder;
    if (person['image'] != null) {
      profileUrl = person['image']['medium'] ?? person['image']['original'] ?? ApiConstants.castPlaceHolder;
    }
    final genderStr = person['gender'] as String? ?? '';
    final gender = genderStr.toLowerCase() == 'male' ? 2 : (genderStr.toLowerCase() == 'female' ? 1 : 0);
    
    final name = person['name'] as String? ?? character?['name'] as String? ?? 'Unknown';
    
    return CastModel(
      id: id,
      name: name,
      profileUrl: profileUrl,
      gender: gender,
    );
  }
}
