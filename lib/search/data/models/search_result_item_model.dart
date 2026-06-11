
import '../../../core/network/api_constants.dart';
import '../../domain/entities/search_result_item.dart';

class SearchResultItemModel extends SearchResultItem {
  const SearchResultItemModel({
    required super.tmdbID,
    required super.posterUrl,
    required super.title,
    required super.isMovie,
  });

  factory SearchResultItemModel.fromJson(Map<String, dynamic> json) {
    // TVmaze API response structure
    final id = json['id'] as int? ?? 0;
    
    // Get poster URL (TVmaze provides image object with medium and original)
    String posterUrl = ApiConstants.moviePlaceHolder;
    if (json['image'] != null) {
      posterUrl = json['image']['medium'] ?? json['image']['original'] ?? ApiConstants.moviePlaceHolder;
    }
    
    // TVmaze is primarily for TV shows, but we can check the type
    final type = json['type'] as String? ?? 'Scripted';
    final isMovie = type == 'Movie';
    
    return SearchResultItemModel(
      tmdbID: id,
      posterUrl: posterUrl,
      title: json['name'] as String? ?? 'Unknown',
      isMovie: isMovie,
    );
  }
}
