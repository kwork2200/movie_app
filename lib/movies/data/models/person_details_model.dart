import '../../../core/network/api_constants.dart';
import '../../domain/entities/person_details.dart';

class PersonDetailsModel extends PersonDetails {
  const PersonDetailsModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.gender,
    super.country,
    super.birthday,
    super.deathday,
    required super.castCredits,
  });

  factory PersonDetailsModel.fromJson(Map<String, dynamic> json, List<dynamic> castCreditsJson) {
    // Get person image
    String imageUrl = ApiConstants.castPlaceHolder;
    if (json['image'] != null) {
      imageUrl = json['image']['original'] ?? 
                 json['image']['medium'] ?? 
                 ApiConstants.castPlaceHolder;
    }

    // Get country
    String? country;
    if (json['country'] != null) {
      country = json['country']['name'] as String?;
    }

    // Parse cast credits
    final List<CastCredit> credits = castCreditsJson.map((credit) {
      return CastCreditModel.fromJson(credit);
    }).toList();

    return PersonDetailsModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      imageUrl: imageUrl,
      gender: json['gender'] as String? ?? 'Unknown',
      country: country,
      birthday: json['birthday'] as String?,
      deathday: json['deathday'] as String?,
      castCredits: credits,
    );
  }
}

class CastCreditModel extends CastCredit {
  const CastCreditModel({
    required super.showId,
    required super.showName,
    super.showImageUrl,
    super.characterName,
  });

  factory CastCreditModel.fromJson(Map<String, dynamic> json) {
    final embedded = json['_embedded'];
    final show = embedded?['show'];
    
    String? showImageUrl;
    if (show != null && show['image'] != null) {
      showImageUrl = show['image']['medium'] ?? 
                     show['image']['original'] ?? 
                     ApiConstants.moviePlaceHolder;
    } else {
      showImageUrl = ApiConstants.moviePlaceHolder;
    }

    return CastCreditModel(
      showId: show?['id'] as int? ?? 0,
      showName: show?['name'] as String? ?? 'Unknown',
      showImageUrl: showImageUrl,
      characterName: json['_links']?['character']?['name'] as String?,
    );
  }
}
