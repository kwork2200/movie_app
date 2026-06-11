
import '../../../core/network/api_constants.dart';
import '../../domain/entities/season.dart';

class SeasonModel extends Season {
  const SeasonModel({
    required super.tmdbID,
    required super.name,
    required super.episodeCount,
    required super.airDate,
    required super.overview,
    required super.posterUrl,
    required super.seasonNumber,
  });

  factory SeasonModel.fromJson(Map<String, dynamic> json) {
    // TVmaze API response structure
    
    // Get poster URL
    String posterUrl = ApiConstants.moviePlaceHolder;
    if (json['image'] != null) {
      posterUrl = json['image']['medium'] ?? json['image']['original'] ?? ApiConstants.moviePlaceHolder;
    }
    
    // Get premiere date
    final premiereDate = json['premiereDate'] as String? ?? '';
    
    // Get summary (remove HTML tags)
    String summary = json['summary'] as String? ?? '';
    if (summary.isNotEmpty) {
      summary = summary.replaceAll(RegExp(r'<[^>]*>'), ''); // Remove HTML tags
    }
    
    return SeasonModel(
      tmdbID: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Season ${json['number'] ?? 0}',
      episodeCount: json['episodeOrder'] as int? ?? 0,
      airDate: premiereDate,
      overview: summary,
      posterUrl: posterUrl,
      seasonNumber: json['number'] as int? ?? 0,
    );
  }
}
