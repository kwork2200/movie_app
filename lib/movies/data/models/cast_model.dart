import '../../../core/network/api_constants.dart';
import '../../domain/entities/cast.dart';

class CastModel extends Cast {
  const CastModel({
    required super.name,
    required super.profileUrl,
    required super.gender,
  });

  factory CastModel.fromJson(Map<String, dynamic> json) {
    // TVmaze cast format: { "person": {...}, "character": {...} }
    final person = json['person'] ?? json;
    final character = json['character'];
    
    // Get profile image
    String profileUrl = ApiConstants.castPlaceHolder;
    if (person['image'] != null) {
      profileUrl = person['image']['medium'] ?? person['image']['original'] ?? ApiConstants.castPlaceHolder;
    }
    
    // TVmaze uses gender object: { "gender": "Male" } or null
    final genderStr = person['gender'] as String? ?? '';
    final gender = genderStr.toLowerCase() == 'male' ? 2 : (genderStr.toLowerCase() == 'female' ? 1 : 0);
    
    // Get name (person name or character name if person not available)
    final name = person['name'] as String? ?? character?['name'] as String? ?? 'Unknown';
    
    return CastModel(
      name: name,
      profileUrl: profileUrl,
      gender: gender,
    );
  }
}
