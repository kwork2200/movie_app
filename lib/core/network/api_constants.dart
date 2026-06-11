class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.tvmaze.com';

  static const String moviePlaceHolder =
      'https://davidkoepp.com/wp-content/themes/blankslate/images/Movie%20Placeholder.jpg';

  static const String castPlaceHolder =
      'https://palmbayprep.org/wp-content/uploads/2015/09/user-icon-placeholder.png';

  static const String avatarPlaceHolder =
      'https://cdn.pixabay.com/photo/2018/11/13/21/43/avatar-3814049__480.png';

  static const String stillPlaceHolder =
      'https://popcornsg.s3.amazonaws.com/gallery/1577405144-six-year.png';

  static const String basePosterUrl = '';
  static const String baseBackdropUrl = '';
  static const String baseStillUrl = '';
  static const String baseProfileUrl = '';
  static const String baseAvatarUrl = '';
  static const String baseVideoUrl = 'https://www.youtube.com/watch?v=';

  static const String searchShowsPath = '/search/shows';
  static const String singleSearchPath = '/singlesearch/shows';
  static const String searchPeoplePath = '/search/people';
  
  static const String schedulePath = '/schedule';
  static const String webSchedulePath = '/schedule/web';
  static const String fullSchedulePath = '/schedule/full';
  
  static const String showsIndexPath = '/shows';
  static String showDetailsPath(int id) => '/shows/$id';
  static String showEpisodesPath(int id) => '/shows/$id/episodes';
  static String showSeasonsPath(int id) => '/shows/$id/seasons';
  static String showCastPath(int id) => '/shows/$id/cast';
  static String showCrewPath(int id) => '/shows/$id/crew';
  static String showImagesPath(int id) => '/shows/$id/images';

  static String seasonEpisodesPath(int seasonId) => '/seasons/$seasonId/episodes';
  
  static String episodeDetailsPath(int id) => '/episodes/$id';
  static String episodeGuestCastPath(int id) => '/episodes/$id/guestcast';
  
  static String personDetailsPath(int id) => '/people/$id';
  static String personCastCreditsPath(int id) => '/people/$id/castcredits';
  
  static const String showUpdatesPath = '/updates/shows';

  static const List<int> popularShowIds = [
    82,
    169,
    210,
    73,
    216,
    335,
    527,
    1,
    66,
    431,
  ];

  static const List<int> topRatedShowIds = [
    82,
    169,
    335,
    216,
    431,
    143,
    123,
    175,
    49,
    83,
  ];
}
