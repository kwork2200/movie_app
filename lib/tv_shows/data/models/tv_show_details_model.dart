

// ignore: must_be_immutable
import 'package:new_movie_app/tv_shows/data/models/season_model.dart';
import 'package:new_movie_app/tv_shows/data/models/tv_show_model.dart';

import '../../../core/domain/entities/media_details.dart';
import '../../../core/network/api_constants.dart';
import 'episode_model.dart';

class TVShowDetailsModel extends MediaDetails {
  TVShowDetailsModel({
    required super.tmdbID,
    required super.title,
    required super.posterUrl,
    required super.backdropUrl,
    required super.releaseDate,
    required super.lastEpisodeToAir,
    required super.genres,
    required super.overview,
    required super.voteAverage,
    required super.voteCount,
    required super.trailerUrl,
    required super.numberOfSeasons,
    required super.seasons,
    required super.similar,
  });

  factory TVShowDetailsModel.fromJson(Map<String, dynamic> json) {
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
    
    // Get premiere date
    final premiered = json['premiered'] as String? ?? '';
    
    // Get summary (remove HTML tags)
    String summary = json['summary'] as String? ?? 'No overview available';
    summary = summary.replaceAll(RegExp(r'<[^>]*>'), ''); // Remove HTML tags
    
    // Format vote count (TVmaze doesn't provide vote count, use weight as proxy)
    final weight = json['weight'] as int? ?? 0;
    final formattedVoteCount = weight >= 1000 
        ? '${(weight / 1000).toStringAsFixed(1)}K'
        : weight.toString();
    
    // Parse seasons (if embedded)
    List<SeasonModel> seasons = [];
    int numberOfSeasons = 0;
    if (json['_embedded'] != null && json['_embedded']['seasons'] != null) {
      final seasonsList = json['_embedded']['seasons'] as List;
      seasons = seasonsList
          .where((e) => e['number'] != null && e['number'] > 0) // Exclude specials (season 0)
          .map((e) => SeasonModel.fromJson(e))
          .toList();
      numberOfSeasons = seasons.length;
    }
    
    // Parse last episode (if embedded)
    EpisodeModel? lastEpisode;
    if (json['_embedded'] != null && json['_embedded']['episodes'] != null) {
      final episodes = json['_embedded']['episodes'] as List;
      if (episodes.isNotEmpty) {
        lastEpisode = EpisodeModel.fromJson(episodes.last);
      }
    }
    
    // Parse similar shows (TVmaze doesn't provide similar, use empty list)
    List<TVShowModel> similar = [];
    
    return TVShowDetailsModel(
      tmdbID: id,
      title: json['name'] as String? ?? 'Unknown',
      posterUrl: posterUrl,
      backdropUrl: backdropUrl,
      releaseDate: premiered,
      lastEpisodeToAir: lastEpisode,
      genres: genres,
      numberOfSeasons: numberOfSeasons,
      voteAverage: rating,
      voteCount: formattedVoteCount,
      overview: summary,
      trailerUrl: '', // TVmaze doesn't provide direct trailer URLs
      seasons: seasons,
      similar: similar,
    );
  }
}
