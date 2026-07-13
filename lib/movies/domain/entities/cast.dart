import 'package:equatable/equatable.dart';

class Cast extends Equatable {
  final int id;
  final String name;
  final String profileUrl;
  final int gender;

  const Cast({
    required this.id,
    required this.name,
    required this.profileUrl,
    required this.gender,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        profileUrl,
        gender,
      ];
}
