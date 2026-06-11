
import 'package:new_movie_app/movies/data/models/review_model.dart';

import '../../../core/domain/entities/media_details.dart';
import '../../../core/network/api_constants.dart';
import 'cast_model.dart';
import 'movie_model.dart';

class MovieDetailsModel extends MediaDetails {
  MovieDetailsModel({
    required super.tmdbID,
    required super.title,
    required super.posterUrl,
    required super.backdropUrl,
    required super.releaseDate,
    required super.genres,
    required super.runtime,
    required super.overview,
    required super.voteAverage,
    required super.voteCount,
    required super.trailerUrl,
    required super.cast,
    required super.reviews,
    required super.similar,
  });

  factory MovieDetailsModel.fromJson(Map<String, dynamic> json) {
    // TVmaze API response structure
    final id = json['id'] as int? ?? 0;
    
    // Parse rating
    final rating = json['rating'] != null && json['rating']['average'] != null
        ? (json['rating']['average'] as num).toDouble()
        : 0.0;
    
    // Get poster and backdrop URLs
    String posterUrl = ApiConstants.moviePlaceHolder;
    String backdropUrl = ApiConstants.moviePlaceHolder;
    if (json['image'] != null) {
      posterUrl = json['image']['medium'] ?? json['image']['original'] ?? ApiConstants.moviePlaceHolder;
      backdropUrl = json['image']['original'] ?? json['image']['medium'] ?? ApiConstants.moviePlaceHolder;
    }
    
    // Parse genres (TVmaze format: ["Drama", "Action"])
    final genresList = json['genres'] as List? ?? [];
    final genres = genresList.isNotEmpty ? genresList.join(', ') : 'N/A';
    
    // Parse runtime (TVmaze provides average runtime in minutes)
    final runtime = json['averageRuntime'] as int? ?? json['runtime'] as int? ?? 0;
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    final formattedRuntime = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
    
    // Get premiere date
    final premiered = json['premiered'] as String? ?? 'N/A';
    
    // Get summary (remove HTML tags)
    String summary = json['summary'] as String? ?? 'No overview available';
    summary = summary.replaceAll(RegExp(r'<[^>]*>'), ''); // Remove HTML tags
    
    // Format vote count (TVmaze doesn't provide vote count, use weight as proxy)
    final weight = json['weight'] as int? ?? 0;
    final formattedVoteCount = weight >= 1000 
        ? '${(weight / 1000).toStringAsFixed(1)}K'
        : weight.toString();
    
    // Parse cast (if embedded)
    List<CastModel> cast = [];
    if (json['_embedded'] != null && json['_embedded']['cast'] != null) {
      cast = (json['_embedded']['cast'] as List)
          .map((e) => CastModel.fromJson(e))
          .toList();
    }
    
    // Parse similar shows (TVmaze doesn't provide similar, but we can use empty list)
    List<MovieModel> similar = [];
    
    return MovieDetailsModel(
      tmdbID: id,
      title: json['name'] as String? ?? 'Unknown',
      posterUrl: posterUrl,
      backdropUrl: backdropUrl,
      releaseDate: premiered,
      genres: genres,
      runtime: formattedRuntime,
      overview: summary,
      voteAverage: rating,
      voteCount: formattedVoteCount,
      trailerUrl: '', // TVmaze doesn't provide direct trailer URLs
      cast: cast,
      reviews: [], // TVmaze doesn't provide reviews
      similar: similar,
    );
  }
}
