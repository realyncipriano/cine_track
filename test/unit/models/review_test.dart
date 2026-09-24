import 'package:flutter_test/flutter_test.dart';
import 'package:cine_track/models/review.dart';

void main() {
  group('Review.fromJson', () {
    test('parses all fields correctly', () {
      final json = {
        'id': 42,
        'user_id': 7,
        'user_name': 'Alice',
        'movie_id': 123,
        'rating': 8,
        'review_text': 'Great movie!',
        'created_at': '2026-06-15 10:00:00',
        'updated_at': '2026-06-15 10:30:00',
        'likes_count': 5,
        'is_liked': true,
      };

      final review = Review.fromJson(json);

      expect(review.id, 42);
      expect(review.userId, 7);
      expect(review.userName, 'Alice');
      expect(review.movieId, 123);
      expect(review.rating, 8);
      expect(review.reviewText, 'Great movie!');
      expect(review.createdAt, '2026-06-15 10:00:00');
      expect(review.updatedAt, '2026-06-15 10:30:00');
      expect(review.likesCount, 5);
      expect(review.isLiked, true);
    });

    test('handles missing optional fields with defaults', () {
      final json = {
        'id': 1,
        'user_id': 2,
        'user_name': 'Bob',
        'movie_id': 456,
        'rating': 6,
        'review_text': 'OK',
        'created_at': '2026-01-01',
        'updated_at': '2026-01-01',
      };

      final review = Review.fromJson(json);

      expect(review.likesCount, 0);
      expect(review.isLiked, false);
    });

    test('handles string numeric fields', () {
      final json = {
        'id': '99',
        'user_id': '3',
        'movie_id': '789',
        'rating': '7',
        'user_name': 'Charlie',
        'review_text': 'Nice',
        'created_at': '2026-07-01',
        'updated_at': '2026-07-01',
        'likes_count': '3',
        'is_liked': 1,
      };

      final review = Review.fromJson(json);

      expect(review.id, 99);
      expect(review.movieId, 789);
      expect(review.rating, 7);
      expect(review.likesCount, 3);
      expect(review.isLiked, true);
    });
  });

  group('Review.copyWith', () {
    test('creates copy with updated likesCount and isLiked', () {
      final review = Review(
        id: 1,
        userId: 1,
        userName: 'Test',
        movieId: 1,
        rating: 5,
        reviewText: '',
        createdAt: '',
        updatedAt: '',
        likesCount: 2,
        isLiked: false,
      );

      final updated = review.copyWith(likesCount: 3, isLiked: true);

      expect(updated.likesCount, 3);
      expect(updated.isLiked, true);

      // Verify original is unchanged
      expect(review.likesCount, 2);
      expect(review.isLiked, false);
    });
  });
}
