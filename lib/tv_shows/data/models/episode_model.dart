
import '../../../core/network/api_constants.dart';
import '../../domain/entities/episode.dart';

class EpisodeModel extends Episode {
  const EpisodeModel({
    required super.number,
    required super.season,
    required super.name,
    required super.runtime,
    required super.stillPath,
    required super.airDate,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    // TVmaze API response structure
    final runtime = json['runtime'] as int? ?? 0;
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    final formattedRuntime = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
    
    // Get still/image URL
    String stillUrl = ApiConstants.stillPlaceHolder;
    if (json['image'] != null) {
      stillUrl = json['image']['medium'] ?? json['image']['original'] ?? ApiConstants.stillPlaceHolder;
    }
    
    // Get air date
    final airDate = json['airdate'] as String? ?? '';
    
    return EpisodeModel(
      number: json['number'] as int? ?? 0,
      season: json['season'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      runtime: formattedRuntime,
      stillPath: stillUrl,
      airDate: airDate,
    );
  }
}
