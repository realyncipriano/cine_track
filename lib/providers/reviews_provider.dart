import 'package:flutter/foundation.dart';
import '../models/review.dart';
import '../services/api_service.dart';
import '../services/api_endpoints.dart';

class ReviewsProvider extends ChangeNotifier {
  final ApiService _api;

  List<Review> _reviews = [];
  Review? _userReview;
  double? _averageRating;
  int _totalReviews = 0;
  bool _isLoading = false;
  String? _error;

  ReviewsProvider(this._api);

  List<Review> get reviews => _reviews;
  Review? get userReview => _userReview;
  double? get averageRating => _averageRating;
  int get totalReviews => _totalReviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchReviews(int movieId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.get('${ApiEndpoints.reviewList}?movie_id=$movieId');
      final list = data['reviews'] as List<dynamic>;
      _reviews = list
          .whereType<Map<String, dynamic>>()
          .map(Review.fromJson)
          .toList();

      final summary = data['summary'];
      final summaryMap = summary is Map<String, dynamic> ? summary : null;
      _averageRating = summaryMap?['average'] != null
          ? (summaryMap!['average'] as num).toDouble()
          : null;
      _totalReviews = summaryMap?['count'] as int? ?? _reviews.length;

      final userReviewData = data['user_review'];
      _userReview = userReviewData is Map<String, dynamic>
          ? Review.fromJson(userReviewData)
          : null;
    } catch (e) {
      _error = '$e';
      debugPrint('fetchReviews error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addReview(int movieId, int rating, String reviewText) async {
    try {
      await _api.post(ApiEndpoints.reviewAdd, {
        'movie_id': movieId,
        'rating': rating,
        'review_text': reviewText,
      });
      await fetchReviews(movieId);
      return true;
    } catch (e) {
      _error = '$e';
      debugPrint('addReview error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteReview(int movieId) async {
    try {
      await _api.post(ApiEndpoints.reviewDelete, {'movie_id': movieId});
      await fetchReviews(movieId);
      return true;
    } catch (e) {
      _error = '$e';
      debugPrint('deleteReview error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> reportReview(int reviewId, String reason) async {
    try {
      await _api.post(ApiEndpoints.reviewReport, {
        'review_id': reviewId,
        'reason': reason,
      });
      return true;
    } catch (e) {
      _error = '$e';
      debugPrint('reportReview error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleLike(int reviewId) async {
    final idx = _reviews.indexWhere((r) => r.id == reviewId);
    Review? previous;
    if (idx >= 0) {
      previous = _reviews[idx];
      final wasLiked = _reviews[idx].isLiked;
      _reviews[idx] = _reviews[idx].copyWith(
        isLiked: !wasLiked,
        likesCount: _reviews[idx].likesCount + (wasLiked ? -1 : 1),
      );
      notifyListeners();
    } else if (_userReview?.id == reviewId) {
      previous = _userReview;
      final wasLiked = _userReview!.isLiked;
      _userReview = _userReview!.copyWith(
        isLiked: !wasLiked,
        likesCount: _userReview!.likesCount + (wasLiked ? -1 : 1),
      );
      notifyListeners();
    }

    try {
      final data = await _api.post(ApiEndpoints.reviewLike, {'review_id': reviewId});
      final liked = data['liked'] as bool;
      final count = data['likes_count'] as int? ?? 0;
      if (idx >= 0) {
        _reviews[idx] = _reviews[idx].copyWith(isLiked: liked, likesCount: count);
      } else if (_userReview?.id == reviewId) {
        _userReview = _userReview!.copyWith(isLiked: liked, likesCount: count);
      }
    } catch (e) {
      if (idx >= 0 && previous != null) {
        _reviews[idx] = previous;
      } else if (_userReview?.id == reviewId && previous != null) {
        _userReview = previous;
      }
      debugPrint('toggleLike error: $e');
    }
    notifyListeners();
  }

  void clear() {
    _reviews = [];
    _userReview = null;
    _averageRating = null;
    _totalReviews = 0;
    _error = null;
    notifyListeners();
  }
}
