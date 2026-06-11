
import '../../../core/domain/entities/media.dart';
import '../../../core/network/api_constants.dart';

class MovieModel extends Media {
  const MovieModel({
    required super.tmdbID,
    required super.title,
    required super.posterUrl,
    required super.backdropUrl,
    required super.voteAverage,
    required super.releaseDate,
    required super.overview,
    required super.isMovie,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    // TVmaze API response structure
    final id = json['id'] as int? ?? 0;
    
    // Parse rating (TVmaze has rating.average)
    final rating = json['rating'] != null && json['rating']['average'] != null
        ? (json['rating']['average'] as num).toDouble()
        : 0.0;
    
    // Get poster URL (TVmaze provides image object with medium and original)
    String posterUrl = ApiConstants.moviePlaceHolder;
    if (json['image'] != null) {
      posterUrl = json['image']['medium'] ?? json['image']['original'] ?? ApiConstants.moviePlaceHolder;
    }
    
    // Get backdrop URL (use original image if available)
    String backdropUrl = ApiConstants.moviePlaceHolder;
    if (json['image'] != null) {
      backdropUrl = json['image']['original'] ?? json['image']['medium'] ?? ApiConstants.moviePlaceHolder;
    }
    
    // Get premiere date
    final premiered = json['premiered'] as String? ?? '';
    
    // Get summary (remove HTML tags)
    String summary = json['summary'] as String? ?? 'No overview available';
    summary = summary.replaceAll(RegExp(r'<[^>]*>'), ''); // Remove HTML tags
    
    return MovieModel(
      tmdbID: id,
      title: json['name'] as String? ?? 'Unknown',
      posterUrl: posterUrl,
      backdropUrl: backdropUrl,
      voteAverage: rating,
      releaseDate: premiered,
      overview: summary,
      isMovie: true, // TVmaze is primarily for shows, but we treat them as movies in this context
    );
  }
}
