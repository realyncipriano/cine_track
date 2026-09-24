import 'package:share_plus/share_plus.dart';
import '../config.dart';

class ShareHelper {
  static String get _baseUrl => AppConfig.apiBaseUrl
      .replaceAll('/api', '')
      .replaceAll('http://10.0.2.2/cine_track', 'https://cine-track-delta.vercel.app');

  static Future<void> shareMovie({
    required int movieId,
    required String title,
    String? year,
  }) async {
    final text = 'Check out "$title"${year != null ? ' ($year)' : ''} on CineTrack!\n'
        '$_baseUrl/movie/$movieId';
    await Share.share(text);
  }

  static Future<void> shareProfile({
    required int userId,
    required String name,
  }) async {
    final text = 'Follow "$name" on CineTrack!\n'
        '$_baseUrl/profile/$userId';
    await Share.share(text);
  }

  static Future<void> shareList({
    required int listId,
    required String listName,
    String? ownerName,
  }) async {
    final owner = ownerName != null ? ' by $ownerName' : '';
    final text = 'Check out the list "$listName"$owner on CineTrack!\n'
        '$_baseUrl/lists/$listId';
    await Share.share(text);
  }

  static Future<void> shareReview({
    required String userName,
    required String movieTitle,
    required int rating,
    required String reviewText,
    required int movieId,
  }) async {
    final stars = '⭐' * rating;
    final snippet = reviewText.length > 100
        ? '${reviewText.substring(0, 100)}…'
        : reviewText;
    final text = '"$userName" reviewed "$movieTitle"\n'
        '$stars\n'
        '"$snippet"\n'
        '$_baseUrl/movie/$movieId';
    await Share.share(text);
  }
}
