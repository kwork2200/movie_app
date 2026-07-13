import 'package:equatable/equatable.dart';

class PersonDetails extends Equatable {
  final int id;
  final String name;
  final String imageUrl;
  final String gender;
  final String? country;
  final String? birthday;
  final String? deathday;
  final List<CastCredit> castCredits;

  const PersonDetails({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.gender,
    this.country,
    this.birthday,
    this.deathday,
    required this.castCredits,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
        gender,
        country,
        birthday,
        deathday,
        castCredits,
      ];
}

class CastCredit extends Equatable {
  final int showId;
  final String showName;
  final String? showImageUrl;
  final String? characterName;

  const CastCredit({
    required this.showId,
    required this.showName,
    this.showImageUrl,
    this.characterName,
  });

  @override
  List<Object?> get props => [
        showId,
        showName,
        showImageUrl,
        characterName,
      ];
}
